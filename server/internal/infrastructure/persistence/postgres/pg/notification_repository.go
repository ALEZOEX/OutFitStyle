package pg

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

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
	id := domain.NewID()

	query := `
		INSERT INTO notifications (
			id, user_id, type, title, body, image_url, data, action_type, action_data, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`

	dataJSON, err := json.Marshal(n.Data)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to marshal notification data")
	}

	actionDataJSON, err := json.Marshal(n.ActionData)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to marshal notification action data")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		n.UserID,
		n.Type,
		n.Title,
		n.Body,
		n.ImageURL,
		dataJSON,
		n.ActionType,
		actionDataJSON,
		time.Now(),
	)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to create notification")
	}

	return id, nil
}

func (r *NotificationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.Notification, error) {
	query := `
		SELECT
			id, user_id, type, title, body, image_url, data, action_type, action_data,
			is_read, read_at, push_sent, push_sent_at, push_error, created_at, expires_at
		FROM notifications
		WHERE id = $1
	`

	var notification domain.Notification
	var dataJSON []byte
	var actionDataJSON []byte
	var readAt *time.Time
	var pushSentAt *time.Time
	var pushError *string
	var expiresAt *time.Time

	err := r.db.QueryRow(ctx, query, id).Scan(
		&notification.ID,
		&notification.UserID,
		&notification.Type,
		&notification.Title,
		&notification.Body,
		&notification.ImageURL,
		&dataJSON,
		&notification.ActionType,
		&actionDataJSON,
		&notification.IsRead,
		&readAt,
		&pushSentAt,
		&pushSentAt,
		&pushError,
		&notification.CreatedAt,
		&expiresAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get notification by ID")
	}

	// Parse data
	if len(dataJSON) > 0 {
		err = json.Unmarshal(dataJSON, &notification.Data)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal notification data")
		}
	}

	// Parse action data
	if len(actionDataJSON) > 0 {
		err = json.Unmarshal(actionDataJSON, &notification.ActionData)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal notification action data")
		}
	}

	// Set nullable fields
	notification.ReadAt = readAt
	notification.PushSentAt = pushSentAt
	notification.PushError = pushError
	notification.ExpiresAt = expiresAt

	return &notification, nil
}

func (r *NotificationRepository) List(ctx context.Context, userID domain.ID, unreadOnly bool, page, limit int) (items []domain.Notification, total int, unreadCount int, err error) {
	// Calculate offset
	offset := (page - 1) * limit

	// Base query
	query := `
		SELECT
			id, user_id, type, title, body, image_url, data, action_type, action_data,
			is_read, read_at, push_sent, push_sent_at, push_error, created_at, expires_at
		FROM notifications
		WHERE user_id = $1
	`
	args := []interface{}{userID}
	argIndex := 2

	if unreadOnly {
		query += " AND is_read = false"
	}

	query += " ORDER BY created_at DESC LIMIT $" + fmt.Sprintf("%d", argIndex) + " OFFSET $" + fmt.Sprintf("%d", argIndex+1)
	args = append(args, limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, 0, errors.Wrap(err, "failed to query notifications")
	}
	defer rows.Close()

	for rows.Next() {
		var notification domain.Notification
		var dataJSON []byte
		var actionDataJSON []byte
		var readAt *time.Time
		var pushSentAt *time.Time
		var pushError *string
		var expiresAt *time.Time

		err := rows.Scan(
			&notification.ID,
			&notification.UserID,
			&notification.Type,
			&notification.Title,
			&notification.Body,
			&notification.ImageURL,
			&dataJSON,
			&notification.ActionType,
			&actionDataJSON,
			&notification.IsRead,
			&readAt,
			&notification.PushSent,
			&pushSentAt,
			&pushError,
			&notification.CreatedAt,
			&expiresAt,
		)
		if err != nil {
			return nil, 0, 0, errors.Wrap(err, "failed to scan notification")
		}

		// Parse data
		if len(dataJSON) > 0 {
			err = json.Unmarshal(dataJSON, &notification.Data)
			if err != nil {
				return nil, 0, 0, errors.Wrap(err, "failed to unmarshal notification data")
			}
		}

		// Parse action data
		if len(actionDataJSON) > 0 {
			err = json.Unmarshal(actionDataJSON, &notification.ActionData)
			if err != nil {
				return nil, 0, 0, errors.Wrap(err, "failed to unmarshal notification action data")
			}
		}

		// Set nullable fields
		notification.ReadAt = readAt
		notification.PushSentAt = pushSentAt
		notification.PushError = pushError
		notification.ExpiresAt = expiresAt

		items = append(items, notification)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM notifications WHERE user_id = $1`
	if unreadOnly {
		countQuery += " AND is_read = false"
	}

	err = r.db.QueryRow(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		return nil, 0, 0, errors.Wrap(err, "failed to count notifications")
	}

	// Get unread count
	unreadQuery := `SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false`
	err = r.db.QueryRow(ctx, unreadQuery, userID).Scan(&unreadCount)
	if err != nil {
		return nil, 0, 0, errors.Wrap(err, "failed to count unread notifications")
	}

	return items, total, unreadCount, nil
}

func (r *NotificationRepository) MarkRead(ctx context.Context, userID domain.ID, notificationID domain.ID) error {
	query := `
		UPDATE notifications
		SET is_read = true, read_at = $1
		WHERE id = $2 AND user_id = $3
	`

	_, err := r.db.Exec(ctx, query, time.Now(), notificationID, userID)
	if err != nil {
		return errors.Wrap(err, "failed to mark notification as read")
	}

	return nil
}

func (r *NotificationRepository) MarkReadAll(ctx context.Context, userID domain.ID) (count int, err error) {
	query := `
		UPDATE notifications
		SET is_read = true, read_at = $1
		WHERE user_id = $2 AND is_read = false
	`

	tag, err := r.db.Exec(ctx, query, time.Now(), userID)
	if err != nil {
		return 0, errors.Wrap(err, "failed to mark all notifications as read")
	}

	return int(tag.RowsAffected()), nil
}

func (r *NotificationRepository) MarkPushResult(ctx context.Context, notificationID domain.ID, sent bool, errMsg *string) error {
	query := `
		UPDATE notifications
		SET push_sent = $1, push_sent_at = $2, push_error = $3
		WHERE id = $4
	`

	var pushSentAt *time.Time
	if sent {
		pushSentAt = new(time.Time)
		*pushSentAt = time.Now()
	}

	_, err := r.db.Exec(ctx, query, sent, pushSentAt, errMsg, notificationID)
	if err != nil {
		return errors.Wrap(err, "failed to update push result")
	}

	return nil
}
