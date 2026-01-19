package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type PromoRepository struct {
	db *pgxpool.Pool
}

func NewPromoRepository(db *pgxpool.Pool) *PromoRepository {
	return &PromoRepository{db: db}
}

func (r *PromoRepository) GetByCode(ctx context.Context, code string) (*domain.PromoCode, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *PromoRepository) Create(ctx context.Context, promo *domain.PromoCode) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *PromoRepository) Update(ctx context.Context, promo *domain.PromoCode) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *PromoRepository) GetUserRedemptions(ctx context.Context, userID domain.ID, promoCode string) ([]domain.PromoRedemption, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *PromoRepository) Redeem(ctx context.Context, userID domain.ID, promoCode string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}