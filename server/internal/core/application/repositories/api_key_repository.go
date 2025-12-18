package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

type APIKeyRecord struct {
	ID domain.ID
	UserID domain.ID

	KeyPrefix string
	KeyHash   string

	Name *string
	Description *string

	Permissions []string
	AllowedOrigins []string

	RateLimitPerMinute int
	RateLimitPerDay    int

	IsActive bool
	LastUsedAt *time.Time
	ExpiresAt  *time.Time

	CreatedAt time.Time
}

type APIKeyRepository interface {
	Create(ctx context.Context, rec APIKeyRecord) (domain.ID, error)
	ListByUser(ctx context.Context, userID domain.ID) ([]APIKeyRecord, error)
	Deactivate(ctx context.Context, userID domain.ID, apiKeyID domain.ID) error

	FindByHash(ctx context.Context, keyHash string) (*APIKeyRecord, error)
	TouchLastUsed(ctx context.Context, apiKeyID domain.ID) error
}