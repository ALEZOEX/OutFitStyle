package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// BillingRepository интерфейс репозитория биллинга
type BillingRepository interface {
	// CreateUserSubscription создает подписку пользователя
	CreateUserSubscription(ctx context.Context, userID int64, planID int64, billingCycle string, periodEnd time.Time, provider string) (int64, error)

	// CancelSubscription отменяет подписку пользователя
	CancelSubscription(ctx context.Context, userID int64, immediate bool) error

	// ReactivateSubscription восстанавливает подписку пользователя
	ReactivateSubscription(ctx context.Context, userID int64) error

	// CreatePayment создает запись о платеже
	CreatePayment(ctx context.Context, p CreatePaymentParams) (int64, error)

	// UpdatePaymentStatusByExternalID обновляет статус платежа по внешнему идентификатору
	UpdatePaymentStatusByExternalID(ctx context.Context, provider string, externalPaymentID string, status string, receiptURL *string, errMsg *string) error

	// ListPayments возвращает список платежей пользователя с пагинацией
	ListPayments(ctx context.Context, userID int64, page, limit int) (items []domain.Payment, total int, err error)
}

// CreatePaymentParams параметры для создания платежа
type CreatePaymentParams struct {
	UserID         int64  // Идентификатор пользователя
	SubscriptionID *int64 // Идентификатор подписки (если применимо)

	Amount   float64 // Сумма платежа
	Currency string  // Валюта

	Status          string // Статус платежа
	PaymentProvider string // Платежный провайдер

	ExternalPaymentID *string    // Внешний идентификатор платежа
	PaymentMethod     *string    // Метод оплаты
	Description       *string    // Описание платежа
	ReceiptURL        *string    // URL чека
	ErrorMessage      *string    // Сообщение об ошибке
	PaidAt            *time.Time // Время оплаты
}
