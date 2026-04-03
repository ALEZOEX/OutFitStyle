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
	recommendations.HandleFunc("/favorites", recommendationHandler.Favorites).Methods("GET")
	recommendations.HandleFunc("/{id}", recommendationHandler.Get).Methods("GET")
	recommendations.HandleFunc("/{id}/rate", recommendationHandler.Rate).Methods("POST")
	recommendations.HandleFunc("/{id}/favorite", recommendationHandler.Favorite).Methods("POST")
	recommendations.HandleFunc("/{id}/favorite", recommendationHandler.Favorite).Methods("DELETE")
	recommendations.HandleFunc("/{id}/regenerate", recommendationHandler.Regenerate).Methods("POST")
}
