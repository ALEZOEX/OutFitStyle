package domain

import "time"

type Achievement struct {
	ID          ID         `json:"id"`
	Code        string     `json:"code"`
	Name        string     `json:"name"`
	Description string     `json:"description"`
	IconEmoji   string     `json:"icon_emoji"`
	Points      int        `json:"points"`
	UnlockedAt  *time.Time `json:"unlocked_at,omitempty"`
	Progress    int        `json:"progress,omitempty"`
}
