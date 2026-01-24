package domain

import "time"

// BillingStatus статус биллинговой транзакции
type BillingStatus string

const (
	// BillingStatusPending статус "в ожидании" - транзакция создана, но еще не обработана
	BillingStatusPending BillingStatus = "pending"
	// BillingStatusPaid статус "оплачено" - транзакция успешно оплачена
	BillingStatusPaid BillingStatus = "paid"
	// BillingStatusFailed статус "неудачно" - транзакция завершилась с ошибкой
	BillingStatusFailed BillingStatus = "failed"
	// BillingStatusRefunded статус "возвращено" - средства по транзакции возвращены
	BillingStatusRefunded BillingStatus = "refunded"
	// BillingStatusCancelled статус "отменено" - транзакция отменена
	BillingStatusCancelled BillingStatus = "cancelled"
)

// BillingTransaction структура для хранения информации о биллинговой транзакции
type BillingTransaction struct {
	ID            ID            `json:"id"`                    // Уникальный идентификатор транзакции
	UserID        ID            `json:"user_id"`               // Идентификатор пользователя, которому принадлежит транзакция
	Amount        float64       `json:"amount"`                // Сумма транзакции
	Currency      string        `json:"currency"`              // Валюта транзакции (например, "USD", "EUR", "RUB")
	Status        BillingStatus `json:"status"`                // Статус транзакции
	PaymentMethod string        `json:"payment_method"`        // Метод оплаты (например, "card", "paypal", "apple_pay")
	TransactionID string        `json:"transaction_id"`        // Внешний идентификатор транзакции от платежного провайдера
	Description   string        `json:"description"`           // Описание транзакции
	Metadata      any           `json:"metadata"`              // Дополнительные данные транзакции
	CreatedAt     time.Time     `json:"created_at"`            // Время создания транзакции
	ProcessedAt   *time.Time    `json:"processed_at,omitempty"` // Время обработки транзакции (если применимо)
}