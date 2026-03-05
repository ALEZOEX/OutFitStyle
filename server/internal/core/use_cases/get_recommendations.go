package usecases

import (
	"context"
	"fmt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// GetRecommendationsInput represents the input for the GetRecommendations use case.
type GetRecommendationsInput struct {
	UserID string `json:"user_id"`
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
// ИЗМЕНЕНИЯ (Март 2026): добавлен параметр itemsByCategory
type MLService interface {
	GetRecommendations(
		ctx context.Context,
		userID domain.ID,
		weather domain.WeatherData,
		itemsByCategory map[string][]domain.ClothingItem,
	) (*domain.RecommendationResponse, error)
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

	// Parse user ID
	userID, err := domain.ParseID(input.UserID)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID: %w", err)
	}

	// Get user profile (опционально)
	userProfile, err := uc.userRepo.GetUserProfile(ctx, userID)
	if err != nil {
		// Логика: продолжаем без профиля, но в реальной системе тут можно логировать
		userProfile = nil
	}

	_ = userProfile // пока профиль не используется

	// Получаем предметы гардероба пользователя по категориям
	// В реальной реализации здесь будет вызов wardrobeRepo.GetItemsByCategory
	itemsByCategory := make(map[string][]domain.ClothingItem)
	// Например:
	// itemsByCategory, err = uc.wardrobeRepo.GetItemsByCategory(ctx, userID)
	// if err != nil {
	//     return nil, fmt.Errorf("failed to get wardrobe items: %w", err)
	// }

	// Get ML recommendations с предметами гардероба
	mlRecommendation, err := uc.mlService.GetRecommendations(ctx, userID, *weather, itemsByCategory)
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
