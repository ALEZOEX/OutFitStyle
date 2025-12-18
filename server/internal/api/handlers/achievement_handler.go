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

type AchievementHandler struct {
	svc *services.AchievementsService
	log *zap.Logger
}

func NewAchievementHandler(svc *services.AchievementsService, log *zap.Logger) *AchievementHandler {
	return &AchievementHandler{svc: svc, log: log}
}

func (h *AchievementHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.ListAll).Methods(http.MethodGet)
	r.HandleFunc("/my", h.My).Methods(http.MethodGet)
}

func (h *AchievementHandler) ListAll(w http.ResponseWriter, r *http.Request) {
	items, err := h.svc.ListAll(r.Context())
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to load achievements"))
		return
	}
	resp.Success(w, map[string]any{"achievements": items})
}

func (h *AchievementHandler) My(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	unlocked, inProgress, totalPoints, rank, err := h.svc.My(r.Context(), userID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to load achievements"))
		return
	}

	resp.Success(w, map[string]any{
		"unlocked":      unlocked,
		"in_progress":   inProgress,
		"total_points":  totalPoints,
		"rank":          rank,
	})
}