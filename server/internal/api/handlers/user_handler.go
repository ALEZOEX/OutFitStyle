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
	"outfitstyle/server/internal/infrastructure/middleware"
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

// GetUserProfile godoc
// @Summary      Получить профиль пользователя
// @Description  Возвращает профиль пользователя по ID. Пользователь может получить только свой профиль.
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  domain.UserProfile
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      404  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Security     BearerAuth
// @Router       /users/{id}/profile [get]
func (h *UserHandler) GetUserProfile(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	requestedUserID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to access another user's profile",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only access own profile"))
		return
	}

	ctx := r.Context()
	profile, err := h.userService.GetUserProfile(ctx, requestedUserID)
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

// UpdateUserProfile godoc
// @Summary      Обновить профиль пользователя
// @Description  Обновляет профиль пользователя по ID. Пользователь может обновлять только свой профиль.
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id     path      int              true  "User ID"
// @Param        profile  body    domain.UserProfile  true  "Данные профиля"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Security     BearerAuth
// @Router       /users/{id}/profile [put]
func (h *UserHandler) UpdateUserProfile(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	requestedUserID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}
	defer r.Body.Close()

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to update another user's profile",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only update own profile"))
		return
	}

	var profile domain.UserProfile
	if err := json.NewDecoder(r.Body).Decode(&profile); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	profile.UserID = domain.ID(requestedUserID)

	ctx := r.Context()
	if err := h.userService.UpdateUserProfile(ctx, &profile); err != nil {
		h.logger.Error("Failed to update user profile", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update user profile"))
		return
	}

	resp.Success(w, map[string]string{"message": "Profile updated successfully"})
}

// GetUserAchievements handles GET /api/v1/users/{id}/achievements
// @Security     BearerAuth
func (h *UserHandler) GetUserAchievements(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	requestedUserID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to access another user's achievements",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only access own achievements"))
		return
	}

	ctx := r.Context()
	achievements, err := h.userService.GetUserAchievements(ctx, requestedUserID)
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

// GetUserRatings handles GET /api/v1/users/{id}/ratings
// @Security     BearerAuth
func (h *UserHandler) GetUserRatings(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	requestedUserID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to access another user's ratings",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only access own ratings"))
		return
	}

	ctx := r.Context()
	ratings, err := h.userService.GetUserRatings(ctx, requestedUserID)
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

// CreateOutfitPlan godoc
// @Summary      Создать план образа
// @Description  Создаёт новый план образа для пользователя. Только для авторизованного пользователя.
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id    path      int             true  "User ID"
// @Param        plan  body      domain.OutfitPlan  true  "Данные плана образа"
// @Success      200   {object}  map[string]string
// @Failure      400   {object}  map[string]string
// @Failure      401   {object}  map[string]string
// @Failure      500   {object}  map[string]string
// @Security     BearerAuth
// @Router       /users/{id}/outfit-plans [post]
func (h *UserHandler) CreateOutfitPlan(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	requestedUserID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}
	defer r.Body.Close()

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to create outfit plan for another user",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only create plan for own account"))
		return
	}

	var plan domain.OutfitPlan
	if err := json.NewDecoder(r.Body).Decode(&plan); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid request body"))
		return
	}

	plan.UserID = domain.ID(requestedUserID)

	ctx := r.Context()
	if err := h.userService.CreateOutfitPlan(ctx, &plan); err != nil {
		h.logger.Error("Failed to create outfit plan", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to create outfit plan"))
		return
	}

	resp.Success(w, map[string]string{"message": "Outfit plan created successfully"})
}

// GetUserOutfitPlans godoc
// @Summary      Получить планы образов пользователя
// @Description  Возвращает список планов образов пользователя. Только для авторизованного пользователя.
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Security     BearerAuth
// @Router       /users/{id}/outfit-plans [get]
func (h *UserHandler) GetUserOutfitPlans(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	requestedUserID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to access another user's outfit plans",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only access own outfit plans"))
		return
	}

	ctx := r.Context()
	plans, err := h.userService.GetUserOutfitPlans(ctx, requestedUserID)
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

// DeleteOutfitPlan godoc
// @Summary      Удалить план образа
// @Description  Удаляет план образа пользователя по ID. Только для авторизованного пользователя.
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id       path      int  true  "User ID"
// @Param        plan_id  path      int  true  "Plan ID"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Security     BearerAuth
// @Router       /users/{id}/outfit-plans/{plan_id} [delete]
func (h *UserHandler) DeleteOutfitPlan(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	requestedUserID, err := parseUserID(vars)
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

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to delete outfit plan for another user",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only delete own plan"))
		return
	}

	ctx := r.Context()
	if err := h.userService.DeleteOutfitPlan(ctx, requestedUserID, planID); err != nil {
		h.logger.Error("Failed to delete outfit plan", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to delete outfit plan"))
		return
	}

	resp.Success(w, map[string]string{"message": "Outfit plan deleted successfully"})
}

// GetUserStats handles GET /api/v1/users/{id}/stats
// @Security     BearerAuth
func (h *UserHandler) GetUserStats(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	requestedUserID, err := parseUserID(vars)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid user ID"))
		return
	}

	// Extract authenticated user ID from context
	authUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		h.logger.Error("User ID not found in context")
		resp.Error(w, http.StatusUnauthorized, errors.New("authentication required"))
		return
	}

	// Check that requested user ID matches authenticated user ID
	if requestedUserID != authUserID {
		h.logger.Warn("User tried to access another user's stats",
			zap.Int("requested_user_id", requestedUserID),
			zap.Int("authenticated_user_id", authUserID))
		resp.Error(w, http.StatusForbidden, errors.New("access denied: can only access own stats"))
		return
	}

	ctx := r.Context()
	stats, err := h.userService.GetUserStats(ctx, requestedUserID)
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
