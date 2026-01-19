package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type ShareRepository struct {
	db *pgxpool.Pool
}

func NewShareRepository(db *pgxpool.Pool) *ShareRepository {
	return &ShareRepository{db: db}
}

func (r *ShareRepository) CreateShareLink(ctx context.Context, link *domain.ShareLink) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ShareRepository) GetByCode(ctx context.Context, code string) (*domain.ShareLink, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ShareRepository) GetByOwner(ctx context.Context, ownerID domain.ID) ([]domain.ShareLink, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ShareRepository) UpdateShareLink(ctx context.Context, link *domain.ShareLink) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}