package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/domain"
)

type SavedOutfitRepository struct {
	db *pgxpool.Pool
}

func NewSavedOutfitRepository(db *pgxpool.Pool) *SavedOutfitRepository {
	return &SavedOutfitRepository{db: db}
}

func (r *SavedOutfitRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SavedOutfitRepository) GetByID(ctx context.Context, outfitID domain.ID) (*domain.SavedOutfit, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SavedOutfitRepository) List(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SavedOutfitRepository) Create(ctx context.Context, userID domain.ID, req domain.SavedOutfitCreateRequest) (*domain.SavedOutfit, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SavedOutfitRepository) Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SavedOutfitRepository) Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.SavedOutfitUpdateRequest) (*domain.SavedOutfit, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SavedOutfitRepository) Delete(ctx context.Context, userID domain.ID, id domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SavedOutfitRepository) MarkWorn(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}