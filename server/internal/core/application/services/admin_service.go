package services

import (
	"context"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type AdminService struct {
	repo repositories.AdminRepository
}

func NewAdminService(repo repositories.AdminRepository) *AdminService {
	return &AdminService{repo: repo}
}

func (s *AdminService) Stats(ctx context.Context) (repositories.AdminStats, error) {
	return s.repo.Stats(ctx)
}

func (s *AdminService) Users(ctx context.Context, page, limit int) ([]repositories.AdminUserRow, int, error) {
	return s.repo.ListUsers(ctx, page, limit)
}

func (s *AdminService) Audit(ctx context.Context, page, limit int) ([]repositories.AuditRow, int, error) {
	return s.repo.ListAudit(ctx, page, limit)
}

func (s *AdminService) CreatePromo(ctx context.Context, createdBy *domain.ID, req repositories.CreatePromoRequest) (domain.ID, error) {
	return s.repo.CreatePromo(ctx, createdBy, req)
}
