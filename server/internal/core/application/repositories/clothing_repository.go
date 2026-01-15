package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

type ClothingRepository interface {
	GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error)
	GetByIDs(ctx context.Context, ids []domain.ID) ([]domain.ClothingItem, error)

	// Кандидаты для ML
	ListWardrobeCandidates(ctx context.Context, userID domain.ID, limit int) ([]domain.ClothingItem, error)
	ListCatalogCandidates(ctx context.Context, includePartners bool, limit int) ([]domain.ClothingItem, error)

	// Lite кандидаты (для рекомендаций)
	ListWardrobeCandidatesLite(ctx context.Context, userID domain.ID, limit int) ([]domain.CandidateLite, error)
	ListCatalogCandidatesLite(ctx context.Context, includePartners bool, limit int) ([]domain.CandidateLite, error)

	CreateUserItem(ctx context.Context, userID domain.ID, item domain.ClothingItem) (domain.ID, error)
}
