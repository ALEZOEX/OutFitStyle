package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// FeatureFlag структура флага функции (фича-флаг)
type FeatureFlag struct {
	ID          domain.ID // Уникальный идентификатор флага
	Key         string    // Ключ флага (уникальный идентификатор в системе)
	Name        string    // Название флага
	Description *string   // Описание флага (опционально)

	Enabled      bool      // Включен ли флаг
	IsEnabled    bool      // Включен ли флаг (альтернативное поле)
	DefaultValue []byte    // Значение по умолчанию (в сериализованном виде)
	Rules        []byte    // Правила включения/выключения (в сериализованном виде)
	CreatedAt    time.Time // Дата создания
	UpdatedAt    time.Time // Дата последнего обновления
}

// FeatureFlagRepository интерфейс репозитория флагов функций
type FeatureFlagRepository interface {
	// List возвращает список всех флагов функций
	List(ctx context.Context) ([]FeatureFlag, error)

	// Get возвращает флаг функции по ключу
	Get(ctx context.Context, key string) (*FeatureFlag, error)

	// SetEnabled устанавливает статус включения флага функции
	SetEnabled(ctx context.Context, key string, enabled bool) error
}
