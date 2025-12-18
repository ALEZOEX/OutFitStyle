package services

import (
	"context"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type SavedOutfitService struct{ repo repositories.SavedOutfitRepository }

func NewSavedOutfitService(r repositories.SavedOutfitRepository) *SavedOutfitService { return &SavedOutfitService{repo: r} }

func (s *SavedOutfitService) List(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error) {
	return s.repo.List(ctx, userID)
}
func (s *SavedOutfitService) Create(ctx context.Context, userID domain.ID, req domain.SavedOutfitCreateRequest) (*domain.SavedOutfit, error) {
	return s.repo.Create(ctx, userID, req)
}
func (s *SavedOutfitService) Get(ctx context.Context, userID, id domain.ID) (*domain.SavedOutfit, error) {
	return s.repo.Get(ctx, userID, id)
}
func (s *SavedOutfitService) Update(ctx context.Context, userID, id domain.ID, req domain.SavedOutfitUpdateRequest) (*domain.SavedOutfit, error) {
	return s.repo.Update(ctx, userID, id, req)
}
func (s *SavedOutfitService) Delete(ctx context.Context, userID, id domain.ID) error {
	return s.repo.Delete(ctx, userID, id)
}
func (s *SavedOutfitService) Worn(ctx context.Context, userID, id domain.ID) (*domain.SavedOutfit, error) {
	return s.repo.MarkWorn(ctx, userID, id)
}