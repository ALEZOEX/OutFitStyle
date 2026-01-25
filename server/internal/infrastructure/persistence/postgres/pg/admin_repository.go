// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
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

// AdminRepository репозиторий для административных функций
type AdminRepository struct {
	db *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
}

// NewAdminRepository создает новый экземпляр репозитория администратора
func NewAdminRepository(db *pgxpool.Pool) *AdminRepository {
	return &AdminRepository{db: db}
}

// Stats возвращает статистику приложения для администратора
// Включает информацию о пользователях, рекомендациях, платежах и других метриках
func (r *AdminRepository) Stats(ctx context.Context) (repositories.AdminStats, error) {
	query := `
		SELECT
			(SELECT COUNT(*) FROM users) as total_users,
			(SELECT COUNT(*) FROM users WHERE last_login_at >= NOW() - INTERVAL '30 days') as active_users,
			(SELECT COUNT(*) FROM recommendations) as total_recommendations,
			(SELECT COUNT(*) FROM saved_outfits) as total_outfits_saved,
			(SELECT COUNT(*) FROM user_wardrobe) as total_wardrobe_items,
			(SELECT COUNT(*) FROM user_achievements WHERE status = 'unlocked') as total_achievements,
			(SELECT COUNT(*) FROM billing_transactions) as total_payments,
			(SELECT COUNT(*) FROM support_tickets) as total_support_tickets,
			(SELECT COUNT(*) FROM feedback) as total_feedback
	`

	var stats repositories.AdminStats
	err := r.db.QueryRow(ctx, query).Scan(
		&stats.TotalUsers,
		&stats.ActiveUsers,
		&stats.TotalRecommendations,
		&stats.TotalOutfitsSaved,
		&stats.TotalWardrobeItems,
		&stats.TotalAchievements,
		&stats.TotalPayments,
		&stats.TotalSupportTickets,
		&stats.TotalFeedback,
	)
	if err != nil {
		return repositories.AdminStats{}, errors.Wrap(err, "failed to get admin stats")
	}

	return stats, nil
}

// ListUsers возвращает список пользователей с пагинацией
// Используется администратором для просмотра списка пользователей
func (r *AdminRepository) ListUsers(ctx context.Context, page, limit int) ([]repositories.AdminUserRow, int, error) {
	offset := (page - 1) * limit

	// Query for users with pagination
	query := `
		SELECT
			id, email, display_name, is_active, is_verified, created_at, last_login_at
		FROM users
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2
	`

	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query users")
	}
	defer rows.Close()

	var users []repositories.AdminUserRow
	for rows.Next() {
		var user repositories.AdminUserRow
		var displayName *string
		var lastLoginAt *time.Time
		var createdAt time.Time

		err := rows.Scan(
			&user.ID,
			&user.Email,
			&displayName,
			&user.IsActive,
			&user.IsVerified,
			&createdAt,
			&lastLoginAt,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan user")
		}

		// Set nullable fields
		user.DisplayName = displayName
		user.CreatedAt = createdAt
		user.LastLoginAt = lastLoginAt

		users = append(users, user)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM users`
	var totalCount int
	err = r.db.QueryRow(ctx, countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count users")
	}

	return users, totalCount, nil
}

// ListAudit возвращает журнал аудита с пагинацией
// Используется администратором для отслеживания действий пользователей
func (r *AdminRepository) ListAudit(ctx context.Context, page, limit int) ([]repositories.AuditRow, int, error) {
	offset := (page - 1) * limit

	// Query for audit logs with pagination
	query := `
		SELECT
			id, user_id, action, entity_id, entity_type, created_at
		FROM audit_log
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2
	`

	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query audit logs")
	}
	defer rows.Close()

	var audits []repositories.AuditRow
	for rows.Next() {
		var audit repositories.AuditRow
		var userID *uuid.UUID
		var createdAt time.Time

		err := rows.Scan(
			&audit.ID,
			&userID,
			&audit.Action,
			&audit.EntityID,
			&audit.EntityType,
			&createdAt,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan audit log")
		}

		// Set nullable fields
		if userID != nil {
			uid := domain.ID(*userID)
			audit.UserID = &uid
		}
		audit.CreatedAt = createdAt

		audits = append(audits, audit)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM audit_log`
	var totalCount int
	err = r.db.QueryRow(ctx, countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count audit logs")
	}

	return audits, totalCount, nil
}

// CreatePromo создает новую промо-акцию
// Используется администратором для создания скидочных кодов и акций
func (r *AdminRepository) CreatePromo(ctx context.Context, createdBy *domain.ID, req repositories.CreatePromoRequest) (domain.ID, error) {
	id := domain.NewID()
	now := time.Now()

	query := `
		INSERT INTO promo_codes (
			id, code, type, value, currency, min_order_amount, max_discount,
			usage_limit, usage_limit_per_user, start_date, end_date, is_active, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
	`

	var createdByUUID *uuid.UUID
	if createdBy != nil {
		uid := uuid.UUID(*createdBy)
		createdByUUID = &uid
	}

	_, err := r.db.Exec(ctx, query,
		id,
		req.Code,
		req.Type,
		req.Value,
		req.Currency,
		req.MinOrderAmount,
		req.MaxDiscount,
		req.UsageLimit,
		req.UsageLimitPerUser,
		req.StartDate,
		req.EndDate,
		req.IsActive,
		createdByUUID,
		now,
		now,
	)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to create promo code")
	}

	return id, nil
}
