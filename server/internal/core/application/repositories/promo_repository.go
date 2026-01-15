package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

type PromoCode struct {
	ID domain.ID

	Code string

	DiscountType  string
	DiscountValue float64

	ApplicablePlans []domain.ID
	MinBillingCycle *string

	MaxUses        *int
	UsesCount      int
	MaxUsesPerUser int

	ValidFrom  time.Time
	ValidUntil *time.Time

	IsActive bool
}

type PromoRepository interface {
	GetByCode(ctx context.Context, code string) (*PromoCode, error)
}
