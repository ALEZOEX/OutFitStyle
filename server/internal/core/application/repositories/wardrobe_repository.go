package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// WardrobeRepository интерфейс репозитория гардероба
type WardrobeRepository interface {
	// List возвращает список элементов гардероба пользователя с фильтрацией и пагинацией
	List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) (items []domain.WardrobeItem, total int, err error)

	// GetByID возвращает элемент гардероба по идентификатору
	GetByID(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error)

	// Add добавляет элемент одежды в гардероб пользователя
	Add(ctx context.Context, userID domain.ID, clothingItemID domain.ID, customName *string, notes *string, tags []string) (*domain.WardrobeItem, error)

	// Update обновляет элемент гардероба
	Update(ctx context.Context, userID domain.ID, wardrobeID domain.ID, patch domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error)

	// Delete удаляет элемент из гардероба
	Delete(ctx context.Context, userID domain.ID, wardrobeID domain.ID) error

	// SetFavorite устанавливает/снимает статус избранного для элемента гардероба
	SetFavorite(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isFavorite bool) error

	// SetArchived устанавливает/снимает статус архивного для элемента гардероба
	SetArchived(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isArchived bool) error

	// MarkWorn отмечает элемент как надетый
	MarkWorn(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error)

	// IsInWardrobe проверяет, находится ли элемент одежды в гардеробе пользователя
	IsInWardrobe(ctx context.Context, userID domain.ID, clothingItemID domain.ID) (bool, error)
}
