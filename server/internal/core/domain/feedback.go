package domain

import "time"

type Feedback struct {
	ID          ID        `json:"id"`
	UserID      ID        `json:"user_id"`
	Type        string    `json:"type"` // bug, suggestion, general
	Message     string    `json:"message"`
	Rating      *int      `json:"rating,omitempty"` // 1-5 stars
	Metadata    any       `json:"metadata,omitempty"`
	IsResolved  bool      `json:"is_resolved"`
	ResolvedAt  *time.Time `json:"resolved_at,omitempty"`
	ResolvedBy  *ID       `json:"resolved_by,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}