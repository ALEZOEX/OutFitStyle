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
	HealthCheck(ctx context.Context) external.HealthCheckResult
	GenerateOutfit(ctx context.Context, userID string, meta map[string]any) (external.GenerateOutfitResponse, error)
	GenerateRecommendation(ctx context.Context, req external.GenerateRecommendationRequest) (external.GenerateRecommendationResponse, error)
	ProcessFeedback(ctx context.Context, userID string, requestID string, meta map[string]any) error
	UpdateUserPreferences(ctx context.Context, userID string, requestID string, meta map[string]any) error
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
func (a *MLServiceAdapter) GetRecommendations(
	ctx context.Context,
	userID domain.ID,
	weather domain.WeatherData,
	itemsByCategory map[string][]domain.ClothingItem,
) (*domain.RecommendationResponse, error) {
	// Конвертируем предметы домена в Item для ML сервиса
	itemsByCategoryML := make(map[string][]external.Item, len(itemsByCategory))
	for category, items := range itemsByCategory {
		mlItems := make([]external.Item, 0, len(items))
		for _, item := range items {
			baseColour := ""
			if item.BaseColour != nil {
				baseColour = *item.BaseColour
			}
			mlItems = append(mlItems, external.Item{
				ID:          item.ID.String(),
				Category:    category, // используем ключ мапы как категорию
				Subcategory: item.Subcategory,
				BaseColour:  baseColour,
				Name:        item.Name,
			})
		}
		itemsByCategoryML[category] = mlItems
	}

	// Конвертируем погоду в контекст для ML
	contextML := map[string]any{
		"temperature":       weather.Temperature,
		"feels_like":        weather.FeelsLike,
		"humidity":          weather.Humidity,
		"wind_speed":        weather.WindSpeed,
		"weather_condition": weather.Weather,
		"location":          weather.Location,
		"activity":          "daily", // можно передать из запроса
		"gender":            "unisex", // можно передать из профиля пользователя
		"duration":          2.0,
	}

	// Создаём запрос к ML сервису
	req := external.GenerateRecommendationRequest{
		RequestID:       domain.NewID().String(),
		UserID:          userID.String(),
		ItemsByCategory: itemsByCategoryML,
		Context:         contextML,
	}

	// Вызываем ML сервис
	resp, err := a.client.GenerateRecommendation(ctx, req)
	if err != nil {
		return nil, fmt.Errorf("failed to get recommendations from ML service: %w", err)
	}

	if !resp.Success {
		return nil, fmt.Errorf("ML service returned unsuccessful response")
	}

	// Возвращаем базовый ответ
	// В реальной реализации здесь будет парсинг outfit'ов из ответа ML
	recommendation := &domain.RecommendationResponse{
		ID:        domain.NewID(),
		UserID:    userID,
		Items:     []domain.RecommendationItem{},
		Weather:   weather,
		CreatedAt: time.Now(),
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
	meta := map[string]any{
		"rating":           feedback.Rating,
		"thermal_feedback": feedback.ThermalFeedback,
		"feedback":         feedback.Feedback,
	}

	return a.client.ProcessFeedback(ctx, userID.String(), requestID, meta)
}

// UpdateUserPreferences wraps the ML client's preference update
func (a *MLServiceAdapter) UpdateUserPreferences(ctx context.Context, userID domain.ID, requestID string, preferences map[string]any) error {
	meta := map[string]any{
		"preferences": preferences,
	}

	return a.client.UpdateUserPreferences(ctx, userID.String(), requestID, meta)
}

// GenerateOutfit wraps the ML client's outfit generation
func (a *MLServiceAdapter) GenerateOutfit(ctx context.Context, userID domain.ID, occasion string, weather domain.WeatherData) error {
	meta := map[string]any{
		"occasion": occasion,
		"weather": map[string]any{
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