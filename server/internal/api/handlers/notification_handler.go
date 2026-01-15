package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

type NotificationHandler struct {
	svc *services.NotificationService
	log *zap.Logger
}

func NewNotificationHandler(svc *services.NotificationService, log *zap.Logger) *NotificationHandler {
	return &NotificationHandler{svc: svc, log: log}
}

func (h *NotificationHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.List).Methods(http.MethodGet)
	r.HandleFunc("/{id}/read", h.ReadOne).Methods(http.MethodPut)
	r.HandleFunc("/read-all", h.ReadAll).Methods(http.MethodPut)

	r.HandleFunc("/token", h.RegisterToken).Methods(http.MethodPost)
	r.HandleFunc("/token", h.DeleteToken).Methods(http.MethodDelete)
}

func (h *NotificationHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	q := r.URL.Query()
	unreadOnly := false
	if v := q.Get("unread_only"); v == "true" || v == "1" {
		unreadOnly = true
	}
	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	items, total, unreadCount, err := h.svc.List(r.Context(), userID, unreadOnly, page, limit)
	if err != nil {
		h.log.Error("notifications list failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list notifications"))
		return
	}

	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	resp.Success(w, map[string]any{
		"notifications": items,
		"unread_count":  unreadCount,
		"pagination": domain.Pagination{
			Page:  page,
			Limit: limit,
			Total: total,
		},
	})
}

func (h *NotificationHandler) ReadOne(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid id"))
		return
	}

	if err := h.svc.MarkRead(r.Context(), userID, id); err != nil {
		if errors.Is(err, repositories.ErrNotFound) {
			resp.Error(w, http.StatusNotFound, err)
			return
		}
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to mark read"))
		return
	}

	resp.Success(w, map[string]any{"success": true})
}

func (h *NotificationHandler) ReadAll(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	n, err := h.svc.MarkReadAll(r.Context(), userID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to mark read-all"))
		return
	}

	resp.Success(w, map[string]any{"success": true, "updated": n})
}

func (h *NotificationHandler) RegisterToken(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.RegisterPushTokenRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	if err := h.svc.RegisterToken(r.Context(), userID, req); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}

func (h *NotificationHandler) DeleteToken(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.DeletePushTokenRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	if err := h.svc.DeleteToken(r.Context(), userID, req.Token); err != nil {
		if errors.Is(err, repositories.ErrNotFound) {
			resp.Error(w, http.StatusNotFound, err)
			return
		}
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}
