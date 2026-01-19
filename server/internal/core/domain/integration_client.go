package domain

import "time"

type IntegrationClient struct {
	ID ID `json:"id"`

	Slug string `json:"slug"` // уникальный код: "ozon", "wb", "partner-abc"
	Name string `json:"name"`

	IsActive bool `json:"is_active"`

	// Лимиты на уровне клиента
	RateLimitPerMinute int `json:"rate_limit_per_minute"`
	RateLimitPerDay    int `json:"rate_limit_per_day"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
