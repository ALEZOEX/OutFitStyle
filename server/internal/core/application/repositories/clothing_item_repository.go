package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// ClothingItemRepository интерфейс для работы с элементами одежды
type ClothingItemRepository interface {
	// GetByID возвращает элемент одежды по идентификатору
	GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error)

	// GetByUser возвращает элементы одежды пользователя
	GetByUser(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error)

	// GetAll возвращает все элементы одежды
	GetAll(ctx context.Context) ([]domain.ClothingItem, error)

	// Create создает новый элемент одежды
	Create(ctx context.Context, item *domain.ClothingItem) error

	// Update обновляет элемент одежды
	Update(ctx context.Context, item *domain.ClothingItem) error

	// Delete удаляет элемент одежды
	Delete(ctx context.Context, id domain.ID) error

	// GetByFilters возвращает элементы одежды по фильтрам
	GetByFilters(ctx context.Context, filters domain.ClothingItemFilters) ([]domain.ClothingItem, error)

	// LinkToWardrobe добавляет элемент одежды в гардероб пользователя
	LinkToWardrobe(ctx context.Context, userID, itemID domain.ID) error

	// UnlinkFromWardrobe удаляет элемент одежды из гардероба пользователя
	UnlinkFromWardrobe(ctx context.Context, userID, itemID domain.ID) error

	// GetByUserWardrobe возвращает элементы одежды из гардероба пользователя
	GetByUserWardrobe(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error)

	// IsInWardrobe проверяет, находится ли элемент одежды в гардеробе пользователя
	IsInWardrobe(ctx context.Context, userID, itemID domain.ID) (bool, error)

	// Дополнительные методы для планирования нарядов
	// BulkInsert массово вставляет элементы одежды
	BulkInsert(ctx context.Context, items []domain.ClothingItem) error

	// FindCandidatesByPlan находит кандидатов для наряда по плану
	FindCandidatesByPlan(ctx context.Context, category string, subcategories []string, warmthMin int16, temp int16, limit int) ([]domain.ClothingItem, error)
}
