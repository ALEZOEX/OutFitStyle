package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

// SubscriptionPlanRepositoryPG репозиторий для работы с планами подписок
type SubscriptionPlanRepositoryPG struct {
	db *pgxpool.Pool
}

// NewSubscriptionPlanRepository создаёт новый репозиторий планов подписок
func NewSubscriptionPlanRepository(db *pgxpool.Pool) *SubscriptionPlanRepositoryPG {
	return &SubscriptionPlanRepositoryPG{db: db}
}

// ListPlans возвращает список всех активных планов подписки
func (r *SubscriptionPlanRepositoryPG) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	query := `
		SELECT id, code, name, description, price_monthly, price_yearly, currency,
		       recommendations_per_day, wardrobe_items_limit, history_days, styles_limit,
		       family_accounts, features, is_active, sort_order, trial_period_days,
		       created_at, updated_at
		FROM subscription_plans
		WHERE is_active = TRUE
		ORDER BY sort_order, id
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query subscription plans")
	}
	defer rows.Close()

	var plans []domain.SubscriptionPlan
	for rows.Next() {
		var plan domain.SubscriptionPlan
		var featuresJSON []byte

		err := rows.Scan(
			&plan.ID,
			&plan.Code,
			&plan.Name,
			&plan.Description,
			&plan.PriceMonthly,
			&plan.PriceYearly,
			&plan.Currency,
			&plan.RecommendationsPerDay,
			&plan.WardrobeItemsLimit,
			&plan.HistoryDays,
			&plan.StylesLimit,
			&plan.FamilyAccounts,
			&featuresJSON,
			&plan.IsActive,
			&plan.SortOrder,
			&plan.TrialPeriodDays,
			&plan.CreatedAt,
			&plan.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan subscription plan")
		}

		if len(featuresJSON) > 0 {
			if err := json.Unmarshal(featuresJSON, &plan.Features); err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal features")
			}
		}

		plans = append(plans, plan)
	}

	return plans, nil
}

// GetPlanByID возвращает план подписки по ID
func (r *SubscriptionPlanRepositoryPG) GetPlanByID(ctx context.Context, id int64) (*domain.SubscriptionPlan, error) {
	query := `
		SELECT id, code, name, description, price_monthly, price_yearly, currency,
		       recommendations_per_day, wardrobe_items_limit, history_days, styles_limit,
		       family_accounts, features, is_active, sort_order, trial_period_days,
		       created_at, updated_at
		FROM subscription_plans
		WHERE id = $1
	`

	var plan domain.SubscriptionPlan
	var featuresJSON []byte

	err := r.db.QueryRow(ctx, query, id).Scan(
		&plan.ID,
		&plan.Code,
		&plan.Name,
		&plan.Description,
		&plan.PriceMonthly,
		&plan.PriceYearly,
		&plan.Currency,
		&plan.RecommendationsPerDay,
		&plan.WardrobeItemsLimit,
		&plan.HistoryDays,
		&plan.StylesLimit,
		&plan.FamilyAccounts,
		&featuresJSON,
		&plan.IsActive,
		&plan.SortOrder,
		&plan.TrialPeriodDays,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get plan by ID")
	}

	if len(featuresJSON) > 0 {
		if err := json.Unmarshal(featuresJSON, &plan.Features); err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal features")
		}
	}

	return &plan, nil
}

// GetPlanByCode возвращает план подписки по коду
func (r *SubscriptionPlanRepositoryPG) GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error) {
	query := `
		SELECT id, code, name, description, price_monthly, price_yearly, currency,
		       recommendations_per_day, wardrobe_items_limit, history_days, styles_limit,
		       family_accounts, features, is_active, sort_order, trial_period_days,
		       created_at, updated_at
		FROM subscription_plans
		WHERE code = $1
	`

	var plan domain.SubscriptionPlan
	var featuresJSON []byte

	err := r.db.QueryRow(ctx, query, code).Scan(
		&plan.ID,
		&plan.Code,
		&plan.Name,
		&plan.Description,
		&plan.PriceMonthly,
		&plan.PriceYearly,
		&plan.Currency,
		&plan.RecommendationsPerDay,
		&plan.WardrobeItemsLimit,
		&plan.HistoryDays,
		&plan.StylesLimit,
		&plan.FamilyAccounts,
		&featuresJSON,
		&plan.IsActive,
		&plan.SortOrder,
		&plan.TrialPeriodDays,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get plan by code")
	}

	if len(featuresJSON) > 0 {
		if err := json.Unmarshal(featuresJSON, &plan.Features); err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal features")
		}
	}

	return &plan, nil
}

// CreatePlan создаёт новый план подписки
func (r *SubscriptionPlanRepositoryPG) CreatePlan(ctx context.Context, plan *domain.SubscriptionPlan) (int64, error) {
	query := `
		INSERT INTO subscription_plans (
			code, name, description, price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit,
			family_accounts, features, is_active, sort_order, trial_period_days,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, NOW(), NOW())
		RETURNING id
	`

	featuresJSON, err := json.Marshal(plan.Features)
	if err != nil {
		return 0, errors.Wrap(err, "failed to marshal features")
	}

	var id int64
	err = r.db.QueryRow(ctx, query,
		plan.Code,
		plan.Name,
		plan.Description,
		plan.PriceMonthly,
		plan.PriceYearly,
		plan.Currency,
		plan.RecommendationsPerDay,
		plan.WardrobeItemsLimit,
		plan.HistoryDays,
		plan.StylesLimit,
		plan.FamilyAccounts,
		featuresJSON,
		plan.IsActive,
		plan.SortOrder,
		plan.TrialPeriodDays,
	).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "failed to create subscription plan")
	}

	return id, nil
}

// UpdatePlan обновляет план подписки
func (r *SubscriptionPlanRepositoryPG) UpdatePlan(ctx context.Context, plan *domain.SubscriptionPlan) error {
	query := `
		UPDATE subscription_plans
		SET code = $1, name = $2, description = $3, price_monthly = $4, price_yearly = $5,
		    currency = $6, recommendations_per_day = $7, wardrobe_items_limit = $8,
		    history_days = $9, styles_limit = $10, family_accounts = $11,
		    features = $12, is_active = $13, sort_order = $14, trial_period_days = $15,
		    updated_at = NOW()
		WHERE id = $16
	`

	featuresJSON, err := json.Marshal(plan.Features)
	if err != nil {
		return errors.Wrap(err, "failed to marshal features")
	}

	_, err = r.db.Exec(ctx, query,
		plan.Code,
		plan.Name,
		plan.Description,
		plan.PriceMonthly,
		plan.PriceYearly,
		plan.Currency,
		plan.RecommendationsPerDay,
		plan.WardrobeItemsLimit,
		plan.HistoryDays,
		plan.StylesLimit,
		plan.FamilyAccounts,
		featuresJSON,
		plan.IsActive,
		plan.SortOrder,
		plan.TrialPeriodDays,
		plan.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update subscription plan")
	}

	return nil
}

// DeletePlan удаляет план подписки (мягкое удаление через is_active)
func (r *SubscriptionPlanRepositoryPG) DeletePlan(ctx context.Context, id int64) error {
	query := `UPDATE subscription_plans SET is_active = FALSE, updated_at = NOW() WHERE id = $1`

	_, err := r.db.Exec(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete subscription plan")
	}

	return nil
}

// UserSubscriptionRepositoryPG репозиторий для работы с подписками пользователей
type UserSubscriptionRepositoryPG struct {
	db *pgxpool.Pool
}

// NewUserSubscriptionRepository создаёт новый репозиторий подписок пользователей
func NewUserSubscriptionRepository(db *pgxpool.Pool) *UserSubscriptionRepositoryPG {
	return &UserSubscriptionRepositoryPG{db: db}
}

// GetActiveSubscription возвращает активную подписку пользователя
func (r *UserSubscriptionRepositoryPG) GetActiveSubscription(ctx context.Context, userID domain.ID) (*domain.UserSubscription, error) {
	query := `
		SELECT id, user_id, plan_id, billing_cycle, started_at, current_period_start,
		       current_period_end, trial_end, status, auto_renew, cancelled_at,
		       cancel_at_period_end, payment_provider, external_subscription_id,
		       cancellation_reason, cancellation_feedback, created_at, updated_at
		FROM user_subscriptions
		WHERE user_id = $1 AND status IN ('active', 'trialing')
		ORDER BY current_period_end DESC
		LIMIT 1
	`

	var sub domain.UserSubscription
	err := r.db.QueryRow(ctx, query, userID).Scan(
		&sub.ID,
		&sub.UserID,
		&sub.Plan.ID,
		&sub.BillingCycle,
		&sub.StartedAt,
		&sub.CurrentPeriodStart,
		&sub.CurrentPeriodEnd,
		&sub.TrialEnd,
		&sub.Status,
		&sub.AutoRenew,
		&sub.CancelledAt,
		&sub.CancelAtPeriodEnd,
		&sub.PaymentProvider,
		&sub.ExternalSubscriptionID,
		&sub.CancellationReason,
		&sub.CancellationFeedback,
		&sub.CreatedAt,
		&sub.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get active subscription")
	}

	return &sub, nil
}

// GetSubscriptionByID возвращает подписку по ID
func (r *UserSubscriptionRepositoryPG) GetSubscriptionByID(ctx context.Context, id int64) (*domain.UserSubscription, error) {
	query := `
		SELECT id, user_id, plan_id, billing_cycle, started_at, current_period_start,
		       current_period_end, trial_end, status, auto_renew, cancelled_at,
		       cancel_at_period_end, payment_provider, external_subscription_id,
		       cancellation_reason, cancellation_feedback, created_at, updated_at
		FROM user_subscriptions
		WHERE id = $1
	`

	var sub domain.UserSubscription
	err := r.db.QueryRow(ctx, query, id).Scan(
		&sub.ID,
		&sub.UserID,
		&sub.Plan.ID,
		&sub.BillingCycle,
		&sub.StartedAt,
		&sub.CurrentPeriodStart,
		&sub.CurrentPeriodEnd,
		&sub.TrialEnd,
		&sub.Status,
		&sub.AutoRenew,
		&sub.CancelledAt,
		&sub.CancelAtPeriodEnd,
		&sub.PaymentProvider,
		&sub.ExternalSubscriptionID,
		&sub.CancellationReason,
		&sub.CancellationFeedback,
		&sub.CreatedAt,
		&sub.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get subscription by ID")
	}

	return &sub, nil
}

// GetUserSubscriptions возвращает все подписки пользователя
func (r *UserSubscriptionRepositoryPG) GetUserSubscriptions(ctx context.Context, userID domain.ID) ([]domain.UserSubscription, error) {
	query := `
		SELECT id, user_id, plan_id, billing_cycle, started_at, current_period_start,
		       current_period_end, trial_end, status, auto_renew, cancelled_at,
		       cancel_at_period_end, payment_provider, external_subscription_id,
		       cancellation_reason, cancellation_feedback, created_at, updated_at
		FROM user_subscriptions
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user subscriptions")
	}
	defer rows.Close()

	var subs []domain.UserSubscription
	for rows.Next() {
		var sub domain.UserSubscription
		err := rows.Scan(
			&sub.ID,
			&sub.UserID,
			&sub.Plan.ID,
			&sub.BillingCycle,
			&sub.StartedAt,
			&sub.CurrentPeriodStart,
			&sub.CurrentPeriodEnd,
			&sub.TrialEnd,
			&sub.Status,
			&sub.AutoRenew,
			&sub.CancelledAt,
			&sub.CancelAtPeriodEnd,
			&sub.PaymentProvider,
			&sub.ExternalSubscriptionID,
			&sub.CancellationReason,
			&sub.CancellationFeedback,
			&sub.CreatedAt,
			&sub.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan subscription")
		}
		subs = append(subs, sub)
	}

	return subs, nil
}

// CreateSubscription создаёт новую подписку пользователя
func (r *UserSubscriptionRepositoryPG) CreateSubscription(ctx context.Context, sub *domain.UserSubscription) (int64, error) {
	query := `
		INSERT INTO user_subscriptions (
			user_id, plan_id, billing_cycle, started_at, current_period_start,
			current_period_end, trial_end, status, auto_renew, cancelled_at,
			cancel_at_period_end, payment_provider, external_subscription_id,
			cancellation_reason, cancellation_feedback, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, NOW(), NOW())
		RETURNING id
	`

	var id int64
	err := r.db.QueryRow(ctx, query,
		sub.UserID,
		sub.Plan.ID,
		sub.BillingCycle,
		sub.StartedAt,
		sub.CurrentPeriodStart,
		sub.CurrentPeriodEnd,
		sub.TrialEnd,
		sub.Status,
		sub.AutoRenew,
		sub.CancelledAt,
		sub.CancelAtPeriodEnd,
		sub.PaymentProvider,
		sub.ExternalSubscriptionID,
		sub.CancellationReason,
		sub.CancellationFeedback,
	).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "failed to create user subscription")
	}

	return id, nil
}

// UpdateSubscription обновляет подписку пользователя
func (r *UserSubscriptionRepositoryPG) UpdateSubscription(ctx context.Context, sub *domain.UserSubscription) error {
	query := `
		UPDATE user_subscriptions
		SET plan_id = $1, billing_cycle = $2, started_at = $3, current_period_start = $4,
		    current_period_end = $5, trial_end = $6, status = $7, auto_renew = $8,
		    cancelled_at = $9, cancel_at_period_end = $10, payment_provider = $11,
		    external_subscription_id = $12, cancellation_reason = $13,
		    cancellation_feedback = $14, updated_at = NOW()
		WHERE id = $15
	`

	_, err := r.db.Exec(ctx, query,
		sub.Plan.ID,
		sub.BillingCycle,
		sub.StartedAt,
		sub.CurrentPeriodStart,
		sub.CurrentPeriodEnd,
		sub.TrialEnd,
		sub.Status,
		sub.AutoRenew,
		sub.CancelledAt,
		sub.CancelAtPeriodEnd,
		sub.PaymentProvider,
		sub.ExternalSubscriptionID,
		sub.CancellationReason,
		sub.CancellationFeedback,
		sub.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update user subscription")
	}

	return nil
}

// CancelSubscription отменяет подписку пользователя
func (r *UserSubscriptionRepositoryPG) CancelSubscription(ctx context.Context, userID domain.ID, immediate bool, reason, feedback *string) error {
	query := `
		UPDATE user_subscriptions
		SET status = CASE WHEN $2 THEN 'cancelled' ELSE status END,
		    cancelled_at = CASE WHEN $2 THEN NOW() ELSE cancelled_at END,
		    cancel_at_period_end = CASE WHEN NOT $2 THEN TRUE ELSE cancel_at_period_end END,
		    cancellation_reason = $3,
		    cancellation_feedback = $4,
		    updated_at = NOW()
		WHERE user_id = $1 AND status IN ('active', 'trialing')
	`

	_, err := r.db.Exec(ctx, query, userID, immediate, reason, feedback)
	if err != nil {
		return errors.Wrap(err, "failed to cancel subscription")
	}

	return nil
}

// ReactivateSubscription восстанавливает подписку пользователя
func (r *UserSubscriptionRepositoryPG) ReactivateSubscription(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE user_subscriptions
		SET status = 'active',
		    cancelled_at = NULL,
		    cancel_at_period_end = FALSE,
		    cancellation_reason = NULL,
		    cancellation_feedback = NULL,
		    updated_at = NOW()
		WHERE user_id = $1 AND status = 'cancelled'
		ORDER BY current_period_end DESC
		LIMIT 1
	`

	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to reactivate subscription")
	}

	return nil
}

// UpgradeSubscription изменяет план подписки
func (r *UserSubscriptionRepositoryPG) UpgradeSubscription(ctx context.Context, userID domain.ID, newPlanID int64, newPeriodEnd time.Time) error {
	query := `
		UPDATE user_subscriptions
		SET plan_id = $1, current_period_end = $2, updated_at = NOW()
		WHERE user_id = $3 AND status IN ('active', 'trialing')
	`

	_, err := r.db.Exec(ctx, query, newPlanID, newPeriodEnd, userID)
	if err != nil {
		return errors.Wrap(err, "failed to upgrade subscription")
	}

	return nil
}

// ExtendSubscription продлевает подписку на указанный период
func (r *UserSubscriptionRepositoryPG) ExtendSubscription(ctx context.Context, userID domain.ID, duration time.Duration) error {
	query := `
		UPDATE user_subscriptions
		SET current_period_end = current_period_end + $2,
		    updated_at = NOW()
		WHERE user_id = $1 AND status IN ('active', 'trialing')
	`

	_, err := r.db.Exec(ctx, query, userID, duration)
	if err != nil {
		return errors.Wrap(err, "failed to extend subscription")
	}

	return nil
}

// StartTrial начинает пробный период для пользователя
func (r *UserSubscriptionRepositoryPG) StartTrial(ctx context.Context, userID domain.ID, planID int64, trialDays int) error {
	now := time.Now()
	trialEnd := now.AddDate(0, 0, trialDays)

	query := `
		INSERT INTO user_subscriptions (
			user_id, plan_id, billing_cycle, started_at, current_period_start,
			current_period_end, trial_end, status, auto_renew, created_at, updated_at
		) VALUES ($1, $2, 'monthly', $3, $3, $4, $5, 'trialing', TRUE, NOW(), NOW())
		ON CONFLICT (user_id, plan_id, status) DO NOTHING
	`

	_, err := r.db.Exec(ctx, query, userID, planID, now, trialEnd, trialEnd)
	if err != nil {
		return errors.Wrap(err, "failed to start trial")
	}

	return nil
}

// GetSubscriptionsExpiringSoon возвращает подписки, истекающие в ближайшее время
func (r *UserSubscriptionRepositoryPG) GetSubscriptionsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error) {
	query := `
		SELECT id, user_id, plan_id, billing_cycle, started_at, current_period_start,
		       current_period_end, trial_end, status, auto_renew, cancelled_at,
		       cancel_at_period_end, payment_provider, external_subscription_id,
		       cancellation_reason, cancellation_feedback, created_at, updated_at
		FROM user_subscriptions
		WHERE status = 'active'
		  AND current_period_end <= $1
		  AND cancel_at_period_end = FALSE
		ORDER BY current_period_end ASC
	`

	rows, err := r.db.Query(ctx, query, before)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query expiring subscriptions")
	}
	defer rows.Close()

	var subs []domain.UserSubscription
	for rows.Next() {
		var sub domain.UserSubscription
		err := rows.Scan(
			&sub.ID,
			&sub.UserID,
			&sub.Plan.ID,
			&sub.BillingCycle,
			&sub.StartedAt,
			&sub.CurrentPeriodStart,
			&sub.CurrentPeriodEnd,
			&sub.TrialEnd,
			&sub.Status,
			&sub.AutoRenew,
			&sub.CancelledAt,
			&sub.CancelAtPeriodEnd,
			&sub.PaymentProvider,
			&sub.ExternalSubscriptionID,
			&sub.CancellationReason,
			&sub.CancellationFeedback,
			&sub.CreatedAt,
			&sub.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan subscription")
		}
		subs = append(subs, sub)
	}

	return subs, nil
}

// GetTrialsExpiringSoon возвращает пробные подписки, истекающие в ближайшее время
func (r *UserSubscriptionRepositoryPG) GetTrialsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error) {
	query := `
		SELECT id, user_id, plan_id, billing_cycle, started_at, current_period_start,
		       current_period_end, trial_end, status, auto_renew, cancelled_at,
		       cancel_at_period_end, payment_provider, external_subscription_id,
		       cancellation_reason, cancellation_feedback, created_at, updated_at
		FROM user_subscriptions
		WHERE status = 'trialing'
		  AND trial_end <= $1
		ORDER BY trial_end ASC
	`

	rows, err := r.db.Query(ctx, query, before)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query expiring trials")
	}
	defer rows.Close()

	var subs []domain.UserSubscription
	for rows.Next() {
		var sub domain.UserSubscription
		err := rows.Scan(
			&sub.ID,
			&sub.UserID,
			&sub.Plan.ID,
			&sub.BillingCycle,
			&sub.StartedAt,
			&sub.CurrentPeriodStart,
			&sub.CurrentPeriodEnd,
			&sub.TrialEnd,
			&sub.Status,
			&sub.AutoRenew,
			&sub.CancelledAt,
			&sub.CancelAtPeriodEnd,
			&sub.PaymentProvider,
			&sub.ExternalSubscriptionID,
			&sub.CancellationReason,
			&sub.CancellationFeedback,
			&sub.CreatedAt,
			&sub.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan trial subscription")
		}
		subs = append(subs, sub)
	}

	return subs, nil
}

// SubscriptionUsageRepositoryPG репозиторий для работы с использованием лимитов
type SubscriptionUsageRepositoryPG struct {
	db *pgxpool.Pool
}

// NewSubscriptionUsageRepository создаёт новый репозиторий использования подписок
func NewSubscriptionUsageRepository(db *pgxpool.Pool) *SubscriptionUsageRepositoryPG {
	return &SubscriptionUsageRepositoryPG{db: db}
}

// GetUsage возвращает использование лимитов пользователя
func (r *SubscriptionUsageRepositoryPG) GetUsage(ctx context.Context, userID domain.ID) (*domain.SubscriptionUsage, error) {
	query := `
		SELECT id, user_id, subscription_id, recommendations_today,
		       recommendations_reset_at, wardrobe_count, last_reset_at
		FROM subscription_usage
		WHERE user_id = $1
	`

	var usage domain.SubscriptionUsage
	err := r.db.QueryRow(ctx, query, userID).Scan(
		&usage.ID,
		&usage.UserID,
		&usage.SubscriptionID,
		&usage.RecommendationsToday,
		&usage.RecommendationsResetAt,
		&usage.WardrobeCount,
		&usage.LastResetAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get subscription usage")
	}

	return &usage, nil
}

// GetOrCreateUsage возвращает или создаёт использование лимитов
func (r *SubscriptionUsageRepositoryPG) GetOrCreateUsage(ctx context.Context, userID domain.ID, subscriptionID *int64) (*domain.SubscriptionUsage, error) {
	query := `
		INSERT INTO subscription_usage (user_id, subscription_id, recommendations_today,
		                                recommendations_reset_at, wardrobe_count, last_reset_at)
		VALUES ($1, $2, 0, CURRENT_DATE, 0, NOW())
		ON CONFLICT (user_id) DO UPDATE
		SET subscription_id = COALESCE($2, subscription_usage.subscription_id)
		RETURNING id, user_id, subscription_id, recommendations_today,
		          recommendations_reset_at, wardrobe_count, last_reset_at
	`

	var usage domain.SubscriptionUsage
	err := r.db.QueryRow(ctx, query, userID, subscriptionID).Scan(
		&usage.ID,
		&usage.UserID,
		&usage.SubscriptionID,
		&usage.RecommendationsToday,
		&usage.RecommendationsResetAt,
		&usage.WardrobeCount,
		&usage.LastResetAt,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get or create subscription usage")
	}

	return &usage, nil
}

// UpdateUsage обновляет использование лимитов
func (r *SubscriptionUsageRepositoryPG) UpdateUsage(ctx context.Context, usage *domain.SubscriptionUsage) error {
	query := `
		UPDATE subscription_usage
		SET recommendations_today = $1, recommendations_reset_at = $2,
		    wardrobe_count = $3, last_reset_at = $4, updated_at = NOW()
		WHERE user_id = $5
	`

	_, err := r.db.Exec(ctx, query,
		usage.RecommendationsToday,
		usage.RecommendationsResetAt,
		usage.WardrobeCount,
		usage.LastResetAt,
		usage.UserID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update subscription usage")
	}

	return nil
}

// IncrementRecommendations увеличивает счётчик рекомендаций
func (r *SubscriptionUsageRepositoryPG) IncrementRecommendations(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE subscription_usage
		SET recommendations_today = recommendations_today + 1,
		    recommendations_reset_at = CASE
		        WHEN recommendations_reset_at < CURRENT_DATE THEN CURRENT_DATE
		        ELSE recommendations_reset_at
		    END,
		    updated_at = NOW()
		WHERE user_id = $1
	`

	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to increment recommendations")
	}

	return nil
}

// IncrementWardrobe увеличивает счётчик вещей в гардеробе
func (r *SubscriptionUsageRepositoryPG) IncrementWardrobe(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE subscription_usage
		SET wardrobe_count = wardrobe_count + 1, updated_at = NOW()
		WHERE user_id = $1
	`

	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to increment wardrobe")
	}

	return nil
}

// DecrementWardrobe уменьшает счётчик вещей в гардеробе
func (r *SubscriptionUsageRepositoryPG) DecrementWardrobe(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE subscription_usage
		SET wardrobe_count = GREATEST(wardrobe_count - 1, 0), updated_at = NOW()
		WHERE user_id = $1
	`

	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to decrement wardrobe")
	}

	return nil
}

// ResetDailyCounters сбрасывает дневные счётчики
func (r *SubscriptionUsageRepositoryPG) ResetDailyCounters(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE subscription_usage
		SET recommendations_today = 0,
		    recommendations_reset_at = CURRENT_DATE,
		    updated_at = NOW()
		WHERE user_id = $1
	`

	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to reset daily counters")
	}

	return nil
}

// BulkResetDailyCounters сбрасывает дневные счётчики для всех пользователей
func (r *SubscriptionUsageRepositoryPG) BulkResetDailyCounters(ctx context.Context) error {
	query := `
		UPDATE subscription_usage
		SET recommendations_today = 0,
		    recommendations_reset_at = CURRENT_DATE,
		    updated_at = NOW()
		WHERE recommendations_reset_at < CURRENT_DATE
	`

	_, err := r.db.Exec(ctx, query)
	if err != nil {
		return errors.Wrap(err, "failed to bulk reset daily counters")
	}

	return nil
}

// SubscriptionTransactionRepositoryPG репозиторий для работы с транзакциями
type SubscriptionTransactionRepositoryPG struct {
	db *pgxpool.Pool
}

// NewSubscriptionTransactionRepository создаёт новый репозиторий транзакций
func NewSubscriptionTransactionRepository(db *pgxpool.Pool) *SubscriptionTransactionRepositoryPG {
	return &SubscriptionTransactionRepositoryPG{db: db}
}

// CreateTransaction создаёт новую транзакцию
func (r *SubscriptionTransactionRepositoryPG) CreateTransaction(ctx context.Context, tx *domain.SubscriptionTransaction) (int64, error) {
	query := `
		INSERT INTO subscription_transactions (
			user_id, subscription_id, amount, currency, status, payment_provider,
			external_payment_id, payment_method, description, receipt_url, error_message,
			paid_at, refunded_at, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, NOW(), NOW())
		RETURNING id
	`

	var id int64
	err := r.db.QueryRow(ctx, query,
		tx.UserID,
		tx.SubscriptionID,
		tx.Amount,
		tx.Currency,
		tx.Status,
		tx.PaymentProvider,
		tx.ExternalPaymentID,
		tx.PaymentMethod,
		tx.Description,
		tx.ReceiptURL,
		tx.ErrorMessage,
		tx.PaidAt,
		tx.RefundedAt,
	).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "failed to create subscription transaction")
	}

	return id, nil
}

// GetTransactionByID возвращает транзакцию по ID
func (r *SubscriptionTransactionRepositoryPG) GetTransactionByID(ctx context.Context, id int64) (*domain.SubscriptionTransaction, error) {
	query := `
		SELECT id, user_id, subscription_id, amount, currency, status, payment_provider,
		       external_payment_id, payment_method, description, receipt_url, error_message,
		       paid_at, refunded_at, created_at, updated_at
		FROM subscription_transactions
		WHERE id = $1
	`

	var tx domain.SubscriptionTransaction
	err := r.db.QueryRow(ctx, query, id).Scan(
		&tx.ID,
		&tx.UserID,
		&tx.SubscriptionID,
		&tx.Amount,
		&tx.Currency,
		&tx.Status,
		&tx.PaymentProvider,
		&tx.ExternalPaymentID,
		&tx.PaymentMethod,
		&tx.Description,
		&tx.ReceiptURL,
		&tx.ErrorMessage,
		&tx.PaidAt,
		&tx.RefundedAt,
		&tx.CreatedAt,
		&tx.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get transaction by ID")
	}

	return &tx, nil
}

// GetTransactionByExternalID возвращает транзакцию по внешнему ID
func (r *SubscriptionTransactionRepositoryPG) GetTransactionByExternalID(ctx context.Context, provider string, externalID string) (*domain.SubscriptionTransaction, error) {
	query := `
		SELECT id, user_id, subscription_id, amount, currency, status, payment_provider,
		       external_payment_id, payment_method, description, receipt_url, error_message,
		       paid_at, refunded_at, created_at, updated_at
		FROM subscription_transactions
		WHERE payment_provider = $1 AND external_payment_id = $2
	`

	var tx domain.SubscriptionTransaction
	err := r.db.QueryRow(ctx, query, provider, externalID).Scan(
		&tx.ID,
		&tx.UserID,
		&tx.SubscriptionID,
		&tx.Amount,
		&tx.Currency,
		&tx.Status,
		&tx.PaymentProvider,
		&tx.ExternalPaymentID,
		&tx.PaymentMethod,
		&tx.Description,
		&tx.ReceiptURL,
		&tx.ErrorMessage,
		&tx.PaidAt,
		&tx.RefundedAt,
		&tx.CreatedAt,
		&tx.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get transaction by external ID")
	}

	return &tx, nil
}

// GetUserTransactions возвращает транзакции пользователя
func (r *SubscriptionTransactionRepositoryPG) GetUserTransactions(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SubscriptionTransaction, int, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}
	offset := (page - 1) * limit

	countQuery := `SELECT COUNT(*) FROM subscription_transactions WHERE user_id = $1`
	var total int
	err := r.db.QueryRow(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count transactions")
	}

	query := `
		SELECT id, user_id, subscription_id, amount, currency, status, payment_provider,
		       external_payment_id, payment_method, description, receipt_url, error_message,
		       paid_at, refunded_at, created_at, updated_at
		FROM subscription_transactions
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query user transactions")
	}
	defer rows.Close()

	var txs []domain.SubscriptionTransaction
	for rows.Next() {
		var tx domain.SubscriptionTransaction
		err := rows.Scan(
			&tx.ID,
			&tx.UserID,
			&tx.SubscriptionID,
			&tx.Amount,
			&tx.Currency,
			&tx.Status,
			&tx.PaymentProvider,
			&tx.ExternalPaymentID,
			&tx.PaymentMethod,
			&tx.Description,
			&tx.ReceiptURL,
			&tx.ErrorMessage,
			&tx.PaidAt,
			&tx.RefundedAt,
			&tx.CreatedAt,
			&tx.UpdatedAt,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan transaction")
		}
		txs = append(txs, tx)
	}

	return txs, total, nil
}

// UpdateTransactionStatus обновляет статус транзакции
func (r *SubscriptionTransactionRepositoryPG) UpdateTransactionStatus(ctx context.Context, id int64, status string, paidAt *time.Time, receiptURL, errorMessage *string) error {
	query := `
		UPDATE subscription_transactions
		SET status = $1, paid_at = COALESCE($2, paid_at), receipt_url = $3,
		    error_message = $4, updated_at = NOW()
		WHERE id = $5
	`

	_, err := r.db.Exec(ctx, query, status, paidAt, receiptURL, errorMessage, id)
	if err != nil {
		return errors.Wrap(err, "failed to update transaction status")
	}

	return nil
}

// UpdateTransactionByExternalID обновляет транзакцию по внешнему ID
func (r *SubscriptionTransactionRepositoryPG) UpdateTransactionByExternalID(ctx context.Context, provider string, externalID string, status string, paidAt *time.Time, receiptURL, errorMessage *string) error {
	query := `
		UPDATE subscription_transactions
		SET status = $1, paid_at = COALESCE($2, paid_at), receipt_url = $3,
		    error_message = $4, updated_at = NOW()
		WHERE payment_provider = $5 AND external_payment_id = $6
	`

	_, err := r.db.Exec(ctx, query, status, paidAt, receiptURL, errorMessage, provider, externalID)
	if err != nil {
		return errors.Wrap(err, "failed to update transaction by external ID")
	}

	return nil
}

// CreateRefundTransaction создаёт транзакцию возврата
func (r *SubscriptionTransactionRepositoryPG) CreateRefundTransaction(ctx context.Context, originalTxID int64, refundTx *domain.SubscriptionTransaction) (int64, error) {
	query := `
		INSERT INTO subscription_transactions (
			user_id, subscription_id, amount, currency, status, payment_provider,
			external_payment_id, description, receipt_url, error_message, refunded_at,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW(), NOW())
		RETURNING id
	`

	var id int64
	err := r.db.QueryRow(ctx, query,
		refundTx.UserID,
		refundTx.SubscriptionID,
		refundTx.Amount,
		refundTx.Currency,
		refundTx.Status,
		refundTx.PaymentProvider,
		refundTx.ExternalPaymentID,
		refundTx.Description,
		refundTx.ReceiptURL,
		refundTx.ErrorMessage,
	).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "failed to create refund transaction")
	}

	return id, nil
}

// FamilyMemberRepositoryPG репозиторий для работы с семейными участниками
type FamilyMemberRepositoryPG struct {
	db *pgxpool.Pool
}

// NewFamilyMemberRepository создаёт новый репозиторий семейных участников
func NewFamilyMemberRepository(db *pgxpool.Pool) *FamilyMemberRepositoryPG {
	return &FamilyMemberRepositoryPG{db: db}
}

// GetFamilyMembers возвращает семейных участников владельца
func (r *FamilyMemberRepositoryPG) GetFamilyMembers(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id, status, invited_at, accepted_at,
		       expires_at, added_by, created_at, updated_at
		FROM family_members
		WHERE owner_user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, ownerUserID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query family members")
	}
	defer rows.Close()

	var members []domain.FamilyMember
	for rows.Next() {
		var member domain.FamilyMember
		err := rows.Scan(
			&member.ID,
			&member.OwnerUserID,
			&member.MemberUserID,
			&member.Status,
			&member.InvitedAt,
			&member.AcceptedAt,
			&member.ExpiresAt,
			&member.AddedBy,
			&member.CreatedAt,
			&member.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan family member")
		}
		members = append(members, member)
	}

	return members, nil
}

// GetFamilyMemberByID возвращает семейного участника по ID
func (r *FamilyMemberRepositoryPG) GetFamilyMemberByID(ctx context.Context, id int64) (*domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id, status, invited_at, accepted_at,
		       expires_at, added_by, created_at, updated_at
		FROM family_members
		WHERE id = $1
	`

	var member domain.FamilyMember
	err := r.db.QueryRow(ctx, query, id).Scan(
		&member.ID,
		&member.OwnerUserID,
		&member.MemberUserID,
		&member.Status,
		&member.InvitedAt,
		&member.AcceptedAt,
		&member.ExpiresAt,
		&member.AddedBy,
		&member.CreatedAt,
		&member.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get family member by ID")
	}

	return &member, nil
}

// GetFamilyMemberByMemberID возвращает семейного участника по ID участника
func (r *FamilyMemberRepositoryPG) GetFamilyMemberByMemberID(ctx context.Context, memberUserID domain.ID) (*domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id, status, invited_at, accepted_at,
		       expires_at, added_by, created_at, updated_at
		FROM family_members
		WHERE member_user_id = $1
	`

	var member domain.FamilyMember
	err := r.db.QueryRow(ctx, query, memberUserID).Scan(
		&member.ID,
		&member.OwnerUserID,
		&member.MemberUserID,
		&member.Status,
		&member.InvitedAt,
		&member.AcceptedAt,
		&member.ExpiresAt,
		&member.AddedBy,
		&member.CreatedAt,
		&member.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get family member by member ID")
	}

	return &member, nil
}

// CreateFamilyMember создаёт нового семейного участника
func (r *FamilyMemberRepositoryPG) CreateFamilyMember(ctx context.Context, member *domain.FamilyMember) (int64, error) {
	query := `
		INSERT INTO family_members (
			owner_user_id, member_user_id, status, invited_at, accepted_at,
			expires_at, added_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
		RETURNING id
	`

	var id int64
	err := r.db.QueryRow(ctx, query,
		member.OwnerUserID,
		member.MemberUserID,
		member.Status,
		member.InvitedAt,
		member.AcceptedAt,
		member.ExpiresAt,
		member.AddedBy,
	).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "failed to create family member")
	}

	return id, nil
}

// UpdateFamilyMember обновляет семейного участника
func (r *FamilyMemberRepositoryPG) UpdateFamilyMember(ctx context.Context, member *domain.FamilyMember) error {
	query := `
		UPDATE family_members
		SET owner_user_id = $1, member_user_id = $2, status = $3, invited_at = $4,
		    accepted_at = $5, expires_at = $6, added_by = $7, updated_at = NOW()
		WHERE id = $8
	`

	_, err := r.db.Exec(ctx, query,
		member.OwnerUserID,
		member.MemberUserID,
		member.Status,
		member.InvitedAt,
		member.AcceptedAt,
		member.ExpiresAt,
		member.AddedBy,
		member.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update family member")
	}

	return nil
}

// RemoveFamilyMember удаляет семейного участника
func (r *FamilyMemberRepositoryPG) RemoveFamilyMember(ctx context.Context, id int64) error {
	query := `DELETE FROM family_members WHERE id = $1`

	_, err := r.db.Exec(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to remove family member")
	}

	return nil
}

// AcceptInvitation принимает приглашение в семью
func (r *FamilyMemberRepositoryPG) AcceptInvitation(ctx context.Context, memberUserID domain.ID) error {
	query := `
		UPDATE family_members
		SET status = 'active', accepted_at = NOW(), updated_at = NOW()
		WHERE member_user_id = $1 AND status = 'pending'
	`

	_, err := r.db.Exec(ctx, query, memberUserID)
	if err != nil {
		return errors.Wrap(err, "failed to accept invitation")
	}

	return nil
}

// GetActiveFamilyMembersCount возвращает количество активных семейных участников
func (r *FamilyMemberRepositoryPG) GetActiveFamilyMembersCount(ctx context.Context, ownerUserID domain.ID) (int, error) {
	query := `SELECT COUNT(*) FROM family_members WHERE owner_user_id = $1 AND status = 'active'`

	var count int
	err := r.db.QueryRow(ctx, query, ownerUserID).Scan(&count)
	if err != nil {
		return 0, errors.Wrap(err, "failed to count family members")
	}

	return count, nil
}

// GetPendingInvitations возвращает ожидающие приглашения
func (r *FamilyMemberRepositoryPG) GetPendingInvitations(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id, status, invited_at, accepted_at,
		       expires_at, added_by, created_at, updated_at
		FROM family_members
		WHERE owner_user_id = $1 AND status = 'pending'
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, ownerUserID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query pending invitations")
	}
	defer rows.Close()

	var members []domain.FamilyMember
	for rows.Next() {
		var member domain.FamilyMember
		err := rows.Scan(
			&member.ID,
			&member.OwnerUserID,
			&member.MemberUserID,
			&member.Status,
			&member.InvitedAt,
			&member.AcceptedAt,
			&member.ExpiresAt,
			&member.AddedBy,
			&member.CreatedAt,
			&member.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan family member")
		}
		members = append(members, member)
	}

	return members, nil
}
