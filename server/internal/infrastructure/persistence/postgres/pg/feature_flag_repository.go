package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

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
	query := `
		SELECT id, key, name, description, is_enabled, created_at, updated_at
		FROM feature_flags
		WHERE id = $1
	`

	var flag domain.FeatureFlag

	err := r.db.QueryRow(ctx, query, flagID).Scan(
		&flag.ID,
		&flag.Key,
		&flag.Name,
		&flag.Description,
		&flag.IsEnabled,
		&flag.CreatedAt,
		&flag.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get feature flag")
	}

	return &flag, nil
}

func (r *FeatureFlagRepository) GetAllFlags(ctx context.Context) ([]domain.FeatureFlag, error) {
	query := `
		SELECT id, key, name, description, is_enabled, created_at, updated_at
		FROM feature_flags
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query feature flags")
	}
	defer rows.Close()

	var flags []domain.FeatureFlag
	for rows.Next() {
		var flag domain.FeatureFlag

		err := rows.Scan(
			&flag.ID,
			&flag.Key,
			&flag.Name,
			&flag.Description,
			&flag.IsEnabled,
			&flag.CreatedAt,
			&flag.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan feature flag")
		}

		flags = append(flags, flag)
	}

	return flags, nil
}

func (r *FeatureFlagRepository) UpdateFlag(ctx context.Context, flag *domain.FeatureFlag) error {
	query := `
		UPDATE feature_flags
		SET name = $1, description = $2, is_enabled = $3, updated_at = $4
		WHERE id = $5
	`

	_, err := r.db.Exec(ctx, query,
		flag.Name,
		flag.Description,
		flag.IsEnabled,
		time.Now(),
		flag.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update feature flag")
	}

	return nil
}

func (r *FeatureFlagRepository) List(ctx context.Context) ([]repositories.FeatureFlag, error) {
	query := `
		SELECT id, key, name, description, is_enabled, created_at, updated_at
		FROM feature_flags
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query feature flags")
	}
	defer rows.Close()

	var flags []repositories.FeatureFlag
	for rows.Next() {
		var flag repositories.FeatureFlag

		err := rows.Scan(
			&flag.ID,
			&flag.Key,
			&flag.Name,
			&flag.Description,
			&flag.IsEnabled,
			&flag.CreatedAt,
			&flag.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan feature flag")
		}

		flags = append(flags, flag)
	}

	return flags, nil
}

func (r *FeatureFlagRepository) Get(ctx context.Context, key string) (*repositories.FeatureFlag, error) {
	query := `
		SELECT id, key, name, description, is_enabled, created_at, updated_at
		FROM feature_flags
		WHERE key = $1
	`

	var flag repositories.FeatureFlag

	err := r.db.QueryRow(ctx, query, key).Scan(
		&flag.ID,
		&flag.Key,
		&flag.Name,
		&flag.Description,
		&flag.IsEnabled,
		&flag.CreatedAt,
		&flag.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get feature flag by key")
	}

	return &flag, nil
}

func (r *FeatureFlagRepository) SetEnabled(ctx context.Context, key string, enabled bool) error {
	query := `
		UPDATE feature_flags
		SET is_enabled = $1, updated_at = $2
		WHERE key = $3
	`

	_, err := r.db.Exec(ctx, query, enabled, time.Now(), key)
	if err != nil {
		return errors.Wrap(err, "failed to set feature flag enabled status")
	}

	return nil
}
