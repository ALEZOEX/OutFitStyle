// Пакет routes содержит функции регистрации маршрутов для API рейтинга рекомендаций
package routes

import (
	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/handlers"
)

// RegisterRatingRoutes регистрирует маршруты для управления рейтингом рекомендаций
func RegisterRatingRoutes(router *mux.Router, ratingHandler *handlers.RatingHandler) {
	// Роуты регистрируются относительно /api/v1/recommendations/{id}
	// RatingHandler сам определяет свои пути через RegisterRoutes
	ratingHandler.RegisterRoutes(router)
}
