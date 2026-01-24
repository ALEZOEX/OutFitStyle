package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type AchievementEngineRepository struct {
	db *pgxpool.Pool
}

func NewAchievementEngineRepository(db *pgxpool.Pool) *AchievementEngineRepository {
	return &AchievementEngineRepository{db: db}
}

func (r *AchievementEngineRepository) GetUserAchievementStatus(ctx context.Context, userID domain.ID, achievementCode string) (*domain.UserAchievement, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AchievementEngineRepository) SetUserAchievementStatus(ctx context.Context, userID domain.ID, achievementCode string, status domain.AchievementStatus) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *AchievementEngineRepository) GetUserAchievementProgress(ctx context.Context, userID domain.ID, achievementCode string) (int, error) {
	// TODO: Implement
	return 0, fmt.Errorf("not implemented")
}

func (r *AchievementEngineRepository) ListActiveDefinitions(ctx context.Context) ([]repositories.AchievementDef, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AchievementEngineRepository) ListUnlockedCodes(ctx context.Context, userID domain.ID) (map[string]bool, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *AchievementEngineRepository) UpsertProgress(ctx context.Context, userID domain.ID, achievementID domain.ID, progress int, unlock bool) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *AchievementEngineRepository) IncrementUserAchievementProgress(ctx context.Context, userID domain.ID, achievementCode string, increment int) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}