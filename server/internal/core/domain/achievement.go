package domain

import "time"

type AchievementStatus string

const (
	AchievementStatusLocked AchievementStatus = "locked"
	AchievementStatusUnlocked AchievementStatus = "unlocked"
	AchievementStatusInProgress AchievementStatus = "in_progress"
)

type AchievementProgress struct {
	Current int `json:"current"`
	Target  int `json:"target"`
}

type UserAchievement struct {
	ID             ID                  `json:"id"`
	UserID         ID                  `json:"user_id"`
	AchievementID  ID                  `json:"achievement_id"`
	Code           string              `json:"code"`
	Status         AchievementStatus   `json:"status"`
	Progress       int                 `json:"progress"`
	UnlockedAt     *time.Time          `json:"unlocked_at,omitempty"`
	CreatedAt      time.Time           `json:"created_at"`
	UpdatedAt      time.Time           `json:"updated_at"`
}

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
