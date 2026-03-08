package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
)

// SessionHandler обработчик для управления сессиями
type SessionHandler struct {
	sessionService *services.SessionService
	logger         *zap.Logger
}

// NewSessionHandler создает новый обработчик сессий
func NewSessionHandler(sessionService *services.SessionService, logger *zap.Logger) *SessionHandler {
	return &SessionHandler{
		sessionService: sessionService,
		logger:         logger,
	}
}

// ListSessions возвращает список всех активных сессий пользователя
// @Summary Список сессий пользователя
// @Description Возвращает список всех активных сессий текущего пользователя
// @Tags sessions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]interface{} "sessions: список сессий"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/v1/sessions [get]
func (h *SessionHandler) ListSessions(c *gin.Context) {
	// Получаем userID и sessionID из контекста (установлены middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	sessionID, _ := c.Get("sessionID")

	uid, ok := userID.(domain.ID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var currentSessionID *domain.ID
	if sid, ok := sessionID.(domain.ID); ok {
		currentSessionID = &sid
	}

	sessions, err := h.sessionService.ListUserSessions(c.Request.Context(), uid, currentSessionID)
	if err != nil {
		h.logger.Error("Failed to list sessions", zap.Error(err))
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve sessions"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"sessions": sessions,
		"config": gin.H{
			"idle_timeout_minutes":    h.sessionService.GetSessionConfig().IdleTimeout.Minutes(),
			"absolute_timeout_hours":  h.sessionService.GetSessionConfig().AbsoluteTimeout.Hours(),
			"max_concurrent_sessions": h.sessionService.GetSessionConfig().MaxConcurrentSessions,
		},
	})
}

// RevokeSessionRequest запрос на отзыв сессии
type RevokeSessionRequest struct {
	SessionID string `json:"session_id" binding:"required"`
}

// RevokeSession отзывает конкретную сессию
// @Summary Отозвать сессию
// @Description Отзывает конкретную сессию пользователя по ID
// @Tags sessions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body RevokeSessionRequest true "Session ID"
// @Success 200 {object} map[string]string "message: Session revoked successfully"
// @Failure 400 {object} map[string]string "Invalid request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 403 {object} map[string]string "Forbidden"
// @Failure 404 {object} map[string]string "Session not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/v1/sessions/revoke [post]
func (h *SessionHandler) RevokeSession(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, ok := userID.(domain.ID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var req RevokeSessionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	sessionID, err := domain.ParseID(req.SessionID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid session ID"})
		return
	}

	if err := h.sessionService.RevokeSession(c.Request.Context(), uid, sessionID); err != nil {
		if err == services.ErrSessionNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Session not found"})
			return
		}
		if err == services.ErrUnauthorizedRevoke {
			c.JSON(http.StatusForbidden, gin.H{"error": "Forbidden"})
			return
		}
		h.logger.Error("Failed to revoke session", zap.Error(err))
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to revoke session"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Session revoked successfully"})
}

// RevokeAllSessions отзывает все сессии пользователя кроме текущей
// @Summary Отозвать все сессии
// @Description Отзывает все сессии пользователя кроме текущей
// @Tags sessions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]string "message: All sessions revoked successfully"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/v1/sessions/revoke-all [post]
func (h *SessionHandler) RevokeAllSessions(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	sessionID, _ := c.Get("sessionID")

	uid, ok := userID.(domain.ID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var currentSessionID *domain.ID
	if sid, ok := sessionID.(domain.ID); ok {
		currentSessionID = &sid
	}

	if err := h.sessionService.RevokeAllSessions(c.Request.Context(), uid, currentSessionID); err != nil {
		h.logger.Error("Failed to revoke all sessions", zap.Error(err))
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to revoke sessions"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "All sessions revoked successfully"})
}
