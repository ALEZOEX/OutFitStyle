package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type BillingRepository struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

func NewBillingRepository(db *dbpkg.DB, logger *zap.Logger) repositories.BillingRepository {
	return &BillingRepository{db: db, logger: logger}
}

func (r *BillingRepository) CreateUserSubscription(ctx context.Context, userID int64, planID int64, billingCycle string, periodEnd time.Time, provider string) (int64, error) {
	q := `
		INSERT INTO user_subscriptions (
			user_id, plan_id, billing_cycle,
			current_period_end,
			status, auto_renew,
			payment_provider
		)
		VALUES ($1,$2,$3,$4,'active',TRUE,$5)
		RETURNING id
	`
	var id int64
	err := r.db.Pool().QueryRow(ctx, q, userID, planID, billingCycle, periodEnd, provider).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "create user_subscription")
	}
	return id, nil
}

func (r *BillingRepository) CancelSubscription(ctx context.Context, userID int64, immediate bool) error {
	// отменяем активную/триал подписку
	// immediate=true: current_period_end=NOW()
	q := `
		UPDATE user_subscriptions
		SET
			status = 'cancelled',
			auto_renew = FALSE,
			cancelled_at = NOW(),
			current_period_end = CASE WHEN $2 THEN NOW() ELSE current_period_end END
		WHERE user_id = $1
		  AND status IN ('active','trialing')
	`
	cmd, err := r.db.Pool().Exec(ctx, q, userID, immediate)
	if err != nil {
		return errors.Wrap(err, "cancel subscription")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *BillingRepository) ReactivateSubscription(ctx context.Context, userID int64) error {
	q := `
		UPDATE user_subscriptions
		SET
			status = 'active',
			auto_renew = TRUE,
			cancelled_at = NULL
		WHERE user_id = $1
		  AND status = 'cancelled'
	`
	cmd, err := r.db.Pool().Exec(ctx, q, userID)
	if err != nil {
		return errors.Wrap(err, "reactivate subscription")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *BillingRepository) CreatePayment(ctx context.Context, p repositories.CreatePaymentParams) (int64, error) {
	q := `
		INSERT INTO payments (
			user_id, subscription_id,
			amount, currency,
			status, payment_provider,
			external_payment_id, payment_method,
			description
		)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING id
	`
	var id int64
	err := r.db.Pool().QueryRow(ctx, q,
		p.UserID, p.SubscriptionID,
		p.Amount, p.Currency,
		p.Status, p.PaymentProvider,
		p.ExternalPaymentID, p.PaymentMethod,
		p.Description,
	).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "create payment")
	}
	return id, nil
}

func (r *BillingRepository) UpdatePaymentStatusByExternalID(ctx context.Context, provider string, externalPaymentID string, status string, receiptURL *string, errMsg *string) error {
	q := `
		UPDATE payments
		SET
			status = $1,
			receipt_url = COALESCE($2, receipt_url),
			error_message = COALESCE($3, error_message),
			completed_at = CASE WHEN $1 IN ('completed','failed','refunded') THEN NOW() ELSE completed_at END
		WHERE payment_provider = $4 AND external_payment_id = $5
	`
	cmd, err := r.db.Pool().Exec(ctx, q, status, receiptURL, errMsg, provider, externalPaymentID)
	if err != nil {
		return errors.Wrap(err, "update payment status")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *BillingRepository) ListPayments(ctx context.Context, userID int64, page, limit int) ([]domain.Payment, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if page <= 0 {
		page = 1
	}
	offset := (page - 1) * limit

	var total int
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM payments WHERE user_id = $1`, userID).Scan(&total); err != nil {
		return nil, 0, errors.Wrap(err, "count payments")
	}

	q := `
		SELECT
			id, user_id, subscription_id,
			amount, currency,
			status, payment_provider,
			external_payment_id, payment_method,
			description, receipt_url, error_message,
			created_at, completed_at
		FROM payments
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.Pool().Query(ctx, q, userID, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "list payments")
	}
	defer rows.Close()

	out := []domain.Payment{}
	for rows.Next() {
		var p domain.Payment
		if err := rows.Scan(
			&p.ID, &p.UserID, &p.SubscriptionID,
			&p.Amount, &p.Currency,
			&p.Status, &p.PaymentProvider,
			&p.ExternalPaymentID, &p.PaymentMethod,
			&p.Description, &p.ReceiptURL, &p.ErrorMessage,
			&p.CreatedAt, &p.CompletedAt,
		); err != nil {
			return nil, 0, errors.Wrap(err, "scan payment")
		}
		out = append(out, p)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Wrap(err, "payments rows")
	}

	return out, total, nil
}

func (r *BillingRepository) _ensure() { _ = pgx.ErrNoRows }