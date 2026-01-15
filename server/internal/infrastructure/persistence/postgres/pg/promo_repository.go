package pg

import (
	"context"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type PromoRepository struct {
	db *dbpkg.DB
}

func NewPromoRepository(db *dbpkg.DB) repositories.PromoRepository {
	return &PromoRepository{db: db}
}

func (r *PromoRepository) GetByCode(ctx context.Context, code string) (*repositories.PromoCode, error) {
	code = strings.TrimSpace(strings.ToUpper(code))
	if code == "" {
		return nil, nil
	}

	q := `
		SELECT
			id, code,
			discount_type, discount_value,
			applicable_plans, min_billing_cycle,
			max_uses, uses_count, max_uses_per_user,
			valid_from, valid_until,
			is_active
		FROM promo_codes
		WHERE code = $1
		LIMIT 1
	`
	var p repositories.PromoCode
	var validUntil *time.Time

	err := r.db.Pool().QueryRow(ctx, q, code).Scan(
		&p.ID, &p.Code,
		&p.DiscountType, &p.DiscountValue,
		&p.ApplicablePlans, &p.MinBillingCycle,
		&p.MaxUses, &p.UsesCount, &p.MaxUsesPerUser,
		&p.ValidFrom, &validUntil,
		&p.IsActive,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get promo by code")
	}
	p.ValidUntil = validUntil
	_ = domain.NewID // silence
	return &p, nil
}
