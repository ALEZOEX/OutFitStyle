package repositories

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

// UserRepository интерфейс репозитория пользователей
type UserRepository interface {
	// GetUser возвращает пользователя по идентификатору
	GetUser(ctx context.Context, id domain.ID) (*domain.User, error)

	// GetUserByEmail возвращает пользователя по email
	GetUserByEmail(ctx context.Context, email string) (*domain.User, error)

	// CreateUser создает нового пользователя
	CreateUser(ctx context.Context, user *domain.User) error

	// UpdateUser обновляет информацию о пользователе
	UpdateUser(ctx context.Context, user *domain.User) error

	// TZ-style profile/stat projection
	// GetUserProfile возвращает профиль пользователя
	GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error)

	// UpdateUserProfile обновляет профиль пользователя
	UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error)

	// GetUserStats возвращает статистику пользователя
	GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error)

	// Achievements (Достижения)
	// GetUserAchievements возвращает достижения пользователя
	GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error)

	// UnlockAchievement разблокирует достижение для пользователя
	UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error

	// Preferences and measurements (Предпочтения и измерения)
	// UpdatePreferences обновляет предпочтения пользователя
	UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error)

	// UpdateBodyMeasurements обновляет антропометрические данные пользователя
	UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error)

	// Default coordinates and timezone (Координаты и часовой пояс по умолчанию)
	// GetDefaultCoords возвращает координаты по умолчанию пользователя
	GetDefaultCoords(ctx context.Context, userID domain.ID) (lat *float64, lon *float64, err error)

	// GetUserTimezone возвращает часовой пояс пользователя
	GetUserTimezone(ctx context.Context, userID domain.ID) (tz string, err error)

	// DeleteUser удаляет пользователя
	DeleteUser(ctx context.Context, userID domain.ID) error

	// RateRecommendation позволяет пользователю оценить рекомендацию
	RateRecommendation(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error
}
