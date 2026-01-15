package domain

import "time"

type APIKey struct {
	ID ID `json:"id"`

	KeyPrefix   string  `json:"key_prefix"`
	Name        *string `json:"name,omitempty"`
	Description *string `json:"description,omitempty"`

	Permissions    []string `json:"permissions,omitempty"`
	AllowedOrigins []string `json:"allowed_origins,omitempty"`

	RateLimitPerMinute int `json:"rate_limit_per_minute"`
	RateLimitPerDay    int `json:"rate_limit_per_day"`

	IsActive bool `json:"is_active"`

	LastUsedAt *time.Time `json:"last_used_at,omitempty"`
	ExpiresAt  *time.Time `json:"expires_at,omitempty"`

	CreatedAt time.Time `json:"created_at"`
}

type APIKeyCreateRequest struct {
	Name           *string  `json:"name,omitempty"`
	Description    *string  `json:"description,omitempty"`
	Permissions    []string `json:"permissions,omitempty"`
	AllowedOrigins []string `json:"allowed_origins,omitempty"`

	RateLimitPerMinute *int `json:"rate_limit_per_minute,omitempty"`
	RateLimitPerDay    *int `json:"rate_limit_per_day,omitempty"`
}

type APIKeyCreateResponse struct {
	APIKey APIKey `json:"api_key"`
	Token  string `json:"token"` // показываем только 1 раз
}

type APIKeyListResponse struct {
	Keys []APIKey `json:"keys"`
}
