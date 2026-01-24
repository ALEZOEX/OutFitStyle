package domain

import "time"

// AffiliateProgram структура аффилированной программы (партнера)
type AffiliateProgram struct {
	ID ID `json:"id"` // Уникальный идентификатор аффилированной программы

	Name        string  `json:"name"`        // Название партнера
	Code        string  `json:"code"`        // Уникальный код партнера: "ozon", "wb", "partner-abc"

	APIBaseURL           *string  `json:"api_base_url,omitempty"`           // Базовый URL для API партнера
	APIKeyEncrypted      *string  `json:"api_key_encrypted,omitempty"`      // Зашифрованный API-ключ партнера
	WebhookSecretEncrypted *string `json:"webhook_secret_encrypted,omitempty"` // Зашифрованный секретный ключ вебхука

	CommissionPercent *float64 `json:"commission_percent,omitempty"`  // Процент комиссии
	CookieDays        *int     `json:"cookie_days,omitempty"`         // Срок действия куки в днях
	AffiliateURLTemplate *string `json:"affiliate_url_template,omitempty"` // Шаблон аффилированной ссылки

	LogoURL     *string `json:"logo_url,omitempty"`     // URL логотипа партнера
	DisplayName *string `json:"display_name,omitempty"` // Отображаемое имя партнера

	IsActive  bool      `json:"is_active"`   // Активен ли партнер
	CreatedAt time.Time `json:"created_at"`  // Дата создания записи
	UpdatedAt time.Time `json:"updated_at"`  // Дата последнего обновления
}

// AffiliateClick структура аффилированного клика
type AffiliateClick struct {
	ID               ID   `json:"id"`                           // Уникальный идентификатор клика
	UserID           *ID  `json:"user_id,omitempty"`            // Идентификатор пользователя (если авторизован)
	PartnerID        ID   `json:"partner_id"`                   // Идентификатор партнера
	ClothingItemID   *ID  `json:"clothing_item_id,omitempty"`   // Идентификатор элемента одежды (если клик по конкретной вещи)
	RecommendationID *ID  `json:"recommendation_id,omitempty"`  // Идентификатор рекомендации (если клик по рекомендации)

	ClickID   *string `json:"click_id,omitempty"`   // Уникальный идентификатор клика от партнера
	SessionID *string `json:"session_id,omitempty"` // Идентификатор сессии пользователя

	ClickedAt time.Time `json:"clicked_at"`         // Время клика

	Converted       bool        `json:"converted"`              // Совершена ли конверсия
	ConvertedAt     *time.Time  `json:"converted_at,omitempty"` // Время конверсии
	ConversionValue *float64    `json:"conversion_value,omitempty"` // Стоимость конверсии
	CommissionEarned *float64   `json:"commission_earned,omitempty"` // Заработанная комиссия
}

// PartnerStats структура статистики партнера
type PartnerStats struct {
	TotalClicks     int     `json:"total_clicks"`      // Общее количество кликов
	TotalConversions int    `json:"total_conversions"`  // Общее количество конверсий
	ConversionRate  float64 `json:"conversion_rate"`   // Процент конверсий
	TotalRevenue    float64 `json:"total_revenue"`     // Общий доход
	TotalCommission float64 `json:"total_commission"`  // Общая комиссия
}

// AffiliateCommission структура комиссионных
type AffiliateCommission struct {
	ID        ID        `json:"id"`                    // Уникальный идентификатор комиссии
	ClickID   string    `json:"click_id"`              // Идентификатор клика
	OrderID   *string   `json:"order_id,omitempty"`    // Идентификатор заказа (если есть)
	Amount    float64   `json:"amount"`                // Сумма заказа
	Commission float64  `json:"commission"`            // Размер комиссии
	Date      time.Time `json:"date"`                  // Дата начисления комиссии
}

// UserAffiliateEarnings структура заработка пользователя по аффилированным программам
type UserAffiliateEarnings struct {
	TotalEarned     float64 `json:"total_earned"`      // Общий заработок пользователя
	TotalClicks     int     `json:"total_clicks"`      // Общее количество кликов пользователя
	TotalConversions int    `json:"total_conversions"`  // Общее количество конверсий пользователя
	ConversionRate  float64 `json:"conversion_rate"`   // Процент конверсий пользователя
	ActivePrograms  int     `json:"active_programs"`   // Количество активных аффилированных программ
}

// AffiliateLink структура аффилированной ссылки
type AffiliateLink struct {
	ID        ID        `json:"id"`                    // Уникальный идентификатор аффилированной ссылки
	PartnerID ID        `json:"partner_id"`            // Идентификатор партнера
	OriginalURL string  `json:"original_url"`          // Оригинальный URL
	AffiliateURL string `json:"affiliate_url"`         // Аффилированный URL
	Clicks    int       `json:"clicks"`                // Количество переходов по ссылке
	CreatedAt time.Time `json:"created_at"`            // Дата создания ссылки
}