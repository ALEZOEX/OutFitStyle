package pg

import (
	"context"
	"strings"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type PushTokenRepository struct {
	db *dbpkg.DB
}

func NewPushTokenRepository(db *dbpkg.DB) repositories.PushTokenRepository {
	return &PushTokenRepository{db: db}
}

func (r *PushTokenRepository) Upsert(ctx context.Context, userID domain.ID, token string, platform string, deviceID *string) error {
	token = strings.TrimSpace(token)
	platform = strings.ToLower(strings.TrimSpace(platform))
	if token == "" {
		return errors.New("token is required")
	}
	if platform != "ios" && platform != "android" && platform != "web" {
		return errors.New("platform must be ios, android, or web")
	}

	_, err := r.db.Pool().Exec(ctx, `
INSERT INTO push_tokens (user_id, token, platform, device_id, is_active)
VALUES ($1,$2,$3,$4,TRUE)
ON CONFLICT (token) DO UPDATE
SET user_id = EXCLUDED.user_id,
platform = EXCLUDED.platform,
device_id = EXCLUDED.device_id,
is_active = TRUE,
last_used_at = NOW()
`, userID, token, platform, deviceID)
	return errors.Wrap(err, "upsert push token")
}

func (r *PushTokenRepository) Deactivate(ctx context.Context, userID domain.ID, token string) error {
	token = strings.TrimSpace(token)
	if token == "" {
		return errors.New("token is required")
	}

	cmd, err := r.db.Pool().Exec(ctx, `
UPDATE push_tokens
SET is_active = FALSE, last_used_at = NOW()
WHERE user_id = $1 AND token = $2
`, userID, token)
	if err != nil {
		return errors.Wrap(err, "deactivate push token")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *PushTokenRepository) ListActiveByUser(ctx context.Context, userID domain.ID) ([]domain.PushToken, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT id, user_id, token, platform, device_id, is_active, last_used_at, created_at
FROM push_tokens
WHERE user_id = $1 AND is_active = TRUE
ORDER BY last_used_at DESC
`, userID)
	if err != nil {
		return nil, errors.Wrap(err, "list active push tokens")
	}
	defer rows.Close()

	var out []domain.PushToken
	for rows.Next() {
		var t domain.PushToken
		if err := rows.Scan(&t.ID, &t.UserID, &t.Token, &t.Platform, &t.DeviceID, &t.IsActive, &t.LastUsedAt, &t.CreatedAt); err != nil {
			return nil, errors.Wrap(err, "scan push token")
		}
		out = append(out, t)
	}
	return out, rows.Err()
}
