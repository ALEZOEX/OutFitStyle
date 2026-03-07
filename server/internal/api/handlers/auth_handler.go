// Пакет handlers содержит HTTP-обработчики для различных API-эндпоинтов
// Реализует маршрутизацию и обработку HTTP-запросов
package handlers

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/email"
	"outfitstyle/server/internal/validation"
	resp "outfitstyle/server/internal/pkg/http"
)

// AuthService интерфейс сервиса аутентификации
type AuthService interface {
	Register(ctx context.Context, input domain.UserRegistration, device services.DeviceInfo) (*services.RegisterResult, error)
	Login(ctx context.Context, input domain.UserLogin, device services.DeviceInfo) (*services.LoginResult, error)
	Refresh(ctx context.Context, refreshToken string) (domain.TokenPair, error)
	Logout(ctx context.Context, userID, sessionID domain.ID, allDevices bool, accessToken string) error
	GoogleSignIn(ctx context.Context, idToken string, device services.DeviceInfo) (*services.LoginResult, error)
	ValidateAccessToken(ctx context.Context, accessToken string) (domain.ID, domain.ID, error)
	ValidateTokenForSilentLogin(ctx context.Context, accessToken string) (*domain.User, error)
	SilentLogin(ctx context.Context, accessToken string, device services.DeviceInfo) (*services.LoginResult, error)
	GoogleClientID() string
}

// AccountLockout интерфейс защиты от brute-force
type AccountLockout interface {
	CheckLoginAttempt(ctx context.Context, email string) (allowed bool, remaining int, lockedUntil *time.Time, err error)
	RecordFailedAttempt(ctx context.Context, email string) error
	Reset(ctx context.Context, email string) error
}

// sanitizeRegistrationRequest применяет санитизацию к данным регистрации
func sanitizeRegistrationRequest(req *domain.UserRegistration) {
	if req.Email != "" {
		req.Email = validation.SanitizeEmail(req.Email)
	}
	if req.DisplayName != nil && *req.DisplayName != "" {
		sanitized := validation.SanitizeDisplayName(*req.DisplayName)
		req.DisplayName = &sanitized
	}
	// Пароль не санизируем — он хешируется bcrypt и никогда не выводится
}

// AuthHandler структура обработчика аутентификации
// Содержит зависимости для обработки запросов аутентификации
type AuthHandler struct {
	auth            AuthService                        // Сервис аутентификации для выполнения бизнес-логики
	lockout         AccountLockout                     // Защита от brute-force атак
	lockoutDuration time.Duration                      // Длительность блокировки
	redis           *redis.Client                      // Redis для кэширования кодов восстановления
	userRepo        repositories.UserRepository        // Репозиторий пользователей
	smtp            *email.SMTPService                 // SMTP сервис для отправки email
	logger          *zap.Logger                        // Логгер для отладки
	cookieSecure    bool                               // Secure flag для refresh token cookie
}

// NewAuthHandler создает новый экземпляр обработчика аутентификации
func NewAuthHandler(
	auth AuthService,
	lockout AccountLockout,
	lockoutDuration time.Duration,
	redis *redis.Client,
	userRepo repositories.UserRepository,
	smtp *email.SMTPService,
	logger *zap.Logger,
	cookieSecure bool,
) *AuthHandler {
	return &AuthHandler{
		auth:            auth,
		lockout:         lockout,
		lockoutDuration: lockoutDuration,
		redis:           redis,
		userRepo:        userRepo,
		smtp:            smtp,
		logger:          logger,
		cookieSecure:    cookieSecure,
	}
}

// RegisterRoutes регистрирует маршруты для обработчика аутентификации
// Устанавливает обработчики для различных эндпоинтов аутентификации
func (h *AuthHandler) RegisterRoutes(r *mux.Router) {
	// r предполагается уже с PathPrefix("/auth")
	r.HandleFunc("/register", h.Register).Methods(http.MethodPost)
	r.HandleFunc("/login", h.Login).Methods(http.MethodPost)
	r.HandleFunc("/refresh", h.Refresh).Methods(http.MethodPost)
	r.HandleFunc("/logout", h.Logout).Methods(http.MethodPost) // требует AuthMiddleware
	r.HandleFunc("/google", h.GoogleSignIn).Methods(http.MethodPost)
	r.HandleFunc("/validate", h.ValidateToken).Methods(http.MethodPost)
	r.HandleFunc("/forgot-password", h.ForgotPassword).Methods(http.MethodPost)
	r.HandleFunc("/reset-password", h.ResetPassword).Methods(http.MethodPost)
}

// Register обрабатывает запрос на регистрацию нового пользователя
// Принимает данные регистрации и создает новый аккаунт пользователя
func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req domain.UserRegistration
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Санитизация входных данных (защита от XSS)
	sanitizeRegistrationRequest(&req)

	// Validate input data
	v := validation.NewValidator()
	validation.ValidateUserRegistration(v, req)

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	device := services.DeviceInfo{
		IPAddress: services.ExtractIP(r.RemoteAddr),
	}
	ua := r.UserAgent()
	if ua != "" {
		device.UserAgent = &ua
	}

	out, err := h.auth.Register(r.Context(), req, device)
	if err != nil {
		// Проверяем, является ли это ошибкой валидации
		if validationErr, ok := err.(*services.ValidationError); ok {
			resp.ValidationError(w, validationErr.Errors)
			return
		}

		status := http.StatusInternalServerError
		if errors.Is(err, services.ErrInvalidCredentials) {
			status = http.StatusBadRequest
		}

		resp.Error(w, status, err)
		return
	}

	// Security: устанавливаем оба токена в httpOnly cookies для веба
	// Access token cookie для аутентификации запросов
	accessCookieConfig := middleware.DefaultAccessCookieConfig()
	accessCookieConfig.Secure = h.cookieSecure
	middleware.SetAccessTokenCookie(w, out.Tokens.AccessToken, accessCookieConfig)

	// Refresh token cookie для обновления токенов
	refreshCookieConfig := middleware.DefaultRefreshCookieConfig()
	refreshCookieConfig.Secure = h.cookieSecure
	middleware.SetRefreshTokenCookie(w, out.Tokens.RefreshToken, refreshCookieConfig)

	// Возвращаем токены в ответе (также в cookies для веба)
	resp.Success(w, out)
}

// Login обрабатывает запрос на аутентификацию пользователя
// Проверяет учетные данные и возвращает токены доступа
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req domain.UserLogin
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Validate input data — только email, НЕ пароль!
	// Валидация сложности пароля ТОЛЬКО при регистрации/смене пароля.
	// При логине проверяем только bcrypt hash (любой пароль).
	v := validation.NewValidator()
	validation.ValidateEmail(v, req.Email)

	if req.DeviceName != nil {
		validation.ValidateStringLength(v, *req.DeviceName, 1, 100, "device_name", "device name")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	// Проверка пустого пароля (но НЕ сложности!)
	if req.Password == "" {
		resp.Error(w, http.StatusBadRequest, errors.New("password required"))
		return
	}

	// Проверяем, не заблокирован ли аккаунт (защита от brute-force)
	email := strings.TrimSpace(strings.ToLower(req.Email))
	allowed, _, lockedUntil, err := h.lockout.CheckLoginAttempt(r.Context(), email)

	if !allowed {
		if lockedUntil != nil {
			retryAfter := int(time.Until(*lockedUntil).Seconds())
			if retryAfter < 0 {
				retryAfter = int(h.lockoutDuration.Seconds())
			}
			w.Header().Set("Retry-After", fmt.Sprintf("%d", retryAfter))
		}
		resp.Error(w, http.StatusTooManyRequests, errors.New("Too many failed login attempts. Please try again later."))
		return
	}

	if err != nil {
		// Логгируем ошибку, но не блокируем вход (graceful degradation)
		h.logger.Error("account lockout check failed", zap.Error(err))
	}

	device := services.DeviceInfo{
		DeviceID:   req.DeviceID,
		DeviceName: req.DeviceName,
		IPAddress:  services.ExtractIP(r.RemoteAddr),
	}
	ua := r.UserAgent()
	if ua != "" {
		device.UserAgent = &ua
	}

	out, err := h.auth.Login(r.Context(), req, device)
	if err != nil {
		if err := h.lockout.RecordFailedAttempt(r.Context(), email); err != nil {
			h.logger.Error("failed to record failed attempt", zap.Error(err))
		}

		resp.Error(w, http.StatusUnauthorized, services.ErrInvalidCredentials)
		return
	}

	// Успешный вход — сбрасываем счётчик попыток
	if err := h.lockout.Reset(r.Context(), email); err != nil {
		h.logger.Error("failed to reset lockout", zap.Error(err))
	}

	// Security: устанавливаем оба токена в httpOnly cookies для веба
	// Access token cookie для аутентификации запросов
	accessCookieConfig := middleware.DefaultAccessCookieConfig()
	accessCookieConfig.Secure = h.cookieSecure
	middleware.SetAccessTokenCookie(w, out.Tokens.AccessToken, accessCookieConfig)

	// Refresh token cookie для обновления токенов
	refreshCookieConfig := middleware.DefaultRefreshCookieConfig()
	refreshCookieConfig.Secure = h.cookieSecure
	middleware.SetRefreshTokenCookie(w, out.Tokens.RefreshToken, refreshCookieConfig)

	// Возвращаем токены в ответе (также в cookies для веба)
	resp.Success(w, out)
}

// refreshRequest структура для запроса обновления токена
type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

// Refresh обрабатывает запрос на обновление токена доступа
// Использует рефреш-токен для получения новой пары токенов
// Security: устанавливает новый refresh token в cookie, инвалидируя старый (rotation)
// Поддерживает refresh token как из body, так и из httpOnly cookie
func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var refreshToken string

	// 1. Пробуем получить refresh token из cookie (для веба)
	cookieConfig := middleware.DefaultRefreshCookieConfig()
	cookie, cookieErr := r.Cookie("refresh_token")
	if cookieErr == nil && cookie != nil && cookie.Value != "" {
		refreshToken = cookie.Value
	}

	// 2. Если нет cookie — пробуем из body (для mobile)
	if refreshToken == "" {
		var req refreshRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			h.logger.Debug("failed to decode refresh request body", zap.Error(err))
		}
		if req.RefreshToken != "" {
			refreshToken = req.RefreshToken
		}
	}

	// 3. Если всё ещё нет — ошибка
	if refreshToken == "" {
		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		return
	}

	// Validate input data
	v := validation.NewValidator()
	validation.ValidateStringLength(v, refreshToken, 1, 500, "refresh_token", "refresh token")

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	pair, err := h.auth.Refresh(r.Context(), refreshToken)
	if err != nil {
		// Security: детект replay attack - если refresh token уже использован
		h.logger.Info("Refresh token error", zap.String("error", err.Error()))
		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		return
	}

	// Security: устанавливаем оба новых токена в cookies (rotation)
	// Access token cookie для аутентификации запросов
	accessCookieConfig := middleware.DefaultAccessCookieConfig()
	accessCookieConfig.Secure = h.cookieSecure
	middleware.SetAccessTokenCookie(w, pair.AccessToken, accessCookieConfig)

	// Refresh token cookie для обновления токенов
	cookieConfig.Secure = h.cookieSecure
	middleware.SetRefreshTokenCookie(w, pair.RefreshToken, cookieConfig)

	// Возвращаем токены в ответе (также в cookies для веба)
	resp.Success(w, map[string]any{"tokens": pair})
}

// logoutRequest структура для запроса выхода из системы
type logoutRequest struct {
	AllDevices bool `json:"all_devices,omitempty"`
}

// Logout обрабатывает запрос на выход из системы
// Может производить выход со всех устройств пользователя
// Security: добавляет access token в blacklist для немедленной инвалидации
// Security: очищает refresh token cookie
func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req logoutRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Debug("failed to decode logout request", zap.Error(err))
	}

	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		return
	}
	sessionID, ok := middleware.GetSessionIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		return
	}

	// Извлекаем access token из заголовка для добавления в blacklist
	accessToken := extractAccessToken(r)

	if err := h.auth.Logout(r.Context(), userID, sessionID, req.AllDevices, accessToken); err != nil {
		resp.Error(w, http.StatusInternalServerError, err)
		return
	}

	// Security: очищаем оба токена из cookies
	// Access token cookie
	accessCookieConfig := middleware.DefaultAccessCookieConfig()
	accessCookieConfig.Secure = h.cookieSecure
	middleware.ClearAccessTokenCookie(w, accessCookieConfig)

	// Refresh token cookie
	refreshCookieConfig := middleware.DefaultRefreshCookieConfig()
	refreshCookieConfig.Secure = h.cookieSecure
	middleware.ClearRefreshTokenCookie(w, refreshCookieConfig)

	resp.Success(w, map[string]any{"success": true})
}

// extractAccessToken извлекает access token из заголовка Authorization
func extractAccessToken(r *http.Request) string {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}
	token := strings.TrimPrefix(authHeader, "Bearer ")
	if token == authHeader {
		token = strings.TrimPrefix(authHeader, "Token ")
		if token == authHeader {
			return ""
		}
	}
	return token
}

// googleSignInRequest структура для запроса входа через Google
type googleSignInRequest struct {
	IDToken string `json:"id_token"`
}

// GoogleSignIn обрабатывает запрос на аутентификацию через Google
// Использует ID-токен Google для аутентификации пользователя
func (h *AuthHandler) GoogleSignIn(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req googleSignInRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Error("Google Sign-In: ошибка парсинга запроса",
			zap.Error(err),
		)
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()
	validation.ValidateStringLength(v, req.IDToken, 1, 2048, "id_token", "ID token")

	if !v.Valid() {
		h.logger.Error("Google Sign-In: валидация не пройдена",
			zap.Any("errors", v.Errors),
		)
		resp.ValidationError(w, v.Errors)
		return
	}

	h.logger.Info("Google Sign-In запрос",
		zap.Int("token_length", len(req.IDToken)),
		zap.String("remote_addr", r.RemoteAddr),
	)

	device := services.DeviceInfo{
		IPAddress: services.ExtractIP(r.RemoteAddr),
	}
	ua := r.UserAgent()
	if ua != "" {
		device.UserAgent = &ua
	}

	h.logger.Info("Вызов AuthService.GoogleSignIn",
		zap.String("client_id", h.auth.GoogleClientID()),
	)
	out, err := h.auth.GoogleSignIn(r.Context(), req.IDToken, device)
	if err != nil {
		h.logger.Error("Ошибка Google Sign-In",
			zap.String("error", err.Error()),
			zap.String("error_type", fmt.Sprintf("%T", err)),
			zap.String("remote_addr", r.RemoteAddr),
		)
		resp.Error(w, http.StatusUnauthorized, errors.New("Google authentication failed"))
		return
	}

	h.logger.Info("Google Sign-In успешен",
		zap.String("user_id", out.User.ID.String()),
		zap.String("email", out.User.Email),
		zap.String("display_name", out.User.GetDisplayName()),
		zap.Bool("is_new_user", out.User.CreatedAt.IsZero() || time.Since(out.User.CreatedAt) < time.Second),
	)

	// Security: устанавливаем оба токена в httpOnly cookies для веба
	// Access token cookie для аутентификации запросов
	accessCookieConfig := middleware.DefaultAccessCookieConfig()
	accessCookieConfig.Secure = h.cookieSecure
	middleware.SetAccessTokenCookie(w, out.Tokens.AccessToken, accessCookieConfig)

	// Refresh token cookie для обновления токенов
	refreshCookieConfig := middleware.DefaultRefreshCookieConfig()
	refreshCookieConfig.Secure = h.cookieSecure
	middleware.SetRefreshTokenCookie(w, out.Tokens.RefreshToken, refreshCookieConfig)

	resp.Success(w, out)
}

// ValidateToken обрабатывает запрос на проверку токена аутентификации
// Проверяет действительность токена и возвращает информацию о пользователе
func (h *AuthHandler) ValidateToken(w http.ResponseWriter, r *http.Request) {
	// Извлекаем токен из заголовка
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		return
	}

	// Удаляем префикс "Bearer ", если он присутствует
	tokenString := strings.TrimPrefix(authHeader, "Bearer ")
	if tokenString == authHeader {
		tokenString = strings.TrimPrefix(authHeader, "Token ")
		if tokenString == authHeader {
			resp.Error(w, http.StatusUnauthorized, errors.New("invalid authorization header format"))
			return
		}
	}

	// Проверяем токен и получаем информацию о пользователе
	user, err := h.auth.ValidateTokenForSilentLogin(r.Context(), tokenString)
	if err != nil {
		resp.Error(w, http.StatusUnauthorized, err)
		return
	}

	// Возвращаем минимальную информацию о пользователе для проверки
	resp.Success(w, map[string]any{
		"valid": true,
		"user": map[string]any{
			"id":           user.ID,
			"display_name": user.DisplayName,
			"email":        user.Email,
			"avatar_url":   user.AvatarURL,
		},
	})
}

// VerifyCode обрабатывает запрос на проверку кода аутентификации
// В настоящее время не используется — восстановление пароля через email с кодом
func (h *AuthHandler) VerifyCode(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	resp.Error(w, http.StatusNotImplemented, errors.New("VerifyCode endpoint is deprecated. Use /auth/reset-password instead"))
}

// RefreshToken обрабатывает запрос на обновление токена
// Делегирует методу Refresh для совместимости
func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	h.Refresh(w, r)
}

// forgotPasswordRequest запрос на восстановление пароля
type forgotPasswordRequest struct {
	Email string `json:"email"`
}

// ForgotPassword обрабатывает запрос на восстановление забытого пароля
// Отправляет email с 6-значным кодом восстановления
func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req forgotPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Валидация email
	v := validation.NewValidator()
	validation.ValidateEmail(v, req.Email)
	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	email := strings.TrimSpace(strings.ToLower(req.Email))

	// Rate limit: 3 запроса на email за 15 минут
	rateLimitKey := fmt.Sprintf("forgot_password_rate:%s", email)
	if h.redis != nil {
		count, err := h.redis.Incr(r.Context(), rateLimitKey).Result()
		if err != nil {
			h.logger.Error("failed to check forgot password rate limit", zap.String("email", email), zap.Error(err))
		}
		if count == 1 {
			if _, err := h.redis.Expire(r.Context(), rateLimitKey, 15*time.Minute).Result(); err != nil {
				h.logger.Error("failed to set rate limit expiry", zap.Error(err))
			}
		}
		if count > 3 {
			// Возвращаем success чтобы не раскрывать информацию о лимите
			resp.Success(w, map[string]any{"success": true})
			return
		}
	}

	// Проверяем, существует ли пользователь
	_, err := h.userRepo.GetUserByEmail(r.Context(), email)
	if err != nil {
		if errors.Is(err, repositories.ErrNotFound) {
			// Не раскрываем, что email не существует (security best practice)
			// Возвращаем успех в любом случае
			resp.Success(w, map[string]any{"success": true})
			return
		}
		resp.Error(w, http.StatusInternalServerError, err)
		return
	}

	// Генерируем 6-значный код
	code, err := generateResetCode()
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.Wrap(err, "failed to generate code"))
		return
	}

	// Сохраняем код в Redis с TTL 15 минут
	codeKey := fmt.Sprintf("password_reset:%s", email)
	if h.redis != nil {
		if err := h.redis.Set(r.Context(), codeKey, code, 15*time.Minute).Err(); err != nil {
			resp.Error(w, http.StatusInternalServerError, errors.Wrap(err, "failed to store code"))
			return
		}
	} else {
		// Fallback: in-memory storage (для разработки без Redis)
		// В production это не должно использоваться
		resp.Error(w, http.StatusInternalServerError, errors.New("Redis unavailable"))
		return
	}

	// Отправляем email
	if h.smtp != nil {
		if err := h.smtp.SendPasswordReset(email, code); err != nil {
			// Логируем ошибку, но не раскрываем пользователю
			// Код всё равно сохранён в Redis
			h.logger.Error("failed to send password reset email",
				zap.String("email", email),
				zap.Error(err),
			)
		}
	} else {
		// Логируем, что SMTP не настроен
		h.logger.Warn("SMTP not configured, password reset email not sent",
			zap.String("email", email),
		)
	}

	// Возвращаем успех (не раскрываем, существует ли пользователь)
	resp.Success(w, map[string]any{"success": true})
}

// resetPasswordRequest запрос на сброс пароля
type resetPasswordRequest struct {
	Email       string `json:"email"`
	Code        string `json:"code"`
	NewPassword string `json:"new_password"`
}

// ResetPassword обрабатывает запрос на сброс пароля по коду
func (h *AuthHandler) ResetPassword(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req resetPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Валидация
	v := validation.NewValidator()
	validation.ValidateEmail(v, req.Email)
	validation.ValidatePasswordPlaintext(v, req.NewPassword)
	validation.ValidateStringLength(v, req.Code, 6, 6, "code", "code")

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	email := strings.TrimSpace(strings.ToLower(req.Email))

	// Проверяем код в Redis
	codeKey := fmt.Sprintf("password_reset:%s", email)
	var storedCode string

	if h.redis != nil {
		val, err := h.redis.Get(r.Context(), codeKey).Result()
		if err == redis.Nil {
			resp.Error(w, http.StatusBadRequest, errors.New("invalid or expired code"))
			return
		}
		if err != nil {
			resp.Error(w, http.StatusInternalServerError, errors.Wrap(err, "failed to verify code"))
			return
		}
		storedCode = val
	} else {
		resp.Error(w, http.StatusInternalServerError, errors.New("Redis unavailable"))
		return
	}

	// Проверяем количество попыток (rate limiting)
	attemptsKey := fmt.Sprintf("password_reset_attempts:%s", email)
	attempts, err := h.redis.Incr(r.Context(), attemptsKey).Result()
	if err != nil {
		h.logger.Error("failed to check password reset attempts", zap.String("email", email), zap.Error(err))
	}
	if attempts == 1 {
		// Устанавливаем TTL 15 минут для счётчика попыток
		_, _ = h.redis.Expire(r.Context(), attemptsKey, 15*time.Minute).Result()
	}
	if attempts > 5 {
		// Слишком много попыток — удаляем код и счётчик
		_ = h.redis.Del(r.Context(), codeKey, attemptsKey).Err()
		resp.Error(w, http.StatusTooManyRequests, errors.New("too many attempts, please request a new code"))
		return
	}

	// Сравниваем коды используя constant-time comparison (защита от timing-атаки)
	if subtle.ConstantTimeCompare([]byte(storedCode), []byte(req.Code)) != 1 {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid code"))
		return
	}

	// Получаем пользователя
	user, err := h.userRepo.GetUserByEmail(r.Context(), email)
	if err != nil {
		if errors.Is(err, repositories.ErrNotFound) {
			resp.Error(w, http.StatusBadRequest, errors.New("user not found"))
			return
		}
		resp.Error(w, http.StatusInternalServerError, err)
		return
	}

	// Обновляем пароль
	if err := h.userRepo.UpdatePassword(r.Context(), user.ID, req.NewPassword); err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.Wrap(err, "failed to update password"))
		return
	}

	// Удаляем код и счётчик попыток из Redis (одноразовый код)
	_ = h.redis.Del(r.Context(), codeKey, attemptsKey).Err()

	resp.Success(w, map[string]any{"success": true})
}

// generateResetCode генерирует 6-значный случайный код
func generateResetCode() (string, error) {
	const digits = "0123456789"
	code := make([]byte, 6)
	for i := range code {
		n, err := rand.Int(rand.Reader, big.NewInt(10))
		if err != nil {
			return "", err
		}
		code[i] = digits[n.Int64()]
	}
	return string(code), nil
}

// GoogleLogin обрабатывает запрос на вход через Google
// Устаревший endpoint — используйте /auth/google вместо этого
func (h *AuthHandler) GoogleLogin(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	resp.Error(w, http.StatusNotImplemented, errors.New("GoogleLogin is deprecated. Use POST /auth/google instead"))
}
