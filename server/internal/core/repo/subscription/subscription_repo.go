package subscription

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// SubscriptionPlanRepo репозиторий для работы с планами подписок в PostgreSQL
type SubscriptionPlanRepo struct {
	db *sql.DB
}

// NewSubscriptionPlanRepo создаёт новый репозиторий планов подписок
func NewSubscriptionPlanRepo(db *sql.DB) *SubscriptionPlanRepo {
	return &SubscriptionPlanRepo{db: db}
}

// ListPlans возвращает список всех активных планов подписки
func (r *SubscriptionPlanRepo) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	query := `
		SELECT 
			id, code, name, description,
			price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, family_accounts,
			features,
			is_active, sort_order, trial_period_days,
			created_at, updated_at
		FROM subscription_plans
		WHERE is_active = TRUE
		ORDER BY sort_order ASC, id ASC
	`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("query plans: %w", err)
	}
	defer rows.Close()

	var plans []domain.SubscriptionPlan
	for rows.Next() {
		var plan domain.SubscriptionPlan
		var description sql.NullString
		var recommendationsPerDay, wardrobeItemsLimit, historyDays, stylesLimit sql.NullInt32
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
			&plan.TrialPeriodDays,
			&plan.CreatedAt,
			&plan.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan plan: %w", err)
		}

		if description.Valid {
			plan.Description = &description.String
		}
		if recommendationsPerDay.Valid {
			v := int(recommendationsPerDay.Int32)
			plan.RecommendationsPerDay = &v
		}
		if wardrobeItemsLimit.Valid {
			v := int(wardrobeItemsLimit.Int32)
			plan.WardrobeItemsLimit = &v
		}
		if historyDays.Valid {
			v := int(historyDays.Int32)
			plan.HistoryDays = &v
		}
		if stylesLimit.Valid {
			v := int(stylesLimit.Int32)
			plan.StylesLimit = &v
		}
		plan.Features = featuresJSON

		plans = append(plans, plan)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows error: %w", err)
	}

	return plans, nil
}

// GetPlanByID возвращает план подписки по ID
func (r *SubscriptionPlanRepo) GetPlanByID(ctx context.Context, id int64) (*domain.SubscriptionPlan, error) {
	query := `
		SELECT 
			id, code, name, description,
			price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, family_accounts,
			features,
			is_active, sort_order, trial_period_days,
			created_at, updated_at
		FROM subscription_plans
		WHERE id = $1
	`

	var plan domain.SubscriptionPlan
	var description sql.NullString
	var recommendationsPerDay, wardrobeItemsLimit, historyDays, stylesLimit sql.NullInt32
	var featuresJSON []byte

	err := r.db.QueryRowContext(ctx, query, id).Scan(
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
		&plan.TrialPeriodDays,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query plan by id: %w", err)
	}

	if description.Valid {
		plan.Description = &description.String
	}
	if recommendationsPerDay.Valid {
		v := int(recommendationsPerDay.Int32)
		plan.RecommendationsPerDay = &v
	}
	if wardrobeItemsLimit.Valid {
		v := int(wardrobeItemsLimit.Int32)
		plan.WardrobeItemsLimit = &v
	}
	if historyDays.Valid {
		v := int(historyDays.Int32)
		plan.HistoryDays = &v
	}
	if stylesLimit.Valid {
		v := int(stylesLimit.Int32)
		plan.StylesLimit = &v
	}
	plan.Features = featuresJSON

	return &plan, nil
}

// GetPlanByCode возвращает план подписки по коду
func (r *SubscriptionPlanRepo) GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error) {
	query := `
		SELECT 
			id, code, name, description,
			price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, family_accounts,
			features,
			is_active, sort_order, trial_period_days,
			created_at, updated_at
		FROM subscription_plans
		WHERE code = $1
	`

	var plan domain.SubscriptionPlan
	var description sql.NullString
	var recommendationsPerDay, wardrobeItemsLimit, historyDays, stylesLimit sql.NullInt32
	var featuresJSON []byte

	err := r.db.QueryRowContext(ctx, query, code).Scan(
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
		&plan.TrialPeriodDays,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query plan by code: %w", err)
	}

	if description.Valid {
		plan.Description = &description.String
	}
	if recommendationsPerDay.Valid {
		v := int(recommendationsPerDay.Int32)
		plan.RecommendationsPerDay = &v
	}
	if wardrobeItemsLimit.Valid {
		v := int(wardrobeItemsLimit.Int32)
		plan.WardrobeItemsLimit = &v
	}
	if historyDays.Valid {
		v := int(historyDays.Int32)
		plan.HistoryDays = &v
	}
	if stylesLimit.Valid {
		v := int(stylesLimit.Int32)
		plan.StylesLimit = &v
	}
	plan.Features = featuresJSON

	return &plan, nil
}

// CreatePlan создаёт новый план подписки
func (r *SubscriptionPlanRepo) CreatePlan(ctx context.Context, plan *domain.SubscriptionPlan) (int64, error) {
	query := `
		INSERT INTO subscription_plans (
			code, name, description,
			price_monthly, price_yearly, currency,
			recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, family_accounts,
			features,
			is_active, sort_order, trial_period_days
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
		RETURNING id
	`

	var id int64
	var description interface{}
	if plan.Description != nil {
		description = *plan.Description
	} else {
		description = nil
	}

	var recPerDay, wardrobeLimit, historyDays, stylesLimit interface{}
	if plan.RecommendationsPerDay != nil {
		recPerDay = *plan.RecommendationsPerDay
	} else {
		recPerDay = nil
	}
	if plan.WardrobeItemsLimit != nil {
		wardrobeLimit = *plan.WardrobeItemsLimit
	} else {
		wardrobeLimit = nil
	}
	if plan.HistoryDays != nil {
		historyDays = *plan.HistoryDays
	} else {
		historyDays = nil
	}
	if plan.StylesLimit != nil {
		stylesLimit = *plan.StylesLimit
	} else {
		stylesLimit = nil
	}

	err := r.db.QueryRowContext(ctx, query,
		plan.Code,
		plan.Name,
		description,
		plan.PriceMonthly,
		plan.PriceYearly,
		plan.Currency,
		recPerDay,
		wardrobeLimit,
		historyDays,
		stylesLimit,
		plan.FamilyAccounts,
		plan.Features,
		plan.IsActive,
		plan.SortOrder,
		plan.TrialPeriodDays,
	).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create plan: %w", err)
	}

	return id, nil
}

// UpdatePlan обновляет план подписки
func (r *SubscriptionPlanRepo) UpdatePlan(ctx context.Context, plan *domain.SubscriptionPlan) error {
	query := `
		UPDATE subscription_plans
		SET 
			name = $2,
			description = $3,
			price_monthly = $4,
			price_yearly = $5,
			currency = $6,
			recommendations_per_day = $7,
			wardrobe_items_limit = $8,
			history_days = $9,
			styles_limit = $10,
			family_accounts = $11,
			features = $12,
			is_active = $13,
			sort_order = $14,
			trial_period_days = $15,
			updated_at = NOW()
		WHERE id = $1
	`

	var description interface{}
	if plan.Description != nil {
		description = *plan.Description
	} else {
		description = nil
	}

	var recPerDay, wardrobeLimit, historyDays, stylesLimit interface{}
	if plan.RecommendationsPerDay != nil {
		recPerDay = *plan.RecommendationsPerDay
	} else {
		recPerDay = nil
	}
	if plan.WardrobeItemsLimit != nil {
		wardrobeLimit = *plan.WardrobeItemsLimit
	} else {
		wardrobeLimit = nil
	}
	if plan.HistoryDays != nil {
		historyDays = *plan.HistoryDays
	} else {
		historyDays = nil
	}
	if plan.StylesLimit != nil {
		stylesLimit = *plan.StylesLimit
	} else {
		stylesLimit = nil
	}

	_, err := r.db.ExecContext(ctx, query,
		plan.ID,
		plan.Name,
		description,
		plan.PriceMonthly,
		plan.PriceYearly,
		plan.Currency,
		recPerDay,
		wardrobeLimit,
		historyDays,
		stylesLimit,
		plan.FamilyAccounts,
		plan.Features,
		plan.IsActive,
		plan.SortOrder,
		plan.TrialPeriodDays,
	)
	if err != nil {
		return fmt.Errorf("update plan: %w", err)
	}

	return nil
}

// DeletePlan удаляет план подписки (мягкое удаление через is_active)
func (r *SubscriptionPlanRepo) DeletePlan(ctx context.Context, id int64) error {
	query := `
		UPDATE subscription_plans
		SET is_active = FALSE, updated_at = NOW()
		WHERE id = $1
	`

	_, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("delete plan: %w", err)
	}

	return nil
}

// UserSubscriptionRepo репозиторий для работы с подписками пользователей в PostgreSQL
type UserSubscriptionRepo struct {
	db *sql.DB
}

// NewUserSubscriptionRepo создаёт новый репозиторий подписок пользователей
func NewUserSubscriptionRepo(db *sql.DB) *UserSubscriptionRepo {
	return &UserSubscriptionRepo{db: db}
}

// GetActiveSubscription возвращает активную подписку пользователя
func (r *UserSubscriptionRepo) GetActiveSubscription(ctx context.Context, userID domain.ID) (*domain.UserSubscription, error) {
	query := `
		SELECT 
			us.id, us.user_id, us.plan_id,
			us.billing_cycle,
			us.started_at, us.current_period_start, us.current_period_end, us.trial_end,
			us.status, us.auto_renew, us.cancelled_at, us.cancel_at_period_end,
			us.payment_provider, us.external_subscription_id,
			us.cancellation_reason, us.cancellation_feedback,
			us.created_at, us.updated_at,
			sp.id, sp.code, sp.name, sp.description,
			sp.price_monthly, sp.price_yearly, sp.currency,
			sp.recommendations_per_day, sp.wardrobe_items_limit, sp.history_days, sp.styles_limit, sp.family_accounts,
			sp.features, sp.is_active, sp.sort_order, sp.trial_period_days,
			sp.created_at, sp.updated_at
		FROM user_subscriptions us
		JOIN subscription_plans sp ON us.plan_id = sp.id
		WHERE us.user_id = $1 AND us.status IN ('active', 'trialing')
		ORDER BY us.current_period_end DESC
		LIMIT 1
	`

	var us domain.UserSubscription
	var plan domain.SubscriptionPlan

	var billingCycle, status, paymentProvider, externalSubID, cancellationReason, cancellationFeedback sql.NullString
	var startedAt, currentPeriodStart, currentPeriodEnd, trialEnd, cancelledAt, createdAt, updatedAt sql.NullTime
	var planDescription sql.NullString
	var planRecPerDay, planWardrobeLimit, planHistoryDays, planStylesLimit sql.NullInt32
	var planFeaturesJSON []byte

	err := r.db.QueryRowContext(ctx, query, userID).Scan(
		&us.ID,
		&us.UserID,
		&plan.ID,
		&billingCycle,
		&startedAt,
		&currentPeriodStart,
		&currentPeriodEnd,
		&trialEnd,
		&status,
		&us.AutoRenew,
		&cancelledAt,
		&us.CancelAtPeriodEnd,
		&paymentProvider,
		&externalSubID,
		&cancellationReason,
		&cancellationFeedback,
		&createdAt,
		&updatedAt,
		&plan.ID,
		&plan.Code,
		&plan.Name,
		&planDescription,
		&plan.PriceMonthly,
		&plan.PriceYearly,
		&plan.Currency,
		&planRecPerDay,
		&planWardrobeLimit,
		&planHistoryDays,
		&planStylesLimit,
		&plan.FamilyAccounts,
		&planFeaturesJSON,
		&plan.IsActive,
		&plan.SortOrder,
		&plan.TrialPeriodDays,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query active subscription: %w", err)
	}

	// Заполняем nullable поля подписки
	if billingCycle.Valid {
		us.BillingCycle = &billingCycle.String
	}
	if status.Valid {
		us.Status = &status.String
	}
	if paymentProvider.Valid {
		us.PaymentProvider = &paymentProvider.String
	}
	if externalSubID.Valid {
		us.ExternalSubscriptionID = &externalSubID.String
	}
	if cancellationReason.Valid {
		us.CancellationReason = &cancellationReason.String
	}
	if cancellationFeedback.Valid {
		us.CancellationFeedback = &cancellationFeedback.String
	}
	if startedAt.Valid {
		us.StartedAt = &startedAt.Time
	}
	if currentPeriodStart.Valid {
		us.CurrentPeriodStart = &currentPeriodStart.Time
	}
	if currentPeriodEnd.Valid {
		us.CurrentPeriodEnd = &currentPeriodEnd.Time
	}
	if trialEnd.Valid {
		us.TrialEnd = &trialEnd.Time
	}
	if cancelledAt.Valid {
		us.CancelledAt = &cancelledAt.Time
	}
	if createdAt.Valid {
		us.CreatedAt = &createdAt.Time
	}
	if updatedAt.Valid {
		us.UpdatedAt = &updatedAt.Time
	}

	// Заполняем nullable поля плана
	if planDescription.Valid {
		plan.Description = &planDescription.String
	}
	if planRecPerDay.Valid {
		v := int(planRecPerDay.Int32)
		plan.RecommendationsPerDay = &v
	}
	if planWardrobeLimit.Valid {
		v := int(planWardrobeLimit.Int32)
		plan.WardrobeItemsLimit = &v
	}
	if planHistoryDays.Valid {
		v := int(planHistoryDays.Int32)
		plan.HistoryDays = &v
	}
	if planStylesLimit.Valid {
		v := int(planStylesLimit.Int32)
		plan.StylesLimit = &v
	}
	plan.Features = planFeaturesJSON

	us.Plan = plan

	return &us, nil
}

// GetSubscriptionByID возвращает подписку по ID
func (r *UserSubscriptionRepo) GetSubscriptionByID(ctx context.Context, id int64) (*domain.UserSubscription, error) {
	query := `
		SELECT 
			us.id, us.user_id, us.plan_id,
			us.billing_cycle,
			us.started_at, us.current_period_start, us.current_period_end, us.trial_end,
			us.status, us.auto_renew, us.cancelled_at, us.cancel_at_period_end,
			us.payment_provider, us.external_subscription_id,
			us.cancellation_reason, us.cancellation_feedback,
			us.created_at, us.updated_at,
			sp.id, sp.code, sp.name, sp.description,
			sp.price_monthly, sp.price_yearly, sp.currency,
			sp.recommendations_per_day, sp.wardrobe_items_limit, sp.history_days, sp.styles_limit, sp.family_accounts,
			sp.features, sp.is_active, sp.sort_order, sp.trial_period_days,
			sp.created_at, sp.updated_at
		FROM user_subscriptions us
		JOIN subscription_plans sp ON us.plan_id = sp.id
		WHERE us.id = $1
	`

	var us domain.UserSubscription
	var plan domain.SubscriptionPlan

	var billingCycle, status, paymentProvider, externalSubID, cancellationReason, cancellationFeedback sql.NullString
	var startedAt, currentPeriodStart, currentPeriodEnd, trialEnd, cancelledAt, createdAt, updatedAt sql.NullTime
	var planDescription sql.NullString
	var planRecPerDay, planWardrobeLimit, planHistoryDays, planStylesLimit sql.NullInt32
	var planFeaturesJSON []byte

	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&us.ID,
		&us.UserID,
		&plan.ID,
		&billingCycle,
		&startedAt,
		&currentPeriodStart,
		&currentPeriodEnd,
		&trialEnd,
		&status,
		&us.AutoRenew,
		&cancelledAt,
		&us.CancelAtPeriodEnd,
		&paymentProvider,
		&externalSubID,
		&cancellationReason,
		&cancellationFeedback,
		&createdAt,
		&updatedAt,
		&plan.ID,
		&plan.Code,
		&plan.Name,
		&planDescription,
		&plan.PriceMonthly,
		&plan.PriceYearly,
		&plan.Currency,
		&planRecPerDay,
		&planWardrobeLimit,
		&planHistoryDays,
		&planStylesLimit,
		&plan.FamilyAccounts,
		&planFeaturesJSON,
		&plan.IsActive,
		&plan.SortOrder,
		&plan.TrialPeriodDays,
		&plan.CreatedAt,
		&plan.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query subscription by id: %w", err)
	}

	// Заполняем nullable поля (аналогично GetActiveSubscription)
	if billingCycle.Valid {
		us.BillingCycle = &billingCycle.String
	}
	if status.Valid {
		us.Status = &status.String
	}
	if paymentProvider.Valid {
		us.PaymentProvider = &paymentProvider.String
	}
	if externalSubID.Valid {
		us.ExternalSubscriptionID = &externalSubID.String
	}
	if cancellationReason.Valid {
		us.CancellationReason = &cancellationReason.String
	}
	if cancellationFeedback.Valid {
		us.CancellationFeedback = &cancellationFeedback.String
	}
	if startedAt.Valid {
		us.StartedAt = &startedAt.Time
	}
	if currentPeriodStart.Valid {
		us.CurrentPeriodStart = &currentPeriodStart.Time
	}
	if currentPeriodEnd.Valid {
		us.CurrentPeriodEnd = &currentPeriodEnd.Time
	}
	if trialEnd.Valid {
		us.TrialEnd = &trialEnd.Time
	}
	if cancelledAt.Valid {
		us.CancelledAt = &cancelledAt.Time
	}
	if createdAt.Valid {
		us.CreatedAt = &createdAt.Time
	}
	if updatedAt.Valid {
		us.UpdatedAt = &updatedAt.Time
	}

	if planDescription.Valid {
		plan.Description = &planDescription.String
	}
	if planRecPerDay.Valid {
		v := int(planRecPerDay.Int32)
		plan.RecommendationsPerDay = &v
	}
	if planWardrobeLimit.Valid {
		v := int(planWardrobeLimit.Int32)
		plan.WardrobeItemsLimit = &v
	}
	if planHistoryDays.Valid {
		v := int(planHistoryDays.Int32)
		plan.HistoryDays = &v
	}
	if planStylesLimit.Valid {
		v := int(planStylesLimit.Int32)
		plan.StylesLimit = &v
	}
	plan.Features = planFeaturesJSON

	us.Plan = plan

	return &us, nil
}

// GetUserSubscriptions возвращает все подписки пользователя
func (r *UserSubscriptionRepo) GetUserSubscriptions(ctx context.Context, userID domain.ID) ([]domain.UserSubscription, error) {
	query := `
		SELECT 
			us.id, us.user_id, us.plan_id,
			us.billing_cycle,
			us.started_at, us.current_period_start, us.current_period_end, us.trial_end,
			us.status, us.auto_renew, us.cancelled_at, us.cancel_at_period_end,
			us.payment_provider, us.external_subscription_id,
			us.cancellation_reason, us.cancellation_feedback,
			us.created_at, us.updated_at,
			sp.id, sp.code, sp.name, sp.description,
			sp.price_monthly, sp.price_yearly, sp.currency,
			sp.recommendations_per_day, sp.wardrobe_items_limit, sp.history_days, sp.styles_limit, sp.family_accounts,
			sp.features, sp.is_active, sp.sort_order, sp.trial_period_days,
			sp.created_at, sp.updated_at
		FROM user_subscriptions us
		JOIN subscription_plans sp ON us.plan_id = sp.id
		WHERE us.user_id = $1
		ORDER BY us.created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("query user subscriptions: %w", err)
	}
	defer rows.Close()

	var subscriptions []domain.UserSubscription
	for rows.Next() {
		var us domain.UserSubscription
		var plan domain.SubscriptionPlan

		var billingCycle, status, paymentProvider, externalSubID, cancellationReason, cancellationFeedback sql.NullString
		var startedAt, currentPeriodStart, currentPeriodEnd, trialEnd, cancelledAt, createdAt, updatedAt sql.NullTime
		var planDescription sql.NullString
		var planRecPerDay, planWardrobeLimit, planHistoryDays, planStylesLimit sql.NullInt32
		var planFeaturesJSON []byte

		err := rows.Scan(
			&us.ID,
			&us.UserID,
			&plan.ID,
			&billingCycle,
			&startedAt,
			&currentPeriodStart,
			&currentPeriodEnd,
			&trialEnd,
			&status,
			&us.AutoRenew,
			&cancelledAt,
			&us.CancelAtPeriodEnd,
			&paymentProvider,
			&externalSubID,
			&cancellationReason,
			&cancellationFeedback,
			&createdAt,
			&updatedAt,
			&plan.ID,
			&plan.Code,
			&plan.Name,
			&planDescription,
			&plan.PriceMonthly,
			&plan.PriceYearly,
			&plan.Currency,
			&planRecPerDay,
			&planWardrobeLimit,
			&planHistoryDays,
			&planStylesLimit,
			&plan.FamilyAccounts,
			&planFeaturesJSON,
			&plan.IsActive,
			&plan.SortOrder,
			&plan.TrialPeriodDays,
			&plan.CreatedAt,
			&plan.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan subscription: %w", err)
		}

		// Заполняем nullable поля
		if billingCycle.Valid {
			us.BillingCycle = &billingCycle.String
		}
		if status.Valid {
			us.Status = &status.String
		}
		if paymentProvider.Valid {
			us.PaymentProvider = &paymentProvider.String
		}
		if externalSubID.Valid {
			us.ExternalSubscriptionID = &externalSubID.String
		}
		if cancellationReason.Valid {
			us.CancellationReason = &cancellationReason.String
		}
		if cancellationFeedback.Valid {
			us.CancellationFeedback = &cancellationFeedback.String
		}
		if startedAt.Valid {
			us.StartedAt = &startedAt.Time
		}
		if currentPeriodStart.Valid {
			us.CurrentPeriodStart = &currentPeriodStart.Time
		}
		if currentPeriodEnd.Valid {
			us.CurrentPeriodEnd = &currentPeriodEnd.Time
		}
		if trialEnd.Valid {
			us.TrialEnd = &trialEnd.Time
		}
		if cancelledAt.Valid {
			us.CancelledAt = &cancelledAt.Time
		}
		if createdAt.Valid {
			us.CreatedAt = &createdAt.Time
		}
		if updatedAt.Valid {
			us.UpdatedAt = &updatedAt.Time
		}

		if planDescription.Valid {
			plan.Description = &planDescription.String
		}
		if planRecPerDay.Valid {
			v := int(planRecPerDay.Int32)
			plan.RecommendationsPerDay = &v
		}
		if planWardrobeLimit.Valid {
			v := int(planWardrobeLimit.Int32)
			plan.WardrobeItemsLimit = &v
		}
		if planHistoryDays.Valid {
			v := int(planHistoryDays.Int32)
			plan.HistoryDays = &v
		}
		if planStylesLimit.Valid {
			v := int(planStylesLimit.Int32)
			plan.StylesLimit = &v
		}
		plan.Features = planFeaturesJSON

		us.Plan = plan
		subscriptions = append(subscriptions, us)
	}

	return subscriptions, nil
}

// CreateSubscription создаёт новую подписку пользователя
func (r *UserSubscriptionRepo) CreateSubscription(ctx context.Context, sub *domain.UserSubscription) (int64, error) {
	query := `
		INSERT INTO user_subscriptions (
			user_id, plan_id, billing_cycle,
			started_at, current_period_start, current_period_end, trial_end,
			status, auto_renew, cancel_at_period_end,
			payment_provider, external_subscription_id,
			cancellation_reason, cancellation_feedback
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		RETURNING id
	`

	var id int64
	var billingCycle, status, paymentProvider, externalSubID, cancellationReason, cancellationFeedback interface{}

	if sub.BillingCycle != nil {
		billingCycle = *sub.BillingCycle
	} else {
		billingCycle = nil
	}
	if sub.Status != nil {
		status = *sub.Status
	} else {
		status = "active"
	}
	if sub.PaymentProvider != nil {
		paymentProvider = *sub.PaymentProvider
	} else {
		paymentProvider = nil
	}
	if sub.ExternalSubscriptionID != nil {
		externalSubID = *sub.ExternalSubscriptionID
	} else {
		externalSubID = nil
	}
	if sub.CancellationReason != nil {
		cancellationReason = *sub.CancellationReason
	} else {
		cancellationReason = nil
	}
	if sub.CancellationFeedback != nil {
		cancellationFeedback = *sub.CancellationFeedback
	} else {
		cancellationFeedback = nil
	}

	var startedAt, currentPeriodStart, currentPeriodEnd, trialEnd time.Time
	if sub.StartedAt != nil {
		startedAt = *sub.StartedAt
	} else {
		startedAt = time.Now()
	}
	if sub.CurrentPeriodStart != nil {
		currentPeriodStart = *sub.CurrentPeriodStart
	} else {
		currentPeriodStart = time.Now()
	}
	if sub.CurrentPeriodEnd != nil {
		currentPeriodEnd = *sub.CurrentPeriodEnd
	} else {
		currentPeriodEnd = time.Now().AddDate(0, 1, 0)
	}
	if sub.TrialEnd != nil {
		trialEnd = *sub.TrialEnd
	} else {
		trialEnd = time.Time{}
	}

	autoRenew := true
	if sub.AutoRenew != nil {
		autoRenew = *sub.AutoRenew
	}

	cancelAtPeriodEnd := false
	if sub.CancelAtPeriodEnd != nil {
		cancelAtPeriodEnd = *sub.CancelAtPeriodEnd
	}

	err := r.db.QueryRowContext(ctx, query,
		sub.UserID,
		sub.Plan.ID,
		billingCycle,
		startedAt,
		currentPeriodStart,
		currentPeriodEnd,
		trialEnd,
		status,
		autoRenew,
		cancelAtPeriodEnd,
		paymentProvider,
		externalSubID,
		cancellationReason,
		cancellationFeedback,
	).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create subscription: %w", err)
	}

	return id, nil
}

// UpdateSubscription обновляет подписку пользователя
func (r *UserSubscriptionRepo) UpdateSubscription(ctx context.Context, sub *domain.UserSubscription) error {
	query := `
		UPDATE user_subscriptions
		SET 
			plan_id = $2,
			billing_cycle = $3,
			current_period_start = $4,
			current_period_end = $5,
			trial_end = $6,
			status = $7,
			auto_renew = $8,
			cancelled_at = $9,
			cancel_at_period_end = $10,
			payment_provider = $11,
			external_subscription_id = $12,
			cancellation_reason = $13,
			cancellation_feedback = $14,
			updated_at = NOW()
		WHERE id = $1
	`

	var billingCycle, status, paymentProvider, externalSubID, cancellationReason, cancellationFeedback interface{}
	if sub.BillingCycle != nil {
		billingCycle = *sub.BillingCycle
	}
	if sub.Status != nil {
		status = *sub.Status
	}
	if sub.PaymentProvider != nil {
		paymentProvider = *sub.PaymentProvider
	}
	if sub.ExternalSubscriptionID != nil {
		externalSubID = *sub.ExternalSubscriptionID
	}
	if sub.CancellationReason != nil {
		cancellationReason = *sub.CancellationReason
	}
	if sub.CancellationFeedback != nil {
		cancellationFeedback = *sub.CancellationFeedback
	}

	var currentPeriodStart, currentPeriodEnd, trialEnd, cancelledAt interface{}
	if sub.CurrentPeriodStart != nil {
		currentPeriodStart = *sub.CurrentPeriodStart
	}
	if sub.CurrentPeriodEnd != nil {
		currentPeriodEnd = *sub.CurrentPeriodEnd
	}
	if sub.TrialEnd != nil {
		trialEnd = *sub.TrialEnd
	}
	if sub.CancelledAt != nil {
		cancelledAt = *sub.CancelledAt
	}

	autoRenew := true
	if sub.AutoRenew != nil {
		autoRenew = *sub.AutoRenew
	}

	cancelAtPeriodEnd := false
	if sub.CancelAtPeriodEnd != nil {
		cancelAtPeriodEnd = *sub.CancelAtPeriodEnd
	}

	_, err := r.db.ExecContext(ctx, query,
		*sub.ID,
		sub.Plan.ID,
		billingCycle,
		currentPeriodStart,
		currentPeriodEnd,
		trialEnd,
		status,
		autoRenew,
		cancelledAt,
		cancelAtPeriodEnd,
		paymentProvider,
		externalSubID,
		cancellationReason,
		cancellationFeedback,
	)
	if err != nil {
		return fmt.Errorf("update subscription: %w", err)
	}

	return nil
}

// CancelSubscription отменяет подписку пользователя
func (r *UserSubscriptionRepo) CancelSubscription(ctx context.Context, userID domain.ID, immediate bool, reason, feedback *string) error {
	var query string
	var args []interface{}

	if immediate {
		query = `
			UPDATE user_subscriptions
			SET 
				status = 'cancelled',
				cancelled_at = NOW(),
				cancellation_reason = $2,
				cancellation_feedback = $3,
				updated_at = NOW()
			WHERE user_id = $1 AND status IN ('active', 'trialing')
		`
		args = []interface{}{userID, reason, feedback}
	} else {
		query = `
			UPDATE user_subscriptions
			SET 
				cancel_at_period_end = TRUE,
				cancellation_reason = $2,
				cancellation_feedback = $3,
				updated_at = NOW()
			WHERE user_id = $1 AND status IN ('active', 'trialing')
		`
		args = []interface{}{userID, reason, feedback}
	}

	_, err := r.db.ExecContext(ctx, query, args...)
	if err != nil {
		return fmt.Errorf("cancel subscription: %w", err)
	}

	return nil
}

// ReactivateSubscription восстанавливает подписку пользователя
func (r *UserSubscriptionRepo) ReactivateSubscription(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE user_subscriptions
		SET 
			status = 'active',
			cancelled_at = NULL,
			cancel_at_period_end = FALSE,
			cancellation_reason = NULL,
			cancellation_feedback = NULL,
			updated_at = NOW()
		WHERE user_id = $1 AND status = 'cancelled'
	`

	_, err := r.db.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("reactivate subscription: %w", err)
	}

	return nil
}

// UpgradeSubscription изменяет план подписки
func (r *UserSubscriptionRepo) UpgradeSubscription(ctx context.Context, userID domain.ID, newPlanID int64, newPeriodEnd time.Time) error {
	query := `
		UPDATE user_subscriptions
		SET 
			plan_id = $2,
			current_period_end = $3,
			updated_at = NOW()
		WHERE user_id = $1 AND status IN ('active', 'trialing')
	`

	_, err := r.db.ExecContext(ctx, query, userID, newPlanID, newPeriodEnd)
	if err != nil {
		return fmt.Errorf("upgrade subscription: %w", err)
	}

	return nil
}

// ExtendSubscription продлевает подписку на указанный период
func (r *UserSubscriptionRepo) ExtendSubscription(ctx context.Context, userID domain.ID, duration time.Duration) error {
	query := `
		UPDATE user_subscriptions
		SET 
			current_period_end = current_period_end + $2::INTERVAL,
			updated_at = NOW()
		WHERE user_id = $1 AND status IN ('active', 'trialing')
	`

	interval := fmt.Sprintf("%d seconds", int(duration.Seconds()))
	_, err := r.db.ExecContext(ctx, query, userID, interval)
	if err != nil {
		return fmt.Errorf("extend subscription: %w", err)
	}

	return nil
}

// StartTrial начинает пробный период для пользователя
func (r *UserSubscriptionRepo) StartTrial(ctx context.Context, userID domain.ID, planID int64, trialDays int) error {
	query := `
		INSERT INTO user_subscriptions (
			user_id, plan_id, billing_cycle,
			started_at, current_period_start, current_period_end, trial_end,
			status, auto_renew
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (user_id, plan_id, status) DO UPDATE SET
			trial_end = EXCLUDED.trial_end,
			status = EXCLUDED.status,
			updated_at = NOW()
	`

	now := time.Now()
	trialEnd := now.AddDate(0, 0, trialDays)
	periodEnd := now.AddDate(0, 1, 0) // После триала - месяц

	_, err := r.db.ExecContext(ctx, query,
		userID,
		planID,
		"monthly",
		now,
		now,
		periodEnd,
		trialEnd,
		"trialing",
		true,
	)
	if err != nil {
		return fmt.Errorf("start trial: %w", err)
	}

	return nil
}

// GetSubscriptionsExpiringSoon возвращает подписки, истекающие в ближайшее время
func (r *UserSubscriptionRepo) GetSubscriptionsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error) {
	query := `
		SELECT 
			us.id, us.user_id, us.plan_id,
			us.billing_cycle,
			us.started_at, us.current_period_start, us.current_period_end, us.trial_end,
			us.status, us.auto_renew, us.cancelled_at, us.cancel_at_period_end,
			us.payment_provider, us.external_subscription_id,
			us.cancellation_reason, us.cancellation_feedback,
			us.created_at, us.updated_at,
			sp.id, sp.code, sp.name, sp.description,
			sp.price_monthly, sp.price_yearly, sp.currency,
			sp.recommendations_per_day, sp.wardrobe_items_limit, sp.history_days, sp.styles_limit, sp.family_accounts,
			sp.features, sp.is_active, sp.sort_order, sp.trial_period_days,
			sp.created_at, sp.updated_at
		FROM user_subscriptions us
		JOIN subscription_plans sp ON us.plan_id = sp.id
		WHERE us.status IN ('active', 'trialing')
		  AND us.current_period_end <= $1
		  AND us.cancel_at_period_end = FALSE
		ORDER BY us.current_period_end ASC
	`

	rows, err := r.db.QueryContext(ctx, query, before)
	if err != nil {
		return nil, fmt.Errorf("query expiring subscriptions: %w", err)
	}
	defer rows.Close()

	var subscriptions []domain.UserSubscription
	for rows.Next() {
		var us domain.UserSubscription
		var plan domain.SubscriptionPlan

		var billingCycle, status, paymentProvider, externalSubID, cancellationReason, cancellationFeedback sql.NullString
		var startedAt, currentPeriodStart, currentPeriodEnd, trialEnd, cancelledAt, createdAt, updatedAt sql.NullTime
		var planDescription sql.NullString
		var planRecPerDay, planWardrobeLimit, planHistoryDays, planStylesLimit sql.NullInt32
		var planFeaturesJSON []byte

		err := rows.Scan(
			&us.ID, &us.UserID, &plan.ID,
			&billingCycle, &startedAt, &currentPeriodStart, &currentPeriodEnd, &trialEnd,
			&status, &us.AutoRenew, &cancelledAt, &us.CancelAtPeriodEnd,
			&paymentProvider, &externalSubID, &cancellationReason, &cancellationFeedback,
			&createdAt, &updatedAt,
			&plan.ID, &plan.Code, &plan.Name, &planDescription,
			&plan.PriceMonthly, &plan.PriceYearly, &plan.Currency,
			&planRecPerDay, &planWardrobeLimit, &planHistoryDays, &planStylesLimit,
			&plan.FamilyAccounts, &planFeaturesJSON, &plan.IsActive, &plan.SortOrder, &plan.TrialPeriodDays,
			&plan.CreatedAt, &plan.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan subscription: %w", err)
		}

		// Заполняем nullable поля (упрощённо)
		if billingCycle.Valid {
			us.BillingCycle = &billingCycle.String
		}
		if status.Valid {
			us.Status = &status.String
		}
		if paymentProvider.Valid {
			us.PaymentProvider = &paymentProvider.String
		}
		if externalSubID.Valid {
			us.ExternalSubscriptionID = &externalSubID.String
		}
		if currentPeriodEnd.Valid {
			us.CurrentPeriodEnd = &currentPeriodEnd.Time
		}

		us.Plan = plan
		subscriptions = append(subscriptions, us)
	}

	return subscriptions, nil
}

// GetTrialsExpiringSoon возвращает пробные подписки, истекающие в ближайшее время
func (r *UserSubscriptionRepo) GetTrialsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error) {
	query := `
		SELECT 
			us.id, us.user_id, us.plan_id,
			us.billing_cycle,
			us.started_at, us.current_period_start, us.current_period_end, us.trial_end,
			us.status, us.auto_renew, us.cancelled_at, us.cancel_at_period_end,
			us.payment_provider, us.external_subscription_id,
			us.cancellation_reason, us.cancellation_feedback,
			us.created_at, us.updated_at,
			sp.id, sp.code, sp.name, sp.description,
			sp.price_monthly, sp.price_yearly, sp.currency,
			sp.recommendations_per_day, sp.wardrobe_items_limit, sp.history_days, sp.styles_limit, sp.family_accounts,
			sp.features, sp.is_active, sp.sort_order, sp.trial_period_days,
			sp.created_at, sp.updated_at
		FROM user_subscriptions us
		JOIN subscription_plans sp ON us.plan_id = sp.id
		WHERE us.status = 'trialing'
		  AND us.trial_end <= $1
		ORDER BY us.trial_end ASC
	`

	rows, err := r.db.QueryContext(ctx, query, before)
	if err != nil {
		return nil, fmt.Errorf("query expiring trials: %w", err)
	}
	defer rows.Close()

	var subscriptions []domain.UserSubscription
	for rows.Next() {
		var us domain.UserSubscription
		var plan domain.SubscriptionPlan

		var billingCycle, status, paymentProvider, externalSubID, cancellationReason, cancellationFeedback sql.NullString
		var startedAt, currentPeriodStart, currentPeriodEnd, trialEnd, cancelledAt, createdAt, updatedAt sql.NullTime
		var planDescription sql.NullString
		var planRecPerDay, planWardrobeLimit, planHistoryDays, planStylesLimit sql.NullInt32
		var planFeaturesJSON []byte

		err := rows.Scan(
			&us.ID, &us.UserID, &plan.ID,
			&billingCycle, &startedAt, &currentPeriodStart, &currentPeriodEnd, &trialEnd,
			&status, &us.AutoRenew, &cancelledAt, &us.CancelAtPeriodEnd,
			&paymentProvider, &externalSubID, &cancellationReason, &cancellationFeedback,
			&createdAt, &updatedAt,
			&plan.ID, &plan.Code, &plan.Name, &planDescription,
			&plan.PriceMonthly, &plan.PriceYearly, &plan.Currency,
			&planRecPerDay, &planWardrobeLimit, &planHistoryDays, &planStylesLimit,
			&plan.FamilyAccounts, &planFeaturesJSON, &plan.IsActive, &plan.SortOrder, &plan.TrialPeriodDays,
			&plan.CreatedAt, &plan.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan subscription: %w", err)
		}

		if billingCycle.Valid {
			us.BillingCycle = &billingCycle.String
		}
		if status.Valid {
			us.Status = &status.String
		}
		if paymentProvider.Valid {
			us.PaymentProvider = &paymentProvider.String
		}
		if externalSubID.Valid {
			us.ExternalSubscriptionID = &externalSubID.String
		}
		if trialEnd.Valid {
			us.TrialEnd = &trialEnd.Time
		}
		if currentPeriodEnd.Valid {
			us.CurrentPeriodEnd = &currentPeriodEnd.Time
		}

		us.Plan = plan
		subscriptions = append(subscriptions, us)
	}

	return subscriptions, nil
}
