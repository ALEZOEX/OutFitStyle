package domain

import (
	"context"
	"time"
)

// PaymentInit represents the result of initializing a payment with a provider
type PaymentInit struct {
	Provider          string
	ExternalPaymentID string
	PaymentURL        *string
	ClientSecret      *string
}

// Payment represents a payment record
type Payment struct {
	ID                int64      `json:"id"`
	UserID           int64      `json:"user_id"`
	SubscriptionID   *int64     `json:"subscription_id,omitempty"`
	Amount           float64    `json:"amount"`
	Currency         string     `json:"currency"`
	Status           string     `json:"status"` // pending, completed, failed, refunded
	PaymentProvider  string     `json:"payment_provider"`
	ExternalPaymentID string    `json:"external_payment_id"`
	ReceiptURL       *string    `json:"receipt_url,omitempty"`
	ErrorMessage     *string    `json:"error_message,omitempty"`
	PaidAt           *time.Time `json:"paid_at,omitempty"`
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`

	// Additional fields that might be needed
	PaymentMethod   *string    `json:"payment_method,omitempty"`
	Description     *string    `json:"description,omitempty"`
	CompletedAt     *time.Time `json:"completed_at,omitempty"`
}

// PaymentGateway defines the interface for payment providers
type PaymentGateway interface {
	// InitPayment создаёт платёж у провайдера и возвращает идентификаторы/URL.
	InitPayment(ctx context.Context, amount float64, currency string, description string, metadata map[string]any) (PaymentInit, error)

	// WebhookParse (MVP): извлечь external_payment_id и новый статус.
	ParseWebhook(ctx context.Context, headers map[string]string, body []byte) (externalPaymentID string, status string, receiptURL *string, errMsg *string, err error)
}