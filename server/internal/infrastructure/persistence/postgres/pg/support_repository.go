package pg

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"math/big"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type SupportRepository struct {
	db *dbpkg.DB
}

func NewSupportRepository(db *dbpkg.DB) repositories.SupportRepository {
	return &SupportRepository{db: db}
}

func (r *SupportRepository) CreateTicket(ctx context.Context, userID domain.ID, req domain.CreateTicketRequest) (*domain.SupportTicket, error) {
	if req.Subject == "" || req.Category == "" || req.Message == "" {
		return nil, errors.New("subject, category, message are required")
	}

	ticketNumber, err := generateTicketNumber()
	if err != nil {
		return nil, err
	}

	attachmentsJSON, _ := json.Marshal(req.Attachments)

	tx, err := r.db.Pool().Begin(ctx)
	if err != nil {
		return nil, errors.Wrap(err, "begin tx")
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var ticket domain.SupportTicket
	err = tx.QueryRow(ctx, `
INSERT INTO support_tickets (user_id, ticket_number, subject, category, priority, status)
VALUES ($1,$2,$3,$4,'normal','open')
RETURNING id, user_id, ticket_number, subject, category, priority, status, created_at, updated_at, resolved_at
`, userID, ticketNumber, req.Subject, req.Category).Scan(
		&ticket.ID, &ticket.UserID, &ticket.TicketNumber, &ticket.Subject, &ticket.Category, &ticket.Priority, &ticket.Status,
		&ticket.CreatedAt, &ticket.UpdatedAt, &ticket.ResolvedAt,
	)
	if err != nil {
		return nil, errors.Wrap(err, "insert ticket")
	}

	_, err = tx.Exec(ctx, `
INSERT INTO support_messages (ticket_id, sender_type, sender_id, message, attachments, is_internal)
VALUES ($1,'user',$2,$3,$4,FALSE)
`, ticket.ID, userID, req.Message, nullJSON(attachmentsJSON))
	if err != nil {
		return nil, errors.Wrap(err, "insert initial message")
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, errors.Wrap(err, "commit")
	}
	return &ticket, nil
}

func (r *SupportRepository) ListTickets(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SupportTicket, int, error) {
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

	var total int
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM support_tickets WHERE user_id = $1`, userID).Scan(&total); err != nil {
		return nil, 0, errors.Wrap(err, "count tickets")
	}

	rows, err := r.db.Pool().Query(ctx, `
SELECT id, user_id, ticket_number, subject, category, priority, status, created_at, updated_at, resolved_at
FROM support_tickets
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3
`, userID, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "list tickets")
	}
	defer rows.Close()

	var out []domain.SupportTicket
	for rows.Next() {
		var t domain.SupportTicket
		if err := rows.Scan(&t.ID, &t.UserID, &t.TicketNumber, &t.Subject, &t.Category, &t.Priority, &t.Status, &t.CreatedAt, &t.UpdatedAt, &t.ResolvedAt); err != nil {
			return nil, 0, errors.Wrap(err, "scan ticket")
		}
		out = append(out, t)
	}
	return out, total, rows.Err()
}

func (r *SupportRepository) GetTicket(ctx context.Context, userID domain.ID, ticketID domain.ID) (*domain.SupportTicket, []domain.SupportMessage, error) {
	var t domain.SupportTicket
	err := r.db.Pool().QueryRow(ctx, `
SELECT id, user_id, ticket_number, subject, category, priority, status, created_at, updated_at, resolved_at
FROM support_tickets
WHERE id = $1 AND user_id = $2
`, ticketID, userID).Scan(&t.ID, &t.UserID, &t.TicketNumber, &t.Subject, &t.Category, &t.Priority, &t.Status, &t.CreatedAt, &t.UpdatedAt, &t.ResolvedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil, nil
		}
		return nil, nil, errors.Wrap(err, "get ticket")
	}

	rows, err := r.db.Pool().Query(ctx, `
SELECT id, ticket_id, sender_type, sender_id, message, attachments, is_internal, created_at
FROM support_messages
WHERE ticket_id = $1
ORDER BY created_at ASC
`, ticketID)
	if err != nil {
		return nil, nil, errors.Wrap(err, "list messages")
	}
	defer rows.Close()

	msgs := []domain.SupportMessage{}
	for rows.Next() {
		var m domain.SupportMessage
		var attachments []byte
		if err := rows.Scan(&m.ID, &m.TicketID, &m.SenderType, &m.SenderID, &m.Message, &attachments, &m.IsInternal, &m.CreatedAt); err != nil {
			return nil, nil, errors.Wrap(err, "scan message")
		}
		if len(attachments) > 0 {
			var a any
			_ = json.Unmarshal(attachments, &a)
			m.Attachments = a
		}
		msgs = append(msgs, m)
	}

	return &t, msgs, rows.Err()
}

func (r *SupportRepository) AddMessage(ctx context.Context, userID domain.ID, ticketID domain.ID, req domain.AddTicketMessageRequest) (*domain.SupportMessage, error) {
	if req.Message == "" {
		return nil, errors.New("message is required")
	}
	attachmentsJSON, _ := json.Marshal(req.Attachments)

	// Ensure ticket belongs to user
	var exists bool
	if err := r.db.Pool().QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM support_tickets WHERE id=$1 AND user_id=$2)`, ticketID, userID).Scan(&exists); err != nil {
		return nil, errors.Wrap(err, "check ticket")
	}
	if !exists {
		return nil, nil
	}

	var m domain.SupportMessage
	err := r.db.Pool().QueryRow(ctx, `
INSERT INTO support_messages (ticket_id, sender_type, sender_id, message, attachments, is_internal)
VALUES ($1,'user',$2,$3,$4,FALSE)
RETURNING id, ticket_id, sender_type, sender_id, message, attachments, is_internal, created_at
`, ticketID, userID, req.Message, nullJSON(attachmentsJSON)).Scan(
		&m.ID, &m.TicketID, &m.SenderType, &m.SenderID, &m.Message, &[]byte{}, &m.IsInternal, &m.CreatedAt,
	)
	if err != nil {
		// проще: загрузим отдельно без Scan attachments
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "insert message")
	}

	// обновим updated_at тикета
	_, _ = r.db.Pool().Exec(ctx, `UPDATE support_tickets SET updated_at = NOW() WHERE id = $1`, ticketID)

	// вернём нормальный объект (с attachments)
	m2 := &domain.SupportMessage{
		ID: m.ID, TicketID: ticketID, SenderType: "user", SenderID: &userID,
		Message: req.Message, Attachments: req.Attachments, IsInternal: false, CreatedAt: m.CreatedAt,
	}
	return m2, nil
}

func generateTicketNumber() (string, error) {
	// OS-YYYYMMDD-XXXX
	now := time.Now().Format("20060102")
	x, err := rand.Int(rand.Reader, big.NewInt(10000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("OS-%s-%04d", now, x.Int64()), nil
}
