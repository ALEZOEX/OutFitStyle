// Пакет handlers содержит HTTP-обработчики для различных API-эндпоинтов
// Реализует маршрутизацию и обработку HTTP-запросов
package handlers

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/mitchellh/mapstructure"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/validation"
	resp "outfitstyle/server/internal/pkg/http"
)

// UserHandler структура обработчика пользовательских запросов
// Содержит зависимости для обработки запросов, связанных с профилем пользователя
type UserHandler struct {
	userService    *services.UserService          // Сервис для работы с пользовательскими данными
	fileService    *services.FileService          // Сервис для работы с файлами
	exportService  *services.ExportService        // Сервис для экспорта данных
	accountService *services.AccountService       // Сервис для управления аккаунтом
	sessionRepo    repositories.SessionRepository // Репозиторий сессий для работы с сессиями пользователя
	logger         *zap.Logger                    // Логгер для записи событий
}

// SessionInfo структура информации о сессии пользователя
type SessionInfo struct {
	ID         domain.ID `json:"id"`                    // Идентификатор сессии
	DeviceName *string   `json:"device_name,omitempty"` // Название устройства
	DeviceType *string   `json:"device_type,omitempty"` // Тип устройства
	IPAddress  *string   `json:"ip_address,omitempty"`  // IP-адрес
	LastUsedAt string    `json:"last_used_at"`          // Время последнего использования
	IsCurrent  bool      `json:"is_current"`            // Признак текущей сессии
	IsActive   bool      `json:"is_active"`             // Признак активности сессии
	ExpiresAt  string    `json:"expires_at"`            // Время истечения срока действия
}

// DeleteAccountBody структура тела запроса для удаления аккаунта
type DeleteAccountBody struct {
	Password string  `json:"password"`           // Пароль пользователя для подтверждения
	Reason   *string `json:"reason,omitempty"`   // Причина удаления аккаунта
	Feedback *string `json:"feedback,omitempty"` // Обратная связь от пользователя
}

// NewUserHandler создает новый экземпляр обработчика пользовательских запросов
func NewUserHandler(
	userService *services.UserService,
	fileSvc *services.FileService,
	exportSvc *services.ExportService,
	accountSvc *services.AccountService,
	sessionRepo repositories.SessionRepository,
	logger *zap.Logger,
) *UserHandler {
	return &UserHandler{
		userService:    userService,
		fileService:    fileSvc,
		exportService:  exportSvc,
		accountService: accountSvc,
		sessionRepo:    sessionRepo,
		logger:         logger,
	}
}

// RegisterRoutes регистрирует маршруты для обработчика пользовательских запросов
func (h *UserHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/profile", h.GetMyProfile).Methods(http.MethodGet)
	r.HandleFunc("/profile", h.UpdateMyProfile).Methods(http.MethodPut)

	// /me is an alias for current user's profile
	r.HandleFunc("/me", h.GetMyProfile).Methods(http.MethodGet)

	r.HandleFunc("/preferences", h.GetPreferences).Methods(http.MethodGet)
	r.HandleFunc("/preferences", h.UpdatePreferences).Methods(http.MethodPut)

	r.HandleFunc("/body", h.UpdateBodyMeasurements).Methods(http.MethodPut)

	r.HandleFunc("/avatar", h.UploadAvatar).Methods(http.MethodPost)

	r.HandleFunc("/export", h.Export).Methods(http.MethodGet)

	r.HandleFunc("/sessions", h.Sessions).Methods(http.MethodGet)
	r.HandleFunc("/sessions/{session_id}", h.DeleteSession).Methods(http.MethodDelete)

	r.HandleFunc("/account", h.DeleteAccount).Methods(http.MethodDelete)
}

// GetMyProfile обрабатывает запрос на получение профиля текущего пользователя
// Возвращает информацию о профиле аутентифицированного пользователя
func (h *UserHandler) GetMyProfile(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	out, err := h.userService.GetUserProfile(r.Context(), userID)
	if err != nil {
		h.logger.Error("get profile failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get profile"))
		return
	}
	if out == nil || out.User == nil {
		resp.Error(w, http.StatusNotFound, errors.New("user not found"))
		return
	}
	resp.Success(w, out)
}

// UpdateMyProfile обрабатывает запрос на обновление профиля текущего пользователя
// Обновляет информацию о профиле аутентифицированного пользователя
func (h *UserHandler) UpdateMyProfile(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	var patch domain.UserProfileUpdate
	if err := json.NewDecoder(r.Body).Decode(&patch); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()

	if patch.DisplayName != nil {
		validation.ValidateStringLength(v, *patch.DisplayName, 1, 500, "display_name", "display name")
	}

	if patch.DefaultLocation != nil {
		validation.ValidateStringLength(v, *patch.DefaultLocation, 1, 200, "default_location", "default location")
	}

	if patch.Gender != nil {
		validation.ValidateInSlice(v, *patch.Gender, []string{"male", "female", "other", "prefer_not_to_say"}, "gender", "gender")
	}

	if patch.Timezone != nil {
		validation.ValidateStringLength(v, *patch.Timezone, 1, 100, "timezone", "timezone")
	}

	if patch.Locale != nil {
		validation.ValidateStringLength(v, *patch.Locale, 2, 10, "locale", "locale")
	}

	if patch.DefaultLatitude != nil {
		validation.ValidateLatitude(v, patch.DefaultLatitude)
	}

	if patch.DefaultLongitude != nil {
		validation.ValidateLongitude(v, patch.DefaultLongitude)
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	out, err := h.userService.UpdateUserProfile(r.Context(), userID, patch)
	if err != nil {
		h.logger.Error("update profile failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update profile"))
		return
	}
	resp.Success(w, out)
}

// @Summary Update user's body measurements
// @Description Update the authenticated user's body measurements
// @Tags users
// @Accept json
// @Produce json
// @Param body_measurement body domain.BodyMeasurements true "Body measurement data"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Security ApiKeyAuth
// @Router /user/body [put]
func (h *UserHandler) UpdateBodyMeasurements(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	var body domain.BodyMeasurements
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()

	// Validate height if provided
	if body.Height != nil {
		validation.ValidateIntegerRange(v, *body.Height, 50, 300, "height", "height in cm")
	}

	// Validate weight if provided
	if body.Weight != nil {
		validation.ValidateIntegerRange(v, *body.Weight, 20, 500, "weight", "weight in kg")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	out, err := h.userService.UpdateBodyMeasurements(r.Context(), userID, body)
	if err != nil {
		h.logger.Error("update body measurements failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update body measurements"))
		return
	}
	resp.Success(w, out)
}

// @Summary Upload user avatar
// @Description Upload a new avatar image for the authenticated user
// @Tags users
// @Accept mpfd
// @Produce json
// @Param file formData file true "Avatar image file"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Security ApiKeyAuth
// @Router /user/avatar [post]
func (h *UserHandler) UploadAvatar(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	// max 10MB
	r.Body = http.MaxBytesReader(w, r.Body, 10*1024*1024)

	if err := r.ParseMultipartForm(10 * 1024 * 1024); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid multipart form"))
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("file is required"))
		return
	}
	defer file.Close()

	ct := header.Header.Get("Content-Type")
	if ct == "" {
		ct = "application/octet-stream"
	}

	res, err := h.fileService.UploadAvatar(r.Context(), userID, header.Filename, ct, header.Size, file)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"avatar_url": res.URL})
}

// @Summary Export user data
// @Description Export the authenticated user's data
// @Tags users
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Security ApiKeyAuth
// @Router /user/export [get]
func (h *UserHandler) Export(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	out, err := h.exportService.ExportUserData(r.Context(), userID)
	if err != nil {
		h.logger.Error("export failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to export"))
		return
	}

	resp.Success(w, out)
}

// @Summary Get user sessions
// @Description Retrieve all active sessions for the authenticated user
// @Tags users
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Security ApiKeyAuth
// @Router /user/sessions [get]
func (h *UserHandler) Sessions(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	curSID, _ := middleware.GetSessionIDFromContext(r.Context())

	sessions, err := h.sessionRepo.ListByUser(r.Context(), userID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list sessions"))
		return
	}

	out := make([]map[string]any, 0, len(sessions))
	for _, s := range sessions {
		out = append(out, map[string]any{
			"id":           s.ID,
			"device_name":  s.DeviceName,
			"device_type":  s.DeviceType,
			"ip_address":   s.IPAddress,
			"last_used_at": s.LastUsedAt,
			"is_current":   s.ID == curSID,
			"is_active":    s.IsActive,
			"expires_at":   s.ExpiresAt,
		})
	}

	resp.Success(w, map[string]any{"sessions": out})
}

// @Summary Delete a user session
// @Description Revoke a specific session for the authenticated user
// @Tags users
// @Produce json
// @Param session_id path string true "Session ID"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Security ApiKeyAuth
// @Router /user/sessions/{session_id} [delete]
func (h *UserHandler) DeleteSession(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	sid, err := domain.ParseID(mux.Vars(r)["session_id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid session_id"))
		return
	}

	// Важно: revoke только своей сессии
	if err := h.sessionRepo.RevokeForUser(r.Context(), userID, sid); err != nil {
		resp.Error(w, http.StatusNotFound, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}

// @Summary Get user preferences
// @Description Retrieve the authenticated user's preferences
// @Tags users
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Security ApiKeyAuth
// @Router /user/preferences [get]
func (h *UserHandler) GetPreferences(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	out, err := h.userService.GetUserProfile(r.Context(), userID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get preferences"))
		return
	}

	if out == nil || out.User == nil {
		resp.Error(w, http.StatusNotFound, errors.New("user not found"))
		return
	}

	// Возвращаем только предпочтения
	resp.Success(w, map[string]any{"preferences": out.User.Preferences})
}

// DeleteAccount обрабатывает запрос на удаление пользовательского аккаунта
// Безвозвратно удаляет аккаунт аутентифицированного пользователя
func (h *UserHandler) DeleteAccount(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var body DeleteAccountBody
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()
	validation.ValidatePasswordPlaintext(v, body.Password)

	if body.Reason != nil {
		validation.ValidateStringLength(v, *body.Reason, 1, 500, "reason", "reason for deletion")
	}

	if body.Feedback != nil {
		validation.ValidateStringLength(v, *body.Feedback, 1, 1000, "feedback", "feedback")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	if err := h.accountService.DeleteAccount(r.Context(), userID, body.Password); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}

// @Summary Update user preferences
// @Description Update the authenticated user's preferences
// @Tags users
// @Accept json
// @Produce json
// @Param preferences body domain.UserPreferences true "Updated preferences"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Security ApiKeyAuth
// @Router /user/preferences [put]
func (h *UserHandler) UpdatePreferences(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	// Читаем тело запроса
	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("failed to read request body: %v", err))
		return
	}

	// Декодируем в map для гибкой обработки
	var rawPrefs map[string]interface{}
	if err := json.Unmarshal(bodyBytes, &rawPrefs); err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid JSON: %v", err))
		h.logger.Error("invalid JSON in preferences", zap.String("body", string(bodyBytes)), zap.Error(err))
		return
	}

	// Validate input data
	v := validation.NewValidator()

	// Check if the preferences map is too large
	if len(rawPrefs) > 50 { // Arbitrary limit to prevent abuse
		v.AddError("preferences", "too many preference fields provided")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	// Создаем структуру для маппинга
	var prefs domain.UserPreferences

	// Используем mapstructure для маппинга с игнорированием неизвестных полей
	decoder, err := mapstructure.NewDecoder(&mapstructure.DecoderConfig{
		Result:           &prefs,
		TagName:          "json",
		WeaklyTypedInput: true,  // Позволяет преобразование типов
		ErrorUnused:      false, // Не ошибка при неизвестных полях
	})

	if err != nil {
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to create decoder: %v", err))
		h.logger.Error("failed to create mapstructure decoder", zap.Error(err))
		return
	}

	if err := decoder.Decode(rawPrefs); err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("failed to decode preferences: %v", err))
		h.logger.Error("failed to decode preferences", zap.Any("raw_prefs", rawPrefs), zap.Error(err))
		return
	}

	// Обновляем предпочтения пользователя
	out, err := h.userService.UpdatePreferences(r.Context(), userID, prefs)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to update preferences: %v", err))
		h.logger.Error("failed to update user preferences", zap.Error(err))
		return
	}

	// Возвращаем обновленные предпочтения
	resp.Success(w, map[string]any{"preferences": out.User.Preferences})
}
