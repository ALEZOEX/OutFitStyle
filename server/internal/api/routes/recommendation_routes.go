package routes

import (
	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/handlers"
)

// RegisterRecommendationRoutes registers recommendation-related routes
func RegisterRecommendationRoutes(router *mux.Router, recommendationHandler *handlers.RecommendationHandler) {
	recommendations := router.PathPrefix("/api/recommendations").Subrouter()

	recommendations.HandleFunc("", recommendationHandler.GetRecommendations).Methods("GET")
	recommendations.HandleFunc("/history", recommendationHandler.GetRecommendationHistory).Methods("GET")
	recommendations.HandleFunc("/{id:[0-9]+}", recommendationHandler.GetRecommendationByID).Methods("GET")
	recommendations.HandleFunc("/{id:[0-9]+}/rate", recommendationHandler.RateRecommendation).Methods("POST")
	recommendations.HandleFunc("/{id:[0-9]+}/favorite", recommendationHandler.AddFavorite).Methods("POST")
	recommendations.HandleFunc("/{id:[0-9]+}/favorite", recommendationHandler.RemoveFavorite).Methods("DELETE")

	// User favorites
	router.HandleFunc("/api/users/{user_id:[0-9]+}/favorites", recommendationHandler.GetUserFavorites).Methods("GET")
}
