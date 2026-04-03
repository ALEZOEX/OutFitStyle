// Пакет routes содержит функции регистрации маршрутов для различных API-эндпоинтов
// Обеспечивает централизованную настройку маршрутов приложения
package routes

import (
	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/handlers"
)

// RegisterRecommendationRoutes регистрирует маршруты, связанные с рекомендациями
// Устанавливает обработчики для эндпоинтов получения и управления рекомендациями
func RegisterRecommendationRoutes(router *mux.Router, recommendationHandler *handlers.RecommendationHandler) {
	recommendations := router.PathPrefix("/api/v1/recommendations").Subrouter()

	recommendations.HandleFunc("", recommendationHandler.List).Methods("GET")
	recommendations.HandleFunc("", recommendationHandler.Create).Methods("POST")
	recommendations.HandleFunc("/history", recommendationHandler.List).Methods("GET")
	recommendations.HandleFunc("/{id:[0-9]+}", recommendationHandler.Get).Methods("GET")
	recommendations.HandleFunc("/{id:[0-9]+}/rate", recommendationHandler.Rate).Methods("POST")
	recommendations.HandleFunc("/{id:[0-9]+}/favorite", recommendationHandler.Favorite).Methods("POST")
	recommendations.HandleFunc("/{id:[0-9]+}/favorite", recommendationHandler.Favorite).Methods("DELETE")

	// User favorites
	router.HandleFunc("/api/users/{user_id:[0-9]+}/favorites", recommendationHandler.Favorites).Methods("GET")
}
