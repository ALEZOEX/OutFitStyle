package routes

import (
	"github.com/gin-gonic/gin"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/middleware"
)

// RegisterSessionRoutes регистрирует маршруты для управления сессиями
func RegisterSessionRoutes(router *gin.RouterGroup, handler *handlers.SessionHandler, authMiddleware gin.HandlerFunc) {
	sessions := router.Group("/sessions")
	sessions.Use(authMiddleware) // Требуется аутентификация

	// GET /api/v1/sessions - список всех сессий пользователя
	sessions.GET("", handler.ListSessions)

	// POST /api/v1/sessions/revoke - отозвать конкретную сессию
	sessions.POST("/revoke", handler.RevokeSession)

	// POST /api/v1/sessions/revoke-all - отозвать все сессии кроме текущей
	sessions.POST("/revoke-all", handler.RevokeAllSessions)
}
