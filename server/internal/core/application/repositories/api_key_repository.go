package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

type APIKeyCreateRecord struct {
	ClientID  domain.ID
	KeyPrefix string
	KeyHash   []byte

	Name        *string
	Description *string

	Permissions []string

	IsActive  bool
	ExpiresAt *time.Time
}

type APIKeyRecord struct {
	ID       domain.ID
	ClientID domain.ID

	KeyPrefix string

	Name        *string
	Description *string

	Permissions []string

	IsActive   bool
	LastUsedAt *time.Time
	ExpiresAt  *time.Time
	CreatedAt  time.Time
}

// APIKeyAuthRecord represents the data needed for API key authentication
type APIKeyAuthRecord struct {
	APIKeyID domain.ID
	ClientID domain.ID
	KeyHash  []byte

	Permissions []string

	IsActive  bool
	ExpiresAt *time.Time

	// Limits from the client record
	RateLimitPerMinute int
	RateLimitPerDay    int
}

type APIKeyRepository interface {
	Create(ctx context.Context, rec APIKeyCreateRecord) (domain.ID, error)
	ListByClient(ctx context.Context, clientID domain.ID) ([]APIKeyRecord, error)
	Deactivate(ctx context.Context, clientID domain.ID, apiKeyID domain.ID) error

	GetForAuthByPrefix(ctx context.Context, prefix string) (*APIKeyAuthRecord, error)
	TouchLastUsed(ctx context.Context, apiKeyID domain.ID, at time.Time) error
}
