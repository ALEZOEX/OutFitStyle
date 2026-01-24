package domain

import "time"

type BillingStatus string

const (
	BillingStatusPending BillingStatus = "pending"
	BillingStatusPaid BillingStatus = "paid"
	BillingStatusFailed BillingStatus = "failed"
	BillingStatusRefunded BillingStatus = "refunded"
	BillingStatusCancelled BillingStatus = "cancelled"
)

type BillingTransaction struct {
	ID               ID            `json:"id"`
	UserID           ID            `json:"user_id"`
	Amount           float64       `json:"amount"`
	Currency         string        `json:"currency"`
	Status           BillingStatus `json:"status"`
	PaymentMethod    string        `json:"payment_method"`
	TransactionID    string        `json:"transaction_id"`
	Description      string        `json:"description"`
	Metadata         any           `json:"metadata"`
	CreatedAt        time.Time     `json:"created_at"`
	ProcessedAt      *time.Time    `json:"processed_at,omitempty"`
}