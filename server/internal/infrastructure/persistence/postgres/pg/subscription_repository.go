package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/domain"
)

type SubscriptionRepository struct {
	db *pgxpool.Pool
}

func NewSubscriptionRepository(db *pgxpool.Pool, logger interface{}) *SubscriptionRepository {
	return &SubscriptionRepository{db: db}
}

func (r *SubscriptionRepository) GetByUser(ctx context.Context, userID domain.ID) (*domain.Subscription, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) Create(ctx context.Context, sub *domain.Subscription) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) Update(ctx context.Context, sub *domain.Subscription) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) Cancel(ctx context.Context, userID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) GetPlan(ctx context.Context, planID domain.ID) (*domain.SubscriptionPlan, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) GetPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) GetActiveSubscription(ctx context.Context, userID int64) (*domain.UserSubscription, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) CountRecommendationsToday(ctx context.Context, userID int64) (int, error) {
	// TODO: Implement
	return 0, fmt.Errorf("not implemented")
}

func (r *SubscriptionRepository) CountWardrobeItems(ctx context.Context, userID int64) (int, error) {
	// TODO: Implement
	return 0, fmt.Errorf("not implemented")
}