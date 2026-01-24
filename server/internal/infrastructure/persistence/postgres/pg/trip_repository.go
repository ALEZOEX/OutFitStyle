package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

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

func (r *TripRepository) List(ctx context.Context, userID domain.ID) ([]domain.Trip, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *TripRepository) Create(ctx context.Context, userID domain.ID, req domain.TripCreateRequest) (*domain.Trip, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *TripRepository) Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.Trip, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *TripRepository) Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.TripUpdateRequest) (*domain.Trip, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *TripRepository) Delete(ctx context.Context, userID domain.ID, id domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}