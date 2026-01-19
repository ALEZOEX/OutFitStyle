package pg

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

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
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *RateLimitViolationRepository) GetViolationsCount(ctx context.Context, key string, window time.Duration) (int, error) {
	// TODO: Implement
	return 0, fmt.Errorf("not implemented")
}

func (r *RateLimitViolationRepository) CleanupOldViolations(ctx context.Context, before time.Time) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}