package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// APIKeyCreateRecord структура для создания API-ключа
type APIKeyCreateRecord struct {
	ClientID  domain.ID // Идентификатор клиента
	KeyPrefix string    // Префикс ключа (для идентификации)
	KeyHash   []byte    // Хэш ключа (секретная часть)

	Name        *string // Имя ключа (опционально)
	Description *string // Описание ключа (опционально)

	Permissions []string // Разрешения ключа

	IsActive  bool       // Активен ли ключ
	ExpiresAt *time.Time // Дата истечения (опционально)
}

type APIKeyRecord struct {
	ID       domain.ID // Уникальный идентификатор ключа
	ClientID domain.ID // Идентификатор клиента

	KeyPrefix string // Префикс ключа

	Name        *string // Имя ключа (опционально)
	Description *string // Описание ключа (опционально)

	Permissions []string // Разрешения ключа

	IsActive   bool       // Активен ли ключ
	LastUsedAt *time.Time // Дата последнего использования
	ExpiresAt  *time.Time // Дата истечения
	CreatedAt  time.Time  // Дата создания
}

// APIKeyAuthRecord представляет данные, необходимые для аутентификации по API-ключу
type APIKeyAuthRecord struct {
	APIKeyID domain.ID // Идентификатор API-ключа
	ClientID domain.ID // Идентификатор клиента
	KeyHash  []byte    // Хэш ключа

	Permissions []string // Разрешения ключа

	IsActive  bool       // Активен ли ключ
	ExpiresAt *time.Time // Дата истечения

	// Ограничения из записи клиента
	RateLimitPerMinute int // Ограничение по минутам
	RateLimitPerDay    int // Ограничение по дням
}

// APIKeyRepository интерфейс репозитория API-ключей
type APIKeyRepository interface {
	// Create создает новый API-ключ
	Create(ctx context.Context, rec APIKeyCreateRecord) (domain.ID, error)

	// ListByClient возвращает список API-ключей для клиента
	ListByClient(ctx context.Context, clientID domain.ID) ([]APIKeyRecord, error)

	// Deactivate деактивирует API-ключ
	Deactivate(ctx context.Context, clientID domain.ID, apiKeyID domain.ID) error

	// GetForAuthByPrefix возвращает данные для аутентификации по префиксу ключа
	GetForAuthByPrefix(ctx context.Context, prefix string) (*APIKeyAuthRecord, error)

	// TouchLastUsed обновляет дату последнего использования
	TouchLastUsed(ctx context.Context, apiKeyID domain.ID, at time.Time) error
}
