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

func (r *NotificationRepository) Create(ctx context.Context, notification *domain.Notification) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *NotificationRepository) GetByUser(ctx context.Context, userID domain.ID, limit, offset int) ([]domain.Notification, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *NotificationRepository) MarkAsRead(ctx context.Context, userID domain.ID, notificationID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *NotificationRepository) MarkAllAsRead(ctx context.Context, userID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}