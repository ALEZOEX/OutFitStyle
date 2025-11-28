package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// UserRepository defines the interface for user data operations
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
	GetUserStats(ctx context.Context, userID int) (*domain.UserStats, error)
	UpdateUserStats(ctx context.Context, userID int, stats *domain.UserStats) error
	GetOutfitPlans(ctx context.Context, userID int, startDate, endDate time.Time) ([]domain.OutfitPlan, error)
	CreateOutfitPlan(ctx context.Context, plan *domain.OutfitPlan) error
	DeleteOutfitPlan(ctx context.Context, userID, planID int) error
}

// Userrepresents a user in the system
type User struct {
	ID                int       `json:"id"`
	Email             string    `json:"email"`
	Username          string    `json:"username"`
	Password          string    `json:"password"`
	IsVerified        bool      `json:"is_verified"`
	VerificationToken string    `json:"verification_token"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

// UserProfile represents a user's profile information
type UserProfile struct {
	ID               int       `json:"id"`
	UserID           int       `json:"user_id"`
	StylePreferences []string  `json:"style_preferences"`
	Size             string    `json:"size"`
	Height           int       `json:"height"`
	Weight           int       `json:"weight"`
	PreferredColors  []string  `json:"preferred_colors"`
	DislikedColors   []string  `json:"disliked_colors"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

// VerificationCode represents a verification code for email verification
type VerificationCode struct {
	Code      string    `json:"code"`
	UserID    int       `json:"user_id"`
	ExpiresAt time.Time `json:"expires_at"`
	Type      string    `json:"type"` // "registration" or "login"
}
