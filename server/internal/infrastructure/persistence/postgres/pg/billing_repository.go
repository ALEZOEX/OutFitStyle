package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type BillingRepository struct {
	db     *pgxpool.Pool
	logger *zap.Logger
}

func NewBillingRepository(db *pgxpool.Pool, logger *zap.Logger) *BillingRepository {
	return &BillingRepository{db: db, logger: logger}
}

func (r *BillingRepository) CreateTransaction(ctx context.Context, transaction *domain.BillingTransaction) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *BillingRepository) GetTransaction(ctx context.Context, transactionID domain.ID) (*domain.BillingTransaction, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *BillingRepository) GetTransactionsByUser(ctx context.Context, userID domain.ID, limit, offset int) ([]domain.BillingTransaction, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *BillingRepository) UpdateTransactionStatus(ctx context.Context, transactionID domain.ID, status domain.BillingStatus) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}