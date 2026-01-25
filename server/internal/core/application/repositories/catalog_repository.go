package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

// CatalogSearchParams параметры поиска в каталоге
type CatalogSearchParams struct {
	Q           *string // Поисковый запрос
	Category    *string // Категория
	Subcategory *string // Подкатегория
	Style       *string // Стиль
	Color       *string // Цвет

	MinPrice *float64 // Минимальная цена
	MaxPrice *float64 // Максимальная цена

	Partner *string // Партнер (partners.code)

	Page  int // Номер страницы
	Limit int // Количество элементов на странице

	SearchTerm string                     // Поисковый термин
	Filters    domain.ClothingItemFilters // Фильтры для элементов одежды
}

// CatalogRepository интерфейс репозитория каталога
type CatalogRepository interface {
	// Search выполняет поиск элементов в каталоге
	Search(ctx context.Context, p CatalogSearchParams) (items []domain.ClothingItem, total int, err error)

	// Categories возвращает список категорий
	Categories(ctx context.Context) (any, error) // отдаём структурой из handler

	// GetItem возвращает элемент каталога по идентификатору
	GetItem(ctx context.Context, id domain.ID) (*domain.ClothingItem, error)

	// Similar возвращает похожие элементы
	Similar(ctx context.Context, id domain.ID, limit int) ([]domain.ClothingItem, error)

	// Click регистрирует клик по элементу каталога и возвращает URL для переадресации
	Click(ctx context.Context, userID *domain.ID, itemID domain.ID) (redirectURL string, err error)
}
