package services

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

const (
	DefaultPage  = 1
	DefaultLimit = 50
	MaxLimit     = 1000
)

var (
	ErrInvalidPromoCode     = errors.New("promo code is required")
	ErrInvalidDiscountType  = errors.New("discount type is required")
	ErrInvalidDiscountValue = errors.New("discount value must be greater than 0")
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

// validatePaginationParams проверяет и устанавливает допустимые значения для пагинации
func validatePaginationParams(page, limit int) (int, int) {
	if page <= 0 {
		page = DefaultPage
	}
	if limit <= 0 {
		limit = DefaultLimit
	} else if limit > MaxLimit {
		limit = MaxLimit
	}
	return page, limit
}

func (s *AdminService) Users(ctx context.Context, page, limit int) ([]repositories.AdminUserRow, int, error) {
	page, limit = validatePaginationParams(page, limit)
	return s.repo.ListUsers(ctx, page, limit)
}

func (s *AdminService) Audit(ctx context.Context, page, limit int) ([]repositories.AuditRow, int, error) {
	page, limit = validatePaginationParams(page, limit)
	return s.repo.ListAudit(ctx, page, limit)
}

func (s *AdminService) CreatePromo(ctx context.Context, createdBy *domain.ID, req repositories.CreatePromoRequest) (domain.ID, error) {
	// Проверяем обязательные поля
	if req.Code == "" {
		return domain.NilID, ErrInvalidPromoCode
	}

	if req.DiscountType == "" {
		return domain.NilID, ErrInvalidDiscountType
	}

	if req.DiscountValue <= 0 {
		return domain.NilID, ErrInvalidDiscountValue
	}

	return s.repo.CreatePromo(ctx, createdBy, req)
}
