package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type ClothingRepository struct {
	db *pgxpool.Pool
}

func NewClothingRepository(db *pgxpool.Pool, logger interface{}) *ClothingRepository {
	return &ClothingRepository{db: db}
}

func (r *ClothingRepository) GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ClothingRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ClothingRepository) Create(ctx context.Context, item *domain.ClothingItem) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ClothingRepository) Update(ctx context.Context, item *domain.ClothingItem) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ClothingRepository) Delete(ctx context.Context, id domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ClothingRepository) GetByCategory(ctx context.Context, userID domain.ID, category string) ([]domain.ClothingItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}