package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type PushTokenRepository struct {
	db *pgxpool.Pool
}

func NewPushTokenRepository(db *pgxpool.Pool) *PushTokenRepository {
	return &PushTokenRepository{db: db}
}

func (r *PushTokenRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.PushToken, error) {
	query := `
		SELECT
			id, user_id, token, platform, device_id, is_active, last_used_at, created_at
		FROM push_tokens
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query push tokens by user")
	}
	defer rows.Close()

	var tokens []domain.PushToken
	for rows.Next() {
		var token domain.PushToken
		var deviceID *string
		var lastUsedAt *time.Time
		var createdAt time.Time

		err := rows.Scan(
			&token.ID,
			&token.UserID,
			&token.Token,
			&token.Platform,
			&deviceID,
			&token.IsActive,
			&lastUsedAt,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan push token")
		}

		// Set nullable fields
		token.DeviceID = deviceID
		if lastUsedAt != nil {
			token.LastUsedAt = lastUsedAt
		}
		token.CreatedAt = createdAt

		tokens = append(tokens, token)
	}

	return tokens, nil
}

func (r *PushTokenRepository) Upsert(ctx context.Context, userID domain.ID, token string, platform string, deviceID *string) error {
	query := `
		INSERT INTO push_tokens (
			id, user_id, token, platform, device_id, is_active, last_used_at, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (user_id, token)
		DO UPDATE SET
			platform = $4, device_id = $5, is_active = $6, last_used_at = $7, updated_at = $9
	`

	id := domain.NewID()
	now := time.Now()

	_, err := r.db.Exec(ctx, query,
		id,
		userID,
		token,
		platform,
		deviceID,
		true, // is_active
		now,  // last_used_at
		now,  // created_at
		now,  // updated_at
	)
	if err != nil {
		return errors.Wrap(err, "failed to upsert push token")
	}

	return nil
}

func (r *PushTokenRepository) Deactivate(ctx context.Context, userID domain.ID, token string) error {
	query := `
		UPDATE push_tokens
		SET is_active = false, updated_at = $1
		WHERE user_id = $2 AND token = $3
	`

	_, err := r.db.Exec(ctx, query, time.Now(), userID, token)
	if err != nil {
		return errors.Wrap(err, "failed to deactivate push token")
	}

	return nil
}

func (r *PushTokenRepository) ListActiveByUser(ctx context.Context, userID domain.ID) ([]domain.PushToken, error) {
	query := `
		SELECT
			id, user_id, token, platform, device_id, is_active, last_used_at, created_at
		FROM push_tokens
		WHERE user_id = $1 AND is_active = true
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query active push tokens by user")
	}
	defer rows.Close()

	var tokens []domain.PushToken
	for rows.Next() {
		var token domain.PushToken
		var deviceID *string
		var lastUsedAt *time.Time
		var createdAt time.Time

		err := rows.Scan(
			&token.ID,
			&token.UserID,
			&token.Token,
			&token.Platform,
			&deviceID,
			&token.IsActive,
			&lastUsedAt,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan push token")
		}

		// Set nullable fields
		token.DeviceID = deviceID
		if lastUsedAt != nil {
			token.LastUsedAt = lastUsedAt
		}
		token.CreatedAt = createdAt

		tokens = append(tokens, token)
	}

	return tokens, nil
}

func (r *PushTokenRepository) Delete(ctx context.Context, userID domain.ID, deviceID string) error {
	query := `
		DELETE FROM push_tokens
		WHERE user_id = $1 AND device_id = $2
	`

	_, err := r.db.Exec(ctx, query, userID, deviceID)
	if err != nil {
		return errors.Wrap(err, "failed to delete push tokens for device")
	}

	return nil
}
