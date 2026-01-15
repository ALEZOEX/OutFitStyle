package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type FeatureFlag struct {
	ID          domain.ID
	Key         string
	Name        string
	Description *string

	Enabled      bool
	DefaultValue []byte
	Rules        []byte
}

type FeatureFlagRepository interface {
	List(ctx context.Context) ([]FeatureFlag, error)
	Get(ctx context.Context, key string) (*FeatureFlag, error)
	SetEnabled(ctx context.Context, key string, enabled bool) error
}
