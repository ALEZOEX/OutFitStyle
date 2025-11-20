package usecases

import (
	"context"
	"fmt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// GetRecommendationsInput represents the input for the GetRecommendations use case.
type GetRecommendationsInput struct {
	UserID int    `json:"user_id"`
	City   string `json:"city"`
}

// GetRecommendationsOutput represents the output for the GetRecommendations use case.
type GetRecommendationsOutput struct {
	Recommendation *domain.RecommendationResponse `json:"recommendation"`
}

// GetRecommendationsUseCase defines the interface for the GetRecommendations use case.
type GetRecommendationsUseCase interface {
	Execute(ctx context.Context, input GetRecommendationsInput) (*GetRecommendationsOutput, error)
}

// getRecommendationsUseCase implements GetRecommendationsUseCase.
type getRecommendationsUseCase struct {
	userRepo           repositories.UserRepository
	recommendationRepo repositories.RecommendationRepository
	weatherService     WeatherService
	mlService          MLService
}

// WeatherService defines the interface for weather service.
type WeatherService interface {
	GetWeather(ctx context.Context, city string) (*domain.WeatherData, error)
}

// MLService defines the interface for ML service.
type MLService interface {
	// В твоём ML клиенте сейчас:
	// GetRecommendations(ctx context.Context, userID int, weather domain.WeatherData) (*domain.RecommendationResponse, error)
	GetRecommendations(ctx context.Context, userID int, weather domain.WeatherData) (*domain.RecommendationResponse, error)
}

// NewGetRecommendationsUseCase creates a new GetRecommendationsUseCase.
func NewGetRecommendationsUseCase(
	userRepo repositories.UserRepository,
	recommendationRepo repositories.RecommendationRepository,
	weatherService WeatherService,
	mlService MLService,
) GetRecommendationsUseCase {
	return &getRecommendationsUseCase{
		userRepo:           userRepo,
		recommendationRepo: recommendationRepo,
		weatherService:     weatherService,
		mlService:          mlService,
	}
}

// Execute executes the GetRecommendations use case.
func (uc *getRecommendationsUseCase) Execute(
	ctx context.Context,
	input GetRecommendationsInput,
) (*GetRecommendationsOutput, error) {
	// Validate input
	if input.City == "" {
		return nil, fmt.Errorf("city is required")
	}

	// Get weather data
	weather, err := uc.weatherService.GetWeather(ctx, input.City)
	if err != nil {
		return nil, fmt.Errorf("failed to get weather data: %w", err)
	}

	// Get user profile (опционально)
	userProfile, err := uc.userRepo.GetUserProfile(ctx, input.UserID)
	if err != nil {
		// Логика: продолжаем без профиля, но в реальной системе тут можно логировать
		userProfile = nil
	}

	_ = userProfile // пока профиль не используется, чтобы не было "declared and not used"

	// Get ML recommendations
	mlRecommendation, err := uc.mlService.GetRecommendations(ctx, input.UserID, *weather)
	if err != nil {
		return nil, fmt.Errorf("failed to get ML recommendations: %w", err)
	}

	// Сохранить рекомендацию в БД
	if _, err := uc.recommendationRepo.CreateRecommendation(ctx, mlRecommendation); err != nil {
		// Не роняем весь use case, но возвращаем обёрнутую ошибку, если хочешь:
		// return nil, fmt.Errorf("failed to save recommendation: %w", err)
		// или можно просто залогировать, если сюда добавить logger
	}

	return &GetRecommendationsOutput{
		Recommendation: mlRecommendation,
	}, nil
}
