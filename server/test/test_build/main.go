package main

import (
	"net/http"
	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
)

func main() {
	var authService *services.AuthService
	var apiKeyService *services.APIKeyService
	
	handler := middleware.AuthMiddleware(authService, apiKeyService)
	
	// Создаем фиктивный HTTP-обработчик
	httpHandler := handler(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {}))
	
	// Проверяем, что все компилируется
	_ = httpHandler
}