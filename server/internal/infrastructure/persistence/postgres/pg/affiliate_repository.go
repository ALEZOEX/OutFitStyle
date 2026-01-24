package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/domain"
)

// AffiliateRepository реализация репозитория аффилированных программ
type AffiliateRepository struct {
	db *pgxpool.Pool
}

// NewAffiliateRepository создает новый экземпляр репозитория аффилированных программ
func NewAffiliateRepository(db *pgxpool.Pool) *AffiliateRepository {
	return &AffiliateRepository{db: db}
}

// RecordClick регистрирует аффилированный клик
func (r *AffiliateRepository) RecordClick(ctx context.Context, click *domain.AffiliateClick) error {
	query := `
		INSERT INTO affiliate_clicks (
			user_id, partner_id, clothing_item_id, recommendation_id,
			click_id, session_id, clicked_at, converted
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	_, err := r.db.Exec(ctx, query,
		click.UserID,
		click.PartnerID,
		click.ClothingItemID,
		click.RecommendationID,
		click.ClickID,
		click.SessionID,
		click.ClickedAt,
		click.Converted,
	)
	return err
}

// GetClickByClickID возвращает аффилированный клик по идентификатору
func (r *AffiliateRepository) GetClickByClickID(ctx context.Context, clickID string) (*domain.AffiliateClick, error) {
	query := `
		SELECT id, user_id, partner_id, clothing_item_id, recommendation_id,
		       click_id, session_id, clicked_at, converted, converted_at,
		       conversion_value, commission_earned
		FROM affiliate_clicks
		WHERE click_id = $1
	`

	row := r.db.QueryRow(ctx, query, clickID)

	var ac domain.AffiliateClick
	var userID, clothingItemID, recommendationID *domain.ID
	var clickIDPtr, sessionID *string
	var convertedAt *time.Time
	var conversionValue, commissionEarned *float64

	err := row.Scan(
		&ac.ID,
		&userID,
		&ac.PartnerID,
		&clothingItemID,
		&recommendationID,
		&clickIDPtr,
		&sessionID,
		&ac.ClickedAt,
		&ac.Converted,
		&convertedAt,
		&conversionValue,
		&commissionEarned,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	ac.UserID = userID
	ac.ClothingItemID = clothingItemID
	ac.RecommendationID = recommendationID
	ac.ClickID = clickIDPtr
	ac.SessionID = sessionID
	ac.ConvertedAt = convertedAt
	ac.ConversionValue = conversionValue
	ac.CommissionEarned = commissionEarned

	return &ac, nil
}

// UpdateClick обновляет информацию о клике
func (r *AffiliateRepository) UpdateClick(ctx context.Context, click *domain.AffiliateClick) error {
	query := `
		UPDATE affiliate_clicks
		SET converted = $1, converted_at = $2, conversion_value = $3, commission_earned = $4
		WHERE id = $5
	`

	_, err := r.db.Exec(ctx, query,
		click.Converted,
		click.ConvertedAt,
		click.ConversionValue,
		click.CommissionEarned,
		click.ID,
	)
	return err
}

// GetPartnerStats возвращает статистику партнера
func (r *AffiliateRepository) GetPartnerStats(ctx context.Context, partnerID domain.ID, startDate, endDate time.Time) (*domain.PartnerStats, error) {
	query := `
		SELECT
			COUNT(*) as total_clicks,
			COUNT(CASE WHEN converted THEN 1 END) as total_conversions,
			COALESCE(SUM(conversion_value), 0) as total_revenue,
			COALESCE(SUM(commission_earned), 0) as total_commission
		FROM affiliate_clicks
		WHERE partner_id = $1 AND clicked_at BETWEEN $2 AND $3
	`

	var stats domain.PartnerStats
	err := r.db.QueryRow(ctx, query, partnerID, startDate, endDate).Scan(
		&stats.TotalClicks,
		&stats.TotalConversions,
		&stats.TotalRevenue,
		&stats.TotalCommission,
	)
	if err != nil {
		return nil, err
	}

	if stats.TotalClicks > 0 {
		stats.ConversionRate = float64(stats.TotalConversions) / float64(stats.TotalClicks) * 100
	}

	return &stats, nil
}

// GetPartnerCommissions возвращает комиссионные партнера
func (r *AffiliateRepository) GetPartnerCommissions(ctx context.Context, partnerID domain.ID, startDate, endDate time.Time) ([]domain.AffiliateCommission, error) {
	query := `
		SELECT id, click_id, NULL as order_id, COALESCE(conversion_value, 0) as amount,
		       COALESCE(commission_earned, 0) as commission, clicked_at
		FROM affiliate_clicks
		WHERE partner_id = $1 AND converted = true AND clicked_at BETWEEN $2 AND $3
		ORDER BY clicked_at DESC
	`

	rows, err := r.db.Query(ctx, query, partnerID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var commissions []domain.AffiliateCommission
	for rows.Next() {
		var c domain.AffiliateCommission
		var amount, commission float64
		var date time.Time

		err := rows.Scan(&c.ID, &c.ClickID, &c.OrderID, &amount, &commission, &date)
		if err != nil {
			return nil, err
		}

		c.Amount = amount
		c.Commission = commission
		c.Date = date

		commissions = append(commissions, c)
	}

	return commissions, nil
}

// GetUserEarnings возвращает заработок пользователя по аффилированным программам
func (r *AffiliateRepository) GetUserEarnings(ctx context.Context, userID domain.ID) (*domain.UserAffiliateEarnings, error) {
	query := `
		SELECT
			COUNT(ac.id) as total_clicks,
			COUNT(CASE WHEN ac.converted THEN 1 END) as total_conversions,
			COALESCE(SUM(ac.commission_earned), 0) as total_earned,
			COUNT(DISTINCT ap.id) as active_programs
		FROM affiliate_clicks ac
		JOIN partners ap ON ac.partner_id = ap.id
		WHERE ac.user_id = $1
	`

	var earnings domain.UserAffiliateEarnings
	err := r.db.QueryRow(ctx, query, userID).Scan(
		&earnings.TotalClicks,
		&earnings.TotalConversions,
		&earnings.TotalEarned,
		&earnings.ActivePrograms,
	)
	if err != nil {
		return nil, err
	}

	if earnings.TotalClicks > 0 {
		earnings.ConversionRate = float64(earnings.TotalConversions) / float64(earnings.TotalClicks) * 100
	}

	return &earnings, nil
}

// GetUserAffiliateLinks возвращает аффилированные ссылки пользователя
func (r *AffiliateRepository) GetUserAffiliateLinks(ctx context.Context, userID domain.ID) ([]domain.AffiliateLink, error) {
	// В текущей реализации мы возвращаем статистику кликов по партнерам
	// В реальной системе здесь будет более сложная логика для отслеживания конкретных ссылок

	query := `
		SELECT
			ap.id,
			ap.name,
			COUNT(ac.id) as clicks
		FROM partners ap
		LEFT JOIN affiliate_clicks ac ON ap.id = ac.partner_id
		WHERE ac.user_id = $1
		GROUP BY ap.id, ap.name
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var links []domain.AffiliateLink
	for rows.Next() {
		var link domain.AffiliateLink
		var partnerName string
		var clicks int

		err := rows.Scan(&link.ID, &partnerName, &clicks)
		if err != nil {
			return nil, err
		}

		link.PartnerID = link.ID
		link.Clicks = clicks
		link.CreatedAt = time.Now() // В реальной системе это будет дата создания ссылки

		links = append(links, link)
	}

	return links, nil
}

// PartnerRepository реализация репозитория партнеров
type PartnerRepository struct {
	db *pgxpool.Pool
}

// NewPartnerRepository создает новый экземпляр репозитория партнеров
func NewPartnerRepository(db *pgxpool.Pool) *PartnerRepository {
	return &PartnerRepository{db: db}
}

// GetByID возвращает партнера по идентификатору
func (r *PartnerRepository) GetByID(ctx context.Context, id domain.ID) (*domain.AffiliateProgram, error) {
	query := `
		SELECT id, name, code, api_base_url, api_key_encrypted, webhook_secret_encrypted,
		       commission_percent, cookie_days, affiliate_url_template, logo_url, display_name,
		       is_active, created_at, updated_at
		FROM partners
		WHERE id = $1
	`

	var p domain.AffiliateProgram
	var apiBaseURL, apiKey, webhookSecret, affiliateURLTemplate, logoURL, displayName *string
	var commissionPercent *float64
	var cookieDays *int

	err := r.db.QueryRow(ctx, query, id).Scan(
		&p.ID,
		&p.Name,
		&p.Code,
		&apiBaseURL,
		&apiKey,
		&webhookSecret,
		&commissionPercent,
		&cookieDays,
		&affiliateURLTemplate,
		&logoURL,
		&displayName,
		&p.IsActive,
		&p.CreatedAt,
		&p.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	p.APIBaseURL = apiBaseURL
	p.APIKeyEncrypted = apiKey
	p.WebhookSecretEncrypted = webhookSecret
	p.CommissionPercent = commissionPercent
	p.CookieDays = cookieDays
	p.AffiliateURLTemplate = affiliateURLTemplate
	p.LogoURL = logoURL
	p.DisplayName = displayName

	return &p, nil
}

// Create создает нового партнера
func (r *PartnerRepository) Create(ctx context.Context, partner *domain.AffiliateProgram) error {
	if partner.ID == "" {
		partner.ID = domain.NewID()
	}

	query := `
		INSERT INTO partners (
			id, name, code, api_base_url, api_key_encrypted, webhook_secret_encrypted,
			commission_percent, cookie_days, affiliate_url_template, logo_url, display_name,
			is_active, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
	`

	_, err := r.db.Exec(ctx, query,
		partner.ID,
		partner.Name,
		partner.Code,
		partner.APIBaseURL,
		partner.APIKeyEncrypted,
		partner.WebhookSecretEncrypted,
		partner.CommissionPercent,
		partner.CookieDays,
		partner.AffiliateURLTemplate,
		partner.LogoURL,
		partner.DisplayName,
		partner.IsActive,
		partner.CreatedAt,
		partner.UpdatedAt,
	)
	return err
}

// Update обновляет информацию о партнере
func (r *PartnerRepository) Update(ctx context.Context, partner *domain.AffiliateProgram) error {
	query := `
		UPDATE partners SET
			name = $1, code = $2, api_base_url = $3, api_key_encrypted = $4,
			webhook_secret_encrypted = $5, commission_percent = $6, cookie_days = $7,
			affiliate_url_template = $8, logo_url = $9, display_name = $10,
			is_active = $11, updated_at = $12
		WHERE id = $13
	`

	_, err := r.db.Exec(ctx, query,
		partner.Name,
		partner.Code,
		partner.APIBaseURL,
		partner.APIKeyEncrypted,
		partner.WebhookSecretEncrypted,
		partner.CommissionPercent,
		partner.CookieDays,
		partner.AffiliateURLTemplate,
		partner.LogoURL,
		partner.DisplayName,
		partner.IsActive,
		time.Now(),
		partner.ID,
	)
	return err
}

// List возвращает список партнеров
func (r *PartnerRepository) List(ctx context.Context, activeOnly bool) ([]domain.AffiliateProgram, error) {
	query := `SELECT id, name, code, api_base_url, api_key_encrypted, webhook_secret_encrypted,
	                 commission_percent, cookie_days, affiliate_url_template, logo_url, display_name,
	                 is_active, created_at, updated_at
	          FROM partners`

	if activeOnly {
		query += " WHERE is_active = true"
	}
	query += " ORDER BY name"

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var partners []domain.AffiliateProgram
	for rows.Next() {
		var p domain.AffiliateProgram
		var apiBaseURL, apiKey, webhookSecret, affiliateURLTemplate, logoURL, displayName *string
		var commissionPercent *float64
		var cookieDays *int

		err := rows.Scan(
			&p.ID,
			&p.Name,
			&p.Code,
			&apiBaseURL,
			&apiKey,
			&webhookSecret,
			&commissionPercent,
			&cookieDays,
			&affiliateURLTemplate,
			&logoURL,
			&displayName,
			&p.IsActive,
			&p.CreatedAt,
			&p.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		p.APIBaseURL = apiBaseURL
		p.APIKeyEncrypted = apiKey
		p.WebhookSecretEncrypted = webhookSecret
		p.CommissionPercent = commissionPercent
		p.CookieDays = cookieDays
		p.AffiliateURLTemplate = affiliateURLTemplate
		p.LogoURL = logoURL
		p.DisplayName = displayName

		partners = append(partners, p)
	}

	return partners, nil
}
