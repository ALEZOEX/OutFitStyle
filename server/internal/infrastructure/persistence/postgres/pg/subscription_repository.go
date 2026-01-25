package pg

import (
	"context"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

// InternalSubscription внутренняя структура для сканирования данных из базы данных
// Соответствует полям в SQL-запросе
type InternalSubscription struct {
	ID                 *domain.ID `db:"id"`
	UserID             domain.ID  `db:"user_id"`
	PlanID             string     `db:"plan_id"`
	Name               string     `db:"name"`
	Description        *string    `db:"description"`
	Interval           string     `db:"interval"`
	IntervalCount      int        `db:"interval_count"`
	TrialPeriodDays    *int       `db:"trial_period_days"`
	IsActive           bool       `db:"is_active"`
	IsTrial            bool       `db:"is_trial"`
	IsCanceled         bool       `db:"is_canceled"`
	CancelAtPeriodEnd  bool       `db:"cancel_at_period_end"`
	CurrentPeriodStart *time.Time `db:"current_period_start"`
	CurrentPeriodEnd   *time.Time `db:"current_period_end"`
	CanceledAt         *time.Time `db:"canceled_at"`
	ExpiresAt          *time.Time `db:"expires_at"`
	CreatedAt          time.Time  `db:"created_at"`
	UpdatedAt          time.Time  `db:"updated_at"`
}

type SubscriptionRepository struct {
	db *pgxpool.Pool
}

func NewSubscriptionRepository(db *pgxpool.Pool, logger interface{}) *SubscriptionRepository {
	return &SubscriptionRepository{db: db}
}

func (r *SubscriptionRepository) GetByUser(ctx context.Context, userID domain.ID) (*domain.Subscription, error) {
	query := `
		SELECT 
			id, user_id, plan_id, name, description, interval, interval_count, 
			trial_period_days, is_active, is_trial, is_canceled, cancel_at_period_end,
			current_period_start, current_period_end, canceled_at, expires_at, 
			created_at, updated_at
		FROM subscriptions
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT 1
	`

	var sub domain.Subscription
	var description *string
	var trialPeriodDays *int
	var canceledAt *time.Time
	var expiresAt *time.Time
	var currentPeriodStart *time.Time
	var currentPeriodEnd *time.Time

	err := r.db.QueryRow(ctx, query, userID).Scan(
		&sub.ID,
		&sub.UserID,
		&sub.PlanID,
		&sub.Name,
		&description,
		&sub.Interval,
		&sub.IntervalCount,
		&trialPeriodDays,
		&sub.IsActive,
		&sub.IsTrial,
		&sub.IsCanceled,
		&sub.CancelAtPeriodEnd,
		&currentPeriodStart,
		&currentPeriodEnd,
		&canceledAt,
		&expiresAt,
		&sub.CreatedAt,
		&sub.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get subscription by user")
	}

	// Set nullable fields
	sub.Description = description
	sub.TrialPeriodDays = trialPeriodDays
	sub.CanceledAt = canceledAt
	sub.ExpiresAt = expiresAt
	sub.CurrentPeriodStart = currentPeriodStart
	sub.CurrentPeriodEnd = currentPeriodEnd

	return &sub, nil
}

func (r *SubscriptionRepository) Create(ctx context.Context, sub *domain.Subscription) error {
	query := `
		INSERT INTO subscriptions (
			id, user_id, plan_id, name, description, interval, interval_count,
			trial_period_days, is_active, is_trial, is_canceled, cancel_at_period_end,
			current_period_start, current_period_end, canceled_at, expires_at,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
	`

	_, err := r.db.Exec(ctx, query,
		sub.ID,
		sub.UserID,
		sub.PlanID,
		sub.Name,
		sub.Description,
		sub.Interval,
		sub.IntervalCount,
		sub.TrialPeriodDays,
		sub.IsActive,
		sub.IsTrial,
		sub.IsCanceled,
		sub.CancelAtPeriodEnd,
		sub.CurrentPeriodStart,
		sub.CurrentPeriodEnd,
		sub.CanceledAt,
		sub.ExpiresAt,
		sub.CreatedAt,
		sub.UpdatedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to create subscription")
	}

	return nil
}

func (r *SubscriptionRepository) Update(ctx context.Context, sub *domain.Subscription) error {
	query := `
		UPDATE subscriptions
		SET plan_id = $1, name = $2, description = $3, interval = $4, interval_count = $5,
			trial_period_days = $6, is_active = $7, is_trial = $8, is_canceled = $9,
			cancel_at_period_end = $10, current_period_start = $11, current_period_end = $12,
			canceled_at = $13, expires_at = $14, updated_at = $15
		WHERE id = $16
	`

	_, err := r.db.Exec(ctx, query,
		sub.PlanID,
		sub.Name,
		sub.Description,
		sub.Interval,
		sub.IntervalCount,
		sub.TrialPeriodDays,
		sub.IsActive,
		sub.IsTrial,
		sub.IsCanceled,
		sub.CancelAtPeriodEnd,
		sub.CurrentPeriodStart,
		sub.CurrentPeriodEnd,
		sub.CanceledAt,
		sub.ExpiresAt,
		time.Now(),
		sub.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update subscription")
	}

	return nil
}

func (r *SubscriptionRepository) Cancel(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE subscriptions
		SET is_canceled = true, cancel_at_period_end = true, updated_at = $1
		WHERE user_id = $2 AND is_canceled = false
	`

	_, err := r.db.Exec(ctx, query, time.Now(), userID)
	if err != nil {
		return errors.Wrap(err, "failed to cancel subscription")
	}

	return nil
}

func (r *SubscriptionRepository) GetPlan(ctx context.Context, planID domain.ID) (*domain.SubscriptionPlan, error) {
	query := `
		SELECT 
			id, code, name, description, price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit,
			family_accounts, features, is_active, sort_order, created_at, updated_at
		FROM subscription_plans
		WHERE id = $1
	`

	var plan domain.SubscriptionPlan
	var description *string
	var recommendationsPerDay *int
	var wardrobeItemsLimit *int
	var historyDays *int
	var stylesLimit *int
	var featuresJSON []byte

	err := r.db.QueryRow(ctx, query, planID).Scan(
		&plan.ID,
		&plan.Code,
		&plan.Name,
		&description,
		&plan.PriceMonthly,
		&plan.PriceYearly,
		&plan.Currency,
		&recommendationsPerDay,
		&wardrobeItemsLimit,
		&historyDays,
		&stylesLimit,
		&plan.FamilyAccounts,
		&featuresJSON,
		&plan.IsActive,
		&plan.SortOrder,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get subscription plan")
	}

	// Set nullable fields
	plan.Description = description
	plan.RecommendationsPerDay = recommendationsPerDay
	plan.WardrobeItemsLimit = wardrobeItemsLimit
	plan.HistoryDays = historyDays
	plan.StylesLimit = stylesLimit

	// Parse features
	if len(featuresJSON) > 0 {
		plan.Features = featuresJSON
	}

	return &plan, nil
}

func (r *SubscriptionRepository) GetPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	return r.ListPlans(ctx)
}

func (r *SubscriptionRepository) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	query := `
		SELECT 
			id, code, name, description, price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit,
			family_accounts, features, is_active, sort_order, created_at, updated_at
		FROM subscription_plans
		WHERE is_active = true
		ORDER BY sort_order, created_at
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query subscription plans")
	}
	defer rows.Close()

	var plans []domain.SubscriptionPlan
	for rows.Next() {
		var plan domain.SubscriptionPlan
		var description *string
		var recommendationsPerDay *int
		var wardrobeItemsLimit *int
		var historyDays *int
		var stylesLimit *int
		var featuresJSON []byte

		err := rows.Scan(
			&plan.ID,
			&plan.Code,
			&plan.Name,
			&description,
			&plan.PriceMonthly,
			&plan.PriceYearly,
			&plan.Currency,
			&recommendationsPerDay,
			&wardrobeItemsLimit,
			&historyDays,
			&stylesLimit,
			&plan.FamilyAccounts,
			&featuresJSON,
			&plan.IsActive,
			&plan.SortOrder,
			&plan.CreatedAt,
			&plan.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan subscription plan")
		}

		// Set nullable fields
		plan.Description = description
		plan.RecommendationsPerDay = recommendationsPerDay
		plan.WardrobeItemsLimit = wardrobeItemsLimit
		plan.HistoryDays = historyDays
		plan.StylesLimit = stylesLimit

		// Parse features
		if len(featuresJSON) > 0 {
			plan.Features = featuresJSON
		}

		plans = append(plans, plan)
	}

	return plans, nil
}

func (r *SubscriptionRepository) GetActiveSubscription(ctx context.Context, userID int64) (*domain.UserSubscription, error) {
	// Convert int64 to domain.ID (UUID)
	userUUID := uuid.UUID{}
	userUUID[0] = byte(userID & 0xFF)
	userUUID[1] = byte((userID >> 8) & 0xFF)
	userUUID[2] = byte((userID >> 16) & 0xFF)
	userUUID[3] = byte((userID >> 24) & 0xFF)
	userUUID[4] = byte((userID >> 32) & 0xFF)
	userUUID[5] = byte((userID >> 40) & 0xFF)
	userUUID[6] = byte((userID >> 48) & 0xFF)
	userUUID[7] = byte((userID >> 56) & 0xFF)
	domainUserID := domain.ID(userUUID)

	query := `
		SELECT
			s.id, s.user_id, s.plan_id, s.name, s.description, s.interval, s.interval_count,
			s.trial_period_days, s.is_active, s.is_trial, s.is_canceled, s.cancel_at_period_end,
			s.current_period_start, s.current_period_end, s.canceled_at, s.expires_at,
			s.created_at, s.updated_at,
			p.code, p.name, p.description, p.price_monthly, p.price_yearly, p.currency,
			p.recommendations_per_day, p.wardrobe_items_limit, p.history_days, p.styles_limit,
			p.family_accounts, p.features, p.is_active, p.sort_order, p.created_at, p.updated_at,
			s.started_at, s.status, s.auto_renew, s.payment_provider, s.external_subscription_id, s.trial_end
		FROM subscriptions s
		JOIN subscription_plans p ON s.plan_id = p.id::text
		WHERE s.user_id = $1 AND s.is_active = true AND s.is_canceled = false
		ORDER BY s.created_at DESC
		LIMIT 1
	`

	var id int64
	var userIDInt int64
	var planID string
	var subName, subDescription, intervalCount *string
	var trialPeriodDays *int
	var isActive, isTrial, isCanceled, cancelAtPeriodEnd bool
	var currentPeriodStart, currentPeriodEnd, cancelledAt, expiresAt *time.Time
	var createdAt, updatedAt time.Time

	// Subscription fields that are also needed for UserSubscription
	var billingCycle *string

	// Subscription plan fields
	var planCode, planName string
	var planDesc *string
	var priceMonthly, priceYearly float64
	var currency string
	var recPerDay, wardrobeLimit, historyDays, stylesLimit *int
	var familyAccounts int
	var features []byte
	var planIsActive bool
	var sortOrder int
	var planCreatedAt, planUpdatedAt time.Time

	// Additional subscription fields that are also needed for UserSubscription
	var startedAt *time.Time
	var status *string
	var autoRenew *bool
	var paymentProvider *string
	var externalSubscriptionID *string
	var trialEnd *time.Time

	err := r.db.QueryRow(ctx, query, domainUserID).Scan(
		&id,
		&userIDInt,
		&planID,
		&subName,
		&subDescription,
		&billingCycle,
		&intervalCount,
		&trialPeriodDays,
		&isActive,
		&isTrial,
		&isCanceled,
		&cancelAtPeriodEnd,
		&currentPeriodStart,
		&currentPeriodEnd,
		&cancelledAt,
		&expiresAt,
		&createdAt,
		&updatedAt,
		&planCode,
		&planName,
		&planDesc,
		&priceMonthly,
		&priceYearly,
		&currency,
		&recPerDay,
		&wardrobeLimit,
		&historyDays,
		&stylesLimit,
		&familyAccounts,
		&features,
		&planIsActive,
		&sortOrder,
		&planCreatedAt,
		&planUpdatedAt,
		&startedAt,
		&status,
		&autoRenew,
		&paymentProvider,
		&externalSubscriptionID,
		&trialEnd,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get active subscription")
	}

	// Convert planID from string to int64
	planIDInt, err := strconv.ParseInt(planID, 10, 64)
	if err != nil {
		return nil, errors.Wrap(err, "failed to parse plan ID")
	}

	// Create the subscription with proper fields
	sub := &domain.UserSubscription{
		ID:     &id,
		UserID: userIDInt,
		Plan: domain.SubscriptionPlan{
			ID:                    planIDInt,
			Code:                  planCode,
			Name:                  planName,
			Description:           planDesc,
			PriceMonthly:          priceMonthly,
			PriceYearly:           priceYearly,
			Currency:              currency,
			RecommendationsPerDay: recPerDay,
			WardrobeItemsLimit:    wardrobeLimit,
			HistoryDays:           historyDays,
			StylesLimit:           stylesLimit,
			FamilyAccounts:        familyAccounts,
			Features:              features,
			IsActive:              planIsActive,
			SortOrder:             sortOrder,
			CreatedAt:             planCreatedAt,
			UpdatedAt:             planUpdatedAt,
		},
		BillingCycle:           billingCycle,
		StartedAt:              startedAt,
		CurrentPeriodStart:     currentPeriodStart,
		CurrentPeriodEnd:       currentPeriodEnd,
		CancelledAt:            cancelledAt,
		Status:                 status,
		AutoRenew:              autoRenew,
		PaymentProvider:        paymentProvider,
		ExternalSubscriptionID: externalSubscriptionID,
		TrialEnd:               trialEnd,
		CreatedAt:              &createdAt,
		UpdatedAt:              &updatedAt,
	}

	return sub, nil
}

func (r *SubscriptionRepository) GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error) {
	query := `
		SELECT 
			id, code, name, description, price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit,
			family_accounts, features, is_active, sort_order, created_at, updated_at
		FROM subscription_plans
		WHERE code = $1 AND is_active = true
	`

	var plan domain.SubscriptionPlan
	var description *string
	var recommendationsPerDay *int
	var wardrobeItemsLimit *int
	var historyDays *int
	var stylesLimit *int
	var featuresJSON []byte

	err := r.db.QueryRow(ctx, query, code).Scan(
		&plan.ID,
		&plan.Code,
		&plan.Name,
		&description,
		&plan.PriceMonthly,
		&plan.PriceYearly,
		&plan.Currency,
		&recommendationsPerDay,
		&wardrobeItemsLimit,
		&historyDays,
		&stylesLimit,
		&plan.FamilyAccounts,
		&featuresJSON,
		&plan.IsActive,
		&plan.SortOrder,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get subscription plan by code")
	}

	// Set nullable fields
	plan.Description = description
	plan.RecommendationsPerDay = recommendationsPerDay
	plan.WardrobeItemsLimit = wardrobeItemsLimit
	plan.HistoryDays = historyDays
	plan.StylesLimit = stylesLimit

	// Parse features
	if len(featuresJSON) > 0 {
		plan.Features = featuresJSON
	}

	return &plan, nil
}

func (r *SubscriptionRepository) CountRecommendationsToday(ctx context.Context, userID int64) (int, error) {
	query := `
		SELECT COUNT(*) 
		FROM recommendations 
		WHERE user_id = $1 
		AND DATE(created_at) = DATE(NOW())
	`

	var count int
	err := r.db.QueryRow(ctx, query, userID).Scan(&count)
	if err != nil {
		return 0, errors.Wrap(err, "failed to count recommendations today")
	}

	return count, nil
}

func (r *SubscriptionRepository) CountWardrobeItems(ctx context.Context, userID int64) (int, error) {
	query := `
		SELECT COUNT(*) 
		FROM user_wardrobe 
		WHERE user_id = $1
	`

	var count int
	err := r.db.QueryRow(ctx, query, userID).Scan(&count)
	if err != nil {
		return 0, errors.Wrap(err, "failed to count wardrobe items")
	}

	return count, nil
}
