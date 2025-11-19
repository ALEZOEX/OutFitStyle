package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/api"
)

// UserHandler handles user-related HTTP requests
type UserHandler struct {
	userService *services.UserService
	logger      *zap.Logger
}

// NewUserHandler creates a new user handler
func NewUserHandler(
	userService *services.UserService,
	logger *zap.Logger,
) *UserHandler {
	return &UserHandler{
		userService: userService,
		logger:      logger,
	}
}

// GetUserProfile handles GET /api/users/{id}/profile
func (h *UserHandler) GetUserProfile(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	ctx := r.Context()
	profile, err := h.userService.GetUserProfile(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user profile", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to get user profile")
		return
	}

	if profile == nil {
		api.JSONError(w, http.StatusNotFound, "User profile not found")
		return
	}

	api.JSONResponse(w, http.StatusOK, profile)
}

// UpdateUserProfile handles PUT /api/users/{id}/profile
func (h *UserHandler) UpdateUserProfile(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	// Parse request body
	var profile domain.UserProfile
	if err := json.NewDecoder(r.Body).Decode(&profile); err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Set the user ID
	profile.UserID = userID

	ctx := r.Context()
	err = h.userService.UpdateUserProfile(ctx, &profile)
	if err != nil {
		h.logger.Error("Failed to update user profile", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to update user profile")
		return
	}

	api.JSONResponse(w, http.StatusOK, map[string]string{"message": "Profile updated successfully"})
}

// GetUserAchievements handles GET /api/users/{id}/achievements
func (h *UserHandler) GetUserAchievements(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	ctx := r.Context()
	achievements, err := h.userService.GetUserAchievements(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user achievements", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to get user achievements")
		return
	}

	response := map[string]interface{}{
		"achievements": achievements,
		"count":        len(achievements),
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// GetUserRatings handles GET /api/users/{id}/ratings
func (h *UserHandler) GetUserRatings(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	ctx := r.Context()
	ratings, err := h.userService.GetUserRatings(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user ratings", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to get user ratings")
		return
	}

	response := map[string]interface{}{
		"ratings": ratings,
		"count":   len(ratings),
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// CreateOutfitPlan handles POST /api/users/{id}/outfit-plans
func (h *UserHandler) CreateOutfitPlan(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	// Parse request body
	var plan domain.OutfitPlan
	if err := json.NewDecoder(r.Body).Decode(&plan); err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Set the user ID
	plan.UserID = userID

	ctx := r.Context()
	err = h.userService.CreateOutfitPlan(ctx, &plan)
	if err != nil {
		h.logger.Error("Failed to create outfit plan", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to create outfit plan")
		return
	}

	api.JSONResponse(w, http.StatusOK, map[string]string{"message": "Outfit plan created successfully"})
}

// GetUserOutfitPlans handles GET /api/users/{id}/outfit-plans
func (h *UserHandler) GetUserOutfitPlans(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	ctx := r.Context()
	plans, err := h.userService.GetUserOutfitPlans(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user outfit plans", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to get user outfit plans")
		return
	}

	response := map[string]interface{}{
		"plans": plans,
		"count": len(plans),
	}

	api.JSONResponse(w, http.StatusOK, response)
}

// DeleteOutfitPlan handles DELETE /api/users/{id}/outfit-plans/{plan_id}
func (h *UserHandler) DeleteOutfitPlan(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	planIDStr := vars["plan_id"]
	planID, err := strconv.Atoi(planIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid plan ID")
		return
	}

	ctx := r.Context()
	err = h.userService.DeleteOutfitPlan(ctx, userID, planID)
	if err != nil {
		h.logger.Error("Failed to delete outfit plan", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to delete outfit plan")
		return
	}

	api.JSONResponse(w, http.StatusOK, map[string]string{"message": "Outfit plan deleted successfully"})
}

// GetUserStats handles GET /api/users/{id}/stats
func (h *UserHandler) GetUserStats(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userIDStr := vars["id"]
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		api.JSONError(w, http.StatusBadRequest, "invalid user ID")
		return
	}

	ctx := r.Context()
	stats, err := h.userService.GetUserStats(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user stats", zap.Error(err))
		api.JSONError(w, http.StatusInternalServerError, "Failed to get user stats")
		return
	}

	if stats == nil {
		api.JSONError(w, http.StatusNotFound, "User stats not found")
		return
	}

	api.JSONResponse(w, http.StatusOK, stats)
}