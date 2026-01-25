package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// RecommendationItemCreate структура для создания элемента рекомендации
type RecommendationItemCreate struct {
	ClothingItemID   domain.ID // Идентификатор элемента одежды
	Category         string    // Категория
	LayerPosition    *int      // Позиция слоя (опционально)
	Score            *float64  // Оценка (опционально)
	Source           string    // Источник (clothing_source)
	IsFromWardrobe   bool      // Из гардероба ли
	AlternativesJSON []byte    // Альтернативы в формате JSON (опционально)
}

// RecommendationItemRow структура строки элемента рекомендации
type RecommendationItemRow struct {
	ID               domain.ID // Уникальный идентификатор элемента
	RecommendationID domain.ID // Идентификатор рекомендации
	ClothingItemID   domain.ID // Идентификатор элемента одежды
	Score            float64   // Рейтинг элемента
	Category         string    // Категория
	Source           string    // Источник
	IsFromWardrobe   bool      // Из гардероба ли
	AlternativesJSON []byte    // Альтернативы в формате JSON
	CreatedAt        time.Time // Время создания элемента
}

// RecommendationSession структура сессии рекомендации
type RecommendationSession struct {
	ID              domain.ID // Идентификатор сессии
	UserID          domain.ID // Идентификатор пользователя
	ContextHash     *string   // Хэш контекста
	ModelVersion    *string   // Версия модели
	WeatherData     []byte    // Данные о погоде
	UserPreferences []byte    // Предпочтения пользователя
}

// RecommendationRepository интерфейс репозитория рекомендаций
type RecommendationRepository interface {
	// Create создает новую рекомендацию
	Create(ctx context.Context, rec *domain.RecommendationRecord, items []RecommendationItemCreate) (domain.ID, error)

	// CreateWithSession создает новую рекомендацию с сессией
	CreateWithSession(ctx context.Context, session *RecommendationSession, rec *domain.RecommendationRecord, items []RecommendationItemCreate) (domain.ID, error)

	// CreateRecommendation создает рекомендацию из ответа
	CreateRecommendation(ctx context.Context, rec *domain.RecommendationResponse) (*domain.RecommendationResponse, error)

	// GetByID возвращает рекомендацию по идентификатору
	GetByID(ctx context.Context, id domain.ID) (*domain.RecommendationRecord, error)

	// ListByUser возвращает список рекомендаций пользователя
	ListByUser(ctx context.Context, userID domain.ID, q domain.RecommendationListQuery) (items []domain.RecommendationRecord, total int, err error)

	// GetItemRows возвращает строки элементов рекомендации
	GetItemRows(ctx context.Context, recommendationID domain.ID) ([]RecommendationItemRow, error)

	// SetRating устанавливает рейтинг рекомендации
	SetRating(ctx context.Context, userID, recommendationID domain.ID, rating int, thermalFeedback *string, feedback *string) (changedToPerfect bool, err error)

	// SetFavorite устанавливает/снимает статус избранного для рекомендации
	SetFavorite(ctx context.Context, userID, recommendationID domain.ID, isFavorite bool) error

	// ListFavorites возвращает список избранных рекомендаций пользователя
	ListFavorites(ctx context.Context, userID domain.ID, limit int) ([]domain.RecommendationRecord, error)

	// CreateSession создает сессию рекомендации
	CreateSession(ctx context.Context, session *RecommendationSession) (domain.ID, error)
}
