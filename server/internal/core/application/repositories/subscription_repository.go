package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// SubscriptionRepository интерфейс репозитория подписок
type SubscriptionRepository interface {
	// ListPlans возвращает список всех доступных планов подписки
	ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error)

	// GetActiveSubscription возвращает активную подписку пользователя
	// Если активной подписки нет — возвращаем nil, nil (сервис подставит free)
	GetActiveSubscription(ctx context.Context, userID int64) (*domain.UserSubscription, error)

	// GetPlanByCode возвращает план подписки по коду
	// План по коду (нужен для free fallback)
	GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error)

	// CountRecommendationsToday возвращает количество рекомендаций, созданных пользователем сегодня
	CountRecommendationsToday(ctx context.Context, userID int64) (int, error)

	// CountWardrobeItems возвращает количество элементов в гардеробе пользователя
	CountWardrobeItems(ctx context.Context, userID int64) (int, error)
}
