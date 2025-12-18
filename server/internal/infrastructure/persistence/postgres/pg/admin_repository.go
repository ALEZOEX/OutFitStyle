package pg

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type AdminRepository struct {
	db *dbpkg.DB
}

func NewAdminRepository(db *dbpkg.DB) repositories.AdminRepository {
	return &AdminRepository{db: db}
}

func (r *AdminRepository) Stats(ctx context.Context) (repositories.AdminStats, error) {
	var s repositories.AdminStats

	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM users`).Scan(&s.UsersTotal); err != nil {
		return s, errors.Wrap(err, "users count")
	}
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM recommendations`).Scan(&s.RecommendationsTotal); err != nil {
		return s, errors.Wrap(err, "recommendations count")
	}
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM user_wardrobe`).Scan(&s.WardrobeTotal); err != nil {
		return s, errors.Wrap(err, "wardrobe count")
	}
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM payments`).Scan(&s.PaymentsTotal); err != nil {
		return s, errors.Wrap(err, "payments count")
	}
	_ = r.db.Pool().QueryRow(ctx, `SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='completed'`).Scan(&s.PaymentsRevenue)
	_ = r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM user_subscriptions WHERE status IN ('active','trialing')`).Scan(&s.ActiveSubscriptions)
	_ = r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM notifications`).Scan(&s.NotificationsTotal)

	return s, nil
}

func (r *AdminRepository) ListUsers(ctx context.Context, page, limit int) ([]repositories.AdminUserRow, int, error) {
	if limit <= 0 { limit = 50 }
	if limit > 200 { limit = 200 }
	if page <= 0 { page = 1 }
	offset := (page - 1) * limit

	var total int
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM users`).Scan(&total); err != nil {
		return nil, 0, errors.Wrap(err, "count users")
	}

	rows, err := r.db.Pool().Query(ctx, `
SELECT id, email, display_name, is_active, is_verified, created_at, last_login_at
FROM users
ORDER BY created_at DESC
LIMIT $1 OFFSET $2
`, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "list users")
	}
	defer rows.Close()

	out := []repositories.AdminUserRow{}
	for rows.Next() {
		var u repositories.AdminUserRow
		if err := rows.Scan(&u.ID, &u.Email, &u.DisplayName, &u.IsActive, &u.IsVerified, &u.CreatedAt, &u.LastLoginAt); err != nil {
			return nil, 0, errors.Wrap(err, "scan user")
		}
		out = append(out, u)
	}
	return out, total, rows.Err()
}

func (r *AdminRepository) ListAudit(ctx context.Context, page, limit int) ([]repositories.AuditRow, int, error) {
	if limit <= 0 { limit = 50 }
	if limit > 200 { limit = 200 }
	if page <= 0 { page = 1 }
	offset := (page - 1) * limit

	var total int
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM audit_logs`).Scan(&total); err != nil {
		return nil, 0, errors.Wrap(err, "count audit")
	}

	rows, err := r.db.Pool().Query(ctx, `
SELECT id, user_id, action, resource_type, resource_id, ip_address::text, success, error_message, created_at
FROM audit_logs
ORDER BY created_at DESC
LIMIT $1 OFFSET $2
`, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "list audit")
	}
	defer rows.Close()

	out := []repositories.AuditRow{}
	for rows.Next() {
		var a repositories.AuditRow
		if err := rows.Scan(&a.ID, &a.UserID, &a.Action, &a.ResourceType, &a.ResourceID, &a.IP, &a.Success, &a.ErrorMessage, &a.CreatedAt); err != nil {
			return nil, 0, errors.Wrap(err, "scan audit")
		}
		out = append(out, a)
	}
	return out, total, rows.Err()
}

func (r *AdminRepository) CreatePromo(ctx context.Context, createdBy *domain.ID, req repositories.CreatePromoRequest) (domain.ID, error) {
	if req.Code == "" || req.DiscountType == "" {
		return domain.ID{}, errors.New("code and discount_type are required")
	}

	active := true
	if req.IsActive != nil {
		active = *req.IsActive
	}

	var id domain.ID
	err := r.db.Pool().QueryRow(ctx, `
INSERT INTO promo_codes (
code, discount_type, discount_value,
applicable_plans, max_uses, valid_until,
is_active, created_by
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
RETURNING id
`, req.Code, req.DiscountType, req.DiscountValue, req.ApplicablePlans, req.MaxUses, req.ValidUntil, active, createdBy).Scan(&id)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "create promo")
	}
	return id, nil
}