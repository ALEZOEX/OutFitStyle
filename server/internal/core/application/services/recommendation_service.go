package services

import (
	"context"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/infrastructure/external"
)

// RecommendationService handles recommendation-related business logic
type RecommendationService struct {
	recommendationRepo repositories.RecommendationRepository
	userRepo           repositories.UserRepository
	weatherService     *external.WeatherService
	mlService          *external.MLService
	logger             *zap.Logger
}

// NewRecommendationService creates a new recommendation service
func NewRecommendationService(
	recommendationRepo repositories.RecommendationRepository,
	userRepo repositories.UserRepository,
	weatherService *external.WeatherService,
	mlService *external.MLService,
	logger *zap.Logger,
) *RecommendationService {
	return &RecommendationService{
		recommendationRepo: recommendationRepo,
		userRepo:           userRepo,
		weatherService:     weatherService,
		mlService:          mlService,
		logger:             logger,
	}
}

// GetRecommendations generates outfit recommendations for a user based on weather data
func (s *RecommendationService) GetRecommendations(ctx context.Context, req domain.RecommendationRequest) (*domain.RecommendationResponse, error) {
	// Get user profile if available
	var userProfile *domain.UserProfile
	var err error
	if req.UserID > 0 {
		userProfile, err = s.userRepo.GetUserProfile(ctx, req.UserID)
		if err != nil {
			s.logger.Warn("Could not load user profile",
				zap.Int("user_id", req.UserID),
				zap.Error(err))
		}
	}

	// Prepare recommendation request for ML service
	mlWeather := domain.WeatherData{
		Location:    req.WeatherData.Location,
		Temperature: req.WeatherData.Temperature,
		FeelsLike:   req.WeatherData.FeelsLike,
		Weather:     req.WeatherData.Weather,
		Humidity:    req.WeatherData.Humidity,
		WindSpeed:   req.WeatherData.WindSpeed,
	}

	// Get recommendations from ML service
	mlResp, err := s.mlService.GetRecommendations(ctx, req.UserID, mlWeather)
	if err != nil {
		return nil, err
	}

	// Create domain recommendation
	outfitScore := 0.0
	if mlResp.OutfitScore != nil {
		outfitScore = *mlResp.OutfitScore
	}

	recommendation := &domain.RecommendationResponse{
		UserID:          req.UserID,
		Location:        mlWeather.Location,
		Temperature:     mlWeather.Temperature,
		Weather:         mlWeather.Weather,
		Recommendations: convertClothingItems(mlResp.Recommendations),
		MLPowered:       true,
		OutfitScore:     &outfitScore,
		Algorithm:       mlResp.Algorithm,
		Timestamp:       time.Now(),
	}

	// Save recommendation to database
	if req.UserID > 0 {
		go func() {
			ctx := context.Background()
			_, err := s.recommendationRepo.CreateRecommendation(ctx, recommendation)
			if err != nil {
				s.logger.Error("Failed to save recommendation",
					zap.Int("user_id", req.UserID),
					zap.Error(err))
			}
		}()
	}

	return recommendation, nil
}

// GetRecommendationHistory retrieves recommendation history for a user
func (s *RecommendationService) GetRecommendationHistory(ctx context.Context, userID int, limit int) ([]domain.RecommendationResponse, error) {
	recommendations, err := s.recommendationRepo.GetUserRecommendations(ctx, userID, limit)
	if err != nil {
		return nil, err
	}

	return recommendations, nil
}

// GetRecommendationByID retrieves a specific recommendation by ID
func (s *RecommendationService) GetRecommendationByID(ctx context.Context, id int) (*domain.RecommendationResponse, error) {
	recommendation, err := s.recommendationRepo.GetRecommendationByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return recommendation, nil
}

// RateRecommendation allows a user to rate a recommendation
func (s *RecommendationService) RateRecommendation(ctx context.Context, userID, recommendationID, rating int, feedback string) error {
	return s.userRepo.RateRecommendation(ctx, userID, recommendationID, rating, feedback)
}

// AddFavorite adds a recommendation to user's favorites
func (s *RecommendationService) AddFavorite(ctx context.Context, userID, recommendationID int) error {
	return s.userRepo.AddFavorite(ctx, userID, recommendationID)
}

// RemoveFavorite removes a recommendation from user's favorites
func (s *RecommendationService) RemoveFavorite(ctx context.Context, userID, favoriteID int) error {
	return s.userRepo.RemoveFavorite(ctx, userID, favoriteID)
}

// GetUserFavorites retrieves user's favorite recommendations
func (s *RecommendationService) GetUserFavorites(ctx context.Context, userID int) ([]domain.FavoriteOutfit, error) {
	return s.userRepo.GetUserFavorites(ctx, userID)
}

// convertClothingItems converts external clothing items to domain clothing items
func convertClothingItems(externalItems []domain.ClothingItem) []domain.ClothingItem {
	items := make([]domain.ClothingItem, len(externalItems))
	for i, item := range externalItems {
		items[i] = domain.ClothingItem{
			ID:                 item.ID,
			UserID:             item.UserID,
			Name:               item.Name,
			Category:           item.Category,
			Subcategory:        item.Subcategory,
			IconEmoji:          item.IconEmoji,
			MLSore:             item.MLSore,
			Confidence:         item.Confidence,
			WeatherSuitability: item.WeatherSuitability,
		}
	}
	return items
}