package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

type AchievementRepository struct {
	db     *pgxpool.Pool
	logger *zap.Logger
}

func NewAchievementRepository(db *pgxpool.Pool, logger *zap.Logger) *AchievementRepository {
	return &AchievementRepository{db: db, logger: logger}
}

func (r *AchievementRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AchievementRepository) GetByID(ctx context.Context, achievementID string) (*domain.Achievement, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AchievementRepository) GrantToUser(ctx context.Context, userID domain.ID, achievementCode string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *AchievementRepository) GetUserProgress(ctx context.Context, userID domain.ID, achievementCode string) (*domain.AchievementProgress, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AchievementRepository) ListAll(ctx context.Context) ([]domain.Achievement, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AchievementRepository) ListMy(ctx context.Context, userID domain.ID) (unlocked []domain.Achievement, inProgress []domain.Achievement, totalPoints int, err error) {
	// TODO: Implement
	return nil, nil, 0, fmt.Errorf("not implemented")
}