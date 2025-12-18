package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type AchievementDef struct {
	ID             domain.ID
	Code           string
	ConditionType  string
	ConditionValue int
	Points         int
}

type AchievementEngineRepository interface {
	ListActiveDefinitions(ctx context.Context) ([]AchievementDef, error)

	// returns set of already unlocked codes
	ListUnlockedCodes(ctx context.Context, userID domain.ID) (map[string]bool, error)

	UpsertProgress(ctx context.Context, userID domain.ID, achievementID domain.ID, progress int, unlock bool) error
}