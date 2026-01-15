package pg

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type FeatureFlagRepository struct{ db *dbpkg.DB }

func NewFeatureFlagRepository(db *dbpkg.DB) repositories.FeatureFlagRepository {
	return &FeatureFlagRepository{db: db}
}

func (r *FeatureFlagRepository) List(ctx context.Context) ([]repositories.FeatureFlag, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT id, key, name, description, enabled, rules, default_value
FROM feature_flags
ORDER BY key ASC
`)
	if err != nil {
		return nil, errors.Wrap(err, "list feature_flags")
	}
	defer rows.Close()

	var out []repositories.FeatureFlag
	for rows.Next() {
		var f repositories.FeatureFlag
		if err := rows.Scan(&f.ID, &f.Key, &f.Name, &f.Description, &f.Enabled, &f.Rules, &f.DefaultValue); err != nil {
			return nil, errors.Wrap(err, "scan feature flag")
		}
		out = append(out, f)
	}
	return out, rows.Err()
}

func (r *FeatureFlagRepository) Get(ctx context.Context, key string) (*repositories.FeatureFlag, error) {
	var f repositories.FeatureFlag
	err := r.db.Pool().QueryRow(ctx, `
SELECT id, key, name, description, enabled, rules, default_value
FROM feature_flags
WHERE key = $1
`, key).Scan(&f.ID, &f.Key, &f.Name, &f.Description, &f.Enabled, &f.Rules, &f.DefaultValue)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get feature flag")
	}
	return &f, nil
}

func (r *FeatureFlagRepository) SetEnabled(ctx context.Context, key string, enabled bool) error {
	cmd, err := r.db.Pool().Exec(ctx, `
UPDATE feature_flags SET enabled = $1, updated_at = NOW()
WHERE key = $2
`, enabled, key)
	if err != nil {
		return errors.Wrap(err, "set feature flag enabled")
	}
	if cmd.RowsAffected() == 0 {
		return errors.New("not found")
	}
	return nil
}
