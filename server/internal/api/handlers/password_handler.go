// Пакет handlers содержит HTTP-обработчики для различных API-эндпоинтов
// Реализует маршрутизацию и обработку HTTP-запросов
package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/gorilla/mux"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/validation"
	resp "outfitstyle/server/internal/pkg/http"
)

// PasswordHandler обработчик запросов управления паролем
type PasswordHandler struct {
	userRepo repositories.UserRepository // Репозиторий пользователей
	logger   *zap.Logger                 // Логгер
}

// SetPasswordRequest запрос установки пароля
type SetPasswordRequest struct {
	CurrentPassword string `json:"current_password,omitempty"` // опционально для Google-пользователей
	NewPassword     string `json:"new_password"`               // новый пароль
}

// NewPasswordHandler создает новый экземпляр обработчика паролей
func NewPasswordHandler(
	userRepo repositories.UserRepository,
	logger *zap.Logger,
) *PasswordHandler {
	return &PasswordHandler{
		userRepo: userRepo,
		logger:   logger,
	}
}

// RegisterRoutes регистрирует маршруты для обработчика паролей
func (h *PasswordHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/set-password", h.SetPassword).Methods(http.MethodPost)
	r.HandleFunc("/change-password", h.ChangePassword).Methods(http.MethodPost)
}

// SetPassword обрабатывает запрос на установку пароля
// Для Google-пользователей current_password не требуется
// Для обычных пользователей требуется проверка текущего пароля
func (h *PasswordHandler) SetPassword(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// 1. Получить userID из токена
	userID, ok := middleware.GetUserIDFromContext(ctx)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// 2. Декодировать тело запроса
	var req SetPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Warn("set-password: invalid request body",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// 3. Валидация нового пароля
	v := validation.NewValidator()
	validation.ValidatePasswordPlaintext(v, req.NewPassword)

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	// 4. Получить пользователя
	user, err := h.userRepo.GetUser(ctx, userID)
	if err != nil {
		h.logger.Error("set-password: failed to get user",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get user"))
		return
	}

	if user == nil {
		resp.Error(w, http.StatusNotFound, errors.New("user not found"))
		return
	}

	// 5. Проверка: если у пользователя уже есть пароль, требуется current_password
	hasPassword := user.PasswordHash != ""
	isGoogleUser := user.OAuthProvider != nil && *user.OAuthProvider == "google"

	if hasPassword {
		// Пользователь с паролем — требуется проверка текущего
		if req.CurrentPassword == "" {
			resp.Error(w, http.StatusBadRequest, errors.New("current_password is required"))
			return
		}

		// Проверка текущего пароля
		if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.CurrentPassword)); err != nil {
			h.logger.Warn("set-password: invalid current_password",
				zap.String("user_id", userID.String()),
			)
			resp.Error(w, http.StatusBadRequest, errors.New("invalid current password"))
			return
		}
	}
	// Для Google-пользователей без пароля current_password не требуется

	// 6. Хеширование нового пароля (cost 12)
	// Используем ту же функцию, что и в репозитории
	if err := h.userRepo.UpdatePassword(ctx, userID, req.NewPassword); err != nil {
		h.logger.Error("set-password: failed to update password",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to set password"))
		return
	}

	h.logger.Info("set-password: password set successfully",
		zap.String("user_id", userID.String()),
		zap.Bool("was_google_user", isGoogleUser),
		zap.Bool("had_password", hasPassword),
	)

	// 7. Возвращаем успех
	resp.Success(w, map[string]any{
		"success": true,
		"message": "Пароль успешно установлен",
	})
}

// ChangePassword обрабатывает запрос на смену пароля
// Требуется проверка текущего пароля для всех пользователей
func (h *PasswordHandler) ChangePassword(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// 1. Получить userID из токена
	userID, ok := middleware.GetUserIDFromContext(ctx)
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// 2. Декодировать тело запроса
	var req SetPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Warn("change-password: invalid request body",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// 3. Валидация
	v := validation.NewValidator()

	if req.CurrentPassword == "" {
		v.AddError("current_password", "current_password is required")
	}

	validation.ValidatePasswordPlaintext(v, req.NewPassword)

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	// 4. Получить пользователя
	user, err := h.userRepo.GetUser(ctx, userID)
	if err != nil {
		h.logger.Error("change-password: failed to get user",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get user"))
		return
	}

	if user == nil {
		resp.Error(w, http.StatusNotFound, errors.New("user not found"))
		return
	}

	// 5. Проверка текущего пароля (обязательно для change-password)
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.CurrentPassword)); err != nil {
		h.logger.Warn("change-password: invalid current_password",
			zap.String("user_id", userID.String()),
		)
		resp.Error(w, http.StatusBadRequest, errors.New("invalid current password"))
		return
	}

	// 6. Обновление пароля
	if err := h.userRepo.UpdatePassword(ctx, userID, req.NewPassword); err != nil {
		h.logger.Error("change-password: failed to update password",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to change password"))
		return
	}

	h.logger.Info("change-password: password changed successfully",
		zap.String("user_id", userID.String()),
	)

	// 7. Возвращаем успех
	resp.Success(w, map[string]any{
		"success": true,
		"message": "Пароль успешно изменен",
	})
}
