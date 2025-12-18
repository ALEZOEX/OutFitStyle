package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

type AdminStats struct {
	UsersTotal           int     `json:"users_total"`
	RecommendationsTotal int     `json:"recommendations_total"`
	WardrobeTotal        int     `json:"wardrobe_total"`
	PaymentsTotal        int     `json:"payments_total"`
	PaymentsRevenue      float64 `json:"payments_revenue_completed"`
	ActiveSubscriptions  int     `json:"active_subscriptions"`
	NotificationsTotal   int     `json:"notifications_total"`
}

type AdminUserRow struct {
	ID          domain.ID  `json:"id"`
	Email       string     `json:"email"`
	DisplayName *string    `json:"display_name,omitempty"`
	IsActive    bool       `json:"is_active"`
	IsVerified  bool       `json:"is_verified"`
	CreatedAt   time.Time  `json:"created_at"`
	LastLoginAt *time.Time `json:"last_login_at,omitempty"`
}

type AuditRow struct {
	ID          domain.ID  `json:"id"`
	UserID      *domain.ID `json:"user_id,omitempty"`
	Action      string     `json:"action"`
	ResourceType *string   `json:"resource_type,omitempty"`
	ResourceID  *domain.ID `json:"resource_id,omitempty"`
	IP          *string    `json:"ip_address,omitempty"`
	Success     bool       `json:"success"`
	ErrorMessage *string   `json:"error_message,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
}

type CreatePromoRequest struct {
	Code          string   `json:"code"`
	DiscountType  string   `json:"discount_type"` // percent|fixed|trial_days
	DiscountValue float64  `json:"discount_value"`
	ApplicablePlans []domain.ID `json:"applicable_plans,omitempty"`
	MaxUses       *int     `json:"max_uses,omitempty"`
	ValidUntil    *time.Time `json:"valid_until,omitempty"`
	IsActive      *bool    `json:"is_active,omitempty"`
}

type AdminRepository interface {
	Stats(ctx context.Context) (AdminStats, error)
	ListUsers(ctx context.Context, page, limit int) ([]AdminUserRow, int, error)
	ListAudit(ctx context.Context, page, limit int) ([]AuditRow, int, error)

	CreatePromo(ctx context.Context, createdBy *domain.ID, req CreatePromoRequest) (domain.ID, error)
}