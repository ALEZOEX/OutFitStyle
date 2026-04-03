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
	"outfitstyle/server/internal/core/use_cases"
	resp "outfitstyle/server/internal/pkg/http"
	"outfitstyle/server/internal/validation"
)

type RecommendationHandler struct {
	svc *services.RecommendationService
	ach *services.AchievementEngine
	log *zap.Logger
	// Optional use case for getting recommendations - may be nil if not needed
	getRecommendationsUC usecases.GetRecommendationsUseCase
}

func NewRecommendationHandler(svc *services.RecommendationService, ach *services.AchievementEngine, log *zap.Logger) *RecommendationHandler {
	return &RecommendationHandler{svc: svc, ach: ach, log: log}
}

// NewRecommendationHandlerWithUseCases creates a new recommendation handler with use cases
func NewRecommendationHandlerWithUseCases(
	svc *services.RecommendationService,
	ach *services.AchievementEngine,
	log *zap.Logger,
	getRecommendationsUC usecases.GetRecommendationsUseCase,
) *RecommendationHandler {
	return &RecommendationHandler{
		svc:                  svc,
		ach:                  ach,
		log:                  log,
		getRecommendationsUC: getRecommendationsUC,
	}
}

func (h *RecommendationHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.Create).Methods(http.MethodPost)
	r.HandleFunc("", h.List).Methods(http.MethodGet)

	r.HandleFunc("/favorites", h.Favorites).Methods(http.MethodGet)
	r.HandleFunc("/{id}", h.Get).Methods(http.MethodGet)

	r.HandleFunc("/{id}/rate", h.Rate).Methods(http.MethodPost)
	r.HandleFunc("/{id}/favorite", h.Favorite).Methods(http.MethodPost)
	r.HandleFunc("/{id}/regenerate", h.Regenerate).Methods(http.MethodPost)

	// Endpoint for the GetRecommendations use case
	r.HandleFunc("/by-city", h.GetRecommendations).Methods(http.MethodGet)
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
	h.log.Info("🔵 [RECOMMENDATION] POST /api/v1/recommendations - START")

	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.log.Warn("⚠️ [RECOMMENDATION] Auth required for recommendation creation")
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	h.log.Info("👤 [RECOMMENDATION] User ID: " + userID.String())
	defer r.Body.Close()

	var req domain.RecommendationCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.log.Error("❌ [RECOMMENDATION] Failed to decode recommendation request", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	h.log.Info("📦 [RECOMMENDATION] Request body",
		zap.Any("latitude", req.Latitude),
		zap.Any("longitude", req.Longitude),
		zap.Any("occasion", req.Occasion),
		zap.Any("location", req.Location),
	)

	// Validate input data
	v := validation.NewValidator()

	// Validate coordinates if provided
	if req.Latitude != nil {
		validation.ValidateLatitude(v, req.Latitude)
	}

	if req.Longitude != nil {
		validation.ValidateLongitude(v, req.Longitude)
	}

	// Validate occasion if provided
	if req.Occasion != nil {
		validation.ValidateStringLength(v, *req.Occasion, 1, 100, "occasion", "occasion")
	}

	// Validate location if provided
	if req.Location != nil {
		validation.ValidateStringLength(v, *req.Location, 1, 200, "location", "location")
	}

	if !v.Valid() {
		h.log.Warn("⚠️ [RECOMMENDATION] Validation failed", zap.Any("errors", v.Errors))
		resp.ValidationError(w, v.Errors)
		return
	}

	h.log.Info("⚙️ [RECOMMENDATION] Calling service.Create...")
	rec, err := h.svc.Create(r.Context(), userID, req)
	if err != nil {
		h.log.Error("❌ [RECOMMENDATION] Failed to create recommendation",
			zap.Error(err),
			zap.String("error_msg", err.Error()),
			zap.String("user_id", userID.String()),
		)
		// Временно: возвращаем реальную ошибку для отладки
		resp.Error(w, http.StatusInternalServerError, errors.New(err.Error()))
		return
	}

	h.log.Info("✅ [RECOMMENDATION] Successfully created recommendation",
		zap.String("id", rec.ID.String()),
		zap.Stringp("occasion", rec.Occasion),
	)
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
		h.log.Error("❌ [RECOMMENDATION] Failed to list recommendations",
			zap.Error(err),
			zap.String("user_id", userID.String()),
		)
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list"))
		return
	}

	// Security: recommendations never null, return empty slice instead
	if list == nil {
		list = []domain.RecommendationRecord{}
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

	// Validate input data
	v := validation.NewValidator()
	validation.ValidateIntegerRange(v, req.Rating, 1, 5, "rating", "rating")

	if req.Feedback != nil {
		validation.ValidateStringLength(v, *req.Feedback, 1, 1000, "feedback", "feedback")
	}

	if req.ThermalFeedback != nil {
		validation.ValidateInSlice(v, *req.ThermalFeedback, []string{"too_hot", "too_cold", "just_right"}, "thermal_feedback", "thermal feedback")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
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

	// Validate input data
	v := validation.NewValidator()

	if req.PreferStyle != nil {
		validation.ValidateStringLength(v, *req.PreferStyle, 1, 100, "prefer_style", "preferred style")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
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

// GetRecommendations handles the GetRecommendations use case
func (h *RecommendationHandler) GetRecommendations(w http.ResponseWriter, r *http.Request) {
	// Check if the use case is available
	if h.getRecommendationsUC == nil {
		resp.Error(w, http.StatusNotImplemented, errors.New("use case not implemented"))
		return
	}

	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	// Extract city from query parameters
	city := r.URL.Query().Get("city")
	if city == "" {
		resp.Error(w, http.StatusBadRequest, errors.New("city parameter is required"))
		return
	}

	// Prepare input for the use case
	input := usecases.GetRecommendationsInput{
		UserID: userID.String(),
		City:   city,
	}

	// Execute the use case
	result, err := h.getRecommendationsUC.Execute(r.Context(), input)
	if err != nil {
		h.log.Error("Failed to execute GetRecommendations use case", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get recommendations"))
		return
	}

	// Return the result
	resp.Success(w, map[string]any{
		"recommendation": result.Recommendation,
	})
}
