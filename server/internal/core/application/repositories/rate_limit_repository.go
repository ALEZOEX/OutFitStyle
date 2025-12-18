package repositories

import (
	"context"
	"time"
)

type RateLimitViolation struct {
	Identifier     string
	IdentifierType string // user|ip|apikey
	Endpoint       string // route template or path

	LimitType   string // global_per_minute|apikey_per_day|...
	LimitValue  int
	CurrentValue int

	CreatedAt time.Time
}

type RateLimitViolationRepository interface {
	Record(ctx context.Context, v RateLimitViolation) error
}