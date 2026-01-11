package handlers

import (
	"bytes"
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
	resp "outfitstyle/server/internal/pkg/http"
)

type UserHandler struct {
	userService    *services.UserService
	fileService    *services.FileService
	exportService  *services.ExportService
	accountService *services.AccountService
	sessionRepo    repositories.SessionRepository
	logger         *zap.Logger
}

type SessionInfo struct {
	ID          domain.ID `json:"id"`
	DeviceName  *string   `json:"device_name,omitempty"`
	DeviceType  *string   `json:"device_type,omitempty"`
	IPAddress   *string   `json:"ip_address,omitempty"`
	LastUsedAt  string    `json:"last_used_at"`
	IsCurrent   bool      `json:"is_current"`
	IsActive    bool      `json:"is_active"`
	ExpiresAt   string    `json:"expires_at"`
}

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

	out, err := h.userService.UpdateUserProfile(r.Context(), userID, patch)
	if err != nil {
		h.logger.Error("update profile failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update profile"))
		return
	}
	resp.Success(w, out)
}

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

type deleteAccountBody struct {
	Password string  `json:"password"`
	Reason   *string `json:"reason,omitempty"`
	Feedback *string `json:"feedback,omitempty"`
}

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

func (h *UserHandler) DeleteAccount(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var body deleteAccountBody
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	if err := h.accountService.DeleteAccount(r.Context(), userID, body.Password); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}

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

	// Создаем структуру для маппинга
	var prefs domain.UserPreferences

	// Используем mapstructure для маппинга с игнорированием неизвестных полей
	decoder, err := mapstructure.NewDecoder(&mapstructure.DecoderConfig{
		Result:           &prefs,
		TagName:          "json",
		WeaklyTypedInput: true, // Позволяет преобразование типов
		ErrorUnused:      false, // Не ошибка при неизвестных полях
	})

	if err != nil {
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to create decoder: %v", err))
		h.logger.Error("failed to create mapstructure decoder", zap.Error(err))
		return
	}

	if err := decoder.Decode(rawPrefs); err != nil {
		h.logger.Error("failed to decode preferences", zap.Error(err), zap.Any("raw_prefs", rawPrefs))
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid preferences format: %v", err))
		return
	}

	// Возвращаем тело для последующей обработки
	r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	out, err := h.userService.UpdatePreferences(r.Context(), userID, prefs)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update preferences"))
		return
	}
	resp.Success(w, out)
}

func (h *UserHandler) UpdateBodyMeasurements(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	var bm domain.BodyMeasurements
	if err := json.NewDecoder(r.Body).Decode(&bm); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	out, err := h.userService.UpdateBodyMeasurements(r.Context(), userID, bm)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update body measurements"))
		return
	}
	resp.Success(w, out)
}

