package services

import (
	"context"

	"outfitstyle/server/internal/core/application/repositories"
)

type FeatureFlagService struct {
	repo repositories.FeatureFlagRepository
}

func NewFeatureFlagService(r repositories.FeatureFlagRepository) *FeatureFlagService {
	return &FeatureFlagService{repo: r}
}

func (s *FeatureFlagService) List(ctx context.Context) ([]repositories.FeatureFlag, error) {
	return s.repo.List(ctx)
}

func (s *FeatureFlagService) IsEnabled(ctx context.Context, key string) (bool, error) {
	f, err := s.repo.Get(ctx, key)
	if err != nil {
		return false, err
	}
	if f == nil {
		return false, nil
	}
	return f.Enabled, nil
}

func (s *FeatureFlagService) SetEnabled(ctx context.Context, key string, enabled bool) error {
	return s.repo.SetEnabled(ctx, key, enabled)
}
