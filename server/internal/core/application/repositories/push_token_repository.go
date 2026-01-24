package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// PushTokenRepository интерфейс репозитория push-токенов
type PushTokenRepository interface {
	// Upsert добавляет или обновляет push-токен пользователя
	Upsert(ctx context.Context, userID domain.ID, token string, platform string, deviceID *string) error

	// Deactivate деактивирует push-токен
	Deactivate(ctx context.Context, userID domain.ID, token string) error

	// ListActiveByUser возвращает список активных push-токенов пользователя
	ListActiveByUser(ctx context.Context, userID domain.ID) ([]domain.PushToken, error)
}
