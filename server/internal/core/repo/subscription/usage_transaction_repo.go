package subscription

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// SubscriptionUsageRepo репозиторий для работы с использованием лимитов
type SubscriptionUsageRepo struct {
	db *sql.DB
}

// NewSubscriptionUsageRepo создаёт новый репозиторий использования лимитов
func NewSubscriptionUsageRepo(db *sql.DB) *SubscriptionUsageRepo {
	return &SubscriptionUsageRepo{db: db}
}

// GetUsage возвращает использование лимитов пользователя
func (r *SubscriptionUsageRepo) GetUsage(ctx context.Context, userID domain.ID) (*domain.SubscriptionUsage, error) {
	query := `
		SELECT id, user_id, subscription_id,
		       recommendations_today, recommendations_reset_at,
		       wardrobe_count, last_reset_at
		FROM subscription_usage
		WHERE user_id = $1
	`

	var usage domain.SubscriptionUsage
	var resetAt, lastResetAt sql.NullTime

	err := r.db.QueryRowContext(ctx, query, userID).Scan(
		&usage.ID,
		&usage.UserID,
		&usage.SubscriptionID,
		&usage.RecommendationsToday,
		&resetAt,
		&usage.WardrobeCount,
		&lastResetAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query usage: %w", err)
	}

	if resetAt.Valid {
		usage.RecommendationsResetAt = &resetAt.Time
	}
	if lastResetAt.Valid {
		usage.LastResetAt = &lastResetAt.Time
	}

	return &usage, nil
}

// GetOrCreateUsage возвращает или создаёт использование лимитов
func (r *SubscriptionUsageRepo) GetOrCreateUsage(ctx context.Context, userID domain.ID, subscriptionID *int64) (*domain.SubscriptionUsage, error) {
	// Пробуем получить существующую запись
	usage, err := r.GetUsage(ctx, userID)
	if err != nil {
		return nil, err
	}
	if usage != nil {
		return usage, nil
	}

	// Создаём новую запись
	query := `
		INSERT INTO subscription_usage (user_id, subscription_id, recommendations_today, wardrobe_count)
		VALUES ($1, $2, 0, 0)
		RETURNING id, user_id, subscription_id, recommendations_today, recommendations_reset_at, wardrobe_count, last_reset_at
	`

	var newUsage domain.SubscriptionUsage
	var resetAt, lastResetAt sql.NullTime

	err = r.db.QueryRowContext(ctx, query, userID, subscriptionID).Scan(
		&newUsage.ID,
		&newUsage.UserID,
		&newUsage.SubscriptionID,
		&newUsage.RecommendationsToday,
		&resetAt,
		&newUsage.WardrobeCount,
		&lastResetAt,
	)
	if err != nil {
		return nil, fmt.Errorf("create usage: %w", err)
	}

	if resetAt.Valid {
		newUsage.RecommendationsResetAt = &resetAt.Time
	}
	if lastResetAt.Valid {
		newUsage.LastResetAt = &lastResetAt.Time
	}

	return &newUsage, nil
}

// UpdateUsage обновляет использование лимитов
func (r *SubscriptionUsageRepo) UpdateUsage(ctx context.Context, usage *domain.SubscriptionUsage) error {
	query := `
		UPDATE subscription_usage
		SET recommendations_today = $2,
		    wardrobe_count = $3,
		    updated_at = NOW()
		WHERE user_id = $1
	`

	_, err := r.db.ExecContext(ctx, query, usage.UserID, usage.RecommendationsToday, usage.WardrobeCount)
	if err != nil {
		return fmt.Errorf("update usage: %w", err)
	}

	return nil
}

// IncrementRecommendations увеличивает счётчик рекомендаций
func (r *SubscriptionUsageRepo) IncrementRecommendations(ctx context.Context, userID domain.ID) error {
	query := `
		INSERT INTO subscription_usage (user_id, recommendations_today, recommendations_reset_at)
		VALUES ($1, 1, CURRENT_DATE)
		ON CONFLICT (user_id) DO UPDATE
		SET recommendations_today = subscription_usage.recommendations_today + 1,
		    recommendations_reset_at = CURRENT_DATE,
		    updated_at = NOW()
	`

	_, err := r.db.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("increment recommendations: %w", err)
	}

	return nil
}

// IncrementWardrobe увеличивает счётчик вещей в гардеробе
func (r *SubscriptionUsageRepo) IncrementWardrobe(ctx context.Context, userID domain.ID) error {
	query := `
		INSERT INTO subscription_usage (user_id, wardrobe_count)
		VALUES ($1, 1)
		ON CONFLICT (user_id) DO UPDATE
		SET wardrobe_count = subscription_usage.wardrobe_count + 1,
		    updated_at = NOW()
	`

	_, err := r.db.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("increment wardrobe: %w", err)
	}

	return nil
}

// DecrementWardrobe уменьшает счётчик вещей в гардеробе
func (r *SubscriptionUsageRepo) DecrementWardrobe(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE subscription_usage
		SET wardrobe_count = GREATEST(0, wardrobe_count - 1),
		    updated_at = NOW()
		WHERE user_id = $1
	`

	_, err := r.db.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("decrement wardrobe: %w", err)
	}

	return nil
}

// ResetDailyCounters сбрасывает дневные счётчики
func (r *SubscriptionUsageRepo) ResetDailyCounters(ctx context.Context, userID domain.ID) error {
	query := `
		UPDATE subscription_usage
		SET recommendations_today = 0,
		    recommendations_reset_at = CURRENT_DATE,
		    last_reset_at = NOW(),
		    updated_at = NOW()
		WHERE user_id = $1
	`

	_, err := r.db.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("reset daily counters: %w", err)
	}

	return nil
}

// BulkResetDailyCounters сбрасывает дневные счётчики для всех пользователей
func (r *SubscriptionUsageRepo) BulkResetDailyCounters(ctx context.Context) error {
	query := `
		UPDATE subscription_usage
		SET recommendations_today = 0,
		    recommendations_reset_at = CURRENT_DATE,
		    last_reset_at = NOW(),
		    updated_at = NOW()
		WHERE recommendations_reset_at < CURRENT_DATE
	`

	_, err := r.db.ExecContext(ctx, query)
	if err != nil {
		return fmt.Errorf("bulk reset daily counters: %w", err)
	}

	return nil
}

// SubscriptionTransactionRepo репозиторий для работы с транзакциями
type SubscriptionTransactionRepo struct {
	db *sql.DB
}

// NewSubscriptionTransactionRepo создаёт новый репозиторий транзакций
func NewSubscriptionTransactionRepo(db *sql.DB) *SubscriptionTransactionRepo {
	return &SubscriptionTransactionRepo{db: db}
}

// CreateTransaction создаёт новую транзакцию
func (r *SubscriptionTransactionRepo) CreateTransaction(ctx context.Context, tx *domain.SubscriptionTransaction) (int64, error) {
	query := `
		INSERT INTO subscription_transactions (
			user_id, subscription_id,
			amount, currency, status,
			payment_provider, external_payment_id, payment_method,
			description, receipt_url, error_message
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id
	`

	var id int64
	var subscriptionID, paymentMethod, description, receiptURL, errorMessage interface{}

	if tx.SubscriptionID != nil {
		subscriptionID = *tx.SubscriptionID
	} else {
		subscriptionID = nil
	}
	if tx.PaymentMethod != nil {
		paymentMethod = *tx.PaymentMethod
	} else {
		paymentMethod = nil
	}
	if tx.Description != nil {
		description = *tx.Description
	} else {
		description = nil
	}
	if tx.ReceiptURL != nil {
		receiptURL = *tx.ReceiptURL
	} else {
		receiptURL = nil
	}
	if tx.ErrorMessage != nil {
		errorMessage = *tx.ErrorMessage
	} else {
		errorMessage = nil
	}

	err := r.db.QueryRowContext(ctx, query,
		tx.UserID,
		subscriptionID,
		tx.Amount,
		tx.Currency,
		tx.Status,
		tx.PaymentProvider,
		tx.ExternalPaymentID,
		paymentMethod,
		description,
		receiptURL,
		errorMessage,
	).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create transaction: %w", err)
	}

	return id, nil
}

// GetTransactionByID возвращает транзакцию по ID
func (r *SubscriptionTransactionRepo) GetTransactionByID(ctx context.Context, id int64) (*domain.SubscriptionTransaction, error) {
	query := `
		SELECT id, user_id, subscription_id, amount, currency, status,
		       payment_provider, external_payment_id, payment_method,
		       description, receipt_url, error_message,
		       paid_at, refunded_at, created_at, updated_at
		FROM subscription_transactions
		WHERE id = $1
	`

	var tx domain.SubscriptionTransaction
	var subscriptionID, paymentMethod, description, receiptURL, errorMessage sql.NullInt64
	var paidAt, refundedAt sql.NullTime

	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&tx.ID,
		&tx.UserID,
		&subscriptionID,
		&tx.Amount,
		&tx.Currency,
		&tx.Status,
		&tx.PaymentProvider,
		&tx.ExternalPaymentID,
		&paymentMethod,
		&description,
		&receiptURL,
		&errorMessage,
		&paidAt,
		&refundedAt,
		&tx.CreatedAt,
		&tx.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query transaction by id: %w", err)
	}

	if subscriptionID.Valid {
		v := int64(subscriptionID.Int64)
		tx.SubscriptionID = &v
	}
	if paymentMethod.Valid {
		// payment_method is VARCHAR, need to fix
	}
	// Упрощённая обработка nullable полей

	return &tx, nil
}

// GetTransactionByExternalID возвращает транзакцию по внешнему ID
func (r *SubscriptionTransactionRepo) GetTransactionByExternalID(ctx context.Context, provider string, externalID string) (*domain.SubscriptionTransaction, error) {
	query := `
		SELECT id, user_id, subscription_id, amount, currency, status,
		       payment_provider, external_payment_id, payment_method,
		       description, receipt_url, error_message,
		       paid_at, refunded_at, created_at, updated_at
		FROM subscription_transactions
		WHERE payment_provider = $1 AND external_payment_id = $2
	`

	var tx domain.SubscriptionTransaction
	var subscriptionID sql.NullInt64
	var paymentMethod, description, receiptURL, errorMessage sql.NullString
	var paidAt, refundedAt sql.NullTime

	err := r.db.QueryRowContext(ctx, query, provider, externalID).Scan(
		&tx.ID,
		&tx.UserID,
		&subscriptionID,
		&tx.Amount,
		&tx.Currency,
		&tx.Status,
		&tx.PaymentProvider,
		&tx.ExternalPaymentID,
		&paymentMethod,
		&description,
		&receiptURL,
		&errorMessage,
		&paidAt,
		&refundedAt,
		&tx.CreatedAt,
		&tx.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query transaction by external id: %w", err)
	}

	if subscriptionID.Valid {
		v := int64(subscriptionID.Int64)
		tx.SubscriptionID = &v
	}
	if paymentMethod.Valid {
		tx.PaymentMethod = &paymentMethod.String
	}
	if description.Valid {
		tx.Description = &description.String
	}
	if receiptURL.Valid {
		tx.ReceiptURL = &receiptURL.String
	}
	if errorMessage.Valid {
		tx.ErrorMessage = &errorMessage.String
	}
	if paidAt.Valid {
		tx.PaidAt = &paidAt.Time
	}
	if refundedAt.Valid {
		tx.RefundedAt = &refundedAt.Time
	}

	return &tx, nil
}

// GetUserTransactions возвращает транзакции пользователя
func (r *SubscriptionTransactionRepo) GetUserTransactions(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SubscriptionTransaction, int, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}
	offset := (page - 1) * limit

	// Получаем общее количество
	countQuery := `SELECT COUNT(*) FROM subscription_transactions WHERE user_id = $1`
	var total int
	err := r.db.QueryRowContext(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("count transactions: %w", err)
	}

	query := `
		SELECT id, user_id, subscription_id, amount, currency, status,
		       payment_provider, external_payment_id, payment_method,
		       description, receipt_url, error_message,
		       paid_at, refunded_at, created_at, updated_at
		FROM subscription_transactions
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.QueryContext(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("query transactions: %w", err)
	}
	defer rows.Close()

	var transactions []domain.SubscriptionTransaction
	for rows.Next() {
		var tx domain.SubscriptionTransaction
		var subscriptionID sql.NullInt64
		var paymentMethod, description, receiptURL, errorMessage sql.NullString
		var paidAt, refundedAt sql.NullTime

		err := rows.Scan(
			&tx.ID, &tx.UserID, &subscriptionID,
			&tx.Amount, &tx.Currency, &tx.Status,
			&tx.PaymentProvider, &tx.ExternalPaymentID,
			&paymentMethod, &description, &receiptURL, &errorMessage,
			&paidAt, &refundedAt, &tx.CreatedAt, &tx.UpdatedAt,
		)
		if err != nil {
			return nil, 0, fmt.Errorf("scan transaction: %w", err)
		}

		if subscriptionID.Valid {
			v := int64(subscriptionID.Int64)
			tx.SubscriptionID = &v
		}
		if paymentMethod.Valid {
			tx.PaymentMethod = &paymentMethod.String
		}
		if description.Valid {
			tx.Description = &description.String
		}
		if receiptURL.Valid {
			tx.ReceiptURL = &receiptURL.String
		}
		if errorMessage.Valid {
			tx.ErrorMessage = &errorMessage.String
		}
		if paidAt.Valid {
			tx.PaidAt = &paidAt.Time
		}
		if refundedAt.Valid {
			tx.RefundedAt = &refundedAt.Time
		}

		transactions = append(transactions, tx)
	}

	return transactions, total, nil
}

// UpdateTransactionStatus обновляет статус транзакции
func (r *SubscriptionTransactionRepo) UpdateTransactionStatus(ctx context.Context, id int64, status string, paidAt *time.Time, receiptURL, errorMessage *string) error {
	query := `
		UPDATE subscription_transactions
		SET status = $2,
		    paid_at = $3,
		    receipt_url = $4,
		    error_message = $5,
		    updated_at = NOW()
		WHERE id = $1
	`

	_, err := r.db.ExecContext(ctx, query, id, status, paidAt, receiptURL, errorMessage)
	if err != nil {
		return fmt.Errorf("update transaction status: %w", err)
	}

	return nil
}

// UpdateTransactionByExternalID обновляет транзакцию по внешнему ID
func (r *SubscriptionTransactionRepo) UpdateTransactionByExternalID(ctx context.Context, provider string, externalID string, status string, paidAt *time.Time, receiptURL, errorMessage *string) error {
	query := `
		UPDATE subscription_transactions
		SET status = $4,
		    paid_at = $5,
		    receipt_url = $6,
		    error_message = $7,
		    updated_at = NOW()
		WHERE payment_provider = $1 AND external_payment_id = $2
	`

	_, err := r.db.ExecContext(ctx, query, provider, externalID, status, paidAt, receiptURL, errorMessage)
	if err != nil {
		return fmt.Errorf("update transaction by external id: %w", err)
	}

	return nil
}

// CreateRefundTransaction создаёт транзакцию возврата
func (r *SubscriptionTransactionRepo) CreateRefundTransaction(ctx context.Context, originalTxID int64, refundTx *domain.SubscriptionTransaction) (int64, error) {
	// Получаем оригинальную транзакцию
	original, err := r.GetTransactionByID(ctx, originalTxID)
	if err != nil {
		return 0, fmt.Errorf("get original transaction: %w", err)
	}
	if original == nil {
		return 0, fmt.Errorf("original transaction not found")
	}

	query := `
		INSERT INTO subscription_transactions (
			user_id, subscription_id,
			amount, currency, status,
			payment_provider, external_payment_id,
			description, receipt_url
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id
	`

	var id int64
	var subscriptionID interface{}
	if refundTx.SubscriptionID != nil {
		subscriptionID = *refundTx.SubscriptionID
	} else {
		subscriptionID = nil
	}

	err = r.db.QueryRowContext(ctx, query,
		refundTx.UserID,
		subscriptionID,
		refundTx.Amount,
		refundTx.Currency,
		refundTx.Status,
		refundTx.PaymentProvider,
		refundTx.ExternalPaymentID,
		refundTx.Description,
		refundTx.ReceiptURL,
	).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create refund transaction: %w", err)
	}

	return id, nil
}
