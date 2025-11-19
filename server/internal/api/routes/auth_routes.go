package routes

import (
	"net/http"
	
	"github.com/gorilla/mux"
	
	"outfitstyle/server/internal/api/handlers"
)

// RegisterAuthRoutes registers authentication-related routes
func RegisterAuthRoutes(router *mux.Router, authHandler *handlers.AuthHandler) {
	// Auth subrouter
	auth := router.PathPrefix("/api/auth").Subrouter()
	
	// POST /api/auth/register - Register a new user
	auth.HandleFunc("/register", authHandler.Register).Methods("POST")
	
	// POST /api/auth/login - Login user
	auth.HandleFunc("/login", authHandler.Login).Methods("POST")
	
	// POST /api/auth/verify - Verify authentication code
	auth.HandleFunc("/verify", authHandler.VerifyCode).Methods("POST")
	
	// POST /api/auth/refresh - Refresh access token
	auth.HandleFunc("/refresh", authHandler.RefreshToken).Methods("POST")
	
	// POST /api/auth/logout - Logout user
	auth.HandleFunc("/logout", authHandler.Logout).Methods("POST")
	
	// POST /api/auth/forgot-password - Request password reset
	auth.HandleFunc("/forgot-password", authHandler.ForgotPassword).Methods("POST")
	
	// POST /api/auth/reset-password - Reset password
	auth.HandleFunc("/reset-password", authHandler.ResetPassword).Methods("POST")
}