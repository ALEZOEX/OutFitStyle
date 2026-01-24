package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// AchievementDef представляет определение достижения
type AchievementDef struct {
	ID             domain.ID // Уникальный идентификатор достижения
	Code           string    // Код достижения (уникальный идентификатор в виде строки)
	ConditionType  string    // Тип условия (например, "items_added", "outfits_created")
	ConditionValue int       // Значение условия (например, 10 для "добавить 10 вещей")
	Points         int       // Количество баллов за достижение
}

// AchievementEngineRepository интерфейс репозитория движка достижений
type AchievementEngineRepository interface {
	// ListActiveDefinitions возвращает список активных определений достижений
	ListActiveDefinitions(ctx context.Context) ([]AchievementDef, error)

	// ListUnlockedCodes возвращает набор уже разблокированных кодов достижений для пользователя
	ListUnlockedCodes(ctx context.Context, userID domain.ID) (map[string]bool, error)

	// UpsertProgress обновляет или создает прогресс по достижению для пользователя
	// Если unlock равно true, значит достижение было разблокировано
	UpsertProgress(ctx context.Context, userID domain.ID, achievementID domain.ID, progress int, unlock bool) error
}
