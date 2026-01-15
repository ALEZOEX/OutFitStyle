package clothing

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

type ClothingItemRepository interface {
	BulkInsert(ctx context.Context, items []domain.ClothingItem) error

	GetByID(ctx context.Context, id int64) (domain.ClothingItem, error)

	FindCandidatesByPlan(ctx context.Context, category string, subcategories []string, warmthMin int16, temp int16, limit int) ([]domain.ClothingItem, error)
}
