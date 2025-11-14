package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"outfitstyle/server/api/models"
	"outfitstyle/server/api/services"
	"outfitstyle/server/api/utils"
)

type UserHandler struct {
	dbService *services.DBService
}

func NewUserHandler(db *services.DBService) *UserHandler {
	return &UserHandler{dbService: db}
}

func (h *UserHandler) GetProfile(w http.ResponseWriter, r *http.Request) {
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

	if h.dbService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	user, err := h.dbService.GetUser(userID)
	if err != nil {
		log.Printf("❌ User not found: %v", err)
		utils.JSONError(w, "Пользователь не найден", http.StatusNotFound)
		return
	}

	profile, err := h.dbService.GetUserProfile(userID)
	if err != nil {
		log.Printf("⚠️ Profile not found: %v", err)
		utils.JSONResponse(w, map[string]interface{}{
			"user":    user,
			"profile": nil,
		}, http.StatusOK)
		return
	}

	utils.JSONResponse(w, map[string]interface{}{
		"user":    user,
		"profile": profile,
	}, http.StatusOK)
}

func (h *UserHandler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut && r.Method != http.MethodPost {
		utils.JSONError(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var profile models.UserProfile
	if err := json.NewDecoder(r.Body).Decode(&profile); err != nil {
		utils.JSONError(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	if profile.UserID == 0 {
		utils.JSONError(w, "user_id обязателен", http.StatusBadRequest)
		return
	}

	if h.dbService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	existing, err := h.dbService.GetUserProfile(profile.UserID)

	if err != nil {
		err = h.dbService.CreateUserProfile(&profile)
		if err != nil {
			log.Printf("❌ Error creating profile: %v", err)
			utils.JSONError(w, "Ошибка создания профиля", http.StatusInternalServerError)
			return
		}
		log.Printf("✅ Created profile for user %d", profile.UserID)
	} else {
		profile.ID = existing.ID
		err = h.dbService.UpdateUserProfile(&profile)
		if err != nil {
			log.Printf("❌ Error updating profile: %v", err)
			utils.JSONError(w, "Ошибка обновления профиля", http.StatusInternalServerError)
			return
		}
		log.Printf("✅ Updated profile for user %d", profile.UserID)
	}

	utils.JSONResponse(w, map[string]interface{}{
		"status":  "success",
		"message": "Профиль сохранен",
		"profile": profile,
	}, http.StatusOK)
}

func (h *UserHandler) GetStats(w http.ResponseWriter, r *http.Request) {
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

	if h.dbService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	stats, err := h.dbService.GetUserStats(userID)
	if err != nil {
		log.Printf("❌ Error getting stats: %v", err)
		utils.JSONError(w, "Ошибка получения статистики", http.StatusInternalServerError)
		return
	}

	utils.JSONResponse(w, stats, http.StatusOK)
}
