package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/domain"
)

type SupportRepository struct {
	db *pgxpool.Pool
}

func NewSupportRepository(db *pgxpool.Pool) *SupportRepository {
	return &SupportRepository{db: db}
}

func (r *SupportRepository) CreateTicket(ctx context.Context, userID domain.ID, req domain.CreateTicketRequest) (*domain.SupportTicket, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SupportRepository) GetTicketsByUser(ctx context.Context, userID domain.ID) ([]domain.SupportTicket, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SupportRepository) UpdateTicket(ctx context.Context, ticket *domain.SupportTicket) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SupportRepository) ListTickets(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SupportTicket, int, error) {
	// TODO: Implement
	return nil, 0, fmt.Errorf("not implemented")
}

func (r *SupportRepository) GetTicket(ctx context.Context, userID domain.ID, ticketID domain.ID) (*domain.SupportTicket, []domain.SupportMessage, error) {
	// TODO: Implement
	return nil, nil, fmt.Errorf("not implemented")
}

func (r *SupportRepository) AddMessage(ctx context.Context, userID domain.ID, ticketID domain.ID, req domain.AddTicketMessageRequest) (*domain.SupportMessage, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}