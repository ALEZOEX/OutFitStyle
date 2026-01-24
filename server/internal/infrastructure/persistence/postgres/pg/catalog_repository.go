package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type CatalogRepository struct {
	db *pgxpool.Pool
}

func NewCatalogRepository(db *pgxpool.Pool) *CatalogRepository {
	return &CatalogRepository{db: db}
}

func (r *CatalogRepository) GetItems(ctx context.Context, filters domain.CatalogFilters) ([]domain.CatalogItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *CatalogRepository) GetItemByID(ctx context.Context, itemID domain.ID) (*domain.CatalogItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *CatalogRepository) CreateItem(ctx context.Context, item *domain.CatalogItem) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *CatalogRepository) UpdateItem(ctx context.Context, item *domain.CatalogItem) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *CatalogRepository) DeleteItem(ctx context.Context, itemID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *CatalogRepository) Search(ctx context.Context, p repositories.CatalogSearchParams) (items []domain.ClothingItem, total int, err error) {
	// TODO: Implement
	return nil, 0, fmt.Errorf("not implemented")
}

func (r *CatalogRepository) Categories(ctx context.Context) (any, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *CatalogRepository) GetItem(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *CatalogRepository) Similar(ctx context.Context, id domain.ID, limit int) ([]domain.ClothingItem, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *CatalogRepository) Click(ctx context.Context, userID *domain.ID, itemID domain.ID) (string, error) {
	// TODO: Implement
	return "", fmt.Errorf("not implemented")
}