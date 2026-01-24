package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/domain"
)

type WardrobeRepository struct {
	db *pgxpool.Pool
}

func NewWardrobeRepository(db *pgxpool.Pool) *WardrobeRepository {
	return &WardrobeRepository{db: db}
}

func (r *WardrobeRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.WardrobeItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) AddItem(ctx context.Context, item *domain.WardrobeItem) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) RemoveItem(ctx context.Context, userID domain.ID, itemID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) UpdateItem(ctx context.Context, item *domain.WardrobeItem) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) (items []domain.WardrobeItem, total int, err error) {
	// TODO: Implement
	return nil, 0, fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) GetByID(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) Add(ctx context.Context, userID domain.ID, clothingItemID domain.ID, customName *string, notes *string, tags []string) (*domain.WardrobeItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) Update(ctx context.Context, userID domain.ID, wardrobeID domain.ID, patch domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) Delete(ctx context.Context, userID domain.ID, wardrobeID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) SetFavorite(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isFavorite bool) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) SetArchived(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isArchived bool) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) MarkWorn(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *WardrobeRepository) IsInWardrobe(ctx context.Context, userID domain.ID, clothingItemID domain.ID) (bool, error) {
	// TODO: Implement
	return false, fmt.Errorf("not implemented")
}