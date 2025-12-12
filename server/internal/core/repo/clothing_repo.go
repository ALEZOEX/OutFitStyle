package repo

import (
	"context"
	"outfit-style-rec/server/internal/core/domain"
)

type SubcategorySpecRepository interface {
	ListAll(ctx context.Context) ([]domain.SubcategorySpec, error)
	Get(ctx context.Context, category, subcategory string) (domain.SubcategorySpec, error)
}

type ClothingItemRepository interface {
	BulkInsert(ctx context.Context, items []domain.ClothingItem) error

	GetByID(ctx context.Context, id int64) (domain.ClothingItem, error)

	FindCandidatesByPlan(ctx context.Context, category string, subcategories []string, warmthMin int16, temp int16, limit int) ([]domain.ClothingItem, error)
}