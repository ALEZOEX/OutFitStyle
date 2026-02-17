// Пакет handlers содержит HTTP-обработчики для различных API-эндпоинтов
// Реализует маршрутизацию и обработку HTTP-запросов
package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/validation"
	resp "outfitstyle/server/internal/pkg/http"
)

// AuthHandler структура обработчика аутентификации
// Содержит зависимости для обработки запросов аутентификации
type AuthHandler struct {
	auth       *services.AuthService // Сервис аутентификации для выполнения бизнес-логики
	lockout    *middleware.AccountLockout // Защита от brute-force атак
}

// NewAuthHandler создает новый экземпляр обработчика аутентификации
func NewAuthHandler(auth *services.AuthService, lockout *middleware.AccountLockout) *AuthHandler {
	return &AuthHandler{auth: auth, lockout: lockout}
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

	// Validate input data
	v := validation.NewValidator()
	validation.ValidateEmail(v, req.Email)
	validation.ValidatePasswordPlaintext(v, req.Password)

	if req.DeviceName != nil {
		validation.ValidateStringLength(v, *req.DeviceName, 1, 100, "device_name", "device name")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	// Проверяем, не заблокирован ли аккаунт (защита от brute-force)
	email := strings.TrimSpace(strings.ToLower(req.Email))
	allowed, remaining, lockedUntil, err := h.lockout.CheckLoginAttempt(r.Context(), email)

	// Добавляем заголовки с информацией о попытках
	w.Header().Set("X-Login-Attempts-Remaining", fmt.Sprintf("%d", remaining))

	if !allowed {
		if lockedUntil != nil {
			retryAfter := int(lockedUntil.Seconds())
			w.Header().Set("Retry-After", fmt.Sprintf("%d", retryAfter))
		}
		resp.Error(w, http.StatusTooManyRequests, errors.New("Too many failed login attempts. Please try again later."))
		return
	}

	if err != nil {
		// Логгируем ошибку, но не блокируем вход (graceful degradation)
		// h.logger.Error("Account lockout check error", zap.Error(err))
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
		// Записываем неудачную попытку
		_ = h.lockout.RecordFailedAttempt(r.Context(), email)

		resp.Error(w, http.StatusUnauthorized, services.ErrInvalidCredentials)
		return
	}

	// Успешный вход — сбрасываем счётчик попыток
	_ = h.lockout.Reset(r.Context(), email)

	resp.Success(w, out)
}

// refreshRequest структура для запроса обновления токена
type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

// Refresh обрабатывает запрос на обновление токена доступа
// Использует рефреш-токен для получения новой пары токенов
func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req refreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()
	validation.ValidateStringLength(v, req.RefreshToken, 1, 500, "refresh_token", "refresh token")

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	pair, err := h.auth.Refresh(r.Context(), req.RefreshToken)
	if err != nil {
		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		return
	}

	resp.Success(w, map[string]any{"tokens": pair})
}

// logoutRequest структура для запроса выхода из системы
type logoutRequest struct {
	AllDevices bool `json:"all_devices,omitempty"`
}

// Logout обрабатывает запрос на выход из системы
// Может производить выход со всех устройств пользователя
func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req logoutRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

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

	if err := h.auth.Logout(r.Context(), userID, sessionID, req.AllDevices); err != nil {
		resp.Error(w, http.StatusInternalServerError, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
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
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()
	validation.ValidateStringLength(v, req.IDToken, 1, 2048, "id_token", "ID token")

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

	out, err := h.auth.GoogleSignIn(r.Context(), req.IDToken, device)
	if err != nil {
		resp.Error(w, http.StatusUnauthorized, err)
		return
	}

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
// Заглушка для функции, которая может быть реализована позже
func (h *AuthHandler) VerifyCode(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	// Заглушка для VerifyCode
	resp.Error(w, http.StatusNotImplemented, errors.New("VerifyCode not implemented"))
}

// RefreshToken обрабатывает запрос на обновление токена
// Заглушка для функции, которая может быть реализована позже
func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	// Заглушка для RefreshToken
	resp.Error(w, http.StatusNotImplemented, errors.New("RefreshToken not implemented"))
}

// ForgotPassword обрабатывает запрос на восстановление забытого пароля
// Заглушка для функции, которая может быть реализована позже
func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	// Заглушка для ForgotPassword
	resp.Error(w, http.StatusNotImplemented, errors.New("ForgotPassword not implemented"))
}

// ResetPassword обрабатывает запрос на сброс пароля
// Заглушка для функции, которая может быть реализована позже
func (h *AuthHandler) ResetPassword(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	// Заглушка для ResetPassword
	resp.Error(w, http.StatusNotImplemented, errors.New("ResetPassword not implemented"))
}

// GoogleLogin обрабатывает запрос на вход через Google
// Заглушка для функции, которая может быть реализована позже
func (h *AuthHandler) GoogleLogin(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	// Заглушка для GoogleLogin
	resp.Error(w, http.StatusNotImplemented, errors.New("GoogleLogin not implemented"))
}
