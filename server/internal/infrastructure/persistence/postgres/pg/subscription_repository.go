package pg

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type SubscriptionRepository struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

func NewSubscriptionRepository(db *dbpkg.DB, logger *zap.Logger) repositories.SubscriptionRepository {
	return &SubscriptionRepository{db: db, logger: logger}
}

func (r *SubscriptionRepository) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	q := `
SELECT
	id, code, name, description,
	price_monthly, price_yearly, currency,
	recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, family_accounts,
	features,
	is_active, sort_order,
	created_at, updated_at
FROM subscription_plans
WHERE is_active = TRUE
ORDER BY sort_order ASC, price_monthly ASC
`
	rows, err := r.db.Pool().Query(ctx, q)
	if err != nil {
		return nil, errors.Wrap(err, "list subscription plans")
	}
	defer rows.Close()

	var out []domain.SubscriptionPlan
	for rows.Next() {
		var p domain.SubscriptionPlan
		if err := rows.Scan(
			&p.ID, &p.Code, &p.Name, &p.Description,
			&p.PriceMonthly, &p.PriceYearly, &p.Currency,
			&p.RecommendationsPerDay, &p.WardrobeItemsLimit, &p.HistoryDays, &p.StylesLimit, &p.FamilyAccounts,
			&p.Features,
			&p.IsActive, &p.SortOrder,
			&p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, errors.Wrap(err, "scan plan")
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

func (r *SubscriptionRepository) GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error) {
	q := `
SELECT
	id, code, name, description,
	price_monthly, price_yearly, currency,
	recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, family_accounts,
	features,
	is_active, sort_order,
	created_at, updated_at
FROM subscription_plans
WHERE code = $1
LIMIT 1
`
	var p domain.SubscriptionPlan
	err := r.db.Pool().QueryRow(ctx, q, code).Scan(
		&p.ID, &p.Code, &p.Name, &p.Description,
		&p.PriceMonthly, &p.PriceYearly, &p.Currency,
		&p.RecommendationsPerDay, &p.WardrobeItemsLimit, &p.HistoryDays, &p.StylesLimit, &p.FamilyAccounts,
		&p.Features,
		&p.IsActive, &p.SortOrder,
		&p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get plan by code")
	}
	return &p, nil
}

func (r *SubscriptionRepository) GetActiveSubscription(ctx context.Context, userID int64) (*domain.UserSubscription, error) {
	q := `
SELECT
	us.id, us.user_id,
	us.billing_cycle, us.started_at, us.current_period_start, us.current_period_end,
	us.cancelled_at, us.status, us.auto_renew,
	us.payment_provider, us.external_subscription_id,
	us.trial_end, us.created_at, us.updated_at,

	sp.id, sp.code, sp.name, sp.description,
	sp.price_monthly, sp.price_yearly, sp.currency,
	sp.recommendations_per_day, sp.wardrobe_items_limit, sp.history_days, sp.styles_limit, sp.family_accounts,
	sp.features,
	sp.is_active, sp.sort_order,
	sp.created_at, sp.updated_at
FROM user_subscriptions us
JOIN subscription_plans sp ON sp.id = us.plan_id
WHERE us.user_id = $1
  AND us.status IN ('active','trialing')
ORDER BY us.current_period_end DESC
LIMIT 1
`
	var s domain.UserSubscription
	var plan domain.SubscriptionPlan
	var id int64

	err := r.db.Pool().QueryRow(ctx, q, userID).Scan(
		&id, &s.UserID,
		&s.BillingCycle, &s.StartedAt, &s.CurrentPeriodStart, &s.CurrentPeriodEnd,
		&s.CancelledAt, &s.Status, &s.AutoRenew,
		&s.PaymentProvider, &s.ExternalSubscriptionID,
		&s.TrialEnd, &s.CreatedAt, &s.UpdatedAt,

		&plan.ID, &plan.Code, &plan.Name, &plan.Description,
		&plan.PriceMonthly, &plan.PriceYearly, &plan.Currency,
		&plan.RecommendationsPerDay, &plan.WardrobeItemsLimit, &plan.HistoryDays, &plan.StylesLimit, &plan.FamilyAccounts,
		&plan.Features,
		&plan.IsActive, &plan.SortOrder,
		&plan.CreatedAt, &plan.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get active subscription")
	}

	s.ID = &id
	s.Plan = plan
	return &s, nil
}

func (r *SubscriptionRepository) CountRecommendationsToday(ctx context.Context, userID int64) (int, error) {
	// МVP: считаем по серверному времени. Позже можно учесть user.timezone.
	var n int
	err := r.db.Pool().QueryRow(ctx, `
SELECT COUNT(*)
FROM recommendations
WHERE user_id = $1
  AND created_at >= date_trunc('day', NOW())
`, userID).Scan(&n)
	return n, errors.Wrap(err, "count recommendations today")
}

func (r *SubscriptionRepository) CountWardrobeItems(ctx context.Context, userID int64) (int, error) {
	var n int
	err := r.db.Pool().QueryRow(ctx, `
SELECT COUNT(*)
FROM user_wardrobe
WHERE user_id = $1
  AND is_archived = FALSE
`, userID).Scan(&n)
	return n, errors.Wrap(err, "count wardrobe items")
}