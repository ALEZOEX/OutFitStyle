package routes

import (
	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/handlers"
)

// RegisterAuthRoutes registers authentication-related routes
func RegisterAuthRoutes(router *mux.Router, authHandler *handlers.AuthHandler) {
	auth := router.PathPrefix("/api/auth").Subrouter()

	auth.HandleFunc("/register", authHandler.Register).Methods("POST")
	auth.HandleFunc("/login", authHandler.Login).Methods("POST")
	auth.HandleFunc("/verify", authHandler.VerifyCode).Methods("POST")
	auth.HandleFunc("/refresh", authHandler.RefreshToken).Methods("POST")
	auth.HandleFunc("/logout", authHandler.Logout).Methods("POST")
	auth.HandleFunc("/forgot-password", authHandler.ForgotPassword).Methods("POST")
	auth.HandleFunc("/reset-password", authHandler.ResetPassword).Methods("POST")
	
	auth.HandleFunc("/google", authHandler.GoogleLogin).Methods("POST")
}
