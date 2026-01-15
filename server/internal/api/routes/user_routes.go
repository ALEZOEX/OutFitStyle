package routes

import (
	"outfitstyle/server/internal/api/handlers"

	"github.com/gorilla/mux"
)

// RegisterUserRoutes registers user-related routes
func RegisterUserRoutes(router *mux.Router, userHandler *handlers.UserHandler) {
	users := router.PathPrefix("/api/users").Subrouter()
	userHandler.RegisterRoutes(users)
}
