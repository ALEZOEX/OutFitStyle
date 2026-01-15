package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

type AdminHandler struct {
	svc *services.AdminService
	log *zap.Logger
}

func NewAdminHandler(svc *services.AdminService, log *zap.Logger) *AdminHandler {
	return &AdminHandler{svc: svc, log: log}
}

func (h *AdminHandler) Stats(w http.ResponseWriter, r *http.Request) {
	s, err := h.svc.Stats(r.Context())
	if err != nil {
		h.log.Error("admin stats failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to load stats"))
		return
	}
	resp.Success(w, s)
}

func (h *AdminHandler) Users(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	items, total, err := h.svc.Users(r.Context(), page, limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list users"))
		return
	}
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 50
	}

	resp.Success(w, map[string]any{
		"users":      items,
		"pagination": domain.Pagination{Page: page, Limit: limit, Total: total},
	})
}

func (h *AdminHandler) Audit(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	items, total, err := h.svc.Audit(r.Context(), page, limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list audit logs"))
		return
	}
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 50
	}

	resp.Success(w, map[string]any{
		"audit":      items,
		"pagination": domain.Pagination{Page: page, Limit: limit, Total: total},
	})
}

func (h *AdminHandler) CreatePromo(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req repositories.CreatePromoRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	id, err := h.svc.CreatePromo(r.Context(), nil, req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"id": id})
}
