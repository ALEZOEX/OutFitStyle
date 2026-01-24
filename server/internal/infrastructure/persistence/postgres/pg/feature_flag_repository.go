package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type FeatureFlagRepository struct {
	db *pgxpool.Pool
}

func NewFeatureFlagRepository(db *pgxpool.Pool) *FeatureFlagRepository {
	return &FeatureFlagRepository{db: db}
}

func (r *FeatureFlagRepository) GetFlag(ctx context.Context, flagID string) (*domain.FeatureFlag, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *FeatureFlagRepository) GetAllFlags(ctx context.Context) ([]domain.FeatureFlag, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *FeatureFlagRepository) UpdateFlag(ctx context.Context, flag *domain.FeatureFlag) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *FeatureFlagRepository) List(ctx context.Context) ([]repositories.FeatureFlag, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *FeatureFlagRepository) Get(ctx context.Context, key string) (*repositories.FeatureFlag, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *FeatureFlagRepository) SetEnabled(ctx context.Context, key string, enabled bool) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}