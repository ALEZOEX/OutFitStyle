// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// BillingRepository репозиторий для работы с биллинговыми операциями
type BillingRepository struct {
	db     *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
	logger *zap.Logger   // Логгер для записи событий
}

// NewBillingRepository создает новый экземпляр репозитория биллинга
func NewBillingRepository(db *pgxpool.Pool, logger *zap.Logger) *BillingRepository {
	return &BillingRepository{db: db, logger: logger}
}

// CreateTransaction создает новую транзакцию в биллинге
func (r *BillingRepository) CreateTransaction(ctx context.Context, transaction *domain.BillingTransaction) error {
	query := `
		INSERT INTO billing_transactions (
			id, user_id, amount, currency, status, payment_method,
			transaction_id, description, metadata, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`

	metadataJSON, err := json.Marshal(transaction.Metadata)
	if err != nil {
		return errors.Wrap(err, "failed to marshal transaction metadata")
	}

	_, err = r.db.Exec(ctx, query,
		transaction.ID,
		transaction.UserID,
		transaction.Amount,
		transaction.Currency,
		transaction.Status,
		transaction.PaymentMethod,
		transaction.TransactionID,
		transaction.Description,
		metadataJSON,
		transaction.CreatedAt,
	)

	if err != nil {
		return errors.Wrap(err, "failed to insert billing transaction")
	}

	return nil
}

func (r *BillingRepository) GetTransaction(ctx context.Context, transactionID domain.ID) (*domain.BillingTransaction, error) {
	query := `
		SELECT
			id, user_id, amount, currency, status, payment_method,
			transaction_id, description, metadata, created_at, processed_at
		FROM billing_transactions
		WHERE id = $1
	`

	var transaction domain.BillingTransaction
	var metadataJSON []byte
	var processedAt *time.Time

	err := r.db.QueryRow(ctx, query, transactionID).Scan(
		&transaction.ID,
		&transaction.UserID,
		&transaction.Amount,
		&transaction.Currency,
		&transaction.Status,
		&transaction.PaymentMethod,
		&transaction.TransactionID,
		&transaction.Description,
		&metadataJSON,
		&transaction.CreatedAt,
		&processedAt,
	)

	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get billing transaction")
	}

	// Unmarshal metadata
	if len(metadataJSON) > 0 {
		err = json.Unmarshal(metadataJSON, &transaction.Metadata)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal transaction metadata")
		}
	}

	transaction.ProcessedAt = processedAt

	return &transaction, nil
}

func (r *BillingRepository) GetTransactionsByUser(ctx context.Context, userID domain.ID, limit, offset int) ([]domain.BillingTransaction, error) {
	query := `
		SELECT
			id, user_id, amount, currency, status, payment_method,
			transaction_id, description, metadata, created_at, processed_at
		FROM billing_transactions
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query billing transactions by user")
	}
	defer rows.Close()

	var transactions []domain.BillingTransaction
	for rows.Next() {
		var transaction domain.BillingTransaction
		var metadataJSON []byte
		var processedAt *time.Time

		err := rows.Scan(
			&transaction.ID,
			&transaction.UserID,
			&transaction.Amount,
			&transaction.Currency,
			&transaction.Status,
			&transaction.PaymentMethod,
			&transaction.TransactionID,
			&transaction.Description,
			&metadataJSON,
			&transaction.CreatedAt,
			&processedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan billing transaction")
		}

		// Unmarshal metadata
		if len(metadataJSON) > 0 {
			err = json.Unmarshal(metadataJSON, &transaction.Metadata)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal transaction metadata")
			}
		}

		transaction.ProcessedAt = processedAt
		transactions = append(transactions, transaction)
	}

	return transactions, nil
}

func (r *BillingRepository) UpdateTransactionStatus(ctx context.Context, transactionID domain.ID, status domain.BillingStatus) error {
	query := `
		UPDATE billing_transactions
		SET status = $1, processed_at = NOW()
		WHERE id = $2
	`

	tag, err := r.db.Exec(ctx, query, status, transactionID)
	if err != nil {
		return errors.Wrap(err, "failed to update transaction status")
	}

	if tag.RowsAffected() == 0 {
		return errors.New("no transaction found with the given ID")
	}

	return nil
}

func (r *BillingRepository) CreateUserSubscription(ctx context.Context, userID int64, planID int64, billingCycle string, periodEnd time.Time, provider string) (int64, error) {
	query := `
		INSERT INTO user_subscriptions (
			user_id, plan_id, billing_cycle, current_period_end,
			status, auto_renew, payment_provider, created_at, updated_at
		) VALUES ($1, $2, $3, $4, 'active', true, $5, NOW(), NOW())
		RETURNING id
	`

	var subscriptionID int64
	err := r.db.QueryRow(ctx, query, userID, planID, billingCycle, periodEnd, provider).Scan(&subscriptionID)
	if err != nil {
		return 0, errors.Wrap(err, "failed to create user subscription")
	}

	return subscriptionID, nil
}

func (r *BillingRepository) CancelSubscription(ctx context.Context, userID int64, immediate bool) error {
	query := `
		UPDATE user_subscriptions
		SET status = 'cancelled', cancelled_at = NOW()
		WHERE user_id = $1 AND status = 'active'
	`

	if immediate {
		query = `
			UPDATE user_subscriptions
			SET status = 'cancelled', cancelled_at = NOW()
			WHERE user_id = $1 AND status = 'active'
		`
	} else {
		// For non-immediate cancellation, we might want to set a flag to cancel at period end
		query = `
			UPDATE user_subscriptions
			SET cancel_at_period_end = true, updated_at = NOW()
			WHERE user_id = $1 AND status = 'active'
		`
	}

	tag, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to cancel subscription")
	}

	if tag.RowsAffected() == 0 {
		return errors.New("no active subscription found for user")
	}

	return nil
}

func (r *BillingRepository) ReactivateSubscription(ctx context.Context, userID int64) error {
	query := `
		UPDATE user_subscriptions
		SET status = 'active', cancelled_at = NULL, cancel_at_period_end = false, updated_at = NOW()
		WHERE user_id = $1 AND (status = 'cancelled' OR cancel_at_period_end = true)
	`

	tag, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to reactivate subscription")
	}

	if tag.RowsAffected() == 0 {
		return errors.New("no cancelled subscription found for user")
	}

	return nil
}

func (r *BillingRepository) CreatePayment(ctx context.Context, p repositories.CreatePaymentParams) (int64, error) {
	query := `
		INSERT INTO payments (
			user_id, subscription_id, amount, currency, status, payment_provider,
			external_payment_id, receipt_url, error_message, paid_at, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())
		RETURNING id
	`

	var paymentID int64
	err := r.db.QueryRow(ctx, query,
		p.UserID,
		p.SubscriptionID,
		p.Amount,
		p.Currency,
		p.Status,
		p.PaymentProvider,
		p.ExternalPaymentID,
		p.ReceiptURL,
		p.ErrorMessage,
		p.PaidAt,
	).Scan(&paymentID)

	if err != nil {
		return 0, errors.Wrap(err, "failed to create payment")
	}

	return paymentID, nil
}

func (r *BillingRepository) UpdatePaymentStatusByExternalID(ctx context.Context, provider string, externalPaymentID string, status string, receiptURL *string, errMsg *string) error {
	query := `
		UPDATE payments
		SET status = $1, receipt_url = $2, error_message = $3, updated_at = NOW()
		WHERE payment_provider = $4 AND external_payment_id = $5
	`

	tag, err := r.db.Exec(ctx, query, status, receiptURL, errMsg, provider, externalPaymentID)
	if err != nil {
		return errors.Wrap(err, "failed to update payment status by external ID")
	}

	if tag.RowsAffected() == 0 {
		return errors.New("no payment found with the given provider and external ID")
	}

	return nil
}

func (r *BillingRepository) ListPayments(ctx context.Context, userID int64, page, limit int) (items []domain.Payment, total int, err error) {
	offset := (page - 1) * limit

	// Get total count
	countQuery := `SELECT COUNT(*) FROM payments WHERE user_id = $1`
	err = r.db.QueryRow(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count payments")
	}

	// Get payments with pagination
	query := `
		SELECT
			id, user_id, subscription_id, amount, currency, status, payment_provider,
			external_payment_id, receipt_url, error_message, paid_at, created_at, updated_at
		FROM payments
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query payments")
	}
	defer rows.Close()

	for rows.Next() {
		var payment domain.Payment
		var subscriptionID *int64
		var receiptURL, errorMessage *string
		var paidAt, createdAt, updatedAt time.Time

		err := rows.Scan(
			&payment.ID,
			&payment.UserID,
			&subscriptionID,
			&payment.Amount,
			&payment.Currency,
			&payment.Status,
			&payment.PaymentProvider,
			&payment.ExternalPaymentID,
			&receiptURL,
			&errorMessage,
			&paidAt,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan payment")
		}

		payment.SubscriptionID = subscriptionID
		payment.ReceiptURL = receiptURL
		payment.ErrorMessage = errorMessage
		payment.PaidAt = &paidAt
		payment.CreatedAt = createdAt
		payment.UpdatedAt = updatedAt

		items = append(items, payment)
	}

	return items, total, nil
}
