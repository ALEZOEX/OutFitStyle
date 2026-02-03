package adapters

import (
	"context"
	"fmt"
	"time"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

// MLClientInterface defines the interface for the ML client to enable mocking
type MLClientInterface interface {
	Rank(ctx context.Context, req external.TZMLRankRequest) (external.TZMLRankResponse, error)
	SendAction(ctx context.Context, req external.ActionRequest) (external.ActionResponse, error)
	HealthCheck(ctx context.Context) bool
	GenerateOutfit(ctx context.Context, userID string, meta map[string]interface{}) (external.GenerateOutfitResponse, error)
	GenerateRecommendation(ctx context.Context, userID string, meta map[string]interface{}) (external.GenerateRecommendationResponse, error)
	ProcessFeedback(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error
	UpdateUserPreferences(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error
}

// MLServiceAdapter adapts the external ML client to the MLService interface
type MLServiceAdapter struct {
	client MLClientInterface
}

// NewMLServiceAdapter creates a new ML service adapter
func NewMLServiceAdapter(client MLClientInterface) *MLServiceAdapter {
	return &MLServiceAdapter{
		client: client,
	}
}

// NewMLServiceAdapterFromExternal creates a new ML service adapter from the external client
func NewMLServiceAdapterFromExternal(client *external.MLClient) *MLServiceAdapter {
	return &MLServiceAdapter{
		client: client,
	}
}

// GetRecommendations implements the MLService interface
func (a *MLServiceAdapter) GetRecommendations(ctx context.Context, userID domain.ID, weather domain.WeatherData) (*domain.RecommendationResponse, error) {
	// Convert domain.WeatherData to the format expected by the ML service
	weatherMeta := map[string]interface{}{
		"temperature": weather.Temperature,
		"feels_like":  weather.FeelsLike,
		"humidity":    weather.Humidity,
		"wind_speed":  weather.WindSpeed,
		"weather":     weather.Weather,
	}

	// Prepare metadata for the ML service
	meta := map[string]interface{}{
		"user_id": userID.String(),
		"weather": weatherMeta,
		"context": map[string]interface{}{
			"location": weather.Location,
		},
	}

	// Call the ML service to generate recommendations
	resp, err := a.client.GenerateRecommendation(ctx, userID.String(), meta)
	if err != nil {
		return nil, fmt.Errorf("failed to get recommendations from ML service: %w", err)
	}

	if !resp.Success {
		return nil, fmt.Errorf("ML service returned unsuccessful response")
	}

	// For now, return a basic recommendation response
	// In a real implementation, you'd parse the actual response from the ML service
	recommendation := &domain.RecommendationResponse{
		ID:        domain.NewID(),
		UserID:    userID,
		Items:     []domain.RecommendationItem{}, // This would come from the ML service response
		Weather:   weather,
		CreatedAt: time.Now(), // Using standard time.Now()
	}

	return recommendation, nil
}

// RankCandidates wraps the ML client's Rank method
func (a *MLServiceAdapter) RankCandidates(ctx context.Context, req *external.TZMLRankRequest) (*external.TZMLRankResponse, error) {
	resp, err := a.client.Rank(ctx, *req)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

// ProcessFeedback wraps the ML client's feedback processing
func (a *MLServiceAdapter) ProcessFeedback(ctx context.Context, userID domain.ID, requestID string, feedback domain.RecommendationRateRequest) error {
	meta := map[string]interface{}{
		"rating":           feedback.Rating,
		"thermal_feedback": feedback.ThermalFeedback,
		"feedback":         feedback.Feedback,
	}

	return a.client.ProcessFeedback(ctx, userID.String(), requestID, meta)
}

// UpdateUserPreferences wraps the ML client's preference update
func (a *MLServiceAdapter) UpdateUserPreferences(ctx context.Context, userID domain.ID, requestID string, preferences map[string]interface{}) error {
	meta := map[string]interface{}{
		"preferences": preferences,
	}

	return a.client.UpdateUserPreferences(ctx, userID.String(), requestID, meta)
}

// GenerateOutfit wraps the ML client's outfit generation
func (a *MLServiceAdapter) GenerateOutfit(ctx context.Context, userID domain.ID, occasion string, weather domain.WeatherData) error {
	meta := map[string]interface{}{
		"occasion": occasion,
		"weather": map[string]interface{}{
			"temperature": weather.Temperature,
			"feels_like":  weather.FeelsLike,
			"humidity":    weather.Humidity,
			"wind_speed":  weather.WindSpeed,
			"weather":     weather.Weather,
		},
	}

	resp, err := a.client.GenerateOutfit(ctx, userID.String(), meta)
	if err != nil {
		return fmt.Errorf("failed to generate outfit: %w", err)
	}

	if !resp.Success {
		return fmt.Errorf("ML service failed to generate outfit")
	}

	return nil
}