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

type RecommendationHandler struct {
	svc *services.RecommendationService
	ach *services.AchievementEngine
	log *zap.Logger
}

func NewRecommendationHandler(svc *services.RecommendationService, ach *services.AchievementEngine, log *zap.Logger) *RecommendationHandler {
	return &RecommendationHandler{svc: svc, ach: ach, log: log}
}

func (h *RecommendationHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.Create).Methods(http.MethodPost)
	r.HandleFunc("", h.List).Methods(http.MethodGet)

	r.HandleFunc("/favorites", h.Favorites).Methods(http.MethodGet)
	r.HandleFunc("/{id}", h.Get).Methods(http.MethodGet)

	r.HandleFunc("/{id}/rate", h.Rate).Methods(http.MethodPost)
	r.HandleFunc("/{id}/favorite", h.Favorite).Methods(http.MethodPost)
	r.HandleFunc("/{id}/regenerate", h.Regenerate).Methods(http.MethodPost)
}

// @Summary Create recommendation
// @Description Creates a new recommendation based on user preferences and weather
// @Tags recommendations
// @Accept json
// @Produce json
// @Param request body domain.RecommendationCreateRequest true "Recommendation request"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/recommendations [post]
func (h *RecommendationHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.log.Info("Auth required for recommendation creation")
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.RecommendationCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.log.Error("Failed to decode recommendation request", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	h.log.Info("Creating recommendation", zap.Any("request", req))
	rec, err := h.svc.Create(r.Context(), userID, req)
	if err != nil {
		h.log.Error("Failed to create recommendation", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to create recommendation"))
		return
	}

	h.log.Info("Successfully created recommendation", zap.String("id", rec.ID.String()))
	resp.Success(w, map[string]any{
		"recommendation": rec,
		// remaining_today добавим позже вместе с подписками/лимитами
	})
}

func (h *RecommendationHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	qp := r.URL.Query()
	var page, limit int
	if p := qp.Get("page"); p != "" {
		if pageNum, err := strconv.Atoi(p); err == nil && pageNum > 0 {
			page = pageNum
		} else {
			page = 1
		}
	} else {
		page = 1
	}

	if l := qp.Get("limit"); l != "" {
		if limitNum, err := strconv.Atoi(l); err == nil && limitNum > 0 {
			limit = limitNum
		} else {
			limit = 20
		}
	} else {
		limit = 20
	}

	q := domain.RecommendationListQuery{
		Page:  page,
		Limit: limit,
	}

	if v := qp.Get("from_date"); v != "" {
		q.FromDate = &v
	}
	if v := qp.Get("to_date"); v != "" {
		q.ToDate = &v
	}
	if v := qp.Get("occasion"); v != "" {
		q.Occasion = &v
	}

	if v := qp.Get("min_rating"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q.MinRating = &n
		}
	}
	if v := qp.Get("is_favorite"); v != "" {
		b := (v == "true" || v == "1")
		q.IsFavorite = &b
	}

	list, total, err := h.svc.List(r.Context(), userID, q)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list"))
		return
	}

	resp.Success(w, map[string]any{
		"recommendations": list,
		"pagination": domain.Pagination{
			Page:  q.Page,
			Limit: q.Limit,
			Total: total,
		},
	})
}

func (h *RecommendationHandler) Favorites(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	list, err := h.svc.Favorites(r.Context(), userID, limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list favorites"))
		return
	}
	resp.Success(w, map[string]any{"recommendations": list, "count": len(list)})
}

func (h *RecommendationHandler) Get(w http.ResponseWriter, r *http.Request) {
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

	rec, err := h.svc.Get(r.Context(), userID, id)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get"))
		return
	}
	if rec == nil {
		resp.Error(w, http.StatusNotFound, errors.New("not found"))
		return
	}
	resp.Success(w, rec)
}

func (h *RecommendationHandler) Rate(w http.ResponseWriter, r *http.Request) {
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
	defer r.Body.Close()

	var req domain.RecommendationRateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	_, err = h.svc.Rate(r.Context(), userID, id, req.Rating, req.ThermalFeedback, req.Feedback)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	var unlocked any = nil
	if h.ach != nil {
		codes, _ := h.ach.Evaluate(r.Context(), userID)
		if len(codes) > 0 {
			unlocked = codes
		}
	}

	resp.Success(w, map[string]any{
		"success":              true,
		"achievement_unlocked": unlocked,
	})
}

func (h *RecommendationHandler) Favorite(w http.ResponseWriter, r *http.Request) {
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
	defer r.Body.Close()

	var req domain.FavoriteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	if err := h.svc.SetFavorite(r.Context(), userID, id, req.IsFavorite); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	resp.Success(w, map[string]any{"success": true})
}

func (h *RecommendationHandler) Regenerate(w http.ResponseWriter, r *http.Request) {
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
	defer r.Body.Close()

	var req domain.RecommendationRegenerateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	rec, err := h.svc.Regenerate(r.Context(), userID, id, req.ExcludeItems, req.PreferStyle)
	if err != nil {
		if errors.Is(err, repositories.ErrNotFound) {
			resp.Error(w, http.StatusNotFound, errors.New("not found"))
			return
		}
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"recommendation": rec})
}

