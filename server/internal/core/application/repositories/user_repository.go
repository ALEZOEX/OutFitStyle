package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

type UserRepository interface {
	GetUser(ctx context.Context, id domain.ID) (*domain.User, error)
	GetUserByEmail(ctx context.Context, email string) (*domain.User, error)

	CreateUser(ctx context.Context, user *domain.User) error
	UpdateUser(ctx context.Context, user *domain.User) error

	// TZ-style profile/stat projection
	GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error)
	UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error)

	GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error)

	// Achievements
	GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error)
	UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error

	// Preferences and measurements
	UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error)
	UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error)

	// Default coordinates and timezone
	GetDefaultCoords(ctx context.Context, userID domain.ID) (lat *float64, lon *float64, err error)
	GetUserTimezone(ctx context.Context, userID domain.ID) (tz string, err error)

	DeleteUser(ctx context.Context, userID domain.ID) error
}
