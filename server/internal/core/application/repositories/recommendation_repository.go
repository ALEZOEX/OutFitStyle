package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

type RecommendationItemCreate struct {
	ClothingItemID   domain.ID
	Category         string
	LayerPosition    *int
	Score            *float64
	Source           string // clothing_source
	IsFromWardrobe   bool
	AlternativesJSON []byte // nullable JSON
}

type RecommendationItemRow struct {
	ClothingItemID   domain.ID
	Category         string
	Source           string
	IsFromWardrobe   bool
	AlternativesJSON []byte
}

type RecommendationRepository interface {
	Create(ctx context.Context, rec *domain.RecommendationRecord, items []RecommendationItemCreate) (domain.ID, error)
	GetByID(ctx context.Context, id domain.ID) (*domain.RecommendationRecord, error)

	ListByUser(ctx context.Context, userID domain.ID, q domain.RecommendationListQuery) (items []domain.RecommendationRecord, total int, err error)

	GetItemRows(ctx context.Context, recommendationID domain.ID) ([]RecommendationItemRow, error)

	SetRating(ctx context.Context, userID, recommendationID domain.ID, rating int, thermalFeedback *string, feedback *string) (changedToPerfect bool, err error)
	SetFavorite(ctx context.Context, userID, recommendationID domain.ID, isFavorite bool) error
	ListFavorites(ctx context.Context, userID domain.ID, limit int) ([]domain.RecommendationRecord, error)
}