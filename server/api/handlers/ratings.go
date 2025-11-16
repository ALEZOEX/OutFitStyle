package handlers

import (
	"encoding/json"
	"log"
	"net/http"

	"outfitstyle/server/api/services"
	"outfitstyle/server/api/utils"
)

type RatingHandler struct {
	mlService *services.MLService
}

func NewRatingHandler(ml *services.MLService) *RatingHandler {
	return &RatingHandler{mlService: ml}
}

func (h *RatingHandler) RateRecommendation(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		utils.JSONError(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req services.MLRateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.JSONError(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	if req.UserID == 0 || req.RecommendationID == 0 {
		utils.JSONError(w, "user_id и recommendation_id обязательны", http.StatusBadRequest)
		return
	}

	if req.OverallRating < 1 || req.OverallRating > 5 {
		utils.JSONError(w, "overall_rating должен быть от 1 до 5", http.StatusBadRequest)
		return
	}

	err := h.mlService.RateRecommendation(req)
	if err != nil {
		log.Printf("❌ Error saving rating: %v", err)
		utils.JSONError(w, "Ошибка сохранения оценки", http.StatusInternalServerError)
		return
	}

	log.Printf("✅ Rating saved: user=%d, rec=%d, rating=%d",
		req.UserID, req.RecommendationID, req.OverallRating)

	// Проверяем достижения
	h.checkRatingAchievements(req.UserID)

	utils.JSONResponse(w, map[string]interface{}{
		"status":  "success",
		"message": "Оценка сохранена",
	}, http.StatusOK)
}

// checkRatingAchievements проверяет достижения, связанные с оценками
func (h *RatingHandler) checkRatingAchievements(userID int) {
	// TODO: Реализовать проверку достижений "Критик моды" и "Эксперт стиля"
	// Пока просто логируем
	log.Printf("Проверка достижений оценок для пользователя %d", userID)
}