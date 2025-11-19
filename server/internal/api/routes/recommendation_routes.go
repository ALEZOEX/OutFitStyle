package routes

import (
	"net/http"
	
	"github.com/gorilla/mux"
	
	"outfitstyle/server/internal/api/handlers"
)

// RegisterRecommendationRoutes registers recommendation-related routes
func RegisterRecommendationRoutes(router *mux.Router, recommendationHandler *handlers.RecommendationHandler) {
	// Recommendations subrouter
	recommendations := router.PathPrefix("/api/recommendations").Subrouter()
	
	// GET /api/recommendations - Get outfit recommendations
	recommendations.HandleFunc("", recommendationHandler.GetRecommendations).Methods("GET")
	
	// GET /api/recommendations/history - Get recommendation history
	recommendations.HandleFunc("/history", recommendationHandler.GetRecommendationHistory).Methods("GET")
	
	// GET /api/recommendations/{id} - Get specific recommendation by ID
	recommendations.HandleFunc("/{id:[0-9]+}", recommendationHandler.GetRecommendationByID).Methods("GET")
	
	// POST /api/recommendations/{id}/rate - Rate a recommendation
	recommendations.HandleFunc("/{id:[0-9]+}/rate", recommendationHandler.RateRecommendation).Methods("POST")
	
	// POST /api/recommendations/{id}/favorite - Add recommendation to favorites
	recommendations.HandleFunc("/{id:[0-9]+}/favorite", recommendationHandler.AddFavorite).Methods("POST")
	
	// DELETE /api/recommendations/{id}/favorite - Remove recommendation from favorites
	recommendations.HandleFunc("/{id:[0-9]+}/favorite", recommendationHandler.RemoveFavorite).Methods("DELETE")
	
	// GET /api/users/{user_id}/favorites - Get user favorites
	recommendations.HandleFunc("/users/{user_id:[0-9]+}/favorites", recommendationHandler.GetUserFavorites).Methods("GET")
}