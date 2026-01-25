package services

import (
	"context"
	"errors"
	"net"
	"strings"
	"time"

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

// TokenServiceInterface интерфейс для сервиса токенов
type TokenServiceInterface interface {
	GenerateRefreshToken() (string, error)
	HashRefreshToken(refreshToken string) string
	GenerateAccessToken(userID, sessionID domain.ID) (token string, expiresAt time.Time, err error)
	ValidateAccessToken(tokenString string) (userID domain.ID, sessionID domain.ID, err error)
	AccessTTL() time.Duration
	RefreshTTL() time.Duration
}

// AuthService сервис аутентификации и авторизации пользователей
type AuthService struct {
	userRepo    repositories.UserRepository    // Репозиторий пользователей
	sessionRepo repositories.SessionRepository // Репозиторий сессий
	tokenSvc    TokenServiceInterface          // Сервис токенов
	google      *external.GoogleAuthClient     // Клиент Google аутентификации
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

// NewAuthService создает новый экземпляр сервиса аутентификации
func NewAuthService(
	userRepo repositories.UserRepository,
	sessionRepo repositories.SessionRepository,
	tokenSvc TokenServiceInterface,
	google *external.GoogleAuthClient,
) *AuthService {
	return &AuthService{
		userRepo:    userRepo,
		sessionRepo: sessionRepo,
		tokenSvc:    tokenSvc,
		google:      google,
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

// Register регистрирует нового пользователя
func (s *AuthService) Register(ctx context.Context, input domain.UserRegistration, device DeviceInfo) (*RegisterResult, error) {
	// Валидируем входные данные
	v := validation.NewValidator()
	validation.ValidateUserRegistration(v, input)

	if !v.Valid() {
		return nil, NewValidationError(v.Errors)
	}

	email := strings.TrimSpace(strings.ToLower(input.Email))

	existing, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil && !errors.Is(err, repositories.ErrNotFound) {
		return nil, err
	}
	if existing != nil {
		return nil, repositories.ErrEmailAlreadyExists
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	u := &domain.User{
		Email:        email,
		PasswordHash: string(hash),
		DisplayName:  input.DisplayName,
		IsActive:     true,
		IsVerified:   false,
		Locale:       "ru",
		Timezone:     "Europe/Moscow",
	}
	if input.Locale != nil && *input.Locale != "" {
		u.Locale = *input.Locale
	}

	if err := s.userRepo.CreateUser(ctx, u); err != nil {
		return nil, err
	}

	pair, err := s.createSessionAndTokens(ctx, u.ID, device)
	if err != nil {
		return nil, err
	}

	return &RegisterResult{User: u, Tokens: pair}, nil
}

// Login выполняет вход пользователя
func (s *AuthService) Login(ctx context.Context, input domain.UserLogin, device DeviceInfo) (*LoginResult, error) {
	email := strings.TrimSpace(strings.ToLower(input.Email))
	if email == "" || input.Password == "" {
		return nil, ErrInvalidCredentials
	}

	u, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, repositories.ErrNotFound) {
			return nil, ErrInvalidCredentials
		}
		return nil, err
	}
	if u == nil {
		return nil, ErrInvalidCredentials
	}

	if err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(input.Password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	pair, err := s.createSessionAndTokens(ctx, u.ID, device)
	if err != nil {
		return nil, err
	}

	return &LoginResult{User: u, Tokens: pair}, nil
}

// Refresh обновляет токены доступа
func (s *AuthService) Refresh(ctx context.Context, refreshToken string) (domain.TokenPair, error) {
	if refreshToken == "" {
		return domain.TokenPair{}, ErrUnauthorized
	}

	hash := s.tokenSvc.HashRefreshToken(refreshToken)
	sess, err := s.sessionRepo.GetByRefreshHash(ctx, hash)
	if err != nil {
		return domain.TokenPair{}, err
	}
	if sess == nil || !sess.IsActive || (sess.ExpiresAt != nil && time.Now().After(*sess.ExpiresAt)) {
		return domain.TokenPair{}, ErrUnauthorized
	}

	// обновляем refresh-токен
	newRefresh, err := s.tokenSvc.GenerateRefreshToken()
	if err != nil {
		return domain.TokenPair{}, err
	}
	newHash := s.tokenSvc.HashRefreshToken(newRefresh)
	newRefreshExp := time.Now().Add(s.tokenSvc.RefreshTTL())

	if err := s.sessionRepo.RotateRefresh(ctx, sess.ID, newHash, newRefreshExp); err != nil {
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

// GoogleSignIn выполняет вход через Google
func (s *AuthService) GoogleSignIn(ctx context.Context, idToken string, device DeviceInfo) (*LoginResult, error) {
	// 1. Валидируем токен через Google
	gUser, err := s.google.Verify(ctx, idToken)
	if err != nil {
		return nil, ErrInvalidCredentials // Или более специфичная ошибка
	}

	if !gUser.EmailVerified {
		return nil, errors.New("email в Google не подтвержден")
	}

	// 2. Ищем пользователя в БД
	u, err := s.userRepo.GetUserByEmail(ctx, gUser.Email)
	if err != nil {
		return nil, err
	}

	var resultUser *domain.User

	if u == nil {
		// 3. Пользователя нет -> Регистрируем автоматически
		displayName := gUser.FirstName
		if gUser.LastName != "" {
			displayName += " " + gUser.LastName
		}

		provider := "google"

		newUser := &domain.User{
			Email:         gUser.Email,
			PasswordHash:  "", // Пароля нет - пустая строка
			DisplayName:   &displayName,
			AvatarURL:     &gUser.Picture,
			IsActive:      true,
			IsVerified:    true, // Google уже проверил
			OAuthProvider: &provider,
			OAuthID:       nil, // Можно сохранить sub из токена, если нужно
			Locale:        "ru",
			Timezone:      "Europe/Moscow",
		}

		if err := s.userRepo.CreateUser(ctx, newUser); err != nil {
			return nil, err
		}
		resultUser = newUser
	} else {
		// 4. Пользователь существует
		// Проверяем, если у пользователя уже есть OAuth-провайдер (Google), просто логиним
		if u.OAuthProvider != nil && *u.OAuthProvider == "google" {
			resultUser = u
		} else {
			// 5. Пользователь существует с email-паролем, нужно "склеить" аккаунты
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
				OAuthID:       nil,
				Locale:        u.Locale,
				Timezone:      u.Timezone,
			}

			// Обновляем пользователя в базе
			if err := s.userRepo.UpdateUser(ctx, updatedUser); err != nil {
				return nil, err
			}
			resultUser = updatedUser
		}
	}

	// 6. Генерируем сессию и токены
	pair, err := s.createSessionAndTokens(ctx, resultUser.ID, device)
	if err != nil {
		return nil, err
	}

	return &LoginResult{User: resultUser, Tokens: pair}, nil
}

// Logout выполняет выход пользователя
func (s *AuthService) Logout(ctx context.Context, userID, sessionID domain.ID, allDevices bool) error {
	if allDevices {
		return s.sessionRepo.RevokeAllForUser(ctx, userID)
	}
	return s.sessionRepo.Revoke(ctx, sessionID)
}

// ValidateAccessToken: JWT + проверка, что сессия активна (logout сразу инвалидирует access-токен)
func (s *AuthService) ValidateAccessToken(ctx context.Context, accessToken string) (domain.ID, domain.ID, error) {
	userID, sessionID, err := s.tokenSvc.ValidateAccessToken(accessToken)
	if err != nil {
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}

	sess, err := s.sessionRepo.GetByID(ctx, sessionID)
	if err != nil {
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}
	if sess == nil || !sess.IsActive || sess.UserID != userID {
		return domain.ID{}, domain.ID{}, ErrUnauthorized
	}

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
