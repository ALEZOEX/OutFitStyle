package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type SupportRepository interface {
	CreateTicket(ctx context.Context, userID domain.ID, req domain.CreateTicketRequest) (*domain.SupportTicket, error)
	ListTickets(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SupportTicket, int, error)
	GetTicket(ctx context.Context, userID domain.ID, ticketID domain.ID) (*domain.SupportTicket, []domain.SupportMessage, error)
	AddMessage(ctx context.Context, userID domain.ID, ticketID domain.ID, req domain.AddTicketMessageRequest) (*domain.SupportMessage, error)
}

type FeedbackRepository interface {
	CreateFeedback(ctx context.Context, userID domain.ID, req domain.CreateFeedbackRequest) (domain.ID, error)
}
