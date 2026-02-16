package subscription

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"

	"outfitstyle/server/internal/core/domain"
)

// PromoCodeRepo репозиторий для работы с промокодами
type PromoCodeRepo struct {
	db *sql.DB
}

// NewPromoCodeRepo создаёт новый репозиторий промокодов
func NewPromoCodeRepo(db *sql.DB) *PromoCodeRepo {
	return &PromoCodeRepo{db: db}
}

// GetByCode возвращает промокод по коду
func (r *PromoCodeRepo) GetByCode(ctx context.Context, code string) (*domain.PromoCode, error) {
	query := `
		SELECT id, code, name,
		       discount_type, discount_value, currency,
		       min_order_amount, max_discount, usage_limit, usage_limit_per_user,
		       applicable_plans, min_billing_cycle,
		       valid_from, valid_until,
		       is_active, uses_count,
		       created_at, updated_at
		FROM promo_codes
		WHERE code = $1 AND is_active = TRUE
	`

	var promo domain.PromoCode
	var name, currency, minBillingCycle sql.NullString
	var minOrderAmount, maxDiscount sql.NullFloat64
	var usageLimit sql.NullInt32
	var validUntil sql.NullTime
	var applicablePlansJSON []byte

	err := r.db.QueryRowContext(ctx, query, code).Scan(
		&promo.ID,
		&promo.Code,
		&name,
		&promo.DiscountType,
		&promo.DiscountValue,
		&currency,
		&minOrderAmount,
		&maxDiscount,
		&usageLimit,
		&promo.UsageLimitPerUser,
		&applicablePlansJSON,
		&minBillingCycle,
		&promo.ValidFrom,
		&validUntil,
		&promo.IsActive,
		&promo.UsesCount,
		&promo.CreatedAt,
		&promo.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query promo code by code: %w", err)
	}

	if name.Valid {
		promo.Name = &name.String
	}
	if currency.Valid {
		promo.Currency = &currency.String
	}
	if minOrderAmount.Valid {
		promo.MinOrderAmount = &minOrderAmount.Float64
	}
	if maxDiscount.Valid {
		promo.MaxDiscount = &maxDiscount.Float64
	}
	if usageLimit.Valid {
		v := int(usageLimit.Int32)
		promo.UsageLimit = &v
	}
	if validUntil.Valid {
		promo.ValidUntil = &validUntil.Time
	}
	if minBillingCycle.Valid {
		promo.MinBillingCycle = &minBillingCycle.String
	}

	// Парсим JSON массив планов
	var plans []string
	if err := json.Unmarshal(applicablePlansJSON, &plans); err == nil {
		promo.ApplicablePlans = plans
	}

	return &promo, nil
}

// GetByID возвращает промокод по ID
func (r *PromoCodeRepo) GetByID(ctx context.Context, id int64) (*domain.PromoCode, error) {
	query := `
		SELECT id, code, name,
		       discount_type, discount_value, currency,
		       min_order_amount, max_discount, usage_limit, usage_limit_per_user,
		       applicable_plans, min_billing_cycle,
		       valid_from, valid_until,
		       is_active, uses_count,
		       created_at, updated_at
		FROM promo_codes
		WHERE id = $1
	`

	var promo domain.PromoCode
	var name, currency, minBillingCycle sql.NullString
	var minOrderAmount, maxDiscount sql.NullFloat64
	var usageLimit sql.NullInt32
	var validUntil sql.NullTime
	var applicablePlansJSON []byte

	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&promo.ID,
		&promo.Code,
		&name,
		&promo.DiscountType,
		&promo.DiscountValue,
		&currency,
		&minOrderAmount,
		&maxDiscount,
		&usageLimit,
		&promo.UsageLimitPerUser,
		&applicablePlansJSON,
		&minBillingCycle,
		&promo.ValidFrom,
		&validUntil,
		&promo.IsActive,
		&promo.UsesCount,
		&promo.CreatedAt,
		&promo.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query promo code by id: %w", err)
	}

	if name.Valid {
		promo.Name = &name.String
	}
	if currency.Valid {
		promo.Currency = &currency.String
	}
	if minOrderAmount.Valid {
		promo.MinOrderAmount = &minOrderAmount.Float64
	}
	if maxDiscount.Valid {
		promo.MaxDiscount = &maxDiscount.Float64
	}
	if usageLimit.Valid {
		v := int(usageLimit.Int32)
		promo.UsageLimit = &v
	}
	if validUntil.Valid {
		promo.ValidUntil = &validUntil.Time
	}
	if minBillingCycle.Valid {
		promo.MinBillingCycle = &minBillingCycle.String
	}

	var plans []string
	if err := json.Unmarshal(applicablePlansJSON, &plans); err == nil {
		promo.ApplicablePlans = plans
	}

	return &promo, nil
}

// CreatePromoCode создаёт новый промокод
func (r *PromoCodeRepo) CreatePromoCode(ctx context.Context, promo *domain.PromoCode) (int64, error) {
	query := `
		INSERT INTO promo_codes (
			code, name,
			discount_type, discount_value, currency,
			min_order_amount, max_discount, usage_limit, usage_limit_per_user,
			applicable_plans, min_billing_cycle,
			valid_from, valid_until,
			is_active
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		RETURNING id
	`

	var id int64
	var name, currency, minBillingCycle interface{}
	var minOrderAmount, maxDiscount interface{}
	var usageLimit interface{}
	var validUntil interface{}

	if promo.Name != nil {
		name = *promo.Name
	} else {
		name = nil
	}
	if promo.Currency != nil {
		currency = *promo.Currency
	} else {
		currency = nil
	}
	if promo.MinOrderAmount != nil {
		minOrderAmount = *promo.MinOrderAmount
	} else {
		minOrderAmount = nil
	}
	if promo.MaxDiscount != nil {
		maxDiscount = *promo.MaxDiscount
	} else {
		maxDiscount = nil
	}
	if promo.UsageLimit != nil {
		usageLimit = *promo.UsageLimit
	} else {
		usageLimit = nil
	}
	if promo.MinBillingCycle != nil {
		minBillingCycle = *promo.MinBillingCycle
	} else {
		minBillingCycle = nil
	}
	if promo.ValidUntil != nil {
		validUntil = *promo.ValidUntil
	} else {
		validUntil = nil
	}

	applicablePlansJSON, err := json.Marshal(promo.ApplicablePlans)
	if err != nil {
		return 0, fmt.Errorf("marshal applicable plans: %w", err)
	}

	err = r.db.QueryRowContext(ctx, query,
		promo.Code,
		name,
		promo.DiscountType,
		promo.DiscountValue,
		currency,
		minOrderAmount,
		maxDiscount,
		usageLimit,
		promo.UsageLimitPerUser,
		applicablePlansJSON,
		minBillingCycle,
		promo.ValidFrom,
		validUntil,
		promo.IsActive,
	).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create promo code: %w", err)
	}

	return id, nil
}

// UpdatePromoCode обновляет промокод
func (r *PromoCodeRepo) UpdatePromoCode(ctx context.Context, promo *domain.PromoCode) error {
	query := `
		UPDATE promo_codes
		SET name = $2,
		    discount_type = $3,
		    discount_value = $4,
		    currency = $5,
		    min_order_amount = $6,
		    max_discount = $7,
		    usage_limit = $8,
		    usage_limit_per_user = $9,
		    applicable_plans = $10,
		    min_billing_cycle = $11,
		    valid_until = $12,
		    is_active = $13,
		    updated_at = NOW()
		WHERE id = $1
	`

	var name, currency, minBillingCycle interface{}
	var minOrderAmount, maxDiscount interface{}
	var usageLimit interface{}
	var validUntil interface{}

	if promo.Name != nil {
		name = *promo.Name
	} else {
		name = promo.Code // default to code if nil
	}
	if promo.Currency != nil {
		currency = *promo.Currency
	} else {
		currency = nil
	}
	if promo.MinOrderAmount != nil {
		minOrderAmount = *promo.MinOrderAmount
	} else {
		minOrderAmount = nil
	}
	if promo.MaxDiscount != nil {
		maxDiscount = *promo.MaxDiscount
	} else {
		maxDiscount = nil
	}
	if promo.UsageLimit != nil {
		usageLimit = *promo.UsageLimit
	} else {
		usageLimit = nil
	}
	if promo.MinBillingCycle != nil {
		minBillingCycle = *promo.MinBillingCycle
	} else {
		minBillingCycle = nil
	}
	if promo.ValidUntil != nil {
		validUntil = *promo.ValidUntil
	} else {
		validUntil = nil
	}

	applicablePlansJSON, err := json.Marshal(promo.ApplicablePlans)
	if err != nil {
		return fmt.Errorf("marshal applicable plans: %w", err)
	}

	_, err = r.db.ExecContext(ctx, query,
		promo.ID,
		name,
		promo.DiscountType,
		promo.DiscountValue,
		currency,
		minOrderAmount,
		maxDiscount,
		usageLimit,
		promo.UsageLimitPerUser,
		applicablePlansJSON,
		minBillingCycle,
		validUntil,
		promo.IsActive,
	)
	if err != nil {
		return fmt.Errorf("update promo code: %w", err)
	}

	return nil
}

// DeletePromoCode удаляет промокод (мягкое удаление через is_active)
func (r *PromoCodeRepo) DeletePromoCode(ctx context.Context, id int64) error {
	query := `
		UPDATE promo_codes
		SET is_active = FALSE, updated_at = NOW()
		WHERE id = $1
	`

	_, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("delete promo code: %w", err)
	}

	return nil
}

// GetUsageCount возвращает количество использований промокода пользователем
func (r *PromoCodeRepo) GetUsageCount(ctx context.Context, promoCodeID int64, userID domain.ID) (int, error) {
	query := `
		SELECT COUNT(*)
		FROM promo_redemptions
		WHERE promo_code_id = $1 AND user_id = $2
	`

	var count int
	err := r.db.QueryRowContext(ctx, query, promoCodeID, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("query usage count: %w", err)
	}

	return count, nil
}

// IncrementUsage увеличивает счётчик использований промокода
func (r *PromoCodeRepo) IncrementUsage(ctx context.Context, promoCodeID int64) error {
	query := `
		UPDATE promo_codes
		SET uses_count = uses_count + 1,
		    updated_at = NOW()
		WHERE id = $1
	`

	_, err := r.db.ExecContext(ctx, query, promoCodeID)
	if err != nil {
		return fmt.Errorf("increment usage: %w", err)
	}

	return nil
}

// ListActivePromoCodes возвращает список активных промокодов
func (r *PromoCodeRepo) ListActivePromoCodes(ctx context.Context) ([]domain.PromoCode, error) {
	query := `
		SELECT id, code, name,
		       discount_type, discount_value, currency,
		       min_order_amount, max_discount, usage_limit, usage_limit_per_user,
		       applicable_plans, min_billing_cycle,
		       valid_from, valid_until,
		       is_active, uses_count,
		       created_at, updated_at
		FROM promo_codes
		WHERE is_active = TRUE
		  AND (valid_until IS NULL OR valid_until > NOW())
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("query active promo codes: %w", err)
	}
	defer rows.Close()

	var promos []domain.PromoCode
	for rows.Next() {
		var promo domain.PromoCode
		var name, currency, minBillingCycle sql.NullString
		var minOrderAmount, maxDiscount sql.NullFloat64
		var usageLimit sql.NullInt32
		var validUntil sql.NullTime
		var applicablePlansJSON []byte

		err := rows.Scan(
			&promo.ID, &promo.Code, &name,
			&promo.DiscountType, &promo.DiscountValue, &currency,
			&minOrderAmount, &maxDiscount, &usageLimit, &promo.UsageLimitPerUser,
			&applicablePlansJSON, &minBillingCycle,
			&promo.ValidFrom, &validUntil,
			&promo.IsActive, &promo.UsesCount,
			&promo.CreatedAt, &promo.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan promo code: %w", err)
		}

		if name.Valid {
			promo.Name = &name.String
		}
		if currency.Valid {
			promo.Currency = &currency.String
		}
		if minOrderAmount.Valid {
			promo.MinOrderAmount = &minOrderAmount.Float64
		}
		if maxDiscount.Valid {
			promo.MaxDiscount = &maxDiscount.Float64
		}
		if usageLimit.Valid {
			v := int(usageLimit.Int32)
			promo.UsageLimit = &v
		}
		if validUntil.Valid {
			promo.ValidUntil = &validUntil.Time
		}
		if minBillingCycle.Valid {
			promo.MinBillingCycle = &minBillingCycle.String
		}

		var plans []string
		if err := json.Unmarshal(applicablePlansJSON, &plans); err == nil {
			promo.ApplicablePlans = plans
		}

		promos = append(promos, promo)
	}

	return promos, nil
}

// PromoRedemptionRepo репозиторий для работы с использованиями промокодов
type PromoRedemptionRepo struct {
	db *sql.DB
}

// NewPromoRedemptionRepo создаёт новый репозиторий использований промокодов
func NewPromoRedemptionRepo(db *sql.DB) *PromoRedemptionRepo {
	return &PromoRedemptionRepo{db: db}
}

// CreateRedemption создаёт запись об использовании промокода
func (r *PromoRedemptionRepo) CreateRedemption(ctx context.Context, redemption *domain.PromoRedemption) (int64, error) {
	query := `
		INSERT INTO promo_redemptions (
			promo_code_id, user_id, subscription_id,
			discount_amount, currency
		) VALUES ($1, $2, $3, $4, $5)
		RETURNING id
	`

	var id int64
	var subscriptionID interface{}
	if redemption.SubscriptionID != nil {
		subscriptionID = *redemption.SubscriptionID
	} else {
		subscriptionID = nil
	}

	err := r.db.QueryRowContext(ctx, query,
		redemption.PromoCodeID,
		redemption.UserID,
		subscriptionID,
		redemption.DiscountAmount,
		redemption.Currency,
	).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create redemption: %w", err)
	}

	return id, nil
}

// GetRedemptionsByUser возвращает использования промокодов пользователем
func (r *PromoRedemptionRepo) GetRedemptionsByUser(ctx context.Context, userID domain.ID) ([]domain.PromoRedemption, error) {
	query := `
		SELECT id, promo_code_id, user_id, subscription_id,
		       discount_amount, currency, created_at
		FROM promo_redemptions
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("query redemptions: %w", err)
	}
	defer rows.Close()

	var redemptions []domain.PromoRedemption
	for rows.Next() {
		var redemption domain.PromoRedemption
		var subscriptionID sql.NullInt64

		err := rows.Scan(
			&redemption.ID,
			&redemption.PromoCodeID,
			&redemption.UserID,
			&subscriptionID,
			&redemption.DiscountAmount,
			&redemption.Currency,
			&redemption.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan redemption: %w", err)
		}

		if subscriptionID.Valid {
			v := int64(subscriptionID.Int64)
			redemption.SubscriptionID = &v
		}

		redemptions = append(redemptions, redemption)
	}

	return redemptions, nil
}

// GetRedemptionByPromoAndUser возвращает использование промокода пользователем
func (r *PromoRedemptionRepo) GetRedemptionByPromoAndUser(ctx context.Context, promoCodeID int64, userID domain.ID) (*domain.PromoRedemption, error) {
	query := `
		SELECT id, promo_code_id, user_id, subscription_id,
		       discount_amount, currency, created_at
		FROM promo_redemptions
		WHERE promo_code_id = $1 AND user_id = $2
	`

	var redemption domain.PromoRedemption
	var subscriptionID sql.NullInt64

	err := r.db.QueryRowContext(ctx, query, promoCodeID, userID).Scan(
		&redemption.ID,
		&redemption.PromoCodeID,
		&redemption.UserID,
		&subscriptionID,
		&redemption.DiscountAmount,
		&redemption.Currency,
		&redemption.CreatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query redemption: %w", err)
	}

	if subscriptionID.Valid {
		v := int64(subscriptionID.Int64)
		redemption.SubscriptionID = &v
	}

	return &redemption, nil
}

// FamilyMemberRepo репозиторий для работы с семейными участниками
type FamilyMemberRepo struct {
	db *sql.DB
}

// NewFamilyMemberRepo создаёт новый репозиторий семейных участников
func NewFamilyMemberRepo(db *sql.DB) *FamilyMemberRepo {
	return &FamilyMemberRepo{db: db}
}

// GetFamilyMembers возвращает семейных участников владельца
func (r *FamilyMemberRepo) GetFamilyMembers(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id,
		       status, invited_at, accepted_at, expires_at,
		       added_by, created_at, updated_at
		FROM family_members
		WHERE owner_user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, ownerUserID)
	if err != nil {
		return nil, fmt.Errorf("query family members: %w", err)
	}
	defer rows.Close()

	var members []domain.FamilyMember
	for rows.Next() {
		var member domain.FamilyMember
		var acceptedAt, expiresAt sql.NullTime
		var addedBy sql.NullInt64

		err := rows.Scan(
			&member.ID,
			&member.OwnerUserID,
			&member.MemberUserID,
			&member.Status,
			&member.InvitedAt,
			&acceptedAt,
			&expiresAt,
			&addedBy,
			&member.CreatedAt,
			&member.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan family member: %w", err)
		}

		if acceptedAt.Valid {
			member.AcceptedAt = &acceptedAt.Time
		}
		if expiresAt.Valid {
			member.ExpiresAt = &expiresAt.Time
		}
		if addedBy.Valid {
			v := int64(addedBy.Int64)
			member.AddedBy = &v
		}

		members = append(members, member)
	}

	return members, nil
}

// GetFamilyMemberByID возвращает семейного участника по ID
func (r *FamilyMemberRepo) GetFamilyMemberByID(ctx context.Context, id int64) (*domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id,
		       status, invited_at, accepted_at, expires_at,
		       added_by, created_at, updated_at
		FROM family_members
		WHERE id = $1
	`

	var member domain.FamilyMember
	var acceptedAt, expiresAt sql.NullTime
	var addedBy sql.NullInt64

	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&member.ID,
		&member.OwnerUserID,
		&member.MemberUserID,
		&member.Status,
		&member.InvitedAt,
		&acceptedAt,
		&expiresAt,
		&addedBy,
		&member.CreatedAt,
		&member.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query family member by id: %w", err)
	}

	if acceptedAt.Valid {
		member.AcceptedAt = &acceptedAt.Time
	}
	if expiresAt.Valid {
		member.ExpiresAt = &expiresAt.Time
	}
	if addedBy.Valid {
		v := int64(addedBy.Int64)
		member.AddedBy = &v
	}

	return &member, nil
}

// GetFamilyMemberByMemberID возвращает семейного участника по ID участника
func (r *FamilyMemberRepo) GetFamilyMemberByMemberID(ctx context.Context, memberUserID domain.ID) (*domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id,
		       status, invited_at, accepted_at, expires_at,
		       added_by, created_at, updated_at
		FROM family_members
		WHERE member_user_id = $1
	`

	var member domain.FamilyMember
	var acceptedAt, expiresAt sql.NullTime
	var addedBy sql.NullInt64

	err := r.db.QueryRowContext(ctx, query, memberUserID).Scan(
		&member.ID,
		&member.OwnerUserID,
		&member.MemberUserID,
		&member.Status,
		&member.InvitedAt,
		&acceptedAt,
		&expiresAt,
		&addedBy,
		&member.CreatedAt,
		&member.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("query family member by member id: %w", err)
	}

	if acceptedAt.Valid {
		member.AcceptedAt = &acceptedAt.Time
	}
	if expiresAt.Valid {
		member.ExpiresAt = &expiresAt.Time
	}
	if addedBy.Valid {
		v := int64(addedBy.Int64)
		member.AddedBy = &v
	}

	return &member, nil
}

// CreateFamilyMember создаёт нового семейного участника
func (r *FamilyMemberRepo) CreateFamilyMember(ctx context.Context, member *domain.FamilyMember) (int64, error) {
	query := `
		INSERT INTO family_members (
			owner_user_id, member_user_id,
			status, invited_at, accepted_at, expires_at,
			added_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id
	`

	var id int64
	var acceptedAt, expiresAt, addedBy interface{}

	if member.AcceptedAt != nil {
		acceptedAt = *member.AcceptedAt
	} else {
		acceptedAt = nil
	}
	if member.ExpiresAt != nil {
		expiresAt = *member.ExpiresAt
	} else {
		expiresAt = nil
	}
	if member.AddedBy != nil {
		addedBy = *member.AddedBy
	} else {
		addedBy = nil
	}

	err := r.db.QueryRowContext(ctx, query,
		member.OwnerUserID,
		member.MemberUserID,
		member.Status,
		member.InvitedAt,
		acceptedAt,
		expiresAt,
		addedBy,
	).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create family member: %w", err)
	}

	return id, nil
}

// UpdateFamilyMember обновляет семейного участника
func (r *FamilyMemberRepo) UpdateFamilyMember(ctx context.Context, member *domain.FamilyMember) error {
	query := `
		UPDATE family_members
		SET status = $2,
		    accepted_at = $3,
		    expires_at = $4,
		    updated_at = NOW()
		WHERE id = $1
	`

	var acceptedAt, expiresAt interface{}
	if member.AcceptedAt != nil {
		acceptedAt = *member.AcceptedAt
	} else {
		acceptedAt = nil
	}
	if member.ExpiresAt != nil {
		expiresAt = *member.ExpiresAt
	} else {
		expiresAt = nil
	}

	_, err := r.db.ExecContext(ctx, query,
		member.ID,
		member.Status,
		acceptedAt,
		expiresAt,
	)
	if err != nil {
		return fmt.Errorf("update family member: %w", err)
	}

	return nil
}

// RemoveFamilyMember удаляет семейного участника
func (r *FamilyMemberRepo) RemoveFamilyMember(ctx context.Context, id int64) error {
	query := `
		DELETE FROM family_members
		WHERE id = $1
	`

	_, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("remove family member: %w", err)
	}

	return nil
}

// AcceptInvitation принимает приглашение в семью
func (r *FamilyMemberRepo) AcceptInvitation(ctx context.Context, memberUserID domain.ID) error {
	query := `
		UPDATE family_members
		SET status = 'active',
		    accepted_at = NOW(),
		    updated_at = NOW()
		WHERE member_user_id = $1 AND status = 'pending'
	`

	_, err := r.db.ExecContext(ctx, query, memberUserID)
	if err != nil {
		return fmt.Errorf("accept invitation: %w", err)
	}

	return nil
}

// GetActiveFamilyMembersCount возвращает количество активных семейных участников
func (r *FamilyMemberRepo) GetActiveFamilyMembersCount(ctx context.Context, ownerUserID domain.ID) (int, error) {
	query := `
		SELECT COUNT(*)
		FROM family_members
		WHERE owner_user_id = $1 AND status = 'active'
	`

	var count int
	err := r.db.QueryRowContext(ctx, query, ownerUserID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("count family members: %w", err)
	}

	return count, nil
}

// GetPendingInvitations возвращает ожидающие приглашения
func (r *FamilyMemberRepo) GetPendingInvitations(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error) {
	query := `
		SELECT id, owner_user_id, member_user_id,
		       status, invited_at, accepted_at, expires_at,
		       added_by, created_at, updated_at
		FROM family_members
		WHERE owner_user_id = $1 AND status = 'pending'
		ORDER BY invited_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, ownerUserID)
	if err != nil {
		return nil, fmt.Errorf("query pending invitations: %w", err)
	}
	defer rows.Close()

	var members []domain.FamilyMember
	for rows.Next() {
		var member domain.FamilyMember
		var acceptedAt, expiresAt sql.NullTime
		var addedBy sql.NullInt64

		err := rows.Scan(
			&member.ID,
			&member.OwnerUserID,
			&member.MemberUserID,
			&member.Status,
			&member.InvitedAt,
			&acceptedAt,
			&expiresAt,
			&addedBy,
			&member.CreatedAt,
			&member.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan family member: %w", err)
		}

		if acceptedAt.Valid {
			member.AcceptedAt = &acceptedAt.Time
		}
		if expiresAt.Valid {
			member.ExpiresAt = &expiresAt.Time
		}
		if addedBy.Valid {
			v := int64(addedBy.Int64)
			member.AddedBy = &v
		}

		members = append(members, member)
	}

	return members, nil
}
