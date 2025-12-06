package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// UserRepository defines the interface for user data operations.
type UserRepository interface {
	GetUser(ctx context.Context, id int) (*domain.User, error)
	GetUserByEmail(ctx context.Context, email string) (*domain.User, error)
	CreateUser(ctx context.Context, user *domain.User) error
	UpdateUser(ctx context.Context, user *domain.User) error

	GetUserProfile(ctx context.Context, userID int) (*domain.UserProfile, error)
	UpdateUserProfile(ctx context.Context, profile *domain.UserProfile) error

	GetUserAchievements(ctx context.Context, userID int) ([]domain.Achievement, error)
	UnlockAchievement(ctx context.Context, userID int, achievementCode string) error

	RateRecommendation(ctx context.Context, userID, recommendationID, rating int, feedback string) error

	AddFavorite(ctx context.Context, userID, recommendationID int) error
	RemoveFavorite(ctx context.Context, userID, favoriteID int) error
	GetUserFavorites(ctx context.Context, userID int) ([]domain.FavoriteOutfit, error)

	GetUserRatings(ctx context.Context, userID int) ([]domain.UserRating, error)

	GetUserOutfitPlans(ctx context.Context, userID int) ([]domain.OutfitPlan, error)
	GetOutfitPlans(ctx context.Context, userID int, startDate, endDate time.Time) ([]domain.OutfitPlan, error)
	CreateOutfitPlan(ctx context.Context, plan *domain.OutfitPlan) error
	DeleteOutfitPlan(ctx context.Context, userID, planID int) error

	GetUserStats(ctx context.Context, userID int) (*domain.UserStats, error)
	UpdateUserStats(ctx context.Context, userID int, stats *domain.UserStats) error
}
