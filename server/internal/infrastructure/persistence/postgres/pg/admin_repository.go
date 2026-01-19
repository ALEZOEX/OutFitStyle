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