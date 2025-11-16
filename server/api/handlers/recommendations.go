package handlers

import (
	"log"
	"net/http"
	"strconv"

	"outfitstyle/server/api/models"
	"outfitstyle/server/api/services"
	"outfitstyle/server/api/utils"
)

type RecommendationHandler struct {
	WeatherService *services.WeatherService
	MLService      *services.MLService
	DBService      *services.DBService
}

func NewRecommendationHandler(ws *services.WeatherService, ml *services.MLService, db *services.DBService) *RecommendationHandler {
	return &RecommendationHandler{
		WeatherService: ws,
		MLService:      ml,
		DBService:      db,
	}
}

func (h *RecommendationHandler) GetRecommendations(w http.ResponseWriter, r *http.Request) {
	city := r.URL.Query().Get("city")
	if city == "" {
		utils.JSONError(w, "city is required", http.StatusBadRequest)
		return
	}

	userIDStr := r.URL.Query().Get("user_id")
	userID := 1 // Значение по умолчанию
	if id, err := strconv.Atoi(userIDStr); err == nil {
		userID = id
	}

	log.Printf("📍 Request: city=%s, user_id=%d", city, userID)

	// Получаем погоду (реальные данные)
	weather, err := h.WeatherService.GetWeather(city)
	if err != nil {
		log.Printf("❌ Weather error: %v", err)
		utils.JSONError(w, "Failed to get weather: "+err.Error(), http.StatusServiceUnavailable)
		return
	}

	log.Printf("🌤 Weather: %s, %.1f°C (%s)", weather.Location, weather.Temperature, weather.Weather)

	// Получаем профиль пользователя
	if h.DBService != nil {
		_, err := h.DBService.GetUserProfile(userID)
		if err != nil {
			log.Printf("⚠️ Could not load user profile for user %d: %v", userID, err)
		}
	} else {
		log.Printf("⚠️ DB service unavailable, using default user profile")
	}

	// Преобразуем ExtendedWeatherData в WeatherData для ML сервиса
	weatherData := &models.WeatherData{
		Location:    weather.Location,
		Temperature: weather.Temperature,
		FeelsLike:   weather.FeelsLike,
		Weather:     weather.Weather,
		Humidity:    weather.Humidity,
		WindSpeed:   weather.WindSpeed,
	}

	// Получаем ML рекомендации
	mlRecommendations, err := h.MLService.GetRecommendations(userID, weatherData)
	if err != nil {
		utils.JSONError(w, "Failed to get ML recommendations: "+err.Error(), http.StatusInternalServerError)
		return
	}

	recommendations := make([]interface{}, len(mlRecommendations.Recommendations))
	for i, v := range mlRecommendations.Recommendations {
		recommendations[i] = v
	}
	outfitScore := mlRecommendations.OutfitScore
	mlPowered := mlRecommendations.MLPowered
	algorithm := mlRecommendations.Algorithm

	log.Printf("✅ Got %d recommendations (score: %.2f, ML: %v)",
		len(recommendations), outfitScore, mlPowered,
	)

	// Формируем ответ
	response := map[string]interface{}{
		"location":        weather.Location,
		"temperature":     weather.Temperature,
		"feels_like":      weather.FeelsLike,
		"weather":         weather.Weather,
		"humidity":        weather.Humidity,
		"wind_speed":      weather.WindSpeed,
		"min_temp":        weather.MinTemp,
		"max_temp":        weather.MaxTemp,
		"will_rain":       weather.WillRain,
		"will_snow":       weather.WillSnow,
		"hourly_forecast": weather.HourlyForecast,
		"message":         h.getWeatherMessage(weather.Temperature),
		"items":           recommendations,
		"ml_powered":      mlPowered,
		"outfit_score":    outfitScore,
		"algorithm":       algorithm,
	}

	// Проверяем достижения
	h.checkAchievements(userID, weather)

	utils.JSONResponse(w, response, http.StatusOK)
}

func (h *RecommendationHandler) GetRecommendationHistory(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	if userIDStr == "" {
		utils.JSONError(w, "Параметр user_id обязателен", http.StatusBadRequest)
		return
	}

	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		utils.JSONError(w, "Неверный user_id", http.StatusBadRequest)
		return
	}

	limitStr := r.URL.Query().Get("limit")
	limit := 20 // Значение по умолчанию
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 && l <= 100 {
			limit = l
		}
	}

	if h.DBService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	recommendations, err := h.DBService.GetUserRecommendations(userID, limit)
	if err != nil {
		log.Printf("❌ DB error: %v", err)
		utils.JSONError(w, "Ошибка получения истории", http.StatusInternalServerError)
		return
	}

	utils.JSONResponse(w, map[string]interface{}{
		"user_id": userID,
		"history": recommendations, // Изменено на "history" для соответствия Flutter-модели
		"count":   len(recommendations),
	}, http.StatusOK)
}

func (h *RecommendationHandler) GetRecommendationByID(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		utils.JSONError(w, "Параметр id обязателен", http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		utils.JSONError(w, "Неверный id", http.StatusBadRequest)
		return
	}

	if h.DBService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	recommendation, err := h.DBService.GetRecommendation(id)
	if err != nil {
		log.Printf("❌ DB error: %v", err)
		utils.JSONError(w, "Рекомендация не найдена", http.StatusNotFound)
		return
	}

	utils.JSONResponse(w, recommendation, http.StatusOK)
}

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

// checkAchievements проверяет и выдает достижения пользователю
func (h *RecommendationHandler) checkAchievements(userID int, weather *services.ExtendedWeatherData) {
	if h.DBService == nil {
		return
	}

	// Запускаем проверки в отдельной горутине, чтобы не блокировать основной запрос
	go func() {
		// TODO: Implement achievement system
		// Currently these methods don't exist in DBService
		// h.DBService.UnlockAchievement(userID, "first_recommendation")
		// h.DBService.UnlockAchievement(userID, "cold_warrior")
		// h.DBService.UnlockAchievement(userID, "rainy_day")
	}()
}