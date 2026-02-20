package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// OutfitRatingRepository интерфейс репозитория оценок рекомендаций
type OutfitRatingRepository interface {
	// Create создаёт новую оценку рекомендации
	Create(ctx context.Context, rating *domain.OutfitRating) error

	// GetByRecommendation возвращает все оценки для рекомендации
	GetByRecommendation(ctx context.Context, recommendationID domain.ID) ([]domain.OutfitRating, error)

	// GetByUserAndRecommendation возвращает оценку пользователя для рекомендации
	GetByUserAndRecommendation(ctx context.Context, userID, recommendationID domain.ID) (*domain.OutfitRating, error)

	// GetAverageQuality возвращает среднюю оценку качества для рекомендации
	GetAverageQuality(ctx context.Context, recommendationID domain.ID) (*domain.RecommendationQualityStats, error)

	// GetUserRatingsForRecommendations возвращает оценки пользователя для списка рекомендаций
	GetUserRatingsForRecommendations(ctx context.Context, userID domain.ID, recommendationIDs []domain.ID) (map[domain.ID]int, error)

	// GetLowQualityItems возвращает вещи с низким рейтингом для пользователя
	GetLowQualityItems(ctx context.Context, userID domain.ID, threshold float64) ([]domain.LowQualityItem, error)

	// GetUserStats возвращает статистику оценок пользователя
	GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserRatingStats, error)

	// HasRated проверяет, оценил ли пользователь рекомендацию
	HasRated(ctx context.Context, userID, recommendationID domain.ID) (bool, error)

	// Update обновляет существующую оценку
	Update(ctx context.Context, rating *domain.OutfitRating) error
}
