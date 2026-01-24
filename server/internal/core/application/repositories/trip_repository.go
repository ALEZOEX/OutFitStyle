package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

// TripRepository интерфейс репозитория поездок
type TripRepository interface {
	// List возвращает список поездок пользователя
	List(ctx context.Context, userID domain.ID) ([]domain.Trip, error)

	// Create создает новую поездку
	Create(ctx context.Context, userID domain.ID, req domain.TripCreateRequest) (*domain.Trip, error)

	// Get возвращает поездку по идентификатору
	Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.Trip, error)

	// Update обновляет информацию о поездке
	Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.TripUpdateRequest) (*domain.Trip, error)

	// Delete удаляет поездку
	Delete(ctx context.Context, userID domain.ID, id domain.ID) error
}
