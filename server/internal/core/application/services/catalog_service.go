package services

import (
	"context"
	"encoding/json"
	"time"

	"github.com/redis/go-redis/v9"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type CatalogService struct {
	repo  repositories.CatalogRepository
	cache *redis.Client
	ttl   time.Duration
}

func NewCatalogService(r repositories.CatalogRepository, cache *redis.Client) *CatalogService {
	return &CatalogService{
		repo:  r,
		cache: cache,
		ttl:  24 * time.Hour,
	}
}

func (s *CatalogService) Search(ctx context.Context, p repositories.CatalogSearchParams) ([]domain.ClothingItem, int, error) {
	return s.repo.Search(ctx, p)
}

func (s *CatalogService) Categories(ctx context.Context) (any, error) {
	const key = "catalog:categories:v1"

	if s.cache != nil {
		if val, err := s.cache.Get(ctx, key).Result(); err == nil && val != "" {
			var out any
			if e := json.Unmarshal([]byte(val), &out); e == nil {
				return out, nil
			}
		}
	}

	out, err := s.repo.Categories(ctx)
	if err != nil {
		return nil, err
	}

	if s.cache != nil {
		if b, e := json.Marshal(out); e == nil {
			_ = s.cache.Set(ctx, key, string(b), s.ttl).Err()
		}
	}

	return out, nil
}

func (s *CatalogService) GetItem(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	return s.repo.GetItem(ctx, id)
}

func (s *CatalogService) Similar(ctx context.Context, id domain.ID, limit int) ([]domain.ClothingItem, error) {
	return s.repo.Similar(ctx, id, limit)
}

func (s *CatalogService) Click(ctx context.Context, userID *domain.ID, itemID domain.ID) (string, error) {
	return s.repo.Click(ctx, userID, itemID)
}