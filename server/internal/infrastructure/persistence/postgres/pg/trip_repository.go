package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type TripRepository struct {
	db *pgxpool.Pool
}

func NewTripRepository(db *pgxpool.Pool) *TripRepository {
	return &TripRepository{db: db}
}

func (r *TripRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.Trip, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *TripRepository) GetByID(ctx context.Context, tripID domain.ID) (*domain.Trip, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *TripRepository) Create(ctx context.Context, trip *domain.Trip) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *TripRepository) Update(ctx context.Context, trip *domain.Trip) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *TripRepository) Delete(ctx context.Context, tripID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}