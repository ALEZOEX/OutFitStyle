package handlers

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

type SubscriptionHandler struct {
	svc *services.SubscriptionService
	log *zap.Logger
}

func NewSubscriptionHandler(svc *services.SubscriptionService, log *zap.Logger) *SubscriptionHandler {
	return &SubscriptionHandler{svc: svc, log: log}
}

func (h *SubscriptionHandler) RegisterPublic(r *mux.Router) {
	r.HandleFunc("/plans", h.ListPlans).Methods(http.MethodGet)
}

func (h *SubscriptionHandler) RegisterProtected(r *mux.Router) {
	r.HandleFunc("/current", h.GetCurrent).Methods(http.MethodGet)
}

func (h *SubscriptionHandler) ListPlans(w http.ResponseWriter, r *http.Request) {
	plans, err := h.svc.ListPlans(r.Context())
	if err != nil {
		h.log.Error("list plans failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to load plans"))
		return
	}
	resp.Success(w, map[string]any{"plans": plans})
}

func (h *SubscriptionHandler) GetCurrent(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	cur, err := h.svc.GetCurrent(r.Context(), userID)
	if err != nil {
		h.log.Error("get current subscription failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to load subscription"))
		return
	}
	resp.Success(w, cur)
}
