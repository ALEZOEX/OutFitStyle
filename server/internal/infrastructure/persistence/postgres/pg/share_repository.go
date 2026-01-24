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

func (r *ShareRepository) GetByOwner(ctx context.Context, ownerID domain.ID) ([]domain.ShareLink, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ShareRepository) UpdateShareLink(ctx context.Context, link *domain.ShareLink) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ShareRepository) CreateShare(ctx context.Context, userID domain.ID, recommendationID *domain.ID, savedOutfitID *domain.ID, showUserName bool) (string, error) {
	// TODO: Implement
	return "", fmt.Errorf("not implemented")
}

func (r *ShareRepository) GetByCode(ctx context.Context, code string) (*repositories.SharedOutfitRecord, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ShareRepository) IncViews(ctx context.Context, code string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ShareRepository) GetUserDisplayName(ctx context.Context, userID domain.ID) (*string, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ShareRepository) GetRecommendationOutfit(ctx context.Context, recommendationID domain.ID) (any, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ShareRepository) GetSavedOutfit(ctx context.Context, savedOutfitID domain.ID) (any, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}