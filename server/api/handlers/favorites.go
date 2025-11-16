package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"outfitstyle/server/api/services"
	"outfitstyle/server/api/utils"
)

type FavoriteHandler struct {
	dbService *services.DBService
}

func NewFavoriteHandler(dbs *services.DBService) *FavoriteHandler {
	return &FavoriteHandler{dbService: dbs}
}

// AddFavorite - POST /api/favorites
func (h *FavoriteHandler) AddFavorite(w http.ResponseWriter, r *http.Request) {
	var payload struct {
		UserID           int `json:"user_id"`
		RecommendationID int `json:"recommendation_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	favoriteID, err := h.dbService.AddFavorite(payload.UserID, payload.RecommendationID)
	if err != nil {
		log.Printf("❌ Error adding favorite: %v", err)
		http.Error(w, "Failed to add favorite", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":      "success",
		"message":     "Outfit added to favorites",
		"favorite_id": favoriteID,
	})
}

// GetFavorites - GET /api/favorites?user_id=1
func (h *FavoriteHandler) GetFavorites(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		http.Error(w, "Invalid user_id", http.StatusBadRequest)
		return
	}

	favorites, err := h.dbService.GetFavoritesByUserID(userID)
	if err != nil {
		log.Printf("❌ Error getting favorites: %v", err)
		http.Error(w, "Failed to get favorites", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	utils.JSONResponse(w, favorites, http.StatusOK)
}

// DeleteFavorite - DELETE /api/favorites/{id}
func (h *FavoriteHandler) DeleteFavorite(w http.ResponseWriter, r *http.Request) {
	favoriteIDStr := r.URL.Query().Get("id")
	favoriteID, err := strconv.Atoi(favoriteIDStr)
	if err != nil {
		http.Error(w, "Invalid favorite id", http.StatusBadRequest)
		return
	}

	err = h.dbService.DeleteFavorite(favoriteID)
	if err != nil {
		log.Printf("❌ Error deleting favorite: %v", err)
		http.Error(w, "Failed to delete favorite", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}