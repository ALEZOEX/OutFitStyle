package services

import (
	"context"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type TripService struct{ repo repositories.TripRepository }

func NewTripService(r repositories.TripRepository) *TripService { return &TripService{repo: r} }

func (s *TripService) List(ctx context.Context, userID domain.ID) ([]domain.Trip, error) {
	return s.repo.List(ctx, userID)
}
func (s *TripService) Create(ctx context.Context, userID domain.ID, req domain.TripCreateRequest) (*domain.Trip, error) {
	return s.repo.Create(ctx, userID, req)
}
func (s *TripService) Get(ctx context.Context, userID, id domain.ID) (*domain.Trip, error) {
	return s.repo.Get(ctx, userID, id)
}
func (s *TripService) Update(ctx context.Context, userID, id domain.ID, req domain.TripUpdateRequest) (*domain.Trip, error) {
	return s.repo.Update(ctx, userID, id, req)
}
func (s *TripService) Delete(ctx context.Context, userID, id domain.ID) error {
	return s.repo.Delete(ctx, userID, id)
}
