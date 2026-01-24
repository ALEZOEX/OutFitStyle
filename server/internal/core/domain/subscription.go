package domain

import (
	"encoding/json"
	"time"
)

type SubscriptionPlan struct {
	ID          int64   `json:"id"`
	Code        string  `json:"code"`
	Name        string  `json:"name"`
	Description *string `json:"description,omitempty"`

	PriceMonthly float64 `json:"price_monthly"`
	PriceYearly  float64 `json:"price_yearly"`
	Currency     string  `json:"currency"`

	RecommendationsPerDay *int `json:"recommendations_per_day,omitempty"`
	WardrobeItemsLimit    *int `json:"wardrobe_items_limit,omitempty"`
	HistoryDays           *int `json:"history_days,omitempty"`
	StylesLimit           *int `json:"styles_limit,omitempty"`
	FamilyAccounts        int  `json:"family_accounts"`

	Features json.RawMessage `json:"features"`

	IsActive  bool `json:"is_active"`
	SortOrder int  `json:"sort_order"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UserSubscription struct {
	ID     *int64 `json:"id,omitempty"` // может быть nil для "virtual free"
	UserID int64  `json:"user_id"`

	Plan SubscriptionPlan `json:"plan"`

	BillingCycle           *string    `json:"billing_cycle,omitempty"` // monthly/yearly
	StartedAt              *time.Time `json:"started_at,omitempty"`
	CurrentPeriodStart     *time.Time `json:"current_period_start,omitempty"`
	CurrentPeriodEnd       *time.Time `json:"current_period_end,omitempty"`
	CancelledAt            *time.Time `json:"cancelled_at,omitempty"`
	Status                 *string    `json:"status,omitempty"` // active/trialing/...
	AutoRenew              *bool      `json:"auto_renew,omitempty"`
	PaymentProvider        *string    `json:"payment_provider,omitempty"`
	ExternalSubscriptionID *string    `json:"external_subscription_id,omitempty"`
	TrialEnd               *time.Time `json:"trial_end,omitempty"`

	CreatedAt *time.Time `json:"created_at,omitempty"`
	UpdatedAt *time.Time `json:"updated_at,omitempty"`
}

type SubscriptionUsage struct {
	RecommendationsToday int  `json:"recommendations_today"`
	RecommendationsLimit *int `json:"recommendations_limit,omitempty"`

	WardrobeCount int  `json:"wardrobe_count"`
	WardrobeLimit *int `json:"wardrobe_limit,omitempty"`
}

type CurrentSubscriptionResponse struct {
	Subscription UserSubscription  `json:"subscription"`
	Usage        SubscriptionUsage `json:"usage"`
}

type Subscription struct {
	ID                  ID        `json:"id"`
	UserID              ID        `json:"user_id"`
	PlanID              string    `json:"plan_id"`
	Name                string    `json:"name"`
	Description         string    `json:"description"`
	Interval            string    `json:"interval"` // month, year
	IntervalCount       int       `json:"interval_count"`
	TrialPeriodDays     *int      `json:"trial_period_days,omitempty"`
	IsActive            bool      `json:"is_active"`
	IsTrial             bool      `json:"is_trial"`
	IsCanceled          bool      `json:"is_canceled"`
	CancelAtPeriodEnd   bool      `json:"cancel_at_period_end"`
	CurrentPeriodStart  time.Time `json:"current_period_start"`
	CurrentPeriodEnd    time.Time `json:"current_period_end"`
	CanceledAt          *time.Time `json:"canceled_at,omitempty"`
	ExpiresAt           *time.Time `json:"expires_at,omitempty"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`
}
