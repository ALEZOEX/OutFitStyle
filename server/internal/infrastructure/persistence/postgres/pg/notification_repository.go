package pg

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type NotificationRepository struct {
	db *dbpkg.DB
}

func NewNotificationRepository(db *dbpkg.DB) repositories.NotificationRepository {
	return &NotificationRepository{db: db}
}

func (r *NotificationRepository) Create(ctx context.Context, n repositories.CreateNotificationParams) (domain.ID, error) {
	q := `
INSERT INTO notifications (
user_id, type, title, body, image_url,
data, action_type, action_data,
is_read, push_sent
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,FALSE,FALSE)
RETURNING id
`
	var id domain.ID
	err := r.db.Pool().QueryRow(ctx, q,
		n.UserID, n.Type, n.Title, n.Body, n.ImageURL,
		nullJSON(n.DataJSON), n.ActionType, nullJSON(n.ActionDataJSON),
	).Scan(&id)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "create notification")
	}
	return id, nil
}

func (r *NotificationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.Notification, error) {
	q := `
SELECT
id, user_id,
type, title, body,
image_url, data,
action_type, action_data,
is_read, read_at,
push_sent, push_sent_at, push_error,
created_at, expires_at
FROM notifications
WHERE id = $1
`
	var n domain.Notification
	err := r.db.Pool().QueryRow(ctx, q, id).Scan(
		&n.ID, &n.UserID,
		&n.Type, &n.Title, &n.Body,
		&n.ImageURL, &n.Data,
		&n.ActionType, &n.ActionData,
		&n.IsRead, &n.ReadAt,
		&n.PushSent, &n.PushSentAt, &n.PushError,
		&n.CreatedAt, &n.ExpiresAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get notification by id")
	}
	return &n, nil
}

func (r *NotificationRepository) List(ctx context.Context, userID domain.ID, unreadOnly bool, page, limit int) ([]domain.Notification, int, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	if page <= 0 {
		page = 1
	}
	offset := (page - 1) * limit

	var unreadCount int
	if err := r.db.Pool().QueryRow(ctx, `
SELECT COUNT(*)
FROM notifications
WHERE user_id = $1 AND is_read = FALSE
`, userID).Scan(&unreadCount); err != nil {
		return nil, 0, 0, errors.Wrap(err, "count unread notifications")
	}

	var total int
	if unreadOnly {
		if err := r.db.Pool().QueryRow(ctx, `
SELECT COUNT(*)
FROM notifications
WHERE user_id = $1 AND is_read = FALSE
`, userID).Scan(&total); err != nil {
			return nil, 0, 0, errors.Wrap(err, "count notifications unreadOnly")
		}
	} else {
		if err := r.db.Pool().QueryRow(ctx, `
SELECT COUNT(*)
FROM notifications
WHERE user_id = $1
`, userID).Scan(&total); err != nil {
			return nil, 0, 0, errors.Wrap(err, "count notifications")
		}
	}

	where := `user_id = $1`
	if unreadOnly {
		where += ` AND is_read = FALSE`
	}

	q := `
SELECT
id, user_id,
type, title, body,
image_url, data,
action_type, action_data,
is_read, read_at,
push_sent, push_sent_at, push_error,
created_at, expires_at
FROM notifications
WHERE ` + where + `
ORDER BY created_at DESC
LIMIT $2 OFFSET $3
`

	rows, err := r.db.Pool().Query(ctx, q, userID, limit, offset)
	if err != nil {
		return nil, 0, 0, errors.Wrap(err, "list notifications")
	}
	defer rows.Close()

	out := make([]domain.Notification, 0, limit)
	for rows.Next() {
		var n domain.Notification
		if err := rows.Scan(
			&n.ID, &n.UserID,
			&n.Type, &n.Title, &n.Body,
			&n.ImageURL, &n.Data,
			&n.ActionType, &n.ActionData,
			&n.IsRead, &n.ReadAt,
			&n.PushSent, &n.PushSentAt, &n.PushError,
			&n.CreatedAt, &n.ExpiresAt,
		); err != nil {
			return nil, 0, 0, errors.Wrap(err, "scan notification")
		}
		out = append(out, n)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, 0, errors.Wrap(err, "rows notifications")
	}

	return out, total, unreadCount, nil
}

func (r *NotificationRepository) MarkRead(ctx context.Context, userID domain.ID, notificationID domain.ID) error {
	cmd, err := r.db.Pool().Exec(ctx, `
UPDATE notifications
SET is_read = TRUE, read_at = NOW()
WHERE id = $1 AND user_id = $2
`, notificationID, userID)
	if err != nil {
		return errors.Wrap(err, "mark notification read")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *NotificationRepository) MarkReadAll(ctx context.Context, userID domain.ID) (int, error) {
	cmd, err := r.db.Pool().Exec(ctx, `
UPDATE notifications
SET is_read = TRUE, read_at = NOW()
WHERE user_id = $1 AND is_read = FALSE
`, userID)
	if err != nil {
		return 0, errors.Wrap(err, "mark all notifications read")
	}
	return int(cmd.RowsAffected()), nil
}

func (r *NotificationRepository) MarkPushResult(ctx context.Context, notificationID domain.ID, sent bool, errMsg *string) error {
	q := `
UPDATE notifications
SET
push_sent = $1,
push_sent_at = CASE WHEN $1 THEN NOW() ELSE push_sent_at END,
push_error = $2
WHERE id = $3
`
	_, err := r.db.Pool().Exec(ctx, q, sent, errMsg, notificationID)
	return errors.Wrap(err, "mark push result")
}
