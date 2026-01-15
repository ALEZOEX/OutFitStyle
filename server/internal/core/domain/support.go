package domain

import "time"

type SupportTicket struct {
	ID           ID     `json:"id"`
	UserID       *ID    `json:"user_id,omitempty"`
	TicketNumber string `json:"ticket_number"`

	Subject  string `json:"subject"`
	Category string `json:"category"`
	Priority string `json:"priority"`
	Status   string `json:"status"`

	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
	ResolvedAt *time.Time `json:"resolved_at,omitempty"`
}

type SupportMessage struct {
	ID          ID        `json:"id"`
	TicketID    ID        `json:"ticket_id"`
	SenderType  string    `json:"sender_type"`
	SenderID    *ID       `json:"sender_id,omitempty"`
	Message     string    `json:"message"`
	Attachments any       `json:"attachments,omitempty"`
	IsInternal  bool      `json:"is_internal"`
	CreatedAt   time.Time `json:"created_at"`
}

type CreateTicketRequest struct {
	Subject     string `json:"subject"`
	Category    string `json:"category"`
	Message     string `json:"message"`
	Attachments any    `json:"attachments,omitempty"` // JSON
}

type AddTicketMessageRequest struct {
	Message     string `json:"message"`
	Attachments any    `json:"attachments,omitempty"` // JSON
}

type CreateFeedbackRequest struct {
	Type        string   `json:"type"`
	Message     string   `json:"message"`
	Screen      *string  `json:"screen,omitempty"`
	Attachments []string `json:"attachments,omitempty"`
}
