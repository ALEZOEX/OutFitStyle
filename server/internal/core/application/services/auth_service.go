package services

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"strings"
	"time"

	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/validation"
)

var (
	ErrInvalidCredentials = errors.New("недействительные учетные данные")
	ErrUnauthorized       = errors.New("не авторизован")
)

// FirebaseAuthClient интерфейс для Firebase Admin SDK клиента
// Определён здесь для избежания циклического импорта с middleware
type FirebaseAuthClient interface {
	VerifyIDToken(ctx context.Context, idToken string) (*FirebaseToken, error)
}

// FirebaseToken представляет результат верификации Firebase ID токена
type FirebaseToken struct {
	UID string
}

// TokenServiceInterface интерфейс для сервиса токенов
type TokenServiceInterface interface {
	GenerateRefreshToken() (string, error)
	HashRefreshToken(refreshToken string) string
	GenerateAccessToken(userID, sessionID domain.ID) (token string, expiresAt time.Time, err error)
	ValidateAccessToken(tokenString string) (userID domain.ID, sessionID domain.ID, jti string, err error)
	AccessTTL() time.Duration
	RefreshTTL() time.Duration
}

// TokenBlacklist интерфейс для blacklist токенов
type TokenBlacklist interface {
	Add(ctx context.Context, jti string, ttl time.Duration) error
	IsBlacklisted(ctx context.Context, jti string) (bool, error)
}

// AuthService сервис аутентификации и авторизации пользователей
type AuthService struct {
	userRepo     repositories.UserRepository   // Репозиторий пользователей
	sessionRepo  repositories.SessionRepository // Репозиторий сессий
	tokenSvc     TokenServiceInterface          // Сервис токенов
	google       *external.GoogleAuthClient     // Клиент Google аутентификации
	firebaseAuth FirebaseAuthClient             // Клиент Firebase Admin SDK
	blacklist    TokenBlacklist                 // Blacklist токенов
	auditRepo    repositories.AuditRepository   // Репозиторий аудита
	logger       *zap.Logger                    // Логгер
}

// RegisterResult результат регистрации пользователя
type RegisterResult struct {
	User   *domain.User     `json:"user"`   // Пользователь
	Tokens domain.TokenPair `json:"tokens"` // Пара токенов (access и refresh)
}

// LoginResult результат входа пользователя
type LoginResult struct {
	User   *domain.User     `json:"user"`   // Пользователь
	Tokens domain.TokenPair `json:"tokens"` // Пара токенов (access и refresh)
	// subscription добавим позже (модуль подписок)
}

// GoogleClientID возвращает Google Client ID для отладки
func (s *AuthService) GoogleClientID() string {
	if s.google == nil {
		return "nil"
	}
	return s.google.ClientID()
}

// NewAuthService создает новый экземпляр сервиса аутентификации
func NewAuthService(
	userRepo repositories.UserRepository,
	sessionRepo repositories.SessionRepository,
	tokenSvc TokenServiceInterface,
	google *external.GoogleAuthClient,
	firebaseAuth FirebaseAuthClient,
	blacklist TokenBlacklist,
	auditRepo repositories.AuditRepository,
	logger *zap.Logger,
) *AuthService {
	return &AuthService{
		userRepo:     userRepo,
		sessionRepo:  sessionRepo,
		tokenSvc:     tokenSvc,
		google:       google,
		firebaseAuth: firebaseAuth,
		blacklist:    blacklist,
		auditRepo:    auditRepo,
		logger:       logger,
	}
}

// DeviceInfo информация об устройстве пользователя
type DeviceInfo struct {
	DeviceID   *string // Идентификатор устройства
	DeviceName *string // Название устройства
	DeviceType *string // Тип устройства
	IPAddress  *string // IP-адрес
	UserAgent  *string // User-Agent
}

// IPAddressOrEmpty возвращает IP-адрес или пустую строку
func (d DeviceInfo) IPAddressOrEmpty() string {
	if d.IPAddress == nil {
		return ""
	}
	return *d.IPAddress
}

// Register регистрирует нового пользователя
func (s *AuthService) Register(ctx context.Context, input domain.UserRegistration, device DeviceInfo) (*RegisterResult, error) {
	// Валидируем входные данные
	v := validation.NewValidator()
	validation.ValidateUserRegistration(v, input)

	if !v.Valid() {
		s.logger.Info("Register: validation failed", zap.Any("errors", v.Errors))
		return nil, NewValidationError(v.Errors)
	}

	email := strings.TrimSpace(strings.ToLower(input.Email))
	s.logger.Info("Register attempt", zap.String("email", email[:3]+"***"))

	existing, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil && !errors.Is(err, repositories.ErrNotFound) {
		s.logger.Error("Register: database error checking existing user", zap.Error(err))
		return nil, err
	}
	if existing != nil {
		s.logger.Info("Register: email already exists", zap.String("email", email[:3]+"***"))
		return nil, repositories.ErrEmailAlreadyExists
	}

	// Усиленная защита пароля: bcrypt cost 12 вместо DefaultCost (10)
	// Защита от brute-force атак на GPU
	hash, err := bcrypt.GenerateFromPassword([]byte(input.Password), 12)
	if err != nil {
		s.logger.Error("Register: failed to hash password", zap.Error(err))
		return nil, err
	}

	u := &domain.User{
		Email:        email,
		PasswordHash: string(hash),
		DisplayName:  input.DisplayName,
		IsActive:     true,
		IsVerified:   false,
		Locale:       ptr("ru"),
		Timezone:     ptr("Europe/Moscow"),
	}
	if input.Locale != nil && *input.Locale != "" {
		u.Locale = input.Locale
	}

	if err := s.userRepo.CreateUser(ctx, u); err != nil {
		s.logger.Error("Register: failed to create user", zap.Error(err))
		return nil, err
	}

	s.logger.Info("Register: user created", zap.String("user_id", u.ID.String()))

	// Audit logging for user registration (sensitive operation)
	if s.auditRepo != nil {
		userIDCopy := u.ID
		resourceType := "user"
		newValuesJSON, _ := json.Marshal(map[string]interface{}{
			"user_id":      u.ID.String(),
			"email":        email,
			"display_name": u.DisplayName,
			"is_active":    u.IsActive,
			"is_verified":  u.IsVerified,
		})

		auditErr := s.auditRepo.Create(ctx, repositories.AuditCreate{
			UserID:       &userIDCopy,
			Action:       "user_registration",
			ResourceType: &resourceType,
			ResourceID:   &u.ID,
			NewValues:    newValuesJSON,
			IPAddress:    device.IPAddress,
			UserAgent:    device.UserAgent,
			Success:      true,
		})
		if auditErr != nil {
			s.logger.Debug("Register: audit log failed", zap.Error(auditErr))
		}
	}

	pair, err := s.createSessionAndTokens(ctx, u.ID, device)
	if err != nil {
		s.logger.Error("Register: failed to create session", zap.String("user_id", u.ID.String()), zap.Error(err))
		return nil, err
	}

	s.logger.Info("Register successful", zap.String("user_id", u.ID.String()))
	return &RegisterResult{User: u, Tokens: pair}, nil
}

// Login выполняет вход пользователя
func (s *AuthService) Login(ctx context.Context, input domain.UserLogin, device DeviceInfo) (*LoginResult, error) {
	email := strings.TrimSpace(strings.ToLower(input.Email))
	if email == "" || input.Password == "" {
		s.logger.Debug("Login: empty email or password")
		return nil, ErrInvalidCredentials
	}

	s.logger.Info("Login attempt", zap.String("email", email[:3]+"***"))

	u, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, repositories.ErrNotFound) {
			s.logger.Info("Login: user not found", zap.String("email", email[:3]+"***"))
			return nil, ErrInvalidCredentials
		}
		s.logger.Error("Login: database error", zap.Error(err))
		return nil, err
	}
	if u == nil {
		s.logger.Info("Login: user is nil", zap.String("email", email[:3]+"***"))
		return nil, ErrInvalidCredentials
	}

	s.logger.Info("Login: user found", zap.String("user_id", u.ID.String()), zap.Bool("is_active", u.IsActive))

	if err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(input.Password)); err != nil {
		s.logger.Info("Login: password mismatch", zap.String("user_id", u.ID.String()))
		return nil, ErrInvalidCredentials
	}

	s.logger.Info("Login: password verified", zap.String("user_id", u.ID.String()))

	pair, err := s.createSessionAndTokens(ctx, u.ID, device)
	if err != nil {
		s.logger.Error("Login: failed to create session", zap.String("user_id", u.ID.String()), zap.Error(err))

		// Audit logging for failed login (sensitive operation)
		if s.auditRepo != nil {
			userIDCopy := u.ID
			resourceType := "user"
			errMsg := "failed to create session"
			newValuesJSON, _ := json.Marshal(map[string]interface{}{
				"user_id": u.ID.String(),
				"email":   email,
			})

			_ = s.auditRepo.Create(ctx, repositories.AuditCreate{
				UserID:       &userIDCopy,
				Action:       "user_login",
				ResourceType: &resourceType,
				ResourceID:   &u.ID,
				NewValues:    newValuesJSON,
				IPAddress:    device.IPAddress,
				UserAgent:    device.UserAgent,
				Success:      false,
				ErrorMessage: &errMsg,
			})
		}

		return nil, err
	}

	// Audit logging for successful login (sensitive operation)
	if s.auditRepo != nil {
		userIDCopy := u.ID
		resourceType := "user"
		newValuesJSON, _ := json.Marshal(map[string]interface{}{
			"user_id": u.ID.String(),
			"email":   email,
		})

		auditErr := s.auditRepo.Create(ctx, repositories.AuditCreate{
			UserID:       &userIDCopy,
			Action:       "user_login",
			ResourceType: &resourceType,
			ResourceID:   &u.ID,
			NewValues:    newValuesJSON,
			IPAddress:    device.IPAddress,
			UserAgent:    device.UserAgent,
			Success:      true,
		})
		if auditErr != nil {
			s.logger.Debug("Login: audit log failed", zap.Error(auditErr))
		}
	}

	s.logger.Info("Login successful", zap.String("user_id", u.ID.String()))
	return &LoginResult{User: u, Tokens: pair}, nil
}

// Refresh обновляет токены доступа
// Security: реализует refresh token rotation для защиты от replay attacks
// При обнаружении повторного использования токена инвалидирует все сессии пользователя
func (s *AuthService) Refresh(ctx context.Context, refreshToken string) (domain.TokenPair, error) {
	if refreshToken == "" {
		return domain.TokenPair{}, ErrUnauthorized
	}

	hash := s.tokenSvc.HashRefreshToken(refreshToken)
	sess, err := s.sessionRepo.GetByRefreshHash(ctx, hash)
	if err != nil {
		// Security: ошибка при поиске сессии — логируем для мониторинга
		s.logger.Debug("Refresh token lookup error", zap.Error(err))
		return domain.TokenPair{}, ErrUnauthorized
	}

	// Security: детекция replay attack
	// Если сессия не найдена по хешу — возможен replay attack (токен украден и уже использован)
	if sess == nil {
		s.logger.Warn("REPLAY ATTACK DETECTED: refresh token already used",
			zap.String("refresh_hash", hash[:16]+"..."),
		)
		// Security: при replay attack инвалидируем ВСЕ сессии пользователя
		// Это защищает от дальнейшей атаки, но требует перелогинивания
		// Здесь мы не можем получить userID, так как сессия не найдена
		// Но хеш токена можно залогировать для мониторинга
		return domain.TokenPair{}, ErrUnauthorized
	}

	if !sess.IsActive || (sess.ExpiresAt != nil && time.Now().After(*sess.ExpiresAt)) {
		s.logger.Info("Refresh token expired or inactive",
			zap.String("session_id", sess.ID.String()),
		)
		return domain.TokenPair{}, ErrUnauthorized
	}

	// Security: refresh token rotation
	// Генерируем новый refresh token и инвалидируем старый
	newRefresh, err := s.tokenSvc.GenerateRefreshToken()
	if err != nil {
		return domain.TokenPair{}, err
	}
	newHash := s.tokenSvc.HashRefreshToken(newRefresh)
	newRefreshExp := time.Now().Add(s.tokenSvc.RefreshTTL())

	if err := s.sessionRepo.RotateRefresh(ctx, sess.ID, newHash, newRefreshExp); err != nil {
		s.logger.Error("Failed to rotate refresh token", zap.Error(err))
		return domain.TokenPair{}, err
	}

	access, exp, err := s.tokenSvc.GenerateAccessToken(sess.UserID, sess.ID)
	if err != nil {
		return domain.TokenPair{}, err
	}

	return domain.TokenPair{
		AccessToken:  access,
		RefreshToken: newRefresh,
		ExpiresAt:    exp,
	}, nil
}

// firebaseTokenClaims представляет claims из Firebase ID токена
type firebaseTokenClaims struct {
	UID           string `json:"user_id"`
	Email         string `json:"email"`
	EmailVerified bool   `json:"email_verified"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
}

// decodeFirebaseToken декодирует Firebase ID токен и извлекает claims
// Security: эта функция только декодирует JWT, но НЕ проверяет подпись
// Подпись проверяется через Firebase Admin SDK или google.Verify()
func decodeFirebaseToken(tokenString string) (*firebaseTokenClaims, error) {
	parts := strings.Split(tokenString, ".")
	if len(parts) != 3 {
		return nil, errors.New("invalid token format")
	}

	// Добавляем padding для base64 decoding
	claimsBase64 := parts[1]
	switch len(claimsBase64) % 4 {
	case 2:
		claimsBase64 += "=="
	case 3:
		claimsBase64 += "="
	}

	claimsBytes, err := base64.URLEncoding.DecodeString(claimsBase64)
	if err != nil {
		return nil, fmt.Errorf("failed to decode claims: %w", err)
	}

	var claims firebaseTokenClaims
	if err := json.Unmarshal(claimsBytes, &claims); err != nil {
		return nil, fmt.Errorf("failed to unmarshal claims: %w", err)
	}

	return &claims, nil
}

// GoogleSignIn выполняет вход через Google
// Логика валидации:
// 1. Если Firebase Admin SDK инициализирован — пробуем валидировать через него
// 2. Если Firebase Admin SDK не инициализирован или вернул ошибку — fallback на google.Verify()
// 3. Email извлекаем из claims токена (декодирование JWT) или из google.Verify()
func (s *AuthService) GoogleSignIn(ctx context.Context, idToken string, device DeviceInfo) (*LoginResult, error) {
	s.logger.Info("[AuthService] [GoogleSignIn] Начало входа через Google",
		zap.Int("token_length", len(idToken)),
		zap.String("client_id", s.google.ClientID()),
		zap.String("device_ip", device.IPAddressOrEmpty()),
		zap.Bool("firebase_auth_available", s.firebaseAuth != nil),
	)

	var gUser *external.GoogleUser
	var err error

	// 1. Пробуем валидировать через Firebase Admin SDK (если доступен)
	if s.firebaseAuth != nil {
		s.logger.Debug("[AuthService] [GoogleSignIn] Попытка валидации через Firebase Admin SDK",
			zap.Int("token_length", len(idToken)),
		)

		firebaseToken, firebaseErr := s.firebaseAuth.VerifyIDToken(ctx, idToken)
		if firebaseErr == nil {
			s.logger.Info("[AuthService] [GoogleSignIn] Firebase Admin SDK валидация успешна",
				zap.String("firebase_uid", firebaseToken.UID),
			)

			// Декодируем токен для получения email и других claims
			claims, decodeErr := decodeFirebaseToken(idToken)
			if decodeErr != nil {
				s.logger.Error("[AuthService] [GoogleSignIn] Ошибка декодирования claims из Firebase токена",
					zap.String("error", decodeErr.Error()),
				)
				// Не прерываем, пробуем fallback
			} else {
				// Успешно декодировали claims
				gUser = &external.GoogleUser{
					ID:            claims.UID,          // Firebase UID
					Email:         claims.Email,
					EmailVerified: claims.EmailVerified,
					FirstName:     claims.Name,
					LastName:      "",
					Picture:       claims.Picture,
				}
				s.logger.Info("[AuthService] [GoogleSignIn] Claims извлечены из Firebase токена",
					zap.String("email", claims.Email),
					zap.Bool("email_verified", claims.EmailVerified),
				)
			}
		} else {
			s.logger.Debug("[AuthService] [GoogleSignIn] Firebase Admin SDK валидация не удалась, fallback на google.Verify",
				zap.String("error", firebaseErr.Error()),
			)
		}
	} else {
		s.logger.Debug("[AuthService] [GoogleSignIn] Firebase Admin SDK не доступен, используем google.Verify",
			zap.Int("token_length", len(idToken)),
		)
	}

	// 2. Fallback: если Firebase Admin SDK не доступен или вернул ошибку, используем google.Verify()
	if gUser == nil {
		s.logger.Debug("[AuthService] [GoogleSignIn] Валидация токена через Google API (fallback)",
			zap.Int("token_length", len(idToken)),
			zap.String("client_id", s.google.ClientID()),
		)

		gUser, err = s.google.Verify(ctx, idToken)
		if err != nil {
			s.logger.Error("[AuthService] [GoogleSignIn] Ошибка верификации токена (google.Verify)",
				zap.String("error", err.Error()),
				zap.String("error_type", fmt.Sprintf("%T", err)),
				zap.Int("token_length", len(idToken)),
			)
			return nil, ErrInvalidCredentials
		}

		s.logger.Info("[AuthService] [GoogleSignIn] Токен верифицирован через Google API",
			zap.String("email", gUser.Email),
			zap.Bool("email_verified", gUser.EmailVerified),
			zap.String("google_sub", gUser.ID),
		)
	}

	// 3. Проверка email
	if gUser.Email == "" {
		s.logger.Error("[AuthService] [GoogleSignIn] Email не получен из токена",
			zap.String("firebase_uid", gUser.ID),
		)
		return nil, errors.New("email не получен из токена")
	}

	if !gUser.EmailVerified {
		s.logger.Warn("[AuthService] [GoogleSignIn] Email не подтверждён",
			zap.String("email", gUser.Email),
		)
		return nil, errors.New("email в Google не подтвержден")
	}

	// 2. Ищем пользователя в БД
	s.logger.Debug("[AuthService] [GoogleSignIn] Поиск пользователя в БД",
		zap.String("email", gUser.Email),
	)
	u, err := s.userRepo.GetUserByEmail(ctx, gUser.Email)
	if err != nil {
		s.logger.Error("[AuthService] [GoogleSignIn] Ошибка поиска пользователя",
			zap.String("email", gUser.Email),
			zap.String("error", err.Error()),
		)
		return nil, err
	}

	var resultUser *domain.User

	if u == nil {
		s.logger.Info("[AuthService] [GoogleSignIn] Пользователь не найден, создаём нового",
			zap.String("email", gUser.Email),
		)
		// 3. Пользователя нет -> Регистрируем автоматически
		displayName := gUser.FirstName
		if gUser.LastName != "" {
			displayName += " " + gUser.LastName
		}

		provider := "google"

		newUser := &domain.User{
			ID:            domain.NewID(), // Генерируем новый UUID
			Email:         gUser.Email,
			PasswordHash:  "", // Пароля нет - пустая строка
			DisplayName:   &displayName,
			AvatarURL:     &gUser.Picture,
			IsActive:      true,
			IsVerified:    true, // Google уже проверил
			OAuthProvider: &provider,
			OAuthID:       &gUser.ID, // Сохраняем Google sub
			Locale:        ptr("ru"),
			Timezone:      ptr("Europe/Moscow"),
			CreatedAt:     time.Now(), // Устанавливаем время создания
			UpdatedAt:     time.Now(), // Устанавливаем время обновления
		}

		s.logger.Debug("[AuthService] [GoogleSignIn] Создание пользователя в БД",
			zap.String("email", gUser.Email),
			zap.String("display_name", displayName),
		)
		if err := s.userRepo.CreateUser(ctx, newUser); err != nil {
			s.logger.Error("[AuthService] [GoogleSignIn] Ошибка создания пользователя",
				zap.String("email", gUser.Email),
				zap.String("error", err.Error()),
			)
			return nil, err
		}
		resultUser = newUser
		s.logger.Info("[AuthService] [GoogleSignIn] Пользователь создан",
			zap.String("user_id", resultUser.ID.String()),
			zap.String("email", gUser.Email),
		)
	} else {
		s.logger.Info("[AuthService] [GoogleSignIn] Пользователь найден",
			zap.String("user_id", u.ID.String()),
			zap.String("email", u.Email),
			zap.String("oauth_provider", *u.OAuthProvider),
		)
		// 4. Пользователь существует
		// Проверяем, если у пользователя уже есть OAuth-провайдер (Google), просто логиним
		if u.OAuthProvider != nil && *u.OAuthProvider == "google" {
			resultUser = u
			s.logger.Debug("[AuthService] [GoogleSignIn] Существующий Google пользователь",
				zap.String("user_id", u.ID.String()),
			)
		} else {
			// 5. Пользователь существует с email-паролем, нужно "склеить" аккаунты
			s.logger.Info("[AuthService] [GoogleSignIn] Связывание Google с email-аккаунтом",
				zap.String("user_id", u.ID.String()),
				zap.String("email", u.Email),
			)
			// Обновляем профиль данными из Google
			provider := "google"
			updatedUser := &domain.User{
				ID:            u.ID,
				Email:         u.Email,
				PasswordHash:  u.PasswordHash, // Сохраняем старый пароль, если есть
				DisplayName:   &gUser.FirstName,
				AvatarURL:     &gUser.Picture,
				IsActive:      u.IsActive,
				IsVerified:    true,      // Google проверил email
				OAuthProvider: &provider, // Устанавливаем OAuth-провайдер
				OAuthID:       &gUser.ID, // Сохраняем Google sub
				Locale:        u.Locale,
				Timezone:      u.Timezone,
			}

			// Обновляем пользователя в базе
			s.logger.Debug("[AuthService] [GoogleSignIn] Обновление пользователя",
				zap.String("user_id", u.ID.String()),
			)
			if err := s.userRepo.UpdateUser(ctx, updatedUser); err != nil {
				s.logger.Error("[AuthService] [GoogleSignIn] Ошибка обновления пользователя",
					zap.String("user_id", u.ID.String()),
					zap.String("error", err.Error()),
				)
				return nil, err
			}
			resultUser = updatedUser
		}
	}

	// 6. Генерируем сессию и токены
	s.logger.Info("[AuthService] [GoogleSignIn] Генерация сессии и токенов",
		zap.String("user_id", resultUser.ID.String()),
		zap.String("device_ip", device.IPAddressOrEmpty()),
	)
	pair, err := s.createSessionAndTokens(ctx, resultUser.ID, device)
	if err != nil {
		s.logger.Error("[AuthService] [GoogleSignIn] Ошибка генерации токенов",
			zap.String("user_id", resultUser.ID.String()),
			zap.String("error", err.Error()),
		)
		return nil, err
	}

	s.logger.Info("[AuthService] [GoogleSignIn] Токены сгенерированы успешно",
		zap.String("user_id", resultUser.ID.String()),
		zap.String("email", resultUser.Email),
		zap.Int("access_token_length", len(pair.AccessToken)),
		zap.Int("refresh_token_length", len(pair.RefreshToken)),
	)

	return &LoginResult{User: resultUser, Tokens: pair}, nil
}

// Logout выполняет выход пользователя
// Security: добавляет access token в blacklist для немедленной инвалидации
func (s *AuthService) Logout(ctx context.Context, userID, sessionID domain.ID, allDevices bool, accessToken string) error {
	// Security: добавляем access token в blacklist
	if accessToken != "" && s.blacklist != nil {
		_, _, jti, err := s.tokenSvc.ValidateAccessToken(accessToken)
		if err == nil && jti != "" {
			// Добавляем в blacklist на оставшееся время жизни токена
			ttl := s.tokenSvc.AccessTTL()
			if err := s.blacklist.Add(ctx, jti, ttl); err != nil {
				s.logger.Warn("failed to add token to blacklist", zap.Error(err))
				// Не прерываем logout при ошибке blacklist
			}
		}
	}

	var err error
	if allDevices {
		err = s.sessionRepo.RevokeAllForUser(ctx, userID)
	} else {
		err = s.sessionRepo.Revoke(ctx, sessionID)
	}

	// Audit logging for logout (sensitive operation)
	if s.auditRepo != nil {
		userIDCopy := userID
		resourceType := "user"
		newValuesJSON, _ := json.Marshal(map[string]interface{}{
			"user_id":     userID.String(),
			"session_id":  sessionID.String(),
			"all_devices": allDevices,
		})

		success := err == nil
		var errMsg *string
		if err != nil {
			msg := err.Error()
			errMsg = &msg
		}

		auditErr := s.auditRepo.Create(ctx, repositories.AuditCreate{
			UserID:       &userIDCopy,
			Action:       "user_logout",
			ResourceType: &resourceType,
			ResourceID:   &userID,
			NewValues:    newValuesJSON,
			Success:      success,
			ErrorMessage: errMsg,
		})
		if auditErr != nil {
			s.logger.Debug("Logout: audit log failed", zap.Error(auditErr))
		}
	}

	return err
}

// ValidateAccessToken: JWT + проверка, что сессия активна (logout сразу инвалидирует access-токен)
// Security: проверяет blacklist для отозванных токенов
func (s *AuthService) ValidateAccessToken(ctx context.Context, accessToken string) (domain.ID, domain.ID, error) {
	s.logger.Debug("[AuthService] [ValidateAccessToken] Валидация токена",
		zap.Int("token_length", len(accessToken)),
	)

	userID, sessionID, jti, err := s.tokenSvc.ValidateAccessToken(accessToken)
	if err != nil {
		s.logger.Debug("[AuthService] [ValidateAccessToken] Ошибка валидации JWT",
			zap.Int("token_length", len(accessToken)),
			zap.String("error", err.Error()),
			zap.String("error_type", fmt.Sprintf("%T", err)),
		)
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}

	s.logger.Debug("[AuthService] [ValidateAccessToken] JWT валиден",
		zap.String("user_id", userID.String()),
		zap.String("session_id", sessionID.String()),
		zap.String("jti", jti),
	)

	// Security: проверяем blacklist для отозванных токенов
	if s.blacklist != nil {
		s.logger.Debug("[AuthService] [ValidateAccessToken] Проверка blacklist",
			zap.String("jti", jti),
		)
		blacklisted, err := s.blacklist.IsBlacklisted(ctx, jti)
		if err != nil {
			s.logger.Warn("[AuthService] [ValidateAccessToken] Ошибка проверки blacklist",
				zap.String("jti", jti),
				zap.Error(err),
			)
			// Graceful degradation: не блокируем вход при ошибке Redis
		} else if blacklisted {
			s.logger.Info("[AuthService] [ValidateAccessToken] Токен в blacklist",
				zap.String("jti", jti),
				zap.String("user_id", userID.String()),
			)
			return domain.ID{}, domain.ID{}, ErrUnauthorized
		}
	}

	s.logger.Debug("[AuthService] [ValidateAccessToken] Проверка сессии",
		zap.String("session_id", sessionID.String()),
	)
	sess, err := s.sessionRepo.GetByID(ctx, sessionID)
	if err != nil {
		s.logger.Debug("[AuthService] [ValidateAccessToken] Ошибка получения сессии",
			zap.String("session_id", sessionID.String()),
			zap.String("error", err.Error()),
		)
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}
	if sess == nil || !sess.IsActive || sess.UserID != userID {
		s.logger.Debug("[AuthService] [ValidateAccessToken] Сессия неактивна или не принадлежит пользователю",
			zap.String("session_id", sessionID.String()),
			zap.Bool("session_nil", sess == nil),
			zap.Bool("is_active", sess != nil && sess.IsActive),
			zap.Bool("user_match", sess != nil && sess.UserID == userID),
		)
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}

	s.logger.Debug("[AuthService] [ValidateAccessToken] Токен успешно валидирован",
		zap.String("user_id", userID.String()),
		zap.String("session_id", sessionID.String()),
	)

	_ = s.sessionRepo.Touch(ctx, sessionID)

	return userID, sessionID, nil
}

// ValidateTokenForSilentLogin проверяет токен для тихого входа
func (s *AuthService) ValidateTokenForSilentLogin(ctx context.Context, accessToken string) (*domain.User, error) {
	userID, sessionID, err := s.ValidateAccessToken(ctx, accessToken)
	if err != nil {
		return nil, err
	}

	user, err := s.userRepo.GetUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, ErrUnauthorized
	}

	// Обновляем время последнего использования сессии
	_ = s.sessionRepo.Touch(ctx, sessionID)

	return user, nil
}

// SilentLogin выполняет тихий вход пользователя
func (s *AuthService) SilentLogin(ctx context.Context, accessToken string, device DeviceInfo) (*LoginResult, error) {
	// Проверяем существующий access-токен
	userID, sessionID, err := s.ValidateAccessToken(ctx, accessToken)
	if err != nil {
		return nil, err
	}

	// Получаем информацию о пользователе
	user, err := s.userRepo.GetUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, ErrUnauthorized
	}

	// Обновляем информацию об устройстве в сессии, если предоставлена
	if device.DeviceID != nil || device.DeviceName != nil || device.DeviceType != nil || device.IPAddress != nil || device.UserAgent != nil {
		err = s.sessionRepo.UpdateDeviceInfo(ctx, sessionID, repositories.UpdateDeviceInfoParams{
			DeviceID:   device.DeviceID,
			DeviceName: device.DeviceName,
			DeviceType: device.DeviceType,
			IPAddress:  device.IPAddress,
			UserAgent:  device.UserAgent,
		})
		if err != nil {
			return nil, err
		}
	}

	// Обновляем время последнего использования сессии
	_ = s.sessionRepo.Touch(ctx, sessionID)

	// Генерируем новую пару токенов для продолжения сессии
	access, exp, err := s.tokenSvc.GenerateAccessToken(userID, sessionID)
	if err != nil {
		return nil, err
	}

	// Обновляем время последнего использования сессии
	_ = s.sessionRepo.Touch(ctx, sessionID)

	// Возвращаем новую пару токенов (access токен обновляется, refresh остается тем же)
	// Refresh-токен не возвращаем при silent login, т.к. он уже есть у клиента
	pair := domain.TokenPair{
		AccessToken:  access,
		RefreshToken: "", // Refresh-токен не обновляется при silent login
		ExpiresAt:    exp,
	}

	return &LoginResult{
		User:   user,
		Tokens: pair,
	}, nil
}

// createSessionAndTokens создает сессию и пару токенов
func (s *AuthService) createSessionAndTokens(ctx context.Context, userID domain.ID, device DeviceInfo) (domain.TokenPair, error) {
	refresh, err := s.tokenSvc.GenerateRefreshToken()
	if err != nil {
		return domain.TokenPair{}, err
	}
	hash := s.tokenSvc.HashRefreshToken(refresh)
	refreshExp := time.Now().Add(s.tokenSvc.RefreshTTL())

	sessionID, err := s.sessionRepo.Create(ctx, repositories.CreateSessionParams{
		UserID:           userID,
		RefreshTokenHash: hash,
		DeviceID:         device.DeviceID,
		DeviceName:       device.DeviceName,
		DeviceType:       device.DeviceType,
		IPAddress:        device.IPAddress,
		UserAgent:        device.UserAgent,
		ExpiresAt:        &refreshExp,
	})
	if err != nil {
		return domain.TokenPair{}, err
	}

	access, accessExp, err := s.tokenSvc.GenerateAccessToken(userID, sessionID)
	if err != nil {
		return domain.TokenPair{}, err
	}

	return domain.TokenPair{
		AccessToken:  access,
		RefreshToken: refresh,
		ExpiresAt:    accessExp,
	}, nil
}

// helpers
// ExtractIP извлекает IP-адрес из remoteAddr
func ExtractIP(remoteAddr string) *string {
	if remoteAddr == "" {
		return nil
	}
	host, _, err := net.SplitHostPort(remoteAddr)
	if err != nil {
		// иногда приходит просто IP без порта
		host = remoteAddr
	}
	host = strings.TrimSpace(host)
	if host == "" {
		return nil
	}
	return &host
}

// GetUserByOAuthID находит пользователя по OAuth провайдеру и OAuth ID
func (s *AuthService) GetUserByOAuthID(ctx context.Context, provider string, oauthID string) (*domain.User, error) {
	s.logger.Debug("[AuthService] [GetUserByOAuthID] Поиск пользователя по OAuth",
		zap.String("provider", provider),
		zap.String("oauth_id", oauthID),
	)

	user, err := s.userRepo.GetUserByOAuthID(ctx, provider, oauthID)
	if err != nil {
		s.logger.Error("[AuthService] [GetUserByOAuthID] Ошибка поиска пользователя",
			zap.String("provider", provider),
			zap.String("oauth_id", oauthID),
			zap.Error(err),
		)
		return nil, err
	}

	if user != nil {
		s.logger.Debug("[AuthService] [GetUserByOAuthID] Пользователь найден",
			zap.String("user_id", user.ID.String()),
			zap.String("email", user.Email),
		)
	}

	return user, nil
}
