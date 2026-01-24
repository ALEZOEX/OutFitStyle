package domain

import "time"

type Session struct {
	ID               ID        `json:"id"`
	UserID           ID        `json:"user_id"`
	RefreshTokenHash string    `json:"-"` // не передаем в JSON
	DeviceInfo     *string   `json:"device_info,omitempty"`
	IPAddress      *string   `json:"ip_address,omitempty"`
	UserAgent      *string   `json:"user_agent,omitempty"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
	ExpiresAt      time.Time `json:"expires_at"`
	LastUsedAt     time.Time `json:"last_used_at"`
}