package domain

import (
	"encoding/json"
	"time"
)

// SubscriptionPlan план подписки (соответствует таблице subscription_plans)
type SubscriptionPlan struct {
	ID          int64   `json:"id"`
	Code        string  `json:"code"` // free, premium, pro, business
	Name        string  `json:"name"`
	Description *string `json:"description,omitempty"`

	// Цены
	PriceMonthly float64 `json:"price_monthly"`
	PriceYearly  float64 `json:"price_yearly"`
	Currency     string  `json:"currency"`

	// Лимиты
	RecommendationsPerDay *int `json:"recommendations_per_day,omitempty"`
	WardrobeItemsLimit    *int `json:"wardrobe_items_limit,omitempty"`
	HistoryDays           *int `json:"history_days,omitempty"`
	StylesLimit           *int `json:"styles_limit,omitempty"`
	FamilyAccounts        int  `json:"family_accounts"`

	// Фичи
	Features json.RawMessage `json:"features"`

	// Метаданные
	IsActive        bool `json:"is_active"`
	SortOrder       int  `json:"sort_order"`
	TrialPeriodDays int  `json:"trial_period_days"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// GetPrice возвращает цену для указанного цикла оплаты
func (p *SubscriptionPlan) GetPrice(cycle BillingCycle) float64 {
	if cycle == BillingCycleYearly {
		return p.PriceYearly
	}
	return p.PriceMonthly
}

// HasUnlimitedRecommendations проверяет, есть ли безлимитные рекомендации
func (p *SubscriptionPlan) HasUnlimitedRecommendations() bool {
	return p.RecommendationsPerDay == nil
}

// HasUnlimitedWardrobe проверяет, есть ли безлимитный гардероб
func (p *SubscriptionPlan) HasUnlimitedWardrobe() bool {
	return p.WardrobeItemsLimit == nil
}

// HasUnlimitedHistory проверяет, есть ли безлимитная история
func (p *SubscriptionPlan) HasUnlimitedHistory() bool {
	return p.HistoryDays == nil
}

// UserSubscription активная подписка пользователя (соответствует таблице user_subscriptions)
type UserSubscription struct {
	ID        *int64 `json:"id,omitempty"`
	UserID    int64  `json:"user_id"`
	UserUUID  ID     `json:"user_uuid,omitempty"` // для совместимости
	Plan      SubscriptionPlan `json:"plan"`

	// Цикл оплаты
	BillingCycle *string `json:"billing_cycle,omitempty"` // monthly|yearly

	// Периоды
	StartedAt          *time.Time `json:"started_at,omitempty"`
	CurrentPeriodStart *time.Time `json:"current_period_start,omitempty"`
	CurrentPeriodEnd   *time.Time `json:"current_period_end,omitempty"`
	TrialEnd           *time.Time `json:"trial_end,omitempty"`

	// Статусы
	Status           *string `json:"status,omitempty"` // active|trialing|cancelled|expired|past_due
	AutoRenew        *bool   `json:"auto_renew,omitempty"`
	CancelledAt      *time.Time `json:"cancelled_at,omitempty"`
	CancelAtPeriodEnd *bool   `json:"cancel_at_period_end,omitempty"`

	// Платежный провайдер
	PaymentProvider        *string `json:"payment_provider,omitempty"`
	ExternalSubscriptionID *string `json:"external_subscription_id,omitempty"`

	// Отмена
	CancellationReason   *string `json:"cancellation_reason,omitempty"`
	CancellationFeedback *string `json:"cancellation_feedback,omitempty"`

	CreatedAt *time.Time `json:"created_at,omitempty"`
	UpdatedAt *time.Time `json:"updated_at,omitempty"`
}

// IsActive проверяет, активна ли подписка
func (s *UserSubscription) IsActive() bool {
	if s.Status == nil {
		return false
	}
	return *s.Status == string(SubscriptionStatusActive) || *s.Status == string(SubscriptionStatusTrialing)
}

// IsTrial проверяет, находится ли подписка в пробном периоде
func (s *UserSubscription) IsTrial() bool {
	if s.TrialEnd == nil {
		return false
	}
	return time.Now().Before(*s.TrialEnd)
}

// IsCancelled проверяет, отменена ли подписка
func (s *UserSubscription) IsCancelled() bool {
	return s.CancelledAt != nil || (s.CancelAtPeriodEnd != nil && *s.CancelAtPeriodEnd)
}

// WillExpireAt возвращает дату окончания подписки
func (s *UserSubscription) WillExpireAt() *time.Time {
	if s.CancelAtPeriodEnd != nil && *s.CancelAtPeriodEnd {
		return s.CurrentPeriodEnd
	}
	if s.Status != nil && *s.Status == string(SubscriptionStatusCancelled) {
		return s.CurrentPeriodEnd
	}
	return s.CurrentPeriodEnd
}

// SubscriptionUsage использование лимитов подписки (соответствует таблице subscription_usage)
type SubscriptionUsage struct {
	ID       *int64 `json:"id,omitempty"`
	UserID   int64  `json:"user_id"`
	UserUUID ID     `json:"user_uuid,omitempty"`
	SubscriptionID *int64 `json:"subscription_id,omitempty"`

	// Счётчики
	RecommendationsToday  int  `json:"recommendations_today"`
	RecommendationsLimit  *int `json:"recommendations_limit,omitempty"`
	RecommendationsResetAt *time.Time `json:"recommendations_reset_at,omitempty"`

	WardrobeCount int  `json:"wardrobe_count"`
	WardrobeLimit *int `json:"wardrobe_limit,omitempty"`

	// История
	LastResetAt *time.Time `json:"last_reset_at,omitempty"`
}

// CanCreateRecommendation проверяет, можно ли создать рекомендацию
func (u *SubscriptionUsage) CanCreateRecommendation() bool {
	if u.RecommendationsLimit == nil {
		return true
	}
	return u.RecommendationsToday < *u.RecommendationsLimit
}

// CanAddWardrobeItem проверяет, можно ли добавить вещь в гардероб
func (u *SubscriptionUsage) CanAddWardrobeItem() bool {
	if u.WardrobeLimit == nil {
		return true
	}
	return u.WardrobeCount < *u.WardrobeLimit
}

// CurrentSubscriptionResponse ответ с текущей подпиской и использованием
type CurrentSubscriptionResponse struct {
	Subscription UserSubscription `json:"subscription"`
	Usage        SubscriptionUsage `json:"usage"`
	Limits       SubscriptionLimits `json:"limits"`
}

// SubscriptionTransaction транзакция подписки (соответствует таблице subscription_transactions)
type SubscriptionTransaction struct {
	ID             int64      `json:"id"`
	UserID         int64      `json:"user_id"`
	UserUUID       ID         `json:"user_uuid,omitempty"`
	SubscriptionID *int64     `json:"subscription_id,omitempty"`

	// Сумма
	Amount   float64 `json:"amount"`
	Currency string  `json:"currency"`

	// Статус
	Status string `json:"status"` // pending|paid|failed|refunded|cancelled

	// Платежный провайдер
	PaymentProvider   string  `json:"payment_provider"`
	ExternalPaymentID string  `json:"external_payment_id"`
	PaymentMethod     *string `json:"payment_method,omitempty"`

	// Метаданные
	Description   *string `json:"description,omitempty"`
	ReceiptURL    *string `json:"receipt_url,omitempty"`
	ErrorMessage  *string `json:"error_message,omitempty"`

	// Временные метки
	PaidAt      *time.Time `json:"paid_at,omitempty"`
	RefundedAt  *time.Time `json:"refunded_at,omitempty"`

	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// FamilyMember семейный участник (соответствует таблице family_members)
type FamilyMember struct {
	ID            int64      `json:"id"`
	OwnerUserID   int64      `json:"owner_user_id"`
	OwnerUserUUID ID         `json:"owner_user_uuid,omitempty"`
	MemberUserID  int64      `json:"member_user_id"`
	MemberUserUUID ID        `json:"member_user_uuid,omitempty"`

	Status      string     `json:"status"` // pending|active|removed|expired
	InvitedAt   time.Time  `json:"invited_at"`
	AcceptedAt  *time.Time `json:"accepted_at,omitempty"`
	ExpiresAt   *time.Time `json:"expires_at,omitempty"`

	AddedBy     *int64   `json:"added_by,omitempty"`
	AddedByUUID *ID      `json:"added_by_uuid,omitempty"`

	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// IsActive проверяет, активен ли семейный участник
func (f *FamilyMember) IsActive() bool {
	return f.Status == string(FamilyMemberStatusActive)
}

// IsPending проверяет, ожидает ли приглашение принятия
func (f *FamilyMember) IsPending() bool {
	return f.Status == string(FamilyMemberStatusPending)
}

// IsExpired проверяет, истёкло ли приглашение
func (f *FamilyMember) IsExpired() bool {
	if f.ExpiresAt == nil {
		return false
	}
	return time.Now().After(*f.ExpiresAt)
}

// UpgradeSubscriptionRequest запрос на изменение плана подписки
type UpgradeSubscriptionRequest struct {
	NewPlanCode     string  `json:"new_plan_code"`
	NewBillingCycle string  `json:"new_billing_cycle,omitempty"`
	PromoCode       *string `json:"promo_code,omitempty"`
}

// ApplyPromoCodeResponse ответ на применение промокода
type ApplyPromoCodeResponse struct {
	Success        bool    `json:"success"`
	DiscountAmount float64 `json:"discount_amount"`
	OriginalAmount float64 `json:"original_amount"`
	FinalAmount    float64 `json:"final_amount"`
	Currency       string  `json:"currency"`
	Message        string  `json:"message,omitempty"`
}
