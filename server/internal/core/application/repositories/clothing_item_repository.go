package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// ClothingItemRepository интерфейс для работы с вещами
type ClothingItemRepository interface {
	GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error)
	GetByUser(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error)
	GetAll(ctx context.Context) ([]domain.ClothingItem, error)
	Create(ctx context.Context, item *domain.ClothingItem) error
	Update(ctx context.Context, item *domain.ClothingItem) error
	Delete(ctx context.Context, id domain.ID) error
	GetByFilters(ctx context.Context, filters domain.ClothingItemFilters) ([]domain.ClothingItem, error)
	LinkToWardrobe(ctx context.Context, userID, itemID domain.ID) error
	UnlinkFromWardrobe(ctx context.Context, userID, itemID domain.ID) error
	GetByUserWardrobe(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error)
	IsInWardrobe(ctx context.Context, userID, itemID domain.ID) (bool, error)
}