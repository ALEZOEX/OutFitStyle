package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// PersonalizationRepository интерфейс репозитория персонализации
type PersonalizationRepository interface {
	// GetUserPreferences возвращает предпочтения пользователя
	GetUserPreferences(ctx context.Context, userID domain.ID) (domain.UserPreferences, error)

	// GetRecentItems возвращает недавно взаимодействованные элементы пользователя
	GetRecentItems(ctx context.Context, userID domain.ID, limit int) ([]domain.ID, error)

	// GetRatedItems возвращает элементы, оцененные пользователем (с высокой и низкой оценкой)
	GetRatedItems(ctx context.Context, userID domain.ID, highMin int, lowMax int, limit int) (high []domain.ID, low []domain.ID, err error)

	// GetStyleDistribution возвращает распределение стилей пользователя (какие стили предпочитает)
	GetStyleDistribution(ctx context.Context, userID domain.ID, limit int) (map[string]float64, error)

	// GetItemRatingsMap возвращает карту оценок элементов для пользователя
	GetItemRatingsMap(ctx context.Context, userID domain.ID, itemIDs []domain.ID) (map[domain.ID]float64, error)
}
