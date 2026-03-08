package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type SessionRepository struct {
	db *pgxpool.Pool
}

func NewSessionRepository(db *pgxpool.Pool, logger interface{}) *SessionRepository {
	return &SessionRepository{db: db}
}

func (r *SessionRepository) CreateSession(ctx context.Context, session *domain.Session) error {
	query := `
		INSERT INTO sessions (
			id, user_id, refresh_token_hash, device_info, ip_address, user_agent,
			is_active, created_at, expires_at, last_used_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`

	_, err := r.db.Exec(ctx, query,
		session.ID,
		session.UserID,
		session.RefreshTokenHash,
		session.DeviceInfo,
		session.IPAddress,
		session.UserAgent,
		session.IsActive,
		session.CreatedAt,
		session.ExpiresAt,
		session.LastUsedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to create session")
	}

	return nil
}

func (r *SessionRepository) GetByID(ctx context.Context, sessionID domain.ID) (*repositories.Session, error) {
	query := `
		SELECT
			id, user_id, refresh_token_hash, device_info, device_id, device_name, device_type,
			ip_address::text, user_agent, is_active, created_at, expires_at, last_used_at
		FROM sessions
		WHERE id = $1
	`

	var session repositories.Session
	var deviceInfo *string
	var deviceID *string
	var deviceName *string
	var deviceType *string
	var ipAddress *string
	var userAgent *string
	var expiresAt *time.Time
	var lastUsedAt *time.Time

	err := r.db.QueryRow(ctx, query, sessionID).Scan(
		&session.ID,
		&session.UserID,
		&session.RefreshTokenHash,
		&deviceInfo,
		&deviceID,
		&deviceName,
		&deviceType,
		&ipAddress,
		&userAgent,
		&session.IsActive,
		&session.CreatedAt,
		&expiresAt,
		&lastUsedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get session by ID")
	}

	// Set nullable fields
	session.DeviceInfo = deviceInfo
	session.DeviceID = deviceID
	session.DeviceName = deviceName
	session.DeviceType = deviceType
	session.IPAddress = ipAddress
	session.UserAgent = userAgent
	session.ExpiresAt = expiresAt
	session.LastUsedAt = lastUsedAt

	return &session, nil
}

func (r *SessionRepository) GetSession(ctx context.Context, id domain.ID) (*domain.Session, error) {
	query := `
		SELECT
			id, user_id, refresh_token_hash, device_info, ip_address::text, user_agent,
			is_active, created_at, expires_at, last_used_at
		FROM sessions
		WHERE id = $1
	`

	var session domain.Session
	var deviceInfo *string
	var ipAddress *string
	var userAgent *string
	var expiresAt *time.Time
	var lastUsedAt *time.Time

	err := r.db.QueryRow(ctx, query, id).Scan(
		&session.ID,
		&session.UserID,
		&session.RefreshTokenHash,
		&deviceInfo,
		&ipAddress,
		&userAgent,
		&session.IsActive,
		&session.CreatedAt,
		&expiresAt,
		&lastUsedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get session")
	}

	// Set nullable fields
	session.DeviceInfo = deviceInfo
	session.IPAddress = ipAddress
	session.UserAgent = userAgent
	session.ExpiresAt = expiresAt
	session.LastUsedAt = lastUsedAt

	return &session, nil
}

func (r *SessionRepository) GetSessionByToken(ctx context.Context, token string) (*domain.Session, error) {
	query := `
		SELECT
			id, user_id, refresh_token_hash, device_info, ip_address::text, user_agent,
			is_active, created_at, expires_at, last_used_at
		FROM sessions
		WHERE refresh_token_hash = $1 AND is_active = true
	`

	var session domain.Session
	var deviceInfo *string
	var ipAddress *string
	var userAgent *string
	var expiresAt *time.Time
	var lastUsedAt *time.Time

	err := r.db.QueryRow(ctx, query, token).Scan(
		&session.ID,
		&session.UserID,
		&session.RefreshTokenHash,
		&deviceInfo,
		&ipAddress,
		&userAgent,
		&session.IsActive,
		&session.CreatedAt,
		&expiresAt,
		&lastUsedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get session by token")
	}

	// Set nullable fields
	session.DeviceInfo = deviceInfo
	session.IPAddress = ipAddress
	session.UserAgent = userAgent
	session.ExpiresAt = expiresAt
	session.LastUsedAt = lastUsedAt

	return &session, nil
}

func (r *SessionRepository) UpdateSession(ctx context.Context, session *domain.Session) error {
	query := `
		UPDATE sessions
		SET device_info = $1, ip_address = $2, user_agent = $3, is_active = $4,
			updated_at = $5, expires_at = $6, last_used_at = $7
		WHERE id = $8
	`

	_, err := r.db.Exec(ctx, query,
		session.DeviceInfo,
		session.IPAddress,
		session.UserAgent,
		session.IsActive,
		time.Now(),
		session.ExpiresAt,
		session.LastUsedAt,
		session.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update session")
	}

	return nil
}

func (r *SessionRepository) DeleteSession(ctx context.Context, id domain.ID) error {
	query := `DELETE FROM sessions WHERE id = $1`

	_, err := r.db.Exec(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete session")
	}

	return nil
}

func (r *SessionRepository) DeleteSessionsByUser(ctx context.Context, userID domain.ID) error {
	query := `DELETE FROM sessions WHERE user_id = $1`

	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to delete sessions by user")
	}

	return nil
}

func (r *SessionRepository) Create(ctx context.Context, p repositories.CreateSessionParams) (domain.ID, error) {
	id := domain.NewID()

	query := `
		INSERT INTO sessions (
			id, user_id, refresh_token_hash, device_info, device_id, device_name, device_type,
			ip_address, user_agent, is_active, created_at, expires_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
	`

	_, err := r.db.Exec(ctx, query,
		id,
		p.UserID,
		p.RefreshTokenHash,
		p.DeviceInfo,
		p.DeviceID,
		p.DeviceName,
		p.DeviceType,
		p.IPAddress,
		p.UserAgent,
		true, // is_active
		time.Now(),
		p.ExpiresAt,
	)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to create session")
	}

	return id, nil
}

func (r *SessionRepository) GetByRefreshHash(ctx context.Context, refreshHash string) (*repositories.Session, error) {
	query := `
		SELECT
			id, user_id, refresh_token_hash, device_info, ip_address::text, user_agent,
			is_active, created_at, expires_at, last_used_at
		FROM sessions
		WHERE refresh_token_hash = $1 AND is_active = true
	`

	var session repositories.Session
	var deviceInfo *string
	var ipAddress *string
	var userAgent *string
	var expiresAt *time.Time
	var lastUsedAt *time.Time

	err := r.db.QueryRow(ctx, query, refreshHash).Scan(
		&session.ID,
		&session.UserID,
		&session.RefreshTokenHash,
		&deviceInfo,
		&ipAddress,
		&userAgent,
		&session.IsActive,
		&session.CreatedAt,
		&expiresAt,
		&lastUsedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get session by refresh hash")
	}

	// Set nullable fields
	session.DeviceInfo = deviceInfo
	session.IPAddress = ipAddress
	session.UserAgent = userAgent
	session.ExpiresAt = expiresAt
	session.LastUsedAt = lastUsedAt

	return &session, nil
}

func (r *SessionRepository) RotateRefresh(ctx context.Context, sessionID domain.ID, newRefreshHash string, newExpiresAt time.Time) error {
	query := `
		UPDATE sessions
		SET refresh_token_hash = $1, expires_at = $2, updated_at = $3
		WHERE id = $4
	`

	_, err := r.db.Exec(ctx, query,
		newRefreshHash,
		newExpiresAt,
		time.Now(),
		sessionID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to rotate refresh token")
	}

	return nil
}

func (r *SessionRepository) Touch(ctx context.Context, sessionID domain.ID) error {
	query := `
		UPDATE sessions
		SET last_used_at = $1, updated_at = $2
		WHERE id = $3
	`

	_, err := r.db.Exec(ctx, query,
		time.Now(),
		time.Now(),
		sessionID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to touch session")
	}

	return nil
}

func (r *SessionRepository) Revoke(ctx context.Context, sessionID domain.ID) error {
	query := `
		UPDATE sessions
		SET is_active = false, updated_at = $1
		WHERE id = $2
	`

	_, err := r.db.Exec(ctx, query,
		time.Now(),
		sessionID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to revoke session")
	}

	return nil
}

func (r *SessionRepository) RevokeAllForUser(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE sessions
		SET is_active = false, updated_at = $1
		WHERE user_id = $2
	`

	_, err := r.db.Exec(ctx, query,
		time.Now(),
		userID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to revoke all sessions for user")
	}

	return nil
}

func (r *SessionRepository) RevokeForUser(ctx context.Context, userID, sessionID domain.ID) error {
	query := `
		UPDATE sessions
		SET is_active = false, updated_at = $1
		WHERE user_id = $2 AND id = $3
	`

	_, err := r.db.Exec(ctx, query,
		time.Now(),
		userID,
		sessionID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to revoke session for user")
	}

	return nil
}

func (r *SessionRepository) ListByUser(ctx context.Context, userID domain.ID) ([]repositories.Session, error) {
	query := `
		SELECT
			id, user_id, refresh_token_hash, device_info, device_id, device_name, device_type,
			ip_address::text, user_agent, is_active, created_at, expires_at, last_used_at
		FROM sessions
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query sessions by user")
	}
	defer rows.Close()

	var sessions []repositories.Session
	for rows.Next() {
		var session repositories.Session
		var deviceInfo *string
		var deviceID *string
		var deviceName *string
		var deviceType *string
		var ipAddress *string
		var userAgent *string
		var expiresAt *time.Time
		var lastUsedAt *time.Time

		err := rows.Scan(
			&session.ID,
			&session.UserID,
			&session.RefreshTokenHash,
			&deviceInfo,
			&deviceID,
			&deviceName,
			&deviceType,
			&ipAddress,
			&userAgent,
			&session.IsActive,
			&session.CreatedAt,
			&expiresAt,
			&lastUsedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan session")
		}

		// Set nullable fields
		session.DeviceInfo = deviceInfo
		session.DeviceID = deviceID
		session.DeviceName = deviceName
		session.DeviceType = deviceType
		session.IPAddress = ipAddress
		session.UserAgent = userAgent
		session.ExpiresAt = expiresAt
		session.LastUsedAt = lastUsedAt

		sessions = append(sessions, session)
	}

	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating sessions")
	}

	return sessions, nil
}
		session.DeviceInfo = deviceInfo
		session.IPAddress = ipAddress
		session.UserAgent = userAgent
		session.ExpiresAt = expiresAt
		session.LastUsedAt = lastUsedAt

		sessions = append(sessions, session)
	}

	return sessions, nil
}

func (r *SessionRepository) UpdateDeviceInfo(ctx context.Context, sessionID domain.ID, p repositories.UpdateDeviceInfoParams) error {
	query := `
		UPDATE sessions
		SET device_info = $1, device_id = $2, device_name = $3, device_type = $4,
		    ip_address = $5, user_agent = $6, updated_at = $7
		WHERE id = $8
	`

	_, err := r.db.Exec(ctx, query,
		p.DeviceInfo,
		p.DeviceID,
		p.DeviceName,
		p.DeviceType,
		p.IPAddress,
		p.UserAgent,
		time.Now(),
		sessionID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update device info")
	}

	return nil
}

func (r *SessionRepository) CleanupExpiredSessions(ctx context.Context) error {
	query := `DELETE FROM sessions WHERE expires_at < $1`

	_, err := r.db.Exec(ctx, query, time.Now())
	if err != nil {
		return errors.Wrap(err, "failed to cleanup expired sessions")
	}

	return nil
}
