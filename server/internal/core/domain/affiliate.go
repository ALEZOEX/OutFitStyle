package domain

import "time"

// AffiliateProgram структура аффилированной программы (партнера)
type AffiliateProgram struct {
	ID domain.ID `json:"id"`

	Name        string  `json:"name"`
	Code        string  `json:"code"`  // Уникальный код партнера: "ozon", "wb", "partner-abc"

	APIBaseURL           *string  `json:"api_base_url,omitempty"`
	APIKeyEncrypted      *string  `json:"api_key_encrypted,omitempty"`
	WebhookSecretEncrypted *string `json:"webhook_secret_encrypted,omitempty"`

	CommissionPercent *float64 `json:"commission_percent,omitempty"`  // Процент комиссии
	CookieDays        *int     `json:"cookie_days,omitempty"`         // Срок действия куки в днях
	AffiliateURLTemplate *string `json:"affiliate_url_template,omitempty"` // Шаблон аффилированной ссылки

	LogoURL     *string `json:"logo_url,omitempty"`
	DisplayName *string `json:"display_name,omitempty"`

	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// AffiliateClick структура аффилированного клика
type AffiliateClick struct {
	ID               ID   `json:"id"`
	UserID           *ID  `json:"user_id,omitempty"`
	PartnerID        ID   `json:"partner_id"`
	ClothingItemID   *ID  `json:"clothing_item_id,omitempty"`
	RecommendationID *ID  `json:"recommendation_id,omitempty"`

	ClickID   *string `json:"click_id,omitempty"`   // Уникальный идентификатор клика
	SessionID *string `json:"session_id,omitempty"` // Идентификатор сессии

	ClickedAt time.Time `json:"clicked_at"`

	Converted       bool        `json:"converted"`
	ConvertedAt     *time.Time  `json:"converted_at,omitempty"`
	ConversionValue *float64    `json:"conversion_value,omitempty"`
	CommissionEarned *float64   `json:"commission_earned,omitempty"`
}

// PartnerStats структура статистики партнера
type PartnerStats struct {
	TotalClicks     int     `json:"total_clicks"`
	TotalConversions int    `json:"total_conversions"`
	ConversionRate  float64 `json:"conversion_rate"`
	TotalRevenue    float64 `json:"total_revenue"`
	TotalCommission float64 `json:"total_commission"`
}

// AffiliateCommission структура комиссионных
type AffiliateCommission struct {
	ID        ID        `json:"id"`
	ClickID   string    `json:"click_id"`
	OrderID   *string   `json:"order_id,omitempty"`
	Amount    float64   `json:"amount"`
	Commission float64  `json:"commission"`
	Date      time.Time `json:"date"`
}

// UserAffiliateEarnings структура заработка пользователя по аффилированным программам
type UserAffiliateEarnings struct {
	TotalEarned     float64 `json:"total_earned"`
	TotalClicks     int     `json:"total_clicks"`
	TotalConversions int    `json:"total_conversions"`
	ConversionRate  float64 `json:"conversion_rate"`
	ActivePrograms  int     `json:"active_programs"`
}

// AffiliateLink структура аффилированной ссылки
type AffiliateLink struct {
	ID        ID        `json:"id"`
	PartnerID ID        `json:"partner_id"`
	OriginalURL string  `json:"original_url"`
	AffiliateURL string `json:"affiliate_url"`
	Clicks    int       `json:"clicks"`
	CreatedAt time.Time `json:"created_at"`
}