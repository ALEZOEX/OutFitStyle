package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type WardrobeRepository interface {
	List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) (items []domain.WardrobeItem, total int, err error)
	GetByID(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error)

	Add(ctx context.Context, userID domain.ID, clothingItemID domain.ID, customName *string, notes *string, tags []string) (*domain.WardrobeItem, error)
	Update(ctx context.Context, userID domain.ID, wardrobeID domain.ID, patch domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error)
	Delete(ctx context.Context, userID domain.ID, wardrobeID domain.ID) error

	SetFavorite(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isFavorite bool) error
	SetArchived(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isArchived bool) error
	MarkWorn(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error)

	IsInWardrobe(ctx context.Context, userID domain.ID, clothingItemID domain.ID) (bool, error)
}