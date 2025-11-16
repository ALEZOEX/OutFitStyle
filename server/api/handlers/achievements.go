package handlers

import (
	"log"
	"net/http"
	"strconv"

	"outfitstyle/server/api/services"
	"outfitstyle/server/api/utils"
)

type AchievementHandler struct {
	dbService *services.DBService
}

func NewAchievementHandler(db *services.DBService) *AchievementHandler {
	return &AchievementHandler{dbService: db}
}

// GetAchievements - GET /api/achievements?user_id=1
func (h *AchievementHandler) GetAchievements(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		utils.JSONError(w, "Invalid user_id", http.StatusBadRequest)
		return
	}

	if h.dbService == nil {
		utils.JSONError(w, "Database unavailable", http.StatusServiceUnavailable)
		return
	}

	// Получаем все достижения с прогрессом пользователя
	achievements, err := h.getUserAchievements(userID)
	if err != nil {
		log.Printf("❌ Error getting achievements: %v", err)
		utils.JSONError(w, "Failed to get achievements", http.StatusInternalServerError)
		return
	}

	utils.JSONResponse(w, achievements, http.StatusOK)
}

// getUserAchievements получает все достижения с прогрессом пользователя
func (h *AchievementHandler) getUserAchievements(userID int) ([]map[string]interface{}, error) {
	query := `
		SELECT 
			ad.id,
			ad.name,
			ad.description,
			ad.icon,
			ad.required_count,
			COALESCE(ua.progress, 0) as current_count,
			ua.unlocked_at
		FROM achievement_definitions ad
		LEFT JOIN user_achievements ua ON ad.id = ua.achievement_id AND ua.user_id = $1
		ORDER BY ua.unlocked_at DESC NULLS LAST, ad.id
	`

	rows, err := h.dbService.DB().Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var achievements []map[string]interface{}
	for rows.Next() {
		var (
			id, name, description, icon string
			requiredCount, currentCount int
			unlockedAt                  interface{}
		)

		if err := rows.Scan(&id, &name, &description, &icon, &requiredCount, &currentCount, &unlockedAt); err != nil {
			log.Printf("⚠️ Error scanning achievement row: %v", err)
			continue
		}

		achievement := map[string]interface{}{
			"id":             id,
			"name":           name,
			"description":    description,
			"icon":           icon,
			"required_count": requiredCount,
			"current_count":  currentCount,
			"unlocked_at":    unlockedAt,
		}
		achievements = append(achievements, achievement)
	}

	return achievements, nil
}