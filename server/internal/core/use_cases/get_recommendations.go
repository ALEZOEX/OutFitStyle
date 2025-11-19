package usecases

import (
	"context"
	"fmt"

	"outfitstyle/server/internal/core/domain/entities"
	"outfitstyle/server/internal/core/domain/repositories"
)

// GetRecommendationsInput represents the input for the GetRecommendations use case
type GetRecommendationsInput struct {
	UserID int64
	City   string
}

// GetRecommendationsOutput represents the output for the GetRecommendations use case
type GetRecommendationsOutput struct {
	Recommendation *entities.Recommendation
}

// GetRecommendationsUseCase defines the interface for the GetRecommendations use case
type GetRecommendationsUseCase interface {
	Execute(ctx context.Context, input GetRecommendationsInput) (*GetRecommendationsOutput, error)
}

// getRecommendationsUseCase implements GetRecommendationsUseCase
type getRecommendationsUseCase struct {
	userRepo           repositories.UserRepository
	recommendationRepo repositories.RecommendationRepository
	weatherService     WeatherService
	mlService          MLService
}

// WeatherService defines the interface for weather service
type WeatherService interface {
	GetWeather(ctx context.Context, city string) (*entities.WeatherData, error)
}

// MLService defines the interface for ML service
type MLService interface {
	GetRecommendations(ctx context.Context, userID int64, weather *entities.WeatherData) (*entities.Recommendation, error)
}

// NewGetRecommendationsUseCase creates a new GetRecommendationsUseCase
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

// Execute executes the GetRecommendations use case
func (uc *getRecommendationsUseCase) Execute(ctx context.Context, input GetRecommendationsInput) (*GetRecommendationsOutput, error) {
	// Validate input
	if input.City == "" {
		return nil, fmt.Errorf("city is required")
	}

	// Get weather data
	weather, err := uc.weatherService.GetWeather(ctx, input.City)
	if err != nil {
		return nil, fmt.Errorf("failed to get weather data: %w", err)
	}

	// Get user profile
	userProfile, err := uc.userRepo.GetUserProfile(ctx, input.UserID)
	if err != nil {
		// Log the error but continue without user profile
		// In a real implementation, you might want to handle this differently
		userProfile = nil
	}

	// Prepare weather data for ML service
	// In a real implementation, you might need to transform the data

	// Get ML recommendations
	mlRecommendation, err := uc.mlService.GetRecommendations(ctx, input.UserID, weather)
	if err != nil {
		return nil, fmt.Errorf("failed to get ML recommendations: %w", err)
	}

	// Save recommendation
	err = uc.recommendationRepo.SaveRecommendation(ctx, mlRecommendation)
	if err != nil {
		// Log the error but don't fail the request
		// In a real implementation, you might want to handle this differently
	}

	// Return the recommendation
	return &GetRecommendationsOutput{
		Recommendation: mlRecommendation,
	}, nil
}
