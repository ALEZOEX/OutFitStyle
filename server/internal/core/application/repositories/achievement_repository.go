package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type AchievementRepository interface {
	ListAll(ctx context.Context) ([]domain.Achievement, error)
	ListMy(ctx context.Context, userID domain.ID) (unlocked []domain.Achievement, inProgress []domain.Achievement, totalPoints int, err error)
}