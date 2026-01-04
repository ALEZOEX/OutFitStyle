package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

type Session struct {
	ID               domain.ID
	UserID           domain.ID
	RefreshTokenHash string
	IsActive         bool
	ExpiresAt        time.Time
	CreatedAt        time.Time
	LastUsedAt       time.Time
	DeviceID         *string
	DeviceName       *string
	DeviceType       *string
	IPAddress        *string
	UserAgent        *string
}

type CreateSessionParams struct {
	UserID           domain.ID
	RefreshTokenHash string

	DeviceID   *string
	DeviceName *string
	DeviceType *string

	IPAddress *string
	UserAgent *string

	ExpiresAt time.Time
}

type UpdateDeviceInfoParams struct {
	DeviceID   *string
	DeviceName *string
	DeviceType *string
	IPAddress  *string
	UserAgent  *string
}

type SessionRepository interface {
	Create(ctx context.Context, p CreateSessionParams) (domain.ID, error)

	GetByID(ctx context.Context, sessionID domain.ID) (*Session, error)
	GetByRefreshHash(ctx context.Context, refreshHash string) (*Session, error)

	RotateRefresh(ctx context.Context, sessionID domain.ID, newRefreshHash string, newExpiresAt time.Time) error
	Touch(ctx context.Context, sessionID domain.ID) error

	Revoke(ctx context.Context, sessionID domain.ID) error
	RevokeAllForUser(ctx context.Context, userID domain.ID) error
	RevokeForUser(ctx context.Context, userID domain.ID, sessionID domain.ID) error
	ListByUser(ctx context.Context, userID domain.ID) ([]Session, error)

	UpdateDeviceInfo(ctx context.Context, sessionID domain.ID, p UpdateDeviceInfoParams) error
}