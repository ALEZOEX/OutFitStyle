package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

// SavedOutfitRepository интерфейс репозитория сохраненных нарядов
type SavedOutfitRepository interface {
	// List возвращает список сохраненных нарядов пользователя
	List(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error)

	// Create создает новый сохраненный наряд
	Create(ctx context.Context, userID domain.ID, req domain.SavedOutfitCreateRequest) (*domain.SavedOutfit, error)

	// Get возвращает сохраненный наряд по идентификатору
	Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error)

	// Update обновляет сохраненный наряд
	Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.SavedOutfitUpdateRequest) (*domain.SavedOutfit, error)

	// Delete удаляет сохраненный наряд
	Delete(ctx context.Context, userID domain.ID, id domain.ID) error

	// MarkWorn отмечает наряд как надетый
	MarkWorn(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error)
}
