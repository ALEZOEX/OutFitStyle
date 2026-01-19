package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type SessionRepository struct {
	db *pgxpool.Pool
}

func NewSessionRepository(db *pgxpool.Pool, logger interface{}) *SessionRepository {
	return &SessionRepository{db: db}
}

func (r *SessionRepository) CreateSession(ctx context.Context, session *domain.Session) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SessionRepository) GetSession(ctx context.Context, id domain.ID) (*domain.Session, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SessionRepository) GetSessionByToken(ctx context.Context, token string) (*domain.Session, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *SessionRepository) UpdateSession(ctx context.Context, session *domain.Session) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SessionRepository) DeleteSession(ctx context.Context, id domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SessionRepository) DeleteSessionsByUser(ctx context.Context, userID domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *SessionRepository) CleanupExpiredSessions(ctx context.Context) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}