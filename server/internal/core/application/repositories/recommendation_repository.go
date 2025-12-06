package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// RecommendationRepository defines operations for working with outfit recommendations.
type RecommendationRepository interface {
	// CreateRecommendation сохраняет рекомендацию и её вещи.
	// Возвращает сгенерированный ID рекомендации.
	CreateRecommendation(ctx context.Context, rec *domain.RecommendationResponse) (int, error)

	// GetUserRecommendations возвращает истории рекомендаций пользователя (последние N штук).
	GetUserRecommendations(ctx context.Context, userID, limit int) ([]domain.RecommendationResponse, error)

	// GetRecommendationByID возвращает рекомендацию с её вещами по ID.
	GetRecommendationByID(ctx context.Context, id int) (*domain.RecommendationResponse, error)
}
