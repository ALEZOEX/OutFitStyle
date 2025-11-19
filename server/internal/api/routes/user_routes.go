фpackage routes

import (
	"net/http"
	
	"github.com/gorilla/mux"
	
	"outfitstyle/server/internal/api/handlers"
)

// RegisterUserRoutes registers user-related routes
func RegisterUserRoutes(router *mux.Router, userHandler *handlers.UserHandler) {
	// Users subrouter
	users := router.PathPrefix("/api/users").Subrouter()
	
	// GET /api/users/{id}/profile - Get user profile
	users.HandleFunc("/{id:[0-9]+}/profile", userHandler.GetUserProfile).Methods("GET")
	
	// PUT /api/users/{id}/profile - Update user profile
	users.HandleFunc("/{id:[0-9]+}/profile", userHandler.UpdateUserProfile).Methods("PUT")
	
	// GET /api/users/{id}/achievements - Get user achievements
	users.HandleFunc("/{id:[0-9]+}/achievements", userHandler.GetUserAchievements).Methods("GET")
	
	// GET /api/users/{id}/ratings - Get user ratings
	users.HandleFunc("/{id:[0-9]+}/ratings", userHandler.GetUserRatings).Methods("GET")
	
	// POST /api/users/{id}/outfit-plans - Create outfit plan
	users.HandleFunc("/{id:[0-9]+}/outfit-plans", userHandler.CreateOutfitPlan).Methods("POST")
	
	// GET /api/users/{id}/outfit-plans - Get user outfit plans
	users.HandleFunc("/{id:[0-9]+}/outfit-plans", userHandler.GetUserOutfitPlans).Methods("GET")
	
	// DELETE /api/users/{id}/outfit-plans/{plan_id} - Delete outfit plan
	users.HandleFunc("/{id:[0-9]+}/outfit-plans/{plan_id:[0-9]+}", userHandler.DeleteOutfitPlan).Methods("DELETE")
	
	// GET /api/users/{id}/stats - Get user statistics
	users.HandleFunc("/{id:[0-9]+}/stats", userHandler.GetUserStats).Methods("GET")
}