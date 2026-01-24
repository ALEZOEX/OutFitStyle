package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type NotificationRepository struct {
	db *pgxpool.Pool
}

func NewNotificationRepository(db *pgxpool.Pool) *NotificationRepository {
	return &NotificationRepository{db: db}
}

func (r *NotificationRepository) Create(ctx context.Context, n repositories.CreateNotificationParams) (domain.ID, error) {
	// TODO: Implement
	return domain.NilID, fmt.Errorf("not implemented")
}

func (r *NotificationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.Notification, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *NotificationRepository) List(ctx context.Context, userID domain.ID, unreadOnly bool, page, limit int) (items []domain.Notification, total int, unreadCount int, err error) {
	// TODO: Implement
	return nil, 0, 0, fmt.Errorf("not implemented")
}

func (r *NotificationRepository) MarkRead(ctx context.Context, userID domain.ID, notificationID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *NotificationRepository) MarkReadAll(ctx context.Context, userID domain.ID) (count int, err error) {
	// TODO: Implement
	return 0, fmt.Errorf("not implemented")
}

func (r *NotificationRepository) MarkPushResult(ctx context.Context, notificationID domain.ID, sent bool, errMsg *string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}