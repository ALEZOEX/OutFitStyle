package pg

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type PromoRepository struct {
	db *pgxpool.Pool
}

func NewPromoRepository(db *pgxpool.Pool) *PromoRepository {
	return &PromoRepository{db: db}
}

func (r *PromoRepository) GetByCode(ctx context.Context, code string) (*repositories.PromoCode, error) {
	query := `
		SELECT
			id, code, type, value, currency, min_order_amount, max_discount,
			usage_limit, usage_limit_per_user, start_date, end_date, is_active,
			created_at, updated_at
		FROM promo_codes
		WHERE code = $1
	`

	var promo repositories.PromoCode
	var currency *string
	var minOrderAmount *float64
	var maxDiscount *float64
	var usageLimit *int
	var usageLimitPerUser *int
	var startDate *time.Time
	var endDate *time.Time

	err := r.db.QueryRow(ctx, query, code).Scan(
		&promo.ID,
		&promo.Code,
		&promo.Type,
		&promo.Value,
		&currency,
		&minOrderAmount,
		&maxDiscount,
		&usageLimit,
		&usageLimitPerUser,
		&startDate,
		&endDate,
		&promo.IsActive,
		&promo.CreatedAt,
		&promo.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get promo code by code")
	}

	// Set nullable fields
	promo.Currency = currency
	promo.MinOrderAmount = minOrderAmount
	promo.MaxDiscount = maxDiscount
	promo.UsageLimit = usageLimit
	promo.UsageLimitPerUser = usageLimitPerUser
	promo.StartDate = startDate
	promo.EndDate = endDate

	return &promo, nil
}

func (r *PromoRepository) Create(ctx context.Context, promo *domain.PromoCode) error {
	query := `
		INSERT INTO promo_codes (
			id, code, type, value, currency, min_order_amount, max_discount,
			usage_limit, usage_limit_per_user, start_date, end_date, is_active,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
	`

	var currency *string
	var minOrderAmount *float64
	var maxDiscount *float64
	var usageLimit *int
	var usageLimitPerUser *int
	var startDate *time.Time
	var endDate *time.Time

	if promo.Currency != nil {
		currency = promo.Currency
	}
	if promo.MinOrderAmount != nil {
		minOrderAmount = promo.MinOrderAmount
	}
	if promo.MaxDiscount != nil {
		maxDiscount = promo.MaxDiscount
	}
	if promo.UsageLimit != nil {
		usageLimit = promo.UsageLimit
	}
	if promo.UsageLimitPerUser != nil {
		usageLimitPerUser = promo.UsageLimitPerUser
	}
	if promo.StartDate != nil {
		startDate = promo.StartDate
	}
	if promo.EndDate != nil {
		endDate = promo.EndDate
	}

	_, err := r.db.Exec(ctx, query,
		promo.ID,
		promo.Code,
		promo.Type,
		promo.Value,
		currency,
		minOrderAmount,
		maxDiscount,
		usageLimit,
		usageLimitPerUser,
		startDate,
		endDate,
		promo.IsActive,
		promo.CreatedAt,
		promo.UpdatedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to create promo code")
	}

	return nil
}

func (r *PromoRepository) Update(ctx context.Context, promo *domain.PromoCode) error {
	query := `
		UPDATE promo_codes SET
			type = $1, value = $2, currency = $3, min_order_amount = $4,
			max_discount = $5, usage_limit = $6, usage_limit_per_user = $7,
			start_date = $8, end_date = $9, is_active = $10, updated_at = $11
		WHERE id = $12
	`

	var currency *string
	var minOrderAmount *float64
	var maxDiscount *float64
	var usageLimit *int
	var usageLimitPerUser *int
	var startDate *time.Time
	var endDate *time.Time

	if promo.Currency != nil {
		currency = promo.Currency
	}
	if promo.MinOrderAmount != nil {
		minOrderAmount = promo.MinOrderAmount
	}
	if promo.MaxDiscount != nil {
		maxDiscount = promo.MaxDiscount
	}
	if promo.UsageLimit != nil {
		usageLimit = promo.UsageLimit
	}
	if promo.UsageLimitPerUser != nil {
		usageLimitPerUser = promo.UsageLimitPerUser
	}
	if promo.StartDate != nil {
		startDate = promo.StartDate
	}
	if promo.EndDate != nil {
		endDate = promo.EndDate
	}

	_, err := r.db.Exec(ctx, query,
		promo.Type,
		promo.Value,
		currency,
		minOrderAmount,
		maxDiscount,
		usageLimit,
		usageLimitPerUser,
		startDate,
		endDate,
		promo.IsActive,
		time.Now(),
		promo.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update promo code")
	}

	return nil
}

func (r *PromoRepository) GetUserRedemptions(ctx context.Context, userID domain.ID, promoCode string) ([]domain.PromoRedemption, error) {
	query := `
		SELECT
			id, user_id, promo_code_id, order_id, discount, currency, created_at
		FROM promo_redemptions
		WHERE user_id = $1 AND promo_code_id = (SELECT id FROM promo_codes WHERE code = $2)
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID, promoCode)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user redemptions")
	}
	defer rows.Close()

	var redemptions []domain.PromoRedemption
	for rows.Next() {
		var redemption domain.PromoRedemption
		var orderID *uuid.UUID
		var createdAt time.Time

		err := rows.Scan(
			&redemption.ID,
			&redemption.UserID,
			&redemption.PromoCodeID,
			&orderID,
			&redemption.Discount,
			&redemption.Currency,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan promo redemption")
		}

		// Set nullable fields
		if orderID != nil {
			oid := domain.ID(*orderID)
			redemption.OrderID = &oid
		}

		redemption.CreatedAt = createdAt

		redemptions = append(redemptions, redemption)
	}

	return redemptions, nil
}

func (r *PromoRepository) Redeem(ctx context.Context, userID domain.ID, promoCode string) error {
	// First, get the promo code details
	promo, err := r.GetByCode(ctx, promoCode)
	if err != nil {
		return errors.Wrap(err, "failed to get promo code")
	}
	if promo == nil {
		return errors.New("promo code not found")
	}

	// Check if promo code is active
	if !promo.IsActive {
		return errors.New("promo code is not active")
	}

	// Check if promo code has expired
	if promo.EndDate != nil && time.Now().After(*promo.EndDate) {
		return errors.New("promo code has expired")
	}

	// Check if promo code has started
	if promo.StartDate != nil && !promo.StartDate.IsZero() && time.Now().Before(*promo.StartDate) {
		return errors.New("promo code has not started yet")
	}

	// Check usage limits
	if promo.UsageLimit != nil {
		var currentUsage int
		err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM promo_redemptions WHERE promo_code_id = $1", promo.ID).Scan(&currentUsage)
		if err != nil {
			return errors.Wrap(err, "failed to check promo code usage limit")
		}
		if currentUsage >= *promo.UsageLimit {
			return errors.New("promo code usage limit reached")
		}
	}

	if promo.UsageLimitPerUser != nil {
		var userUsage int
		err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM promo_redemptions WHERE promo_code_id = $1 AND user_id = $2", promo.ID, userID).Scan(&userUsage)
		if err != nil {
			return errors.Wrap(err, "failed to check user promo code usage limit")
		}
		if userUsage >= *promo.UsageLimitPerUser {
			return errors.New("promo code usage limit per user reached")
		}
	}

	// Create redemption record
	id := domain.NewID()
	query := `
		INSERT INTO promo_redemptions (
			id, user_id, promo_code_id, created_at
		) VALUES ($1, $2, $3, $4)
	`

	_, err = r.db.Exec(ctx, query, id, userID, promo.ID, time.Now())
	if err != nil {
		return errors.Wrap(err, "failed to redeem promo code")
	}

	return nil
}
