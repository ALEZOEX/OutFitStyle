package pg

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

// PromoRedemptionRepositoryPG репозиторий для работы с использованиями промокодов
type PromoRedemptionRepositoryPG struct {
	db *pgxpool.Pool
}

// NewPromoRedemptionRepository создаёт новый репозиторий использований промокодов
func NewPromoRedemptionRepository(db *pgxpool.Pool) *PromoRedemptionRepositoryPG {
	return &PromoRedemptionRepositoryPG{db: db}
}

// CreateRedemption создаёт запись об использовании промокода
func (r *PromoRedemptionRepositoryPG) CreateRedemption(ctx context.Context, redemption *domain.PromoRedemption) (int64, error) {
	query := `INSERT INTO promo_redemptions (promo_code_id, user_id, subscription_id, discount_amount, currency) VALUES ($1, $2, $3, $4, $5) RETURNING id`
	var id int64
	err := r.db.QueryRow(ctx, query, redemption.PromoCodeID, redemption.UserID, redemption.SubscriptionID, redemption.DiscountAmount, redemption.Currency).Scan(&id)
	if err != nil {
		return 0, errors.Wrap(err, "failed to create promo redemption")
	}
	return id, nil
}

// GetRedemptionsByUser возвращает использования промокодов пользователем
func (r *PromoRedemptionRepositoryPG) GetRedemptionsByUser(ctx context.Context, userID domain.ID) ([]domain.PromoRedemption, error) {
	query := `SELECT id, promo_code_id, user_id, subscription_id, discount_amount, currency, created_at FROM promo_redemptions WHERE user_id = $1 ORDER BY created_at DESC`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user redemptions")
	}
	defer rows.Close()
	var redemptions []domain.PromoRedemption
	for rows.Next() {
		var redemption domain.PromoRedemption
		err := rows.Scan(&redemption.ID, &redemption.PromoCodeID, &redemption.UserID, &redemption.SubscriptionID, &redemption.DiscountAmount, &redemption.Currency, &redemption.CreatedAt)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan promo redemption")
		}
		redemptions = append(redemptions, redemption)
	}
	return redemptions, nil
}

// GetRedemptionByPromoAndUser возвращает использование промокода пользователем
func (r *PromoRedemptionRepositoryPG) GetRedemptionByPromoAndUser(ctx context.Context, promoCodeID int64, userID domain.ID) (*domain.PromoRedemption, error) {
	query := `SELECT id, promo_code_id, user_id, subscription_id, discount_amount, currency, created_at FROM promo_redemptions WHERE promo_code_id = $1 AND user_id = $2`
	var redemption domain.PromoRedemption
	err := r.db.QueryRow(ctx, query, promoCodeID, userID).Scan(&redemption.ID, &redemption.PromoCodeID, &redemption.UserID, &redemption.SubscriptionID, &redemption.DiscountAmount, &redemption.Currency, &redemption.CreatedAt)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get redemption by promo and user")
	}
	return &redemption, nil
}
