package domain

import (
	"encoding/json"
	"time"
)

type Notification struct {
	ID     ID `json:"id"`
	UserID ID `json:"user_id"`

	Type  string  `json:"type"`
	Title string  `json:"title"`
	Body  *string `json:"body,omitempty"`

	ImageURL *string `json:"image_url,omitempty"`

	Data json.RawMessage `json:"data,omitempty"`

	ActionType *string         `json:"action_type,omitempty"`
	ActionData json.RawMessage `json:"action_data,omitempty"`

	IsRead bool       `json:"is_read"`
	ReadAt *time.Time `json:"read_at,omitempty"`

	PushSent   bool       `json:"push_sent"`
	PushSentAt *time.Time `json:"push_sent_at,omitempty"`
	PushError  *string    `json:"push_error,omitempty"`

	CreatedAt time.Time  `json:"created_at"`
	ExpiresAt *time.Time `json:"expires_at,omitempty"`
}

type PushToken struct {
	ID       ID      `json:"id"`
	UserID   ID      `json:"user_id"`
	Token    string  `json:"token"`
	Platform string  `json:"platform"` // ios|android|web
	DeviceID *string `json:"device_id,omitempty"`

	IsActive   bool      `json:"is_active"`
	LastUsedAt time.Time `json:"last_used_at"`
	CreatedAt  time.Time `json:"created_at"`
}

type RegisterPushTokenRequest struct {
	Token    string  `json:"token"`
	Platform string  `json:"platform"`
	DeviceID *string `json:"device_id,omitempty"`
}

type DeletePushTokenRequest struct {
	Token string `json:"token"`
}
