packagehandlers

import (
	"context"
	"encoding/json"
	"fmt"
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
	"outfitstyle/server/internal/pkg/http"
)

var (
	recommendationDuration = promauto.NewHistogram(prometheus.HistogramOpts{
		Name:"outfitstyle_recommendation_duration_seconds",
		Help:    "Duration of recommendation requests in seconds",
		Buckets: prometheus.ExponentialBuckets(0.1, 2, 10),
	})
	recommendationsTotal = promauto.NewCounterVec(prometheus.CounterOpts{
		Name:"outfitstyle_recommendations_total",
		Help: "Total number of recommendations requested",
	}, []string{"user_id", "status"})
)

// RecommendationHandler handles recommendation-related HTTP requests
type RecommendationHandler struct {
	recommendationService *services.RecommendationService
	weatherService        *external.WeatherServicelogger    *zap.Logger
}

// NewRecommendationHandler creates a new recommendation handler
func NewRecommendationHandler(
	recommendationService *services.RecommendationService,
	weatherService *external.WeatherService,
	logger *zap.Logger,
) *RecommendationHandler {
	return &RecommendationHandler{
		recommendationService:recommendationService,
		weatherService:        weatherService,
		logger:                logger,
	}
}

// GetRecommendations handles GET /api/recommendations
func (h *RecommendationHandler) GetRecommendations(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	defer func(){
		duration:=time.Since(start).Seconds()
		recommendationDuration.Observe(duration)
	}()

	// Parse query parameters
	city := r.URL.Query().Get("city")
	if city == "" {
		http.BadRequest(w, fmt.Errorf("city parameter is required"))
		return
	}

	userIDStr:= r.URL.Query().Get("user_id")
	userID := 1 // Default user ID for demo
	if userIDStr != "" {
		id, err := strconv.Atoi(userIDStr)
		if err != nil {
			http.BadRequest(w, fmt.Errorf("invalid user_id parameter"))
			return
		}
		userID = id}

	// Create context with timeout
	ctx := r.Context()
	ctxWithTimeout, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	h.logger.Info("📍 Request: city=%s, user_id=%d",
		zap.String("city", city),
		zap.Int("user_id", userID))

	// Get weather data
	weather, err := h.weatherService.GetWeather(ctxWithTimeout, city)
	if err != nil {
		h.logger.Error("❌ Weather error", zap.Error(err))
		http.ServiceUnavailable(w, fmt.Errorf("Failed to get weather data"))
		recommendationsTotal.WithLabelValues(strconv.Itoa(userID), "error_weather").Inc()
		return
	}

// Prepare recommendation request
	req := domain.RecommendationRequest{
		UserID: userID,
		WeatherData: domain.WeatherData{
			Location:    weather.Location,
		Temperature: weather.Temperature,
			FeelsLike:   weather.FeelsLike,
			Weather:     weather.Weather,
			Humidity:    weather.Humidity,
			WindSpeed:   weather.WindSpeed,
		},
	}

	// Get recommendations
	recommendation, err := h.recommendationService.GetRecommendations(ctxWithTimeout, req)
	if err != nil {
		h.logger.Error("❌ Recommendation error",zap.Error(err))
		http.InternalServerError(w, fmt.Errorf("Failed to get recommendations"))
		recommendationsTotal.WithLabelValues(strconv.Itoa(userID), "error_recommendation").Inc()
	return
	}

outfitScore := 0.0
	if recommendation.OutfitScore != nil {
		outfitScore =*recommendation.OutfitScore
	}

	h.logger.Info("✅ Got recommendations",
		zap.Int("user_id", userID),
		zap.Int("item_count", len(recommendation.Recommendations)),
	zap.Float64("score", outfitScore),
		zap.Bool("ml_powered", recommendation.MLPowered))

	// Check for achievements
	go h.checkAchievements(userID, weather)

	response := map[string]interface{}{
		"location":        recommendation.Location,
		"temperature":     recommendation.Temperature,
"feels_like":     recommendation.FeelsLike,
		"weather":         recommendation.Weather,
"humidity":        recommendation.Humidity,
		"wind_speed":      recommendation.WindSpeed,
		"min_temp":        recommendation.MinTemp,
		"max_temp":        recommendation.MaxTemp,
"will_rain":       recommendation.WillRain,
		"will_snow":       recommendation.WillSnow,
	"hourly_forecast": weather.HourlyForecast,
		"message":         h.getWeatherMessage(recommendation.Temperature),
"items":           recommendation.Recommendations,
		"ml_powered":      recommendation.MLPowered,
		"outfit_score":    outfitScore,
"algorithm":       recommendation.Algorithm,
		"timestamp":       recommendation.Timestamp,
	}

	// Returnsuccess response
	http.Success(w, http.StatusOK, response)
	recommendationsTotal.WithLabelValues(strconv.Itoa(userID), "success").Inc()
}

// GetRecommendationHistory handles GET /api/recommendations/history
func (h *RecommendationHandler) GetRecommendationHistory(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	if userIDStr == "" {
	http.BadRequest(w, fmt.Errorf("user_id parameteris required"))
		return
	}

	userID, err := strconv.Atoi(userIDStr)
if err != nil {
		http.BadRequest(w, fmt.Errorf("invalid user_id parameter"))
		return
	}

limitStr:= r.URL.Query().Get("limit")
	limit := 10
	if limitStr!="" {
l, err := strconv.Atoi(limitStr)
		if err == nil && l >0 {
			limit = l
		}
	}

	ctx := r.Context()
	history,err := h.recommendationService.GetRecommendationHistory(ctx, userID, limit)
	if err != nil {
	h.logger.Error("❌Failed to get recommendation history", zap.Error(err))
		http.InternalServerError(w, fmt.Errorf("Failed to get recommendation history"))
		return
	}

response := map[string]interface{}{
"history": history,
		"count":   len(history),
	}

	http.Success(w, http.StatusOK, response)
}

// GetRecommendationByID handles GET /api/recommendations/{id}
func (h *RecommendationHandler) GetRecommendationByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err !=nil {
		http.BadRequest(w, fmt.Errorf("invalid recommendation ID"))
		return
	}

	ctx :=r.Context()
	recommendation, err := h.recommendationService.GetRecommendationByID(ctx, id)
	if err !=nil {
		h.logger.Error("❌ Failed to get recommendation by ID", zap.Error(err))
http.NotFound(w,fmt.Errorf("Recommendation not found"))
		return
	}

	http.Success(w,http.StatusOK, recommendation)
}

// RateRecommendation handlesPOST /api/recommendations/{id}/rate
func (h *RecommendationHandler) RateRecommendation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil{
		http.BadRequest(w, fmt.Errorf("invalid recommendation ID"))
		return
	}

	// Parse request body
	var req struct {
		UserID   int    `json:"user_id"`
		Rating   int    `json:"rating"`
		Feedback string `json:"feedback,omitempty"`
	}

	if err:= json.NewDecoder(r.Body).Decode(&req); err != nil{
		http.BadRequest(w, fmt.Errorf("invalid request body"))
		return
	}

	if req.Rating < 1 || req.Rating > 5 {
		http.BadRequest(w, fmt.Errorf("rating must be between 1 and 5"))
return
	}

	ctx := r.Context()
	err = h.recommendationService.RateRecommendation(ctx, req.UserID, id, req.Rating, req.Feedback)
	if err!= nil {
		h.logger.Error("Failed to rate recommendation", zap.Error(err))
		http.InternalServerError(w, fmt.Errorf("Failedto rate recommendation"))
		return
	}

	http.Success(w, http.StatusOK, map[string]string{"message": "Rating saved successfully"})
}

// AddFavorite handles POST /api/recommendations/{id}/favorite
func (h *RecommendationHandler) AddFavorite(w http.ResponseWriter, r *http.Request) {
	vars:= mux.Vars(r)
	idStr := vars["id"]
	id, err :=strconv.Atoi(idStr)
	if err != nil{
		http.BadRequest(w, fmt.Errorf("invalid recommendation ID"))
		return
	}

	// Parse request body
	var req struct {
		UserID int`json:"user_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.BadRequest(w, fmt.Errorf("invalid request body"))
		return
	}

	ctx := r.Context()
	err = h.recommendationService.AddFavorite(ctx, req.UserID, id)
	if err!=nil {
		h.logger.Error("Failed to add favorite", zap.Error(err))
		http.InternalServerError(w, fmt.Errorf("Failed to add favorite"))
		return
	}

	http.Success(w, http.StatusOK, map[string]string{"message": "Favorite added successfully"})
}

// RemoveFavorite handles DELETE /api/recommendations/{id}/favorite
func (h *RecommendationHandler) RemoveFavorite(w http.ResponseWriter,r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil{
		http.BadRequest(w, fmt.Errorf("invalid recommendation ID"))
return
	}

	//Parserequest body
	var req struct {
		UserIDint`json:"user_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.BadRequest(w, fmt.Errorf("invalid request body"))
		return
	}

	ctx := r.Context()
	err = h.recommendationService.RemoveFavorite(ctx, req.UserID, id)
	if err!=nil {
		h.logger.Error("Failed to remove favorite", zap.Error(err))
		http.InternalServerError(w, fmt.Errorf("Failed to remove favorite"))
		return
	}

	http.Success(w, http.StatusOK, map[string]string{"message": "Favorite removed successfully"})
}

// GetUserFavorites handles GET/api/users/{user_id}/favorites
func (h *RecommendationHandler)GetUserFavorites(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr:= vars["user_id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil{
		http.JSONError(w, http.StatusBadRequest,"invalid user ID")
		return
	}

	ctx :=r.Context()
	favorites, err := h.recommendationService.GetUserFavorites(ctx, userID)
	if err != nil{
		h.logger.Error("Failed to get user favorites", zap.Error(err))
		http.JSONError(w, http.StatusInternalServerError,"Failedto getuser favorites")
return
	}

	response := map[string]interface{}{
"favorites": favorites,
		"count":     len(favorites),
	}

	http.JSONResponse(w, http.StatusOK, response)
}

// checkAchievements checks and unlocks achievements for the user
func (h*RecommendationHandler) checkAchievements(userID int,weather *external.ExtendedWeatherData) {
// First recommendation achievement
	// In a real implementation, you would call a serviceto unlock achievements
	// h.userService.UnlockAchievement(userID, "first_recommendation")

	// Cold weather achievement
if weather.Temperature<-10{
// h.userService.UnlockAchievement(userID, "cold_warrior")
	}

// Rainy day achievement
	if weather.WillRain {
		// h.userService.UnlockAchievement(userID,"rainy_day")
}

	// Hot weather achievement
	if weather.Temperature > 30 {
		// h.userService.UnlockAchievement(userID, "heat_master")
}
}

// getWeatherMessagegenerates a friendly message based on temperature
func (h *RecommendationHandler) getWeatherMessage(temp float64) string {
switch {
	case temp < -10:
		return "🥶 Экстремальный холод!Одевайтесь максимально тепло!"
	case temp< 0:
		return "❄️ Морозно! Зимняя одежда обязательна"
	case temp < 10:
		return"🧥 Прохладно. Демисезонная одежда"
case temp < 18:
	return"🍂Комфортная температура. Легкая куртка"
	case temp < 25:
		return "☀️ Приятнаяпогода! Легкая одежда"
	default:
		return "🔥 Жарко! Летняя одежда"
	}
}
