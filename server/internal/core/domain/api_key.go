package domain

import "time"

type APIKey struct {
	ID ID `json:"id"`

	ClientID ID `json:"client_id"` // Владелец ключа (партнёр)

	KeyPrefix   string  `json:"key_prefix"`
	Name        *string `json:"name,omitempty"`
	Description *string `json:"description,omitempty"`

	Permissions []string `json:"permissions,omitempty"`

	// Лимиты на уровне клиента, а не ключа
	RateLimitPerMinute int `json:"rate_limit_per_minute"`
	RateLimitPerDay    int `json:"rate_limit_per_day"`

	IsActive bool `json:"is_active"`

	LastUsedAt *time.Time `json:"last_used_at,omitempty"`
	ExpiresAt  *time.Time `json:"expires_at,omitempty"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Добавляем поле для хэша ключа
	KeyHash []byte `json:"-"` // Не передаем в JSON, так как это чувствительная информация
}

type APIKeyCreateRequest struct {
	Name        *string  `json:"name,omitempty"`
	Description *string  `json:"description,omitempty"`
	Permissions []string `json:"permissions,omitempty"`
	ClientID    ID       `json:"client_id"` // Владелец ключа
}

type APIKeyCreateResponse struct {
	APIKey APIKey `json:"api_key"`
	Token  string `json:"token"`
}

type APIKeyListResponse struct {
	Keys []APIKey `json:"keys"`
}
