package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// AuditCreate структура для создания записи аудита
type AuditCreate struct {
	UserID *domain.ID  // Идентификатор пользователя (если применимо)

	Action       string     // Выполненное действие
	ResourceType *string    // Тип ресурса (если применимо)
	ResourceID   *domain.ID // Идентификатор ресурса (если применимо)

	OldValue []byte  // Старое значение (в сериализованном виде)
	NewValue []byte  // Новое значение (в сериализованном виде)

	IPAddress *string // IP-адрес пользователя
	UserAgent *string // User-Agent пользователя

	Success      bool      // Успешно ли выполнено действие
	ErrorMessage *string   // Сообщение об ошибке (если было)
}

// AuditRepository интерфейс репозитория аудита
type AuditRepository interface {
	// Create создает новую запись аудита
	Create(ctx context.Context, a AuditCreate) error
}
