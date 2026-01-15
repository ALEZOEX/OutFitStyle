package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

type SavedOutfitRepository interface {
	List(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error)
	Create(ctx context.Context, userID domain.ID, req domain.SavedOutfitCreateRequest) (*domain.SavedOutfit, error)
	Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error)
	Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.SavedOutfitUpdateRequest) (*domain.SavedOutfit, error)
	Delete(ctx context.Context, userID domain.ID, id domain.ID) error
	MarkWorn(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error)
}
