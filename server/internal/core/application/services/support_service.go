package services

import (
	"context"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type SupportService struct {
	repo repositories.SupportRepository
	fb   repositories.FeedbackRepository
}

func NewSupportService(repo repositories.SupportRepository, fb repositories.FeedbackRepository) *SupportService {
	return &SupportService{repo: repo, fb: fb}
}

func (s *SupportService) CreateTicket(ctx context.Context, userID domain.ID, req domain.CreateTicketRequest) (*domain.SupportTicket, error) {
	return s.repo.CreateTicket(ctx, userID, req)
}

func (s *SupportService) ListTickets(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SupportTicket, int, error) {
	return s.repo.ListTickets(ctx, userID, page, limit)
}

func (s *SupportService) GetTicket(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SupportTicket, []domain.SupportMessage, error) {
	return s.repo.GetTicket(ctx, userID, id)
}

func (s *SupportService) AddMessage(ctx context.Context, userID domain.ID, ticketID domain.ID, req domain.AddTicketMessageRequest) (*domain.SupportMessage, error) {
	return s.repo.AddMessage(ctx, userID, ticketID, req)
}

func (s *SupportService) CreateFeedback(ctx context.Context, userID domain.ID, req domain.CreateFeedbackRequest) (domain.ID, error) {
	return s.fb.CreateFeedback(ctx, userID, req)
}
