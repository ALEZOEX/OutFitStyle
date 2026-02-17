// Пакет routes содержит функции регистрации маршрутов для различных API-эндпоинтов
// Обеспечивает централизованную настройку маршрутов приложения
package routes

import (
	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/handlers"
)

// RegisterAuthRoutes регистрирует маршруты, связанные с аутентификацией
// Устанавливает обработчики для эндпоинтов регистрации, входа и управления сессией
func RegisterAuthRoutes(router *mux.Router, authHandler *handlers.AuthHandler) {
	auth := router.PathPrefix("/api/auth").Subrouter()

	auth.HandleFunc("/register", authHandler.Register).Methods("POST")
	auth.HandleFunc("/login", authHandler.Login).Methods("POST")
	auth.HandleFunc("/verify", authHandler.VerifyCode).Methods("POST")
	auth.HandleFunc("/refresh", authHandler.RefreshToken).Methods("POST")
	auth.HandleFunc("/logout", authHandler.Logout).Methods("POST")
	auth.HandleFunc("/forgot-password", authHandler.ForgotPassword).Methods("POST")
	auth.HandleFunc("/reset-password", authHandler.ResetPassword).Methods("POST")

	// Google Sign-In - использует рабочую реализацию GoogleSignIn
	auth.HandleFunc("/google", authHandler.GoogleSignIn).Methods("POST")
}
