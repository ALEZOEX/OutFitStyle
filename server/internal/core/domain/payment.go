package domain

import (
	"context"
	"time"
)

// PaymentInit представляет результат инициализации платежа у провайдера
type PaymentInit struct {
	Provider          string  `json:"provider"`
	ExternalPaymentID string  `json:"external_payment_id"`
	PaymentURL        *string `json:"payment_url,omitempty"`
	ClientSecret      *string `json:"client_secret,omitempty"`
	ConfirmationURL   *string `json:"confirmation_url,omitempty"` // для YooKassa
	ConfirmationType  *string `json:"confirmation_type,omitempty"` // redirect|embedded|external
}

// Payment представляет запись о платеже
type Payment struct {
	ID                int64      `json:"id"`
	UserID            int64      `json:"user_id"`
	UserUUID          ID         `json:"user_uuid,omitempty"`
	SubscriptionID    *int64     `json:"subscription_id,omitempty"`
	Amount            float64    `json:"amount"`
	Currency          string     `json:"currency"`
	Status            string     `json:"status"` // pending|completed|failed|refunded
	PaymentProvider   string     `json:"payment_provider"`
	ExternalPaymentID string     `json:"external_payment_id"`
	ReceiptURL        *string    `json:"receipt_url,omitempty"`
	ErrorMessage      *string    `json:"error_message,omitempty"`
	PaidAt            *time.Time `json:"paid_at,omitempty"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`

	// Дополнительные поля
	PaymentMethod *string    `json:"payment_method,omitempty"`
	Description   *string    `json:"description,omitempty"`
	CompletedAt   *time.Time `json:"completed_at,omitempty"`

	// Метаданные для YooKassa
	Metadata map[string]string `json:"metadata,omitempty"`
}

// PaymentGateway определяет интерфейс для платежных провайдеров
type PaymentGateway interface {
	// InitPayment создаёт платёж у провайдера и возвращает идентификаторы/URL
	InitPayment(ctx context.Context, amount float64, currency string, description string, metadata map[string]any) (PaymentInit, error)

	// GetPaymentStatus получает статус платежа у провайдера
	GetPaymentStatus(ctx context.Context, externalPaymentID string) (status string, receiptURL *string, errMsg *string, err error)

	// RefundPayment возвращает средства по платежу
	RefundPayment(ctx context.Context, externalPaymentID string, amount *float64, description string) error

	// ParseWebhook обрабатывает webhook от провайдера
	ParseWebhook(ctx context.Context, headers map[string]string, body []byte) (externalPaymentID string, status string, receiptURL *string, errMsg *string, err error)

	// VerifyWebhookSignature проверяет подпись webhook (для безопасности)
	VerifyWebhookSignature(ctx context.Context, headers map[string]string, body []byte) error
}

// YooKassaPaymentInit параметры для инициализации платежа YooKassa
type YooKassaPaymentInit struct {
	Amount       float64            `json:"amount"`
	Currency     string             `json:"currency"`
	Description  string             `json:"description"`
	Metadata     map[string]string  `json:"metadata"`
	Confirmation YooKassaConfirmation `json:"confirmation"`
	Capture      bool               `json:"capture"` // автосписание (true) или двухстадийная оплата (false)
}

// YooKassaConfirmation параметры подтверждения платежа YooKassa
type YooKassaConfirmation struct {
	Type        string `json:"type"`        // redirect|embedded|external
	ReturnURL   string `json:"return_url"`  // URL возврата после оплаты
	ConfirmURL  string `json:"confirm_url,omitempty"` // URL подтверждения (для embedded)
}

// YooKassaPaymentResponse ответ от YooKassa API
type YooKassaPaymentResponse struct {
	ID           string                 `json:"id"`
	Status       string                 `json:"status"` // waiting_for_payment|succeeded|canceled|pending
	Amount       YooKassaAmount         `json:"amount"`
	Description  string                 `json:"description"`
	Metadata     map[string]string      `json:"metadata"`
	Confirmation YooKassaConfirmation   `json:"confirmation"`
	Capture      bool                   `json:"capture"`
	CreatedAt    time.Time              `json:"created_at"`
	ExpiresAt    time.Time              `json:"expires_at"`
	ReceiptURL   *string                `json:"receipt_url,omitempty"`
	ErrorMessage *string                `json:"error_message,omitempty"`
}

// YooKassaAmount сумма платежа YooKassa
type YooKassaAmount struct {
	Value    string `json:"value"`
	Currency string `json:"currency"`
}

// YooKassaWebhookEvent событие webhook от YooKassa
type YooKassaWebhookEvent struct {
	Type   string                 `json:"type"` // payment.succeeded|payment.canceled|payment.waiting_for_capture|refund.succeeded
	Object YooKassaPaymentResponse `json:"object"`
}

// YooKassaRefundRequest запрос на возврат средств YooKassa
type YooKassaRefundRequest struct {
	PaymentID   string            `json:"payment_id"`
	Amount      YooKassaAmount    `json:"amount"`
	Description string            `json:"description"`
	Metadata    map[string]string `json:"metadata,omitempty"`
}

// YooKassaRefundResponse ответ на возврат средств YooKassa
type YooKassaRefundResponse struct {
	ID          string        `json:"id"`
	PaymentID   string        `json:"payment_id"`
	Status      string        `json:"status"` // pending|succeeded|canceled
	Amount      YooKassaAmount `json:"amount"`
	CreatedAt   time.Time     `json:"created_at"`
	Description string        `json:"description"`
}

// YooKassaConfig конфигурация YooKassa
type YooKassaConfig struct {
	ShopID    string `json:"shop_id"`
	SecretKey string `json:"secret_key"`
	BaseURL   string `json:"base_url"` // https://api.yookassa.ru/v3
}

// PaymentProvider тип платежного провайдера
type PaymentProvider string

const (
	PaymentProviderYooKassa PaymentProvider = "yookassa"
	PaymentProviderStripe   PaymentProvider = "stripe"
	PaymentProviderDummy    PaymentProvider = "dummy" // для тестирования
)

// YooKassaPaymentStatus маппинг статусов YooKassa на внутренние статусы
var YooKassaPaymentStatusMap = map[string]PaymentStatus{
	"waiting_for_payment": PaymentStatusPending,
	"succeeded":           PaymentStatusPaid,
	"canceled":            PaymentStatusCancelled,
	"pending":             PaymentStatusPending,
	"waiting_for_capture": PaymentStatusPending,
}

// YooKassaWebhookTypes типы webhook событий YooKassa
const (
	YooKassaWebhookPaymentSucceeded       = "payment.succeeded"
	YooKassaWebhookPaymentCanceled        = "payment.canceled"
	YooKassaWebhookPaymentWaitingForCapture = "payment.waiting_for_capture"
	YooKassaWebhookRefundSucceeded        = "refund.succeeded"
	YooKassaWebhookRefundFailed           = "refund.failed"
)
