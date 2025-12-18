package repositories

import (
"context"

"outfitstyle/server/internal/core/domain"
)

type PushTokenRepository interface {
Upsert(ctx context.Context, userID domain.ID, token string, platform string, deviceID *string) error
Deactivate(ctx context.Context, userID domain.ID, token string) error

ListActiveByUser(ctx context.Context, userID domain.ID) ([]domain.PushToken, error)
}