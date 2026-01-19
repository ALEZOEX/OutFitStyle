package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type PushTokenRepository struct {
	db *pgxpool.Pool
}

func NewPushTokenRepository(db *pgxpool.Pool) *PushTokenRepository {
	return &PushTokenRepository{db: db}
}

func (r *PushTokenRepository) Upsert(ctx context.Context, userID domain.ID, deviceID string, token string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *PushTokenRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.PushToken, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *PushTokenRepository) Delete(ctx context.Context, userID domain.ID, deviceID string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}