package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type SupportRepository struct {
	db *pgxpool.Pool
}

func NewSupportRepository(db *pgxpool.Pool) *SupportRepository {
	return &SupportRepository{db: db}
}

func (r *SupportRepository) CreateTicket(ctx context.Context, userID domain.ID, req domain.CreateTicketRequest) (*domain.SupportTicket, error) {
	id := domain.NewID()
	now := time.Now()

	query := `
		INSERT INTO support_tickets (
			id, user_id, ticket_number, subject, category, priority, status, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	ticketNumber := "TKT-" + id.String()[:8] // Generate a ticket number

	_, err := r.db.Exec(ctx, query,
		id,
		userID,
		ticketNumber,
		req.Subject,
		req.Category,
		"medium", // Default priority
		"open",   // Default status
		now,
		now,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to create support ticket")
	}

	// Create initial message for the ticket
	messageID := domain.NewID()
	messageQuery := `
		INSERT INTO support_messages (
			id, ticket_id, sender_type, sender_id, message, attachments, is_internal, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	attachmentsJSON, err := json.Marshal(req.Attachments)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal attachments")
	}

	_, err = r.db.Exec(ctx, messageQuery,
		messageID,
		id,
		"user",
		userID,
		req.Subject,
		attachmentsJSON,
		false, // is_internal
		now,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to create initial support message")
	}

	ticket := &domain.SupportTicket{
		ID:           id,
		UserID:       &userID, // Convert to pointer
		TicketNumber: ticketNumber,
		Subject:      req.Subject,
		Category:     req.Category,
		Priority:     "medium", // Default priority
		Status:       "open",
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	return ticket, nil
}

func (r *SupportRepository) GetTicketsByUser(ctx context.Context, userID domain.ID) ([]domain.SupportTicket, error) {
	query := `
		SELECT 
			id, user_id, ticket_number, subject, category, priority, status, 
			created_at, updated_at, resolved_at
		FROM support_tickets
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query support tickets by user")
	}
	defer rows.Close()

	var tickets []domain.SupportTicket
	for rows.Next() {
		var ticket domain.SupportTicket
		var resolvedAt *time.Time

		err := rows.Scan(
			&ticket.ID,
			&ticket.UserID,
			&ticket.TicketNumber,
			&ticket.Subject,
			&ticket.Category,
			&ticket.Priority,
			&ticket.Status,
			&ticket.CreatedAt,
			&ticket.UpdatedAt,
			&resolvedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan support ticket")
		}

		// Set nullable fields
		ticket.ResolvedAt = resolvedAt

		tickets = append(tickets, ticket)
	}

	return tickets, nil
}

func (r *SupportRepository) UpdateTicket(ctx context.Context, ticket *domain.SupportTicket) error {
	query := `
		UPDATE support_tickets
		SET subject = $1, category = $2, priority = $3, status = $4, 
			updated_at = $5, resolved_at = $6
		WHERE id = $7
	`

	_, err := r.db.Exec(ctx, query,
		ticket.Subject,
		ticket.Category,
		ticket.Priority,
		ticket.Status,
		time.Now(),
		ticket.ResolvedAt,
		ticket.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update support ticket")
	}

	return nil
}

func (r *SupportRepository) ListTickets(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SupportTicket, int, error) {
	// Calculate offset
	offset := (page - 1) * limit

	// Query for tickets
	query := `
		SELECT 
			id, user_id, ticket_number, subject, category, priority, status, 
			created_at, updated_at, resolved_at
		FROM support_tickets
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query support tickets")
	}
	defer rows.Close()

	var tickets []domain.SupportTicket
	for rows.Next() {
		var ticket domain.SupportTicket
		var resolvedAt *time.Time

		err := rows.Scan(
			&ticket.ID,
			&ticket.UserID,
			&ticket.TicketNumber,
			&ticket.Subject,
			&ticket.Category,
			&ticket.Priority,
			&ticket.Status,
			&ticket.CreatedAt,
			&ticket.UpdatedAt,
			&resolvedAt,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan support ticket")
		}

		// Set nullable fields
		ticket.ResolvedAt = resolvedAt

		tickets = append(tickets, ticket)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM support_tickets WHERE user_id = $1`
	var total int
	err = r.db.QueryRow(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count support tickets")
	}

	return tickets, total, nil
}

func (r *SupportRepository) GetTicket(ctx context.Context, userID domain.ID, ticketID domain.ID) (*domain.SupportTicket, []domain.SupportMessage, error) {
	// Get ticket
	ticketQuery := `
		SELECT 
			id, user_id, ticket_number, subject, category, priority, status, 
			created_at, updated_at, resolved_at
		FROM support_tickets
		WHERE user_id = $1 AND id = $2
	`

	var ticket domain.SupportTicket
	var resolvedAt *time.Time

	err := r.db.QueryRow(ctx, ticketQuery, userID, ticketID).Scan(
		&ticket.ID,
		&ticket.UserID,
		&ticket.TicketNumber,
		&ticket.Subject,
		&ticket.Category,
		&ticket.Priority,
		&ticket.Status,
		&ticket.CreatedAt,
		&ticket.UpdatedAt,
		&resolvedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil, nil
		}
		return nil, nil, errors.Wrap(err, "failed to get support ticket")
	}

	// Set nullable fields
	ticket.ResolvedAt = resolvedAt

	// Get messages for the ticket
	messagesQuery := `
		SELECT 
			id, ticket_id, sender_type, sender_id, message, attachments, is_internal, created_at
		FROM support_messages
		WHERE ticket_id = $1
		ORDER BY created_at ASC
	`

	messagesRows, err := r.db.Query(ctx, messagesQuery, ticketID)
	if err != nil {
		return nil, nil, errors.Wrap(err, "failed to query support messages")
	}
	defer messagesRows.Close()

	var messages []domain.SupportMessage
	for messagesRows.Next() {
		var message domain.SupportMessage
		var senderID *uuid.UUID
		var attachmentsJSON []byte

		err := messagesRows.Scan(
			&message.ID,
			&message.TicketID,
			&message.SenderType,
			&senderID,
			&message.Message,
			&attachmentsJSON,
			&message.IsInternal,
			&message.CreatedAt,
		)
		if err != nil {
			return nil, nil, errors.Wrap(err, "failed to scan support message")
		}

		// Set nullable fields
		if senderID != nil {
			sid := domain.ID(*senderID)
			message.SenderID = &sid
		}

		// Parse attachments
		if len(attachmentsJSON) > 0 {
			err = json.Unmarshal(attachmentsJSON, &message.Attachments)
			if err != nil {
				return nil, nil, errors.Wrap(err, "failed to unmarshal attachments")
			}
		}

		messages = append(messages, message)
	}

	return &ticket, messages, nil
}

func (r *SupportRepository) AddMessage(ctx context.Context, userID domain.ID, ticketID domain.ID, req domain.AddTicketMessageRequest) (*domain.SupportMessage, error) {
	id := domain.NewID()
	now := time.Now()

	// Verify that the ticket belongs to the user
	var ticketExists bool
	err := r.db.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM support_tickets WHERE id = $1 AND user_id = $2)", ticketID, userID).Scan(&ticketExists)
	if err != nil {
		return nil, errors.Wrap(err, "failed to verify ticket ownership")
	}
	if !ticketExists {
		return nil, errors.New("ticket not found or does not belong to user")
	}

	// Insert message
	query := `
		INSERT INTO support_messages (
			id, ticket_id, sender_type, sender_id, message, attachments, is_internal, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	attachmentsJSON, err := json.Marshal(req.Attachments)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal attachments")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		ticketID,
		"user",
		userID,
		req.Message,
		attachmentsJSON,
		false, // is_internal
		now,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to add support message")
	}

	// Update ticket's updated_at timestamp
	updateTicketQuery := `UPDATE support_tickets SET updated_at = $1 WHERE id = $2`
	_, err = r.db.Exec(ctx, updateTicketQuery, now, ticketID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to update ticket timestamp")
	}

	message := &domain.SupportMessage{
		ID:          id,
		TicketID:    ticketID,
		SenderType:  "user",
		SenderID:    &userID,
		Message:     req.Message,
		Attachments: req.Attachments,
		IsInternal:  false,
		CreatedAt:   now,
	}

	return message, nil
}
