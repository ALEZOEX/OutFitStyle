package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// PromoCode структура промо-кода
type PromoCode struct {
	ID domain.ID // Уникальный идентификатор промо-кода

	Code string // Код промо-акции

	Type              string     // Тип промо-акции
	Value             float64    // Значение промо-акции
	Currency          *string    // Валюта
	MinOrderAmount    *float64   // Минимальная сумма заказа
	MaxDiscount       *float64   // Максимальная скидка
	UsageLimit        *int       // Лимит использования
	UsageLimitPerUser *int       // Лимит использования на пользователя
	StartDate         *time.Time // Дата начала
	EndDate           *time.Time // Дата окончания

	DiscountType  string  // Тип скидки (percent, fixed, trial_days)
	DiscountValue float64 // Значение скидки

	ApplicablePlans []domain.ID // Применимые планы подписки
	MinBillingCycle *string     // Минимальный цикл оплаты (опционально)

	MaxUses        *int // Максимальное количество использований (опционально)
	UsesCount      int  // Количество использований
	MaxUsesPerUser int  // Максимальное количество использований одним пользователем

	ValidFrom  time.Time  // Дата начала действия
	ValidUntil *time.Time // Дата окончания действия (опционально)

	IsActive  bool      // Активен ли промо-код
	CreatedAt time.Time // Дата создания
	UpdatedAt time.Time // Дата последнего обновления
}

// PromoRepository интерфейс репозитория промо-кодов
type PromoRepository interface {
	// GetByCode возвращает промо-код по его коду
	GetByCode(ctx context.Context, code string) (*PromoCode, error)
}
