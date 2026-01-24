package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// SharedOutfitRecord структура записи общего наряда
type SharedOutfitRecord struct {
	ID domain.ID  // Уникальный идентификатор записи

	UserID       domain.ID  // Идентификатор пользователя
	ShowUserName bool       // Показывать ли имя пользователя
	IsPublic     bool       // Публичный ли доступ

	RecommendationID *domain.ID  // Идентификатор рекомендации (опционально)
	SavedOutfitID    *domain.ID  // Идентификатор сохраненного наряда (опционально)

	ShareCode string  // Код для общего доступа
}

// ShareRepository интерфейс репозитория шаринга
type ShareRepository interface {
	// CreateShare создает новую запись общего доступа к наряду
	CreateShare(ctx context.Context, userID domain.ID, recommendationID *domain.ID, savedOutfitID *domain.ID, showUserName bool) (shareCode string, err error)

	// GetByCode возвращает запись общего доступа по коду
	GetByCode(ctx context.Context, code string) (*SharedOutfitRecord, error)

	// IncViews увеличивает счетчик просмотров
	IncViews(ctx context.Context, code string) error

	// GetUserDisplayName возвращает отображаемое имя пользователя
	GetUserDisplayName(ctx context.Context, userID domain.ID) (*string, error)

	// GetRecommendationOutfit возвращает наряд из рекомендации
	GetRecommendationOutfit(ctx context.Context, recommendationID domain.ID) (outfit any, err error)

	// GetSavedOutfit возвращает сохраненный наряд
	GetSavedOutfit(ctx context.Context, savedOutfitID domain.ID) (outfit any, err error)
}
