package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type AdminRepository struct {
	db *pgxpool.Pool
}

func NewAdminRepository(db *pgxpool.Pool) *AdminRepository {
	return &AdminRepository{db: db}
}

func (r *AdminRepository) GetStats(ctx context.Context) (*domain.AdminStats, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AdminRepository) GetUsers(ctx context.Context, limit, offset int) ([]domain.User, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AdminRepository) GetAuditLogs(ctx context.Context, limit, offset int) ([]domain.AuditEvent, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AdminRepository) Stats(ctx context.Context) (repositories.AdminStats, error) {
	// TODO: Implement
	return repositories.AdminStats{}, fmt.Errorf("not implemented")
}

func (r *AdminRepository) ListUsers(ctx context.Context, page, limit int) ([]repositories.AdminUserRow, int, error) {
	// TODO: Implement
	return nil, 0, fmt.Errorf("not implemented")
}

func (r *AdminRepository) ListAudit(ctx context.Context, page, limit int) ([]repositories.AuditRow, int, error) {
	// TODO: Implement
	return nil, 0, fmt.Errorf("not implemented")
}

func (r *AdminRepository) CreatePromo(ctx context.Context, createdBy *domain.ID, req repositories.CreatePromoRequest) (domain.ID, error) {
	// TODO: Implement
	return domain.NilID, fmt.Errorf("not implemented")
}