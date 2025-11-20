package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
	resp "outfitstyle/server/internal/pkg/http"
)

var (
	recommendationDuration = promauto.NewHistogram(prometheus.HistogramOpts{
		Name:    "outfitstyle_recommendation_duration_seconds",
		Help:    "Duration of recommendation requests in seconds",
		Buckets: prometheus.ExponentialBuckets(0.1, 2, 10),
	})

	recommendationsTotal = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "outfitstyle_recommendations_total",
		Help: "Total number of recommendations requested",
	}, []string{"user_id", "status"})
)

// RecommendationHandler handles recommendation-related HTTP requests
type RecommendationHandler struct {
	recommendationService *services.RecommendationService
	weatherService        *external.WeatherService
	logger                *zap.Logger
}

// NewRecommendationHandler creates a new recommendation handler
func NewRecommendationHandler(
	recommendationService *services.RecommendationService,
	weatherService *external.WeatherService,
	logger *zap.Logger,
) *RecommendationHandler {
	return &RecommendationHandler{
		recommendationService: recommendationService,
		weatherService:        weatherService,
		logger:                logger,
	}
}

// GetRecommendations handles GET /api/recommendations
func (h *RecommendationHandler) GetRecommendations(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	defer func() {
		duration := time.Since(start).Seconds()
		recommendationDuration.Observe(duration)
	}()

	// Parse query parameters
	city := r.URL.Query().Get("city")
	if city == "" {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("city parameter is required"))
		return
	}

	userIDStr := r.URL.Query().Get("user_id")
	userID := 1 // Default user ID
	if userIDStr != "" {
		id, err := strconv.Atoi(userIDStr)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid user_id parameter"))
			return
		}
		userID = id
	}

	// Create context with timeout
	ctx := r.Context()
	ctxWithTimeout, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	h.logger.Info("Get recommendations request",
		zap.String("city", city),
		zap.Int("user_id", userID),
	)

	// Get weather data
	weather, err := h.weatherService.GetWeather(ctxWithTimeout, city)
	if err != nil {
		h.logger.Error("Weather error", zap.Error(err))
		resp.Error(w, http.StatusServiceUnavailable, fmt.Errorf("failed to get weather data"))
		recommendationsTotal.WithLabelValues(strconv.Itoa(userID), "error_weather").Inc()
		return
	}

	// Prepare recommendation request
	// ВАЖНО: Используем weather.WeatherData.Field, так как ExtendedWeatherData встраивает WeatherData
	req := domain.RecommendationRequest{
		UserID: domain.ID(userID),
		WeatherData: domain.WeatherData{
			Location:    weather.WeatherData.Location,
			Temperature: weather.WeatherData.Temperature,
			FeelsLike:   weather.WeatherData.FeelsLike,
			Weather:     weather.WeatherData.Weather,
			Humidity:    weather.WeatherData.Humidity,
			WindSpeed:   weather.WeatherData.WindSpeed,
			MinTemp:     weather.WeatherData.MinTemp,
			MaxTemp:     weather.WeatherData.MaxTemp,
			WillRain:    weather.WeatherData.WillRain,
			WillSnow:    weather.WeatherData.WillSnow,
		},
	}

	// Get recommendations
	recommendation, err := h.recommendationService.GetRecommendations(ctxWithTimeout, req)
	if err != nil {
		h.logger.Error("Recommendation error", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get recommendations"))
		recommendationsTotal.WithLabelValues(strconv.Itoa(userID), "error_recommendation").Inc()
		return
	}

	outfitScore := 0.0
	if recommendation.OutfitScore > 0 {
		outfitScore = recommendation.OutfitScore
	}

	h.logger.Info("Got recommendations",
		zap.Int("user_id", userID),
		zap.Int("item_count", len(recommendation.Items)), // Items, не Recommendations
		zap.Float64("score", outfitScore),
		zap.Bool("ml_powered", recommendation.MLPowered),
	)

	// Check for achievements (async)
	go h.checkAchievements(userID, weather)

	response := map[string]interface{}{
		"location":        recommendation.Location,
		"temperature":     recommendation.Temperature,
		"feels_like":      recommendation.FeelsLike,
		"weather":         recommendation.Weather,
		"humidity":        recommendation.Humidity,
		"wind_speed":      recommendation.WindSpeed,
		"min_temp":        recommendation.MinTemp,
		"max_temp":        recommendation.MaxTemp,
		"will_rain":       recommendation.WillRain,
		"will_snow":       recommendation.WillSnow,
		"hourly_forecast": weather.WeatherData.HourlyForecast,
		"message":         h.getWeatherMessage(recommendation.Temperature),
		"items":           recommendation.Items,
		"ml_powered":      recommendation.MLPowered,
		"outfit_score":    outfitScore,
		"algorithm":       recommendation.Algorithm,
		"timestamp":       recommendation.Timestamp,
	}

	resp.Success(w, response)
	recommendationsTotal.WithLabelValues(strconv.Itoa(userID), "success").Inc()
}

// GetRecommendationHistory handles GET /api/recommendations/history
func (h *RecommendationHandler) GetRecommendationHistory(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	if userIDStr == "" {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("user_id parameter is required"))
		return
	}

	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid user_id parameter"))
		return
	}

	limit := 10
	if limitStr := r.URL.Query().Get("limit"); limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 {
			limit = l
		}
	}

	ctx := r.Context()
	history, err := h.recommendationService.GetRecommendationHistory(ctx, userID, limit)
	if err != nil {
		h.logger.Error("Failed to get recommendation history", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get recommendation history"))
		return
	}

	response := map[string]interface{}{
		"history": history,
		"count":   len(history),
	}

	resp.Success(w, response)
}

// GetRecommendationByID handles GET /api/recommendations/{id}
func (h *RecommendationHandler) GetRecommendationByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	id, err := strconv.Atoi(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid recommendation ID"))
		return
	}

	ctx := r.Context()
	recommendation, err := h.recommendationService.GetRecommendationByID(ctx, id)
	if err != nil {
		h.logger.Error("Failed to get recommendation by ID", zap.Error(err), zap.Int("id", id))
		resp.Error(w, http.StatusNotFound, fmt.Errorf("recommendation not found"))
		return
	}

	resp.Success(w, recommendation)
}

// RateRecommendation handles POST /api/recommendations/{id}/rate
func (h *RecommendationHandler) RateRecommendation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	id, err := strconv.Atoi(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid recommendation ID"))
		return
	}

	defer r.Body.Close()

	var req struct {
		UserID   int    `json:"user_id"`
		Rating   int    `json:"rating"`
		Feedback string `json:"feedback,omitempty"`
	}

	if !decodeJSONReq(w, r, &req) {
		return
	}

	if req.Rating < 1 || req.Rating > 5 {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("rating must be between 1 and 5"))
		return
	}

	ctx := r.Context()
	if err := h.recommendationService.RateRecommendation(ctx, req.UserID, id, req.Rating, req.Feedback); err != nil {
		h.logger.Error("Failed to rate recommendation",
			zap.Error(err),
			zap.Int("recommendation_id", id),
			zap.Int("user_id", req.UserID),
		)
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to rate recommendation"))
		return
	}

	resp.Success(w, map[string]string{"message": "Rating saved successfully"})
}

// AddFavorite handles POST /api/recommendations/{id}/favorite
func (h *RecommendationHandler) AddFavorite(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	id, err := strconv.Atoi(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid recommendation ID"))
		return
	}

	defer r.Body.Close()

	var req struct {
		UserID int `json:"user_id"`
	}

	if !decodeJSONReq(w, r, &req) {
		return
	}

	ctx := r.Context()
	if err := h.recommendationService.AddFavorite(ctx, req.UserID, id); err != nil {
		h.logger.Error("Failed to add favorite",
			zap.Error(err),
			zap.Int("recommendation_id", id),
			zap.Int("user_id", req.UserID),
		)
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to add favorite"))
		return
	}

	resp.Success(w, map[string]string{"message": "Favorite added successfully"})
}

// RemoveFavorite handles DELETE /api/recommendations/{id}/favorite
func (h *RecommendationHandler) RemoveFavorite(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	id, err := strconv.Atoi(idStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid recommendation ID"))
		return
	}

	defer r.Body.Close()

	// Для DELETE тела может не быть, берем user_id из query или тела
	// Упростим: ожидаем JSON как в AddFavorite
	var req struct {
		UserID int `json:"user_id"`
	}
	if !decodeJSONReq(w, r, &req) {
		return
	}

	ctx := r.Context()
	if err := h.recommendationService.RemoveFavorite(ctx, req.UserID, id); err != nil {
		h.logger.Error("Failed to remove favorite",
			zap.Error(err),
			zap.Int("recommendation_id", id),
			zap.Int("user_id", req.UserID),
		)
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to remove favorite"))
		return
	}

	resp.Success(w, map[string]string{"message": "Favorite removed successfully"})
}

// GetUserFavorites handles GET /api/users/{user_id}/favorites
func (h *RecommendationHandler) GetUserFavorites(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["user_id"]

	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid user ID"))
		return
	}

	ctx := r.Context()
	favorites, err := h.recommendationService.GetUserFavorites(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user favorites",
			zap.Error(err),
			zap.Int("user_id", userID),
		)
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get user favorites"))
		return
	}

	response := map[string]interface{}{
		"favorites": favorites,
		"count":     len(favorites),
	}

	resp.Success(w, response)
}

// Helper: decodeJSONReq
func decodeJSONReq(w http.ResponseWriter, r *http.Request, dst interface{}) bool {
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		log.Printf("decodeJSON error: %v", err)
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid request body"))
		return false
	}
	return true
}

// checkAchievements checks and unlocks achievements for the user
func (h *RecommendationHandler) checkAchievements(userID int, weather *external.ExtendedWeatherData) {
	// Здесь должна быть логика ачивок
	// Например:
	if weather.WeatherData.Temperature < -10 {
		h.logger.Info("Achievement unlocked: Cold Warrior", zap.Int("user_id", userID))
	}
}

// getWeatherMessage generates a friendly message based on temperature
func (h *RecommendationHandler) getWeatherMessage(temp float64) string {
	switch {
	case temp < -10:
		return "🥶 Экстремальный холод! Одевайтесь максимально тепло!"
	case temp < 0:
		return "❄️ Морозно! Зимняя одежда обязательна"
	case temp < 10:
		return "🧥 Прохладно. Демисезонная одежда"
	case temp < 18:
		return "🍂 Комфортная температура. Легкая куртка"
	case temp < 25:
		return "☀️ Приятная погода! Легкая одежда"
	default:
		return "🔥 Жарко! Летняя одежда"
	}
}
