package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
)

type AuditRepository struct {
	db     *pgxpool.Pool
	logger *zap.Logger
}

func NewAuditRepository(db *pgxpool.Pool) repositories.AuditRepository {
	return &AuditRepository{db: db, logger: zap.NewNop()}
}

func (r *AuditRepository) Create(ctx context.Context, a repositories.AuditCreate) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}