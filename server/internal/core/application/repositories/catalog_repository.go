package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

type CatalogSearchParams struct {
	Q           *string
	Category    *string
	Subcategory *string
	Style       *string
	Color       *string

	MinPrice *float64
	MaxPrice *float64

	Partner *string // partners.code

	Page  int
	Limit int
}

type CatalogRepository interface {
	Search(ctx context.Context, p CatalogSearchParams) (items []domain.ClothingItem, total int, err error)
	Categories(ctx context.Context) (any, error) // отдаём структурой из handler
	GetItem(ctx context.Context, id domain.ID) (*domain.ClothingItem, error)
	Similar(ctx context.Context, id domain.ID, limit int) ([]domain.ClothingItem, error)

	Click(ctx context.Context, userID *domain.ID, itemID domain.ID) (redirectURL string, err error)
}
