package pg

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type APIKeyRepository struct{ db *dbpkg.DB }

func NewAPIKeyRepository(db *dbpkg.DB) repositories.APIKeyRepository {
	return &APIKeyRepository{db: db}
}

func (r *APIKeyRepository) Create(ctx context.Context, rec repositories.APIKeyRecord) (domain.ID, error) {
	q := `
INSERT INTO api_keys (
user_id, key_prefix, key_hash,
name, description,
permissions, allowed_origins,
rate_limit_per_minute, rate_limit_per_day,
is_active, expires_at
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,TRUE,$10)
RETURNING id
`
	var id domain.ID
	err := r.db.Pool().QueryRow(ctx, q,
		rec.UserID, rec.KeyPrefix, rec.KeyHash,
		rec.Name, rec.Description,
		rec.Permissions, rec.AllowedOrigins,
		rec.RateLimitPerMinute, rec.RateLimitPerDay,
		rec.ExpiresAt,
	).Scan(&id)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "create api key")
	}
	return id, nil
}

func (r *APIKeyRepository) ListByUser(ctx context.Context, userID domain.ID) ([]repositories.APIKeyRecord, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT
id, user_id, key_prefix, key_hash,
name, description,
permissions, allowed_origins,
rate_limit_per_minute, rate_limit_per_day,
is_active, last_used_at, expires_at,
created_at
FROM api_keys
WHERE user_id = $1
ORDER BY created_at DESC
`, userID)
	if err != nil {
		return nil, errors.Wrap(err, "list api keys")
	}
	defer rows.Close()

	var out []repositories.APIKeyRecord
	for rows.Next() {
		var rec repositories.APIKeyRecord
		if err := rows.Scan(
			&rec.ID, &rec.UserID, &rec.KeyPrefix, &rec.KeyHash,
			&rec.Name, &rec.Description,
			&rec.Permissions, &rec.AllowedOrigins,
			&rec.RateLimitPerMinute, &rec.RateLimitPerDay,
			&rec.IsActive, &rec.LastUsedAt, &rec.ExpiresAt,
			&rec.CreatedAt,
		); err != nil {
			return nil, errors.Wrap(err, "scan api key")
		}
		out = append(out, rec)
	}
	return out, rows.Err()
}

func (r *APIKeyRepository) Deactivate(ctx context.Context, userID domain.ID, apiKeyID domain.ID) error {
	cmd, err := r.db.Pool().Exec(ctx, `
UPDATE api_keys
SET is_active = FALSE
WHERE id = $1 AND user_id = $2
`, apiKeyID, userID)
	if err != nil {
		return errors.Wrap(err, "deactivate api key")
	}
	if cmd.RowsAffected() == 0 {
		return errors.New("not found")
	}
	return nil
}

func (r *APIKeyRepository) FindByHash(ctx context.Context, keyHash string) (*repositories.APIKeyRecord, error) {
	var rec repositories.APIKeyRecord
	err := r.db.Pool().QueryRow(ctx, `
SELECT
id, user_id, key_prefix, key_hash,
name, description,
permissions, allowed_origins,
rate_limit_per_minute, rate_limit_per_day,
is_active, last_used_at, expires_at,
created_at
FROM api_keys
WHERE key_hash = $1
LIMIT 1
`, keyHash).Scan(
		&rec.ID, &rec.UserID, &rec.KeyPrefix, &rec.KeyHash,
		&rec.Name, &rec.Description,
		&rec.Permissions, &rec.AllowedOrigins,
		&rec.RateLimitPerMinute, &rec.RateLimitPerDay,
		&rec.IsActive, &rec.LastUsedAt, &rec.ExpiresAt,
		&rec.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "find api key by hash")
	}
	return &rec, nil
}

func (r *APIKeyRepository) TouchLastUsed(ctx context.Context, apiKeyID domain.ID) error {
	_, err := r.db.Pool().Exec(ctx, `UPDATE api_keys SET last_used_at = NOW() WHERE id = $1`, apiKeyID)
	return errors.Wrap(err, "touch api key")
}
