package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type CreateNotificationParams struct {
	UserID domain.ID
	Type   string
	Title  string
	Body   *string

	ImageURL *string

	DataJSON       []byte
	ActionType     *string
	ActionDataJSON []byte

	ExpiresAt *string // optional ISO timestamp; можно расширить позже
}

type NotificationRepository interface {
	Create(ctx context.Context, n CreateNotificationParams) (domain.ID, error)
	GetByID(ctx context.Context, id domain.ID) (*domain.Notification, error)

	List(ctx context.Context, userID domain.ID, unreadOnly bool, page, limit int) (items []domain.Notification, total int, unreadCount int, err error)

	MarkRead(ctx context.Context, userID domain.ID, notificationID domain.ID) error
	MarkReadAll(ctx context.Context, userID domain.ID) (count int, err error)

	MarkPushResult(ctx context.Context, notificationID domain.ID, sent bool, errMsg *string) error
}
