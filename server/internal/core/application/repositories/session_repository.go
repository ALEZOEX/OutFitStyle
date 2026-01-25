package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// Session структура сессии пользователя
type Session struct {
	ID               domain.ID  // Уникальный идентификатор сессии
	UserID           domain.ID  // Идентификатор пользователя
	RefreshTokenHash string     // Хэш refresh-токена
	IsActive         bool       // Активна ли сессия
	ExpiresAt        *time.Time // Время истечения срока действия
	CreatedAt        *time.Time // Время создания сессии
	LastUsedAt       *time.Time // Время последнего использования
	DeviceID         *string    // Идентификатор устройства
	DeviceName       *string    // Название устройства
	DeviceType       *string    // Тип устройства
	IPAddress        *string    // IP-адрес
	UserAgent        *string    // User-Agent
	DeviceInfo       *string    // Информация об устройстве
}

// CreateSessionParams параметры для создания сессии
type CreateSessionParams struct {
	UserID           domain.ID // Идентификатор пользователя
	RefreshTokenHash string    // Хэш refresh-токена

	DeviceID   *string // Идентификатор устройства
	DeviceName *string // Название устройства
	DeviceType *string // Тип устройства

	IPAddress  *string // IP-адрес
	UserAgent  *string // User-Agent
	DeviceInfo *string // Информация об устройстве

	ExpiresAt *time.Time // Время истечения срока действия
}

// UpdateDeviceInfoParams параметры для обновления информации об устройстве
type UpdateDeviceInfoParams struct {
	DeviceID   *string // Идентификатор устройства
	DeviceName *string // Название устройства
	DeviceType *string // Тип устройства
	IPAddress  *string // IP-адрес
	UserAgent  *string // User-Agent
	DeviceInfo *string // Информация об устройстве
}

// SessionRepository интерфейс репозитория сессий
type SessionRepository interface {
	// Create создает новую сессию
	Create(ctx context.Context, p CreateSessionParams) (domain.ID, error)

	// GetByID возвращает сессию по идентификатору
	GetByID(ctx context.Context, sessionID domain.ID) (*Session, error)

	// GetByRefreshHash возвращает сессию по хэшу refresh-токена
	GetByRefreshHash(ctx context.Context, refreshHash string) (*Session, error)

	// RotateRefresh обновляет refresh-токен
	RotateRefresh(ctx context.Context, sessionID domain.ID, newRefreshHash string, newExpiresAt time.Time) error

	// Touch обновляет время последнего использования сессии
	Touch(ctx context.Context, sessionID domain.ID) error

	// Revoke отменяет сессию
	Revoke(ctx context.Context, sessionID domain.ID) error

	// RevokeAllForUser отменяет все сессии пользователя
	RevokeAllForUser(ctx context.Context, userID domain.ID) error

	// RevokeForUser отменяет конкретную сессию пользователя
	RevokeForUser(ctx context.Context, userID domain.ID, sessionID domain.ID) error

	// ListByUser возвращает список сессий пользователя
	ListByUser(ctx context.Context, userID domain.ID) ([]Session, error)

	// UpdateDeviceInfo обновляет информацию об устройстве
	UpdateDeviceInfo(ctx context.Context, sessionID domain.ID, p UpdateDeviceInfoParams) error
}
