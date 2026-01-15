package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

type TripRepository interface {
	List(ctx context.Context, userID domain.ID) ([]domain.Trip, error)
	Create(ctx context.Context, userID domain.ID, req domain.TripCreateRequest) (*domain.Trip, error)
	Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.Trip, error)
	Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.TripUpdateRequest) (*domain.Trip, error)
	Delete(ctx context.Context, userID domain.ID, id domain.ID) error
}
