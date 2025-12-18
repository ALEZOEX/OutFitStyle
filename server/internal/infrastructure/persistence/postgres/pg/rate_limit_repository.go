package pg

import (
	"context"
	"time"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type RateLimitViolationRepository struct {
	db *dbpkg.DB
}

func NewRateLimitViolationRepository(db *dbpkg.DB) repositories.RateLimitViolationRepository {
	return &RateLimitViolationRepository{db: db}
}

func (r *RateLimitViolationRepository) Record(ctx context.Context, v repositories.RateLimitViolation) error {
	if v.CreatedAt.IsZero() {
		v.CreatedAt = time.Now()
	}

	_, err := r.db.Pool().Exec(ctx, `
INSERT INTO rate_limit_violations (
identifier, identifier_type, endpoint,
limit_type, limit_value, current_value,
created_at
)
VALUES ($1,$2,$3,$4,$5,$6,$7)
`, v.Identifier, v.IdentifierType, v.Endpoint, v.LimitType, v.LimitValue, v.CurrentValue, v.CreatedAt)

	return errors.Wrap(err, "insert rate_limit_violation")
}