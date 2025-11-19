packagecontrollers

import (
	"context"
	"encoding/json"
	"fmt"
"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/use_cases"
	"outfitstyle/server/internal/pkg/http"
)

// RecommendationControllerhandles recommendation-related HTTP requests
type RecommendationController struct {
	getRecommendationsUseCase usecases.GetRecommendationsUseCase
	logger                   *zap.Logger
}

// NewRecommendationController creates a new RecommendationController
func NewRecommendationController(
	getRecommendationsUseCase usecases.GetRecommendationsUseCase,
	logger *zap.Logger,
) *RecommendationController {
	return &RecommendationController{
		getRecommendationsUseCase: getRecommendationsUseCase,
		logger:                   logger,
	}
}

// GetRecommendations handles GET /api/recommendations
func (c *RecommendationController) GetRecommendations(w http.ResponseWriter, r *http.Request) {
	// Parse query parameters
	city := r.URL.Query().Get("city")
	if city == "" {
		http.BadRequest(w, fmt.Errorf("city parameter is required"))
		return
	}

	userIDStr := r.URL.Query().Get("user_id")
	userID := int64(1)// Default user ID for demo
	if userIDStr != "" {
		id, err := strconv.ParseInt(userIDStr, 10,64)
		if err != nil {
			http.BadRequest(w, fmt.Errorf("invalid user_id parameter"))
			return
		}
		userID = id
	}

//Create context with timeout
	ctx := r.Context()
	ctxWithTimeout, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	c.logger.Info("📍 Request: city=%s, user_id=%d",
		zap.String("city", city),
		zap.Int64("user_id",userID))

	// Execute use case
	input := usecases.GetRecommendationsInput{
		UserID: userID,
		City:   city,
	}

	output, err := c.getRecommendationsUseCase.Execute(ctxWithTimeout, input)
	if err != nil {
		c.logger.Error("❌ Recommendation error", zap.Error(err))
		http.InternalServerError(w, fmt.Errorf("Failed to get recommendations"))
		return
	}

	// Return success response
	http.Success(w, http.StatusOK, output.Recommendation)
}

// RegisterRoutes registers the recommendation routes
func (c *RecommendationController) RegisterRoutes(router *mux.Router){
	// Recommendations
	recommendations := router.PathPrefix("/api/recommendations").Subrouter()
	recommendations.HandleFunc("", c.GetRecommendations).Methods("GET")
	// Add other routes as needed
}