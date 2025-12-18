package services

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

var (
	ErrRecommendationsLimitExceeded = errors.New("recommendations daily limit exceeded")
	ErrWardrobeLimitExceeded        = errors.New("wardrobe items limit exceeded")
)

type SubscriptionService struct {
	repo repositories.SubscriptionRepository
}

func NewSubscriptionService(repo repositories.SubscriptionRepository) *SubscriptionService {
	return &SubscriptionService{repo: repo}
}

func (s *SubscriptionService) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	return s.repo.ListPlans(ctx)
}

func (s *SubscriptionService) GetCurrent(ctx context.Context, userID domain.ID) (*domain.CurrentSubscriptionResponse, error) {
	userIDInt := domain.IDToInt64(userID)
	sub, err := s.repo.GetActiveSubscription(ctx, userIDInt)
	if err != nil {
		return nil, err
	}

	var effective domain.UserSubscription
	if sub == nil {
		freePlan, err := s.repo.GetPlanByCode(ctx, "free")
		if err != nil {
			return nil, err
		}
		if freePlan == nil {
			return nil, errors.New("free plan not found in DB")
		}

		effective = domain.UserSubscription{
			ID:     nil,
			UserID: userIDInt,
			Plan:   *freePlan,
		}
	} else {
		effective = *sub
	}

	recToday, err := s.repo.CountRecommendationsToday(ctx, userIDInt)
	if err != nil {
		return nil, err
	}

	wardrobeCount, err := s.repo.CountWardrobeItems(ctx, userIDInt)
	if err != nil {
		return nil, err
	}

	usage := domain.SubscriptionUsage{
		RecommendationsToday: recToday,
		RecommendationsLimit: effective.Plan.RecommendationsPerDay,
		WardrobeCount:        wardrobeCount,
		WardrobeLimit:        effective.Plan.WardrobeItemsLimit,
	}

	return &domain.CurrentSubscriptionResponse{
		Subscription: effective,
		Usage:        usage,
	}, nil
}

func (s *SubscriptionService) CheckCanCreateRecommendation(ctx context.Context, userID domain.ID) error {
	cur, err := s.GetCurrent(ctx, userID)
	if err != nil {
		return err
	}
	limit := cur.Usage.RecommendationsLimit
	if limit != nil && cur.Usage.RecommendationsToday >= *limit {
		return ErrRecommendationsLimitExceeded
	}
	return nil
}

func (s *SubscriptionService) CheckCanAddWardrobeItem(ctx context.Context, userID domain.ID) error {
	cur, err := s.GetCurrent(ctx, userID)
	if err != nil {
		return err
	}
	limit := cur.Usage.WardrobeLimit
	if limit != nil && cur.Usage.WardrobeCount >= *limit {
		return ErrWardrobeLimitExceeded
	}
	return nil
}