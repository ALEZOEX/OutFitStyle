package domain

import "time"

type PromoCode struct {
	ID              ID        `json:"id"`
	Code            string    `json:"code"`
	Type            string    `json:"type"` // percentage, fixed_amount, free_shipping
	Value           float64   `json:"value"`
	Currency        *string   `json:"currency,omitempty"` // for fixed amount discounts
	MinOrderAmount  *float64  `json:"min_order_amount,omitempty"`
	MaxDiscount     *float64  `json:"max_discount,omitempty"`
	UsageLimit      *int      `json:"usage_limit,omitempty"`
	UsageLimitPerUser *int     `json:"usage_limit_per_user,omitempty"`
	StartDate       time.Time `json:"start_date"`
	EndDate         *time.Time `json:"end_date,omitempty"`
	IsActive        bool      `json:"is_active"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

type PromoRedemption struct {
	ID         ID        `json:"id"`
	UserID     ID        `json:"user_id"`
	PromoCodeID ID       `json:"promo_code_id"`
	OrderID    *ID       `json:"order_id,omitempty"`
	Discount   float64   `json:"discount"`
	Currency   string    `json:"currency"`
	CreatedAt  time.Time `json:"created_at"`
}