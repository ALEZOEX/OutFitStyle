package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
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