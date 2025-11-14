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
	weatherService *services.WeatherService
	mlService      *services.MLService
	dbService      *services.DBService
}

func NewRecommendationHandler(ws *services.WeatherService, ml *services.MLService, db *services.DBService) *RecommendationHandler {
	return &RecommendationHandler{
		weatherService: ws,
		mlService:      ml,
		dbService:      db,
	}
}

func (h *RecommendationHandler) GetRecommendations(w http.ResponseWriter, r *http.Request) {
	city := r.URL.Query().Get("city")
	if city == "" {
		utils.JSONError(w, "Параметр city обязателен", http.StatusBadRequest)
		return
	}

	userIDStr := r.URL.Query().Get("user_id")
	userID := 1
	if userIDStr != "" {
		if id, err := strconv.Atoi(userIDStr); err == nil {
			userID = id
		}
	}

	log.Printf("📍 Request: city=%s, user_id=%d", city, userID)

	weather, err := h.weatherService.GetWeather(city)
	if err != nil {
		log.Printf("❌ Weather API error: %v", err)
		utils.JSONError(w, "Не удалось получить данные о погоде", http.StatusInternalServerError)
		return
	}

	log.Printf("🌤 Weather: %s, %.1f°C (%s)", weather.Location, weather.Temperature, weather.Weather)

	mlResp, err := h.mlService.GetRecommendations(userID, weather)
	if err != nil {
		log.Printf("⚠️ ML service error: %v, using fallback", err)
		recommendation := h.generateFallbackRecommendation(weather)
		utils.JSONResponse(w, recommendation, http.StatusOK)
		return
	}

	recommendation := &models.Recommendation{
		Location:    weather.Location,
		Temperature: weather.Temperature,
		Weather:     weather.Weather,
		Message:     h.generateMessage(weather, mlResp.Recommendations),
		Items:       mlResp.Recommendations,
		Humidity:    weather.Humidity,
		WindSpeed:   weather.WindSpeed,
		MLPowered:   mlResp.MLPowered,
		OutfitScore: &mlResp.OutfitScore,
		Algorithm:   mlResp.Algorithm,
	}

	utils.JSONResponse(w, recommendation, http.StatusOK)
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
	limit := 20
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 && l <= 100 {
			limit = l
		}
	}

	if h.dbService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	recommendations, err := h.dbService.GetUserRecommendations(userID, limit)
	if err != nil {
		log.Printf("❌ DB error: %v", err)
		utils.JSONError(w, "Ошибка получения истории", http.StatusInternalServerError)
		return
	}

	utils.JSONResponse(w, map[string]interface{}{
		"user_id":         userID,
		"recommendations": recommendations,
		"count":           len(recommendations),
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

	if h.dbService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	recommendation, err := h.dbService.GetRecommendation(id)
	if err != nil {
		log.Printf("❌ DB error: %v", err)
		utils.JSONError(w, "Рекомендация не найдена", http.StatusNotFound)
		return
	}

	utils.JSONResponse(w, recommendation, http.StatusOK)
}

func (h *RecommendationHandler) generateMessage(weather *models.WeatherData, items []models.ClothingItem) string {
	temp := weather.Temperature
	var message string

	switch {
	case temp < -10:
		message = "🥶 Экстремальный холод! Одевайтесь максимально тепло!"
	case temp < 0:
		message = "❄️ Морозно! Зимняя одежда обязательна"
	case temp < 10:
		message = "🧥 Прохладно. Демисезонная одежда"
	case temp < 18:
		message = "🍂 Комфортная температура. Легкая куртка"
	case temp < 25:
		message = "☀️ Приятная погода! Легкая одежда"
	default:
		message = "🔥 Жарко! Летняя одежда"
	}

	weatherLower := weather.Weather
	if weatherLower == "Дождь" || weatherLower == "Морось" {
		message += " ☔ Возьмите зонт!"
	} else if weatherLower == "Снег" {
		message += " ❄️ Идет снег!"
	}

	if weather.WindSpeed > 10 {
		message += " 💨 Сильный ветер!"
	}

	return message
}

func (h *RecommendationHandler) generateFallbackRecommendation(weather *models.WeatherData) *models.Recommendation {
	temp := weather.Temperature
	var items []models.ClothingItem

	switch {
	case temp < -10:
		items = []models.ClothingItem{
			{Name: "Пуховик", Category: "outerwear", IconEmoji: "🧥"},
			{Name: "Термобелье", Category: "upper", IconEmoji: "👕"},
			{Name: "Зимние ботинки", Category: "footwear", IconEmoji: "👢"},
			{Name: "Шапка", Category: "accessories", IconEmoji: "🧢"},
			{Name: "Перчатки", Category: "accessories", IconEmoji: "🧤"},
		}
	case temp < 0:
		items = []models.ClothingItem{
			{Name: "Зимняя куртка", Category: "outerwear", IconEmoji: "🧥"},
			{Name: "Свитер", Category: "upper", IconEmoji: "👕"},
			{Name: "Джинсы", Category: "lower", IconEmoji: "👖"},
			{Name: "Ботинки", Category: "footwear", IconEmoji: "👞"},
		}
	case temp < 10:
		items = []models.ClothingItem{
			{Name: "Демисезонная куртка", Category: "outerwear", IconEmoji: "🧥"},
			{Name: "Толстовка", Category: "upper", IconEmoji: "👕"},
			{Name: "Джинсы", Category: "lower", IconEmoji: "👖"},
			{Name: "Кроссовки", Category: "footwear", IconEmoji: "👟"},
		}
	case temp < 18:
		items = []models.ClothingItem{
			{Name: "Легкая куртка", Category: "outerwear", IconEmoji: "🧥"},
			{Name: "Рубашка", Category: "upper", IconEmoji: "👔"},
			{Name: "Брюки", Category: "lower", IconEmoji: "👖"},
			{Name: "Кроссовки", Category: "footwear", IconEmoji: "👟"},
		}
	case temp < 25:
		items = []models.ClothingItem{
			{Name: "Футболка", Category: "upper", IconEmoji: "👕"},
			{Name: "Джинсы", Category: "lower", IconEmoji: "👖"},
			{Name: "Кроссовки", Category: "footwear", IconEmoji: "👟"},
		}
	default:
		items = []models.ClothingItem{
			{Name: "Майка", Category: "upper", IconEmoji: "👕"},
			{Name: "Шорты", Category: "lower", IconEmoji: "🩳"},
			{Name: "Сандалии", Category: "footwear", IconEmoji: "👡"},
		}
	}

	if weather.Weather == "Дождь" || weather.Weather == "Морось" {
		items = append(items, models.ClothingItem{
			Name:      "Зонт",
			Category:  "accessories",
			IconEmoji: "☂️",
		})
	}

	return &models.Recommendation{
		Location:    weather.Location,
		Temperature: weather.Temperature,
		Weather:     weather.Weather,
		Message:     h.generateMessage(weather, items),
		Items:       items,
		Humidity:    weather.Humidity,
		WindSpeed:   weather.WindSpeed,
		MLPowered:   false,
		Algorithm:   "rule_based_fallback",
	}
}
