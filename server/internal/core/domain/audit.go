package domain

import "time"

type AuditEvent struct {
	ID          ID        `json:"id"`
	Action      string    `json:"action"`
	EntityID    string    `json:"entity_id"`
	EntityType  string    `json:"entity_type"`
	UserID      *ID       `json:"user_id,omitempty"`
	IPAddress   string    `json:"ip_address"`
	UserAgent   string    `json:"user_agent"`
	OldValues   any       `json:"old_values"`
	NewValues   any       `json:"new_values"`
	CreatedAt   time.Time `json:"created_at"`
}