package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// PromoCode структура промо-кода
type PromoCode struct {
	ID domain.ID  // Уникальный идентификатор промо-кода

	Code string  // Код промо-акции

	DiscountType  string   // Тип скидки (percent, fixed, trial_days)
	DiscountValue float64  // Значение скидки

	ApplicablePlans []domain.ID  // Применимые планы подписки
	MinBillingCycle *string      // Минимальный цикл оплаты (опционально)

	MaxUses        *int  // Максимальное количество использований (опционально)
	UsesCount      int   // Количество использований
	MaxUsesPerUser int   // Максимальное количество использований одним пользователем

	ValidFrom  time.Time   // Дата начала действия
	ValidUntil *time.Time  // Дата окончания действия (опционально)

	IsActive bool  // Активен ли промо-код
}

// PromoRepository интерфейс репозитория промо-кодов
type PromoRepository interface {
	// GetByCode возвращает промо-код по его коду
	GetByCode(ctx context.Context, code string) (*PromoCode, error)
}
