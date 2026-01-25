package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type RateLimitViolationRepository struct {
	db *pgxpool.Pool
}

func NewRateLimitViolationRepository(db *pgxpool.Pool) *RateLimitViolationRepository {
	return &RateLimitViolationRepository{db: db}
}

func (r *RateLimitViolationRepository) RecordViolation(ctx context.Context, key string, window time.Duration) error {
	query := `
		INSERT INTO rate_limit_violations (
			id, key, violation_time, window_duration, created_at
		) VALUES ($1, $2, $3, $4, $5)
	`

	id := domain.NewID()
	now := time.Now()

	_, err := r.db.Exec(ctx, query,
		id,
		key,
		now,
		window.Seconds(),
		now,
	)
	if err != nil {
		return errors.Wrap(err, "failed to record rate limit violation")
	}

	return nil
}

func (r *RateLimitViolationRepository) GetViolationsCount(ctx context.Context, key string, window time.Duration) (int, error) {
	query := `
		SELECT COUNT(*)
		FROM rate_limit_violations
		WHERE key = $1 AND violation_time >= $2
	`

	since := time.Now().Add(-window)
	var count int

	err := r.db.QueryRow(ctx, query, key, since).Scan(&count)
	if err != nil {
		return 0, errors.Wrap(err, "failed to get rate limit violations count")
	}

	return count, nil
}

func (r *RateLimitViolationRepository) Record(ctx context.Context, v repositories.RateLimitViolation) error {
	query := `
		INSERT INTO rate_limit_violations (
			id, key, resource_type, resource_id, limit_type, limit_value, window_duration, violation_time, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	id := domain.NewID()
	now := time.Now()

	_, err := r.db.Exec(ctx, query,
		id,
		v.Key,
		v.ResourceType,
		v.ResourceID,
		v.LimitType,
		v.LimitValue,
		v.WindowDuration.Seconds(),
		v.ViolationTime,
		now,
	)
	if err != nil {
		return errors.Wrap(err, "failed to record rate limit violation")
	}

	return nil
}

func (r *RateLimitViolationRepository) CleanupOldViolations(ctx context.Context, before time.Time) error {
	query := `
		DELETE FROM rate_limit_violations
		WHERE violation_time < $1
	`

	_, err := r.db.Exec(ctx, query, before)
	if err != nil {
		return errors.Wrap(err, "failed to cleanup old rate limit violations")
	}

	return nil
}
