package domain

import "time"

// SubscribeRequest запрос на оформление подписки
type SubscribeRequest struct {
	PlanCode        string  `json:"plan_code"` // free|premium|pro|business
	BillingCycle    string  `json:"billing_cycle"` // monthly|yearly
	PaymentProvider string  `json:"payment_provider"` // yookassa|stripe|dummy

	PaymentMethodID *string `json:"payment_method_id,omitempty"`
	PromoCode       *string `json:"promo_code,omitempty"`

	// Для YooKassa
	ReturnURL *string `json:"return_url,omitempty"`
}

// SubscribeResponse ответ на оформление подписки
type SubscribeResponse struct {
	Subscription UserSubscription `json:"subscription"`
	PaymentURL   *string          `json:"payment_url,omitempty"`
	ClientSecret *string          `json:"client_secret,omitempty"`
	PaymentID    *string          `json:"payment_id,omitempty"`
}

// CancelSubscriptionRequest запрос на отмену подписки
type CancelSubscriptionRequest struct {
	Reason    *string `json:"reason,omitempty"`
	Feedback  *string `json:"feedback,omitempty"`
	Immediate *bool   `json:"immediate,omitempty"`
}

// PromoRequest запрос на проверку промокода
type PromoRequest struct {
	Code     string  `json:"code"`
	PlanCode *string `json:"plan_code,omitempty"`
}

// PromoResponse ответ с информацией о промокоде
type PromoResponse struct {
	Code           string     `json:"code"`
	Name           *string    `json:"name,omitempty"`
	DiscountType   string     `json:"discount_type"`
	DiscountValue  float64    `json:"discount_value"`
	Currency       *string    `json:"currency,omitempty"`
	ValidUntil     *time.Time `json:"valid_until,omitempty"`
	ApplicablePlans []string  `json:"applicable_plans"`
}
