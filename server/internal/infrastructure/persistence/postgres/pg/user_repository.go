package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type UserRepository struct {
	db     *pgxpool.Pool
	logger *zap.Logger
}

func NewUserRepository(db *pgxpool.Pool, logger *zap.Logger) *UserRepository {
	return &UserRepository{db: db, logger: logger}
}

func (r *UserRepository) GetUser(ctx context.Context, id domain.ID) (*domain.User, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *UserRepository) UpdateUser(ctx context.Context, user *domain.User) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *UserRepository) GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *UserRepository) UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UserRepository) GetDefaultCoords(ctx context.Context, userID domain.ID) (lat *float64, lon *float64, err error) {
	// TODO: Implement
	return nil, nil, fmt.Errorf("not implemented")
}