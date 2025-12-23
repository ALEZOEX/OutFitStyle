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

		// ФИКС: Если в БД нет плана free, создаем временный объект, чтобы не крашиться
		var plan domain.SubscriptionPlan
		if freePlan == nil {
			limit := 3
			wardrobeLimit := 30
			historyLimit := 7
			stylesLimit := 2
			familyAccounts := 1
			plan = domain.SubscriptionPlan{
				Code: "free",
				Name: "Free (Fallback)",
				RecommendationsPerDay: &limit,
				WardrobeItemsLimit: &wardrobeLimit,
				HistoryDays: &historyLimit,
				StylesLimit: &stylesLimit,
				FamilyAccounts: familyAccounts,
				PriceMonthly: 0,
				PriceYearly: 0,
				Currency: "USD",
				Features: []byte(`["basic_recommendations", "weather_alerts", "style_tracking"]`),
				IsActive: true,
				SortOrder: 0,
			}
		} else {
			plan = *freePlan
		}

		effective = domain.UserSubscription{
			ID:     nil,
			UserID: userIDInt,
			Plan:   plan,
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