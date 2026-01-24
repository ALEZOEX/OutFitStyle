package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

// ClothingRepository интерфейс репозитория одежды
type ClothingRepository interface {
	// GetByID возвращает элемент одежды по идентификатору
	GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error)

	// GetByIDs возвращает элементы одежды по списку идентификаторов
	GetByIDs(ctx context.Context, ids []domain.ID) ([]domain.ClothingItem, error)

	// Кандидаты для ML-сервиса
	// ListWardrobeCandidates возвращает кандидатов из гардероба пользователя для ML
	ListWardrobeCandidates(ctx context.Context, userID domain.ID, limit int) ([]domain.ClothingItem, error)

	// ListCatalogCandidates возвращает кандидатов из каталога для ML (включая партнерские)
	ListCatalogCandidates(ctx context.Context, includePartners bool, limit int) ([]domain.ClothingItem, error)

	// Lite кандидаты (для рекомендаций)
	// ListWardrobeCandidatesLite возвращает упрощенные кандидаты из гардероба для рекомендаций
	ListWardrobeCandidatesLite(ctx context.Context, userID domain.ID, limit int) ([]domain.CandidateLite, error)

	// ListCatalogCandidatesLite возвращает упрощенные кандидаты из каталога для рекомендаций
	ListCatalogCandidatesLite(ctx context.Context, includePartners bool, limit int) ([]domain.CandidateLite, error)

	// CreateUserItem создает элемент одежды пользователя
	CreateUserItem(ctx context.Context, userID domain.ID, item domain.ClothingItem) (domain.ID, error)
}
