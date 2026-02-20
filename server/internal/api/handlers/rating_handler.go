package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/validation"
	resp "outfitstyle/server/internal/pkg/http"
)

// RatingHandler обработчик запросов рейтинга рекомендаций
type RatingHandler struct {
	svc    *services.RatingService
	ach    *services.AchievementEngine
	logger *zap.Logger
}

// NewRatingHandler создаёт новый экземпляр обработчика рейтинга
func NewRatingHandler(
	svc *services.RatingService,
	ach *services.AchievementEngine,
	logger *zap.Logger,
) *RatingHandler {
	return &RatingHandler{
		svc:    svc,
		ach:    ach,
		logger: logger,
	}
}

// RegisterRoutes регистрирует HTTP роуты
func (h *RatingHandler) RegisterRoutes(r *mux.Router) {
	// POST /api/v1/recommendations/{id}/rate - оценить рекомендацию
	r.HandleFunc("/{id}/rate", h.RateOutfit).Methods(http.MethodPost)
	
	// GET /api/v1/recommendations/{id}/quality - получить статистику качества
	r.HandleFunc("/{id}/quality", h.GetQuality).Methods(http.MethodGet)
	
	// GET /api/v1/ratings/me/stats - статистика оценок текущего пользователя
	r.HandleFunc("/me/stats", h.GetUserStats).Methods(http.MethodGet)
}

// RateOutfitRequest запрос на оценку рекомендации
type RateOutfitRequest struct {
	Rating          int     `json:"rating"`            // 1-5 звёзд
	OutfitItems     []int64 `json:"outfit_items"`      // ID вещей в наряде
	Feedback        *string `json:"feedback,omitempty"` // Текстовый отзыв
	ThermalFeedback *string `json:"thermal_feedback,omitempty"` // "too_hot", "too_cold", "just_right"
}

// RateOutfit godoc
// @Summary Оценить рекомендацию
// @Description Оценивает рекомендацию одежды (1-5 звёзд), конвертируется в quality_score -10..+10
// @Tags ratings
// @Accept json
// @Produce json
// @Param id path string true "ID рекомендации"
// @Param request body RateOutfitRequest true "Оценка рекомендации"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/recommendations/{id}/rate [post]
func (h *RatingHandler) RateOutfit(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("некорректный ID рекомендации"))
		return
	}

	defer r.Body.Close()

	var req RateOutfitRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Error("Не удалось декодировать запрос оценки", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, errors.New("некорректный формат запроса"))
		return
	}

	// Валидация
	v := validation.NewValidator()
	validation.ValidateIntegerRange(v, req.Rating, 1, 5, "rating", "рейтинг (1-5)")

	if req.Feedback != nil {
		validation.ValidateStringLength(v, *req.Feedback, 0, 1000, "feedback", "отзыв")
	}

	if req.ThermalFeedback != nil {
		validation.ValidateInSlice(v, *req.ThermalFeedback, []string{"too_hot", "too_cold", "just_right"}, "thermal_feedback", "термальная обратная связь")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	h.logger.Info("Оценка рекомендации",
		zap.String("user_id", userID.String()),
		zap.String("recommendation_id", id.String()),
		zap.Int("rating", req.Rating),
	)

	// Оцениваем рекомендацию
	rating, err := h.svc.RateOutfit(
		r.Context(),
		userID,
		id,
		req.Rating,
		req.OutfitItems,
		req.Feedback,
		req.ThermalFeedback,
	)
	if err != nil {
		h.logger.Error("Не удалось оценить рекомендацию", zap.Error(err))
		
		if errors.Is(err, errors.New("record not found")) {
			resp.Error(w, http.StatusNotFound, errors.New("рекомендация не найдена"))
			return
		}
		
		resp.Error(w, http.StatusBadRequest, errors.New("не удалось оценить рекомендацию"))
		return
	}

	// Проверяем достижения
	var unlocked any = nil
	if h.ach != nil {
		codes, _ := h.ach.Evaluate(r.Context(), userID)
		if len(codes) > 0 {
			unlocked = codes
		}
	}

	h.logger.Info("Рекомендация оценена",
		zap.String("user_id", userID.String()),
		zap.String("recommendation_id", id.String()),
		zap.Int("quality_score", rating.QualityScore),
	)

	resp.Success(w, map[string]any{
		"success": true,
		"rating": map[string]any{
			"id":                rating.ID,
			"recommendation_id": rating.RecommendationID,
			"rating":            rating.Rating,
			"quality_score":     rating.QualityScore,
			"feedback":          rating.Feedback,
			"thermal_feedback":  rating.ThermalFeedback,
			"created_at":        rating.CreatedAt,
		},
		"achievement_unlocked": unlocked,
	})
}

// GetQuality godoc
// @Summary Получить статистику качества рекомендации
// @Description Возвращает агрегированную статистику качества рекомендации (средний рейтинг, количество оценок)
// @Tags ratings
// @Produce json
// @Param id path string true "ID рекомендации"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/recommendations/{id}/quality [get]
func (h *RatingHandler) GetQuality(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("некорректный ID рекомендации"))
		return
	}

	h.logger.Debug("Запрос статистики качества",
		zap.String("user_id", userID.String()),
		zap.String("recommendation_id", id.String()),
	)

	quality, err := h.svc.GetRecommendationQuality(r.Context(), userID, id)
	if err != nil {
		h.logger.Error("Не удалось получить статистику качества", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("не удалось получить статистику"))
		return
	}

	resp.Success(w, map[string]any{
		"quality": quality,
	})
}

// GetUserStats godoc
// @Summary Получить статистику оценок пользователя
// @Description Возвращает общую статистику оценок текущего пользователя
// @Tags ratings
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/ratings/me/stats [get]
func (h *RatingHandler) GetUserStats(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	stats, err := h.svc.GetUserRatingStats(r.Context(), userID)
	if err != nil {
		h.logger.Error("Не удалось получить статистику пользователя", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("не удалось получить статистику"))
		return
	}

	if stats == nil {
		// Пользователь ещё не оценивал рекомендации
		resp.Success(w, map[string]any{
			"stats": &domain.UserRatingStats{
				UserID:          userID,
				TotalRatings:    0,
				AvgRating:       0,
				AvgQualityScore: 0,
				PositiveRatings: 0,
				NegativeRatings: 0,
			},
		})
		return
	}

	resp.Success(w, map[string]any{
		"stats": stats,
	})
}

// GetUserRating godoc
// @Summary Получить оценку пользователя для рекомендации
// @Description Возвращает оценку текущего пользователя для указанной рекомендации
// @Tags ratings
// @Produce json
// @Param id path string true "ID рекомендации"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/recommendations/{id}/my-rating [get]
func (h *RatingHandler) GetUserRating(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("некорректный ID рекомендации"))
		return
	}

	rating, err := h.svc.GetUserRating(r.Context(), userID, id)
	if err != nil {
		h.logger.Error("Не удалось получить оценку пользователя", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("не удалось получить оценку"))
		return
	}

	if rating == nil {
		resp.Success(w, map[string]any{
			"rating": nil,
			"has_rated": false,
		})
		return
	}

	resp.Success(w, map[string]any{
		"rating": rating,
		"has_rated": true,
	})
}

// FilterLowQualityItems godoc
// @Summary Фильтровать вещи с низким рейтингом
// @Description Исключает вещи со средним quality_score < threshold из списка кандидатов
// @Tags ratings
// @Accept json
// @Produce json
// @Param request body FilterLowQualityRequest true "Запрос на фильтрацию"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/ratings/filter-low-quality [post]
func (h *RatingHandler) FilterLowQualityItems(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	defer r.Body.Close()

	var req struct {
		CandidateIDs []domain.ID `json:"candidate_ids"` // ID кандидатов
		Threshold    *float64    `json:"threshold"`     // Порог quality_score (по умолчанию -5)
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("некорректный формат запроса"))
		return
	}

	threshold := -5.0
	if req.Threshold != nil {
		threshold = *req.Threshold
	}

	filteredIDs, err := h.svc.FilterLowQualityItems(r.Context(), userID, req.CandidateIDs, threshold)
	if err != nil {
		h.logger.Error("Не удалось отфильтровать вещи с низким рейтингом", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("не удалось отфильтровать вещи"))
		return
	}

	resp.Success(w, map[string]any{
		"original_count": len(req.CandidateIDs),
		"filtered_count": len(filteredIDs),
		"filtered_out":   len(req.CandidateIDs) - len(filteredIDs),
		"candidate_ids":  filteredIDs,
	})
}

// HasRated godoc
// @Summary Проверить, оценил ли пользователь рекомендацию
// @Description Возвращает true если пользователь уже оценил указанную рекомендацию
// @Tags ratings
// @Produce json
// @Param id path string true "ID рекомендации"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/recommendations/{id}/has-rated [get]
func (h *RatingHandler) HasRated(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("некорректный ID рекомендации"))
		return
	}

	hasRated, err := h.svc.HasUserRated(r.Context(), userID, id)
	if err != nil {
		h.logger.Error("Не удалось проверить наличие оценки", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("не удалось проверить оценку"))
		return
	}

	resp.Success(w, map[string]any{
		"has_rated": hasRated,
	})
}

// GetLowQualityItemsForML godoc
// @Summary Получить вещи с низким рейтингом для ML
// @Description Возвращает список ID вещей с низким рейтингом для исключения из ML рекомендаций
// @Tags ratings
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/ratings/low-quality-items [get]
func (h *RatingHandler) GetLowQualityItemsForML(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	itemIDs, err := h.svc.GetLowQualityItemsForML(r.Context(), userID)
	if err != nil {
		h.logger.Error("Не удалось получить вещи с низким рейтингом", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("не удалось получить вещи"))
		return
	}

	resp.Success(w, map[string]any{
		"low_quality_items": itemIDs,
		"count":             len(itemIDs),
	})
}

// GetUserRatingsForRecommendations godoc
// @Summary Получить оценки пользователя для списка рекомендаций
// @Description Возвращает мапу ID рекомендаций → оценка пользователя
// @Tags ratings
// @Accept json
// @Produce json
// @Param request body GetUserRatingsRequest true "Запрос оценок"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/v1/ratings/bulk [post]
func (h *RatingHandler) GetUserRatingsForRecommendations(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("требуется аутентификация"))
		return
	}

	defer r.Body.Close()

	var req struct {
		RecommendationIDs []string `json:"recommendation_ids"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("некорректный формат запроса"))
		return
	}

	// Парсим ID рекомендаций
	recIDs := make([]domain.ID, 0, len(req.RecommendationIDs))
	for _, idStr := range req.RecommendationIDs {
		id, err := domain.ParseID(idStr)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, errors.New("некорректный ID рекомендации: "+idStr))
			return
		}
		recIDs = append(recIDs, id)
	}

	ratings, err := h.svc.GetUserRatingsForRecommendations(r.Context(), userID, recIDs)
	if err != nil {
		h.logger.Error("Не удалось получить оценки пользователя", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("не удалось получить оценки"))
		return
	}

	// Конвертируем в map[string]int для JSON ответа
	ratingsMap := make(map[string]int)
	for recID, rating := range ratings {
		ratingsMap[recID.String()] = rating
	}

	resp.Success(w, map[string]any{
		"ratings": ratingsMap,
	})
}

// GetUserRatingsRequest запрос на получение оценок
type GetUserRatingsRequest struct {
	RecommendationIDs []string `json:"recommendation_ids"`
}

// FilterLowQualityRequest запрос на фильтрацию вещей с низким рейтингом
type FilterLowQualityRequest struct {
	CandidateIDs []domain.ID `json:"candidate_ids"`
	Threshold    *float64    `json:"threshold"`
}
