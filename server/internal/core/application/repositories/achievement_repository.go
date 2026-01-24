package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// AchievementRepository интерфейс репозитория достижений
type AchievementRepository interface {
	// ListAll возвращает все возможные достижения в системе
	ListAll(ctx context.Context) ([]domain.Achievement, error)

	// ListMy возвращает достижения пользователя: полученные, в процессе и общее количество баллов
	// unlocked - список разблокированных достижений
	// inProgress - список достижений в процессе выполнения
	// totalPoints - общее количество баллов пользователя
	ListMy(ctx context.Context, userID domain.ID) (unlocked []domain.Achievement, inProgress []domain.Achievement, totalPoints int, err error)
}
