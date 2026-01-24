package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// SupportRepository интерфейс репозитория поддержки
type SupportRepository interface {
	// CreateTicket создает новый тикет поддержки
	CreateTicket(ctx context.Context, userID domain.ID, req domain.CreateTicketRequest) (*domain.SupportTicket, error)

	// ListTickets возвращает список тикетов поддержки пользователя
	ListTickets(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SupportTicket, int, error)

	// GetTicket возвращает тикет поддержки с сообщениями
	GetTicket(ctx context.Context, userID domain.ID, ticketID domain.ID) (*domain.SupportTicket, []domain.SupportMessage, error)

	// AddMessage добавляет сообщение к тикету поддержки
	AddMessage(ctx context.Context, userID domain.ID, ticketID domain.ID, req domain.AddTicketMessageRequest) (*domain.SupportMessage, error)
}

// FeedbackRepository интерфейс репозитория обратной связи
type FeedbackRepository interface {
	// CreateFeedback создает новую запись обратной связи
	CreateFeedback(ctx context.Context, userID domain.ID, req domain.CreateFeedbackRequest) (domain.ID, error)
}
