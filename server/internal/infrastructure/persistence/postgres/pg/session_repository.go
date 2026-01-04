package pg

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type SessionRepository struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

func NewSessionRepository(db *dbpkg.DB, logger *zap.Logger) repositories.SessionRepository {
	return &SessionRepository{db: db, logger: logger}
}

func (r *SessionRepository) Create(ctx context.Context, p repositories.CreateSessionParams) (domain.ID, error) {
	q := `
INSERT INTO user_sessions (
user_id,
refresh_token_hash,
device_id, device_name, device_type,
ip_address, user_agent,
is_active,
expires_at
)
VALUES ($1,$2,$3,$4,$5,$6,$7,TRUE,$8)
RETURNING id
`
	var id domain.ID
	err := r.db.Pool().QueryRow(ctx, q,
		p.UserID,
		p.RefreshTokenHash,
		p.DeviceID, p.DeviceName, p.DeviceType,
		p.IPAddress, p.UserAgent,
		p.ExpiresAt,
	).Scan(&id)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "create session")
	}
	return id, nil
}

func (r *SessionRepository) GetByID(ctx context.Context, sessionID domain.ID) (*repositories.Session, error) {
	q := `
SELECT
id, user_id, refresh_token_hash,
device_id, device_name, device_type,
ip_address::text, user_agent,
is_active, expires_at, created_at, last_used_at
FROM user_sessions
WHERE id = $1
`
	var s repositories.Session
	err := r.db.Pool().QueryRow(ctx, q, sessionID).Scan(
		&s.ID,
		&s.UserID,
		&s.RefreshTokenHash,
		&s.DeviceID, &s.DeviceName, &s.DeviceType,
		&s.IPAddress, &s.UserAgent,
		&s.IsActive, &s.ExpiresAt, &s.CreatedAt, &s.LastUsedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get session by id")
	}
	return &s, nil
}

func (r *SessionRepository) GetByRefreshHash(ctx context.Context, refreshHash string) (*repositories.Session, error) {
	q := `
SELECT
id, user_id, refresh_token_hash,
device_id, device_name, device_type,
ip_address::text, user_agent,
is_active, expires_at, created_at, last_used_at
FROM user_sessions
WHERE refresh_token_hash = $1
`
	var s repositories.Session
	err := r.db.Pool().QueryRow(ctx, q, refreshHash).Scan(
		&s.ID,
		&s.UserID,
		&s.RefreshTokenHash,
		&s.DeviceID, &s.DeviceName, &s.DeviceType,
		&s.IPAddress, &s.UserAgent,
		&s.IsActive, &s.ExpiresAt, &s.CreatedAt, &s.LastUsedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get session by refresh hash")
	}
	return &s, nil
}

func (r *SessionRepository) RotateRefresh(ctx context.Context, sessionID domain.ID, newRefreshHash string, newExpiresAt time.Time) error {
	q := `
UPDATE user_sessions
SET refresh_token_hash = $1, expires_at = $2, last_used_at = NOW()
WHERE id = $3 AND is_active = TRUE
`
	cmd, err := r.db.Pool().Exec(ctx, q, newRefreshHash, newExpiresAt, sessionID)
	if err != nil {
		return errors.Wrap(err, "rotate refresh")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *SessionRepository) Touch(ctx context.Context, sessionID domain.ID) error {
	q := `UPDATE user_sessions SET last_used_at = NOW() WHERE id = $1 AND is_active = TRUE`
	_, err := r.db.Pool().Exec(ctx, q, sessionID)
	return errors.Wrap(err, "touch session")
}

func (r *SessionRepository) Revoke(ctx context.Context, sessionID domain.ID) error {
	q := `UPDATE user_sessions SET is_active = FALSE, last_used_at = NOW() WHERE id = $1`
	cmd, err := r.db.Pool().Exec(ctx, q, sessionID)
	if err != nil {
		return errors.Wrap(err, "revoke session")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *SessionRepository) RevokeAllForUser(ctx context.Context, userID domain.ID) error {
	q := `UPDATE user_sessions SET is_active = FALSE, last_used_at = NOW() WHERE user_id = $1`
	_, err := r.db.Pool().Exec(ctx, q, userID)
	return errors.Wrap(err, "revoke all sessions")
}

func (r *SessionRepository) RevokeForUser(ctx context.Context, userID domain.ID, sessionID domain.ID) error {
	q := `UPDATE user_sessions SET is_active = FALSE, last_used_at = NOW() WHERE id = $1 AND user_id = $2`
	cmd, err := r.db.Pool().Exec(ctx, q, sessionID, userID)
	if err != nil {
		return errors.Wrap(err, "revoke session for user")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *SessionRepository) UpdateDeviceInfo(ctx context.Context, sessionID domain.ID, p repositories.UpdateDeviceInfoParams) error {
	query := `UPDATE user_sessions SET updated_at = NOW()`
	args := []interface{}{sessionID}
	argIndex := 2

	if p.DeviceID != nil {
		query += fmt.Sprintf(", device_id = $%d", argIndex)
		args = append(args, *p.DeviceID)
		argIndex++
	}
	if p.DeviceName != nil {
		query += fmt.Sprintf(", device_name = $%d", argIndex)
		args = append(args, *p.DeviceName)
		argIndex++
	}
	if p.DeviceType != nil {
		query += fmt.Sprintf(", device_type = $%d", argIndex)
		args = append(args, *p.DeviceType)
		argIndex++
	}
	if p.IPAddress != nil {
		query += fmt.Sprintf(", ip_address = $%d", argIndex)
		args = append(args, *p.IPAddress)
		argIndex++
	}
	if p.UserAgent != nil {
		query += fmt.Sprintf(", user_agent = $%d", argIndex)
		args = append(args, *p.UserAgent)
		argIndex++
	}

	query += " WHERE id = $1"

	_, err := r.db.Pool().Exec(ctx, query, args...)
	return err
}

func (r *SessionRepository) ListByUser(ctx context.Context, userID domain.ID) ([]repositories.Session, error) {
	q := `
SELECT
id, user_id, refresh_token_hash,
device_id, device_name, device_type,
ip_address::text, user_agent,
is_active, expires_at, created_at, last_used_at
FROM user_sessions
WHERE user_id = $1
ORDER BY last_used_at DESC
`
	rows, err := r.db.Pool().Query(ctx, q, userID)
	if err != nil {
		return nil, errors.Wrap(err, "list sessions")
	}
	defer rows.Close()

	var out []repositories.Session
	for rows.Next() {
		var s repositories.Session
		if err := rows.Scan(
			&s.ID, &s.UserID, &s.RefreshTokenHash,
			&s.DeviceID, &s.DeviceName, &s.DeviceType,
			&s.IPAddress, &s.UserAgent,
			&s.IsActive, &s.ExpiresAt, &s.CreatedAt, &s.LastUsedAt,
		); err != nil {
			return nil, errors.Wrap(err, "scan session")
		}
		out = append(out, s)
	}
	return out, rows.Err()
}