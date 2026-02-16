package domain

import "time"

// PromoCode промокод для скидок на подписки
type PromoCode struct {
	ID                ID         `json:"id"`
	Code              string     `json:"code"`
	Name              *string    `json:"name,omitempty"`
	Type              string     `json:"type"` // percentage, fixed_amount, free_shipping (legacy)
	Value             float64    `json:"value"`
	Currency          *string    `json:"currency,omitempty"`
	MinOrderAmount    *float64   `json:"min_order_amount,omitempty"`
	MaxDiscount       *float64   `json:"max_discount,omitempty"`
	UsageLimit        *int       `json:"usage_limit,omitempty"`
	UsageLimitPerUser *int       `json:"usage_limit_per_user,omitempty"`
	StartDate         *time.Time `json:"start_date,omitempty"`
	EndDate           *time.Time `json:"end_date,omitempty"`
	IsActive          bool       `json:"is_active"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`

	// Новые поля для системы подписок
	DiscountType      string     `json:"discount_type"` // percentage|fixed_amount|free_trial|free_month
	DiscountValue     float64    `json:"discount_value"`
	ValidFrom         time.Time  `json:"valid_from"`
	ValidUntil        *time.Time `json:"valid_until,omitempty"`
	UsesCount         int        `json:"uses_count"`
	ApplicablePlans   []string   `json:"applicable_plans"`
	MinBillingCycle   *string    `json:"min_billing_cycle,omitempty"`
}

// IsValidForPlan проверяет, применим ли промокод к плану
func (p *PromoCode) IsValidForPlan(planCode string) bool {
	if len(p.ApplicablePlans) == 0 {
		return true
	}
	for _, code := range p.ApplicablePlans {
		if code == planCode {
			return true
		}
	}
	return false
}

// IsValidForCycle проверяет, применим ли промокод к циклу оплаты
func (p *PromoCode) IsValidForCycle(cycle string) bool {
	if p.MinBillingCycle == nil {
		return true
	}
	// yearly >= monthly
	if *p.MinBillingCycle == "yearly" && cycle != "yearly" {
		return false
	}
	return true
}

// IsExpired проверяет, истёк ли промокод
func (p *PromoCode) IsExpired() bool {
	if p.ValidUntil == nil {
		return false
	}
	return time.Now().After(*p.ValidUntil)
}

// CanBeUsedByUser проверяет, может ли пользователь использовать промокод
func (p *PromoCode) CanBeUsedByUser(usedCount int) bool {
	if p.UsageLimitPerUser != nil && *p.UsageLimitPerUser > 0 && usedCount >= *p.UsageLimitPerUser {
		return false
	}
	if p.UsageLimit != nil && p.UsesCount >= *p.UsageLimit {
		return false
	}
	return true
}

// PromoRedemption использование промокода
type PromoRedemption struct {
	ID             ID        `json:"id"`
	UserID         ID        `json:"user_id"`
	PromoCodeID    ID        `json:"promo_code_id"`
	OrderID        *ID       `json:"order_id,omitempty"`
	SubscriptionID *int64    `json:"subscription_id,omitempty"`
	Discount       float64   `json:"discount"`
	DiscountAmount float64   `json:"discount_amount"`
	Currency       string    `json:"currency"`
	CreatedAt      time.Time `json:"created_at"`
}
