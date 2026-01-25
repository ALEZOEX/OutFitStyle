package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// CreateNotificationParams параметры для создания уведомления
type CreateNotificationParams struct {
	UserID domain.ID // Идентификатор пользователя
	Type   string    // Тип уведомления
	Title  string    // Заголовок
	Body   *string   // Текст (опционально)

	ImageURL *string // URL изображения (опционально)

	Data           *string // Дополнительные данные (в формате JSON)
	DataJSON       []byte  // Дополнительные данные (в формате JSON)
	ActionType     *string // Тип действия (опционально)
	ActionData     *string // Данные действия (в формате JSON)
	ActionDataJSON []byte  // Данные действия (в формате JSON)

	ExpiresAt *string // Время истечения (опционально, формат ISO); можно расширить позже
}

// NotificationRepository интерфейс репозитория уведомлений
type NotificationRepository interface {
	// Create создает новое уведомление
	Create(ctx context.Context, n CreateNotificationParams) (domain.ID, error)

	// GetByID возвращает уведомление по идентификатору
	GetByID(ctx context.Context, id domain.ID) (*domain.Notification, error)

	// List возвращает список уведомлений пользователя с пагинацией
	List(ctx context.Context, userID domain.ID, unreadOnly bool, page, limit int) (items []domain.Notification, total int, unreadCount int, err error)

	// MarkRead отмечает уведомление как прочитанное
	MarkRead(ctx context.Context, userID domain.ID, notificationID domain.ID) error

	// MarkReadAll отмечает все уведомления пользователя как прочитанные
	MarkReadAll(ctx context.Context, userID domain.ID) (count int, err error)

	// MarkPushResult отмечает результат отправки push-уведомления
	MarkPushResult(ctx context.Context, notificationID domain.ID, sent bool, errMsg *string) error
}
