package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

type BillingRepository interface {
	CreateUserSubscription(ctx context.Context, userID int64, planID int64, billingCycle string, periodEnd time.Time, provider string) (int64, error)
	CancelSubscription(ctx context.Context, userID int64, immediate bool) error
	ReactivateSubscription(ctx context.Context, userID int64) error

	CreatePayment(ctx context.Context, p CreatePaymentParams) (int64, error)
	UpdatePaymentStatusByExternalID(ctx context.Context, provider string, externalPaymentID string, status string, receiptURL *string, errMsg *string) error

	ListPayments(ctx context.Context, userID int64, page, limit int) (items []domain.Payment, total int, err error)
}

type CreatePaymentParams struct {
	UserID         int64
	SubscriptionID *int64

	Amount   float64
	Currency string

	Status          string
	PaymentProvider string

	ExternalPaymentID *string
	PaymentMethod     *string
	Description       *string
}