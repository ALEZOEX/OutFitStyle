package pg

import (
	"context"
	"fmt"
	"time"

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

func (r *BillingRepository) CreateUserSubscription(ctx context.Context, userID int64, planID int64, billingCycle string, periodEnd time.Time, provider string) (int64, error) {
	// TODO: Implement
	return 0, fmt.Errorf("not implemented")
}

func (r *BillingRepository) CancelSubscription(ctx context.Context, userID int64, immediate bool) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *BillingRepository) ReactivateSubscription(ctx context.Context, userID int64) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *BillingRepository) CreatePayment(ctx context.Context, p repositories.CreatePaymentParams) (int64, error) {
	// TODO: Implement
	return 0, fmt.Errorf("not implemented")
}

func (r *BillingRepository) UpdatePaymentStatusByExternalID(ctx context.Context, provider string, externalPaymentID string, status string, receiptURL *string, errMsg *string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *BillingRepository) ListPayments(ctx context.Context, userID int64, page, limit int) (items []domain.Payment, total int, err error) {
	// TODO: Implement
	return nil, 0, fmt.Errorf("not implemented")
}