package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type SubscriptionRepository interface {
	ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error)

	// Если активной подписки нет — возвращаем nil, nil (сервис подставит free)
	GetActiveSubscription(ctx context.Context, userID int64) (*domain.UserSubscription, error)

	// План по коду (нужен для free fallback)
	GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error)

	CountRecommendationsToday(ctx context.Context, userID int64) (int, error)
	CountWardrobeItems(ctx context.Context, userID int64) (int, error)
}