package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

// UserHandler handles user-related HTTP requests.
type UserHandler struct {
	userService *services.UserService
	logger      *zap.Logger
}

// NewUserHandler creates a new user handler.
func NewUserHandler(
	userService *services.UserService,
	logger *zap.Logger,
) *UserHandler {
	return &UserHandler{
		userService: userService,
		logger:      logger,
	}
}

// parseUserID is a small helper to parse user id from path vars.
func parseUserID(vars map[string]string) (int, error) {
	userIDStr, ok := vars["id"]
	if !ok || userIDStr == "" {
		return 0, errors.New("user ID is required")
	}
	return strconv.Atoi(userIDStr)
}

// GetUserProfile handles GET /api/users/{id}/profile.
func (h *UserHandler) GetUserProfile(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	ctx := r.Context()
	profile, err := h.userService.GetUserProfile(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user profile", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get user profile"))
		return
	}

	if profile == nil {
		resp.Error(w, http.StatusNotFound, errors.New("user profile not found"))
		return
	}

	resp.Success(w, profile)
}

// UpdateUserProfile handles PUT /api/users/{id}/profile.
func (h *UserHandler) UpdateUserProfile(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}
	defer r.Body.Close()

	var profile domain.UserProfile
	if err := json.NewDecoder(r.Body).Decode(&profile); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	profile.UserID = domain.ID(userID)

	ctx := r.Context()
	if err := h.userService.UpdateUserProfile(ctx, &profile); err != nil {
		h.logger.Error("Failed to update user profile", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update user profile"))
		return
	}

	resp.Success(w, map[string]string{"message": "Profile updated successfully"})
}

// GetUserAchievements handles GET /api/users/{id}/achievements.
func (h *UserHandler) GetUserAchievements(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	ctx := r.Context()
	achievements, err := h.userService.GetUserAchievements(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user achievements", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get user achievements"))
		return
	}

	response := map[string]interface{}{
		"achievements": achievements,
		"count":        len(achievements),
	}
	resp.Success(w, response)
}

// GetUserRatings handles GET /api/users/{id}/ratings.
func (h *UserHandler) GetUserRatings(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	ctx := r.Context()
	ratings, err := h.userService.GetUserRatings(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user ratings", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get user ratings"))
		return
	}

	response := map[string]interface{}{
		"ratings": ratings,
		"count":   len(ratings),
	}
	resp.Success(w, response)
}

// CreateOutfitPlan handles POST /api/users/{id}/outfit-plans.
func (h *UserHandler) CreateOutfitPlan(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}
	defer r.Body.Close()

	var plan domain.OutfitPlan
	if err := json.NewDecoder(r.Body).Decode(&plan); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	plan.UserID = domain.ID(userID)

	ctx := r.Context()
	if err := h.userService.CreateOutfitPlan(ctx, &plan); err != nil {
		h.logger.Error("Failed to create outfit plan", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to create outfit plan"))
		return
	}

	resp.Success(w, map[string]string{"message": "Outfit plan created successfully"})
}

// GetUserOutfitPlans handles GET /api/users/{id}/outfit-plans.
func (h *UserHandler) GetUserOutfitPlans(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	ctx := r.Context()
	plans, err := h.userService.GetUserOutfitPlans(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user outfit plans", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get user outfit plans"))
		return
	}

	response := map[string]interface{}{
		"plans": plans,
		"count": len(plans),
	}
	resp.Success(w, response)
}

// DeleteOutfitPlan handles DELETE /api/users/{id}/outfit-plans/{plan_id}.
func (h *UserHandler) DeleteOutfitPlan(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	planIDStr, ok := vars["plan_id"]
	if !ok || planIDStr == "" {
		resp.Error(w, http.StatusBadRequest, errors.New("plan ID is required"))
		return
	}

	planID, err := strconv.Atoi(planIDStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid plan ID"))
		return
	}

	ctx := r.Context()
	if err := h.userService.DeleteOutfitPlan(ctx, userID, planID); err != nil {
		h.logger.Error("Failed to delete outfit plan", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to delete outfit plan"))
		return
	}

	resp.Success(w, map[string]string{"message": "Outfit plan deleted successfully"})
}

// GetUserStats handles GET /api/users/{id}/stats.
func (h *UserHandler) GetUserStats(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	ctx := r.Context()
	stats, err := h.userService.GetUserStats(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get user stats", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get user stats"))
		return
	}

	if stats == nil {
		resp.Error(w, http.StatusNotFound, errors.New("user stats not found"))
		return
	}

	resp.Success(w, stats)
}
