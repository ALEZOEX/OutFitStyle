package repositories

import (
	"context"
	"time"
)

// RateLimitViolation структура нарушения лимита запросов
type RateLimitViolation struct {
	Identifier     string // Идентификатор (ID пользователя, IP-адрес, API-ключ)
	IdentifierType string // Тип идентификатора (user|ip|apikey)
	Endpoint       string // Конечная точка (шаблон маршрута или путь)
	Key            string // Ключ нарушения

	LimitType    string // Тип лимита (global_per_minute|apikey_per_day|...)
	LimitValue   int    // Значение лимита
	CurrentValue int    // Текущее значение (превышающее лимит)

	ResourceType   string        // Тип ресурса
	ResourceID     string        // Идентификатор ресурса
	WindowDuration time.Duration // Продолжительность окна (в секундах)
	ViolationTime  *time.Time    // Время нарушения

	CreatedAt time.Time // Дата создания записи
}

// RateLimitViolationRepository интерфейс репозитория нарушений лимита запросов
type RateLimitViolationRepository interface {
	// Record записывает факт нарушения лимита запросов
	Record(ctx context.Context, v RateLimitViolation) error
}
