package services

import (
	"context"
	
	"go.uber.org/zap"
	
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/application/repositories"
)

// UserService handles user-related business logic
type UserService struct {
	userRepo repositories.UserRepository
	logger   *zap.Logger
}

// NewUserService creates a new user service
func NewUserService(
	userRepo repositories.UserRepository,
	logger *zap.Logger,
) *UserService {
	return &UserService{
		userRepo: userRepo,
		logger:   logger,
	}
}

// GetUserProfile retrieves a user's profile
func (s *UserService) GetUserProfile(ctx context.Context, userID int) (*domain.UserProfile, error) {
	return s.userRepo.GetUserProfile(ctx, userID)
}

// UpdateUserProfile updates a user's profile
func (s *UserService) UpdateUserProfile(ctx context.Context, profile *domain.UserProfile) error {
	return s.userRepo.UpdateUserProfile(ctx, profile)
}

// GetUserAchievements retrieves a user's achievements
func (s *UserService) GetUserAchievements(ctx context.Context, userID int) ([]domain.Achievement, error) {
	return s.userRepo.GetUserAchievements(ctx, userID)
}

// UnlockAchievement unlocks an achievement for a user
func (s *UserService) UnlockAchievement(ctx context.Context, userID int, achievementCode string) error {
	return s.userRepo.UnlockAchievement(ctx, userID, achievementCode)
}

// RateRecommendation saves a user's rating for a recommendation
func (s *UserService) RateRecommendation(ctx context.Context, userID, recommendationID, rating int, feedback string) error {
	return s.userRepo.RateRecommendation(ctx, userID, recommendationID, rating, feedback)
}

// GetUserRatings retrieves user's ratings
func (s *UserService) GetUserRatings(ctx context.Context, userID int) ([]domain.UserRating, error) {
	return s.userRepo.GetUserRatings(ctx, userID)
}

// AddFavorite adds a recommendation to user's favorites
func (s *UserService) AddFavorite(ctx context.Context, userID, recommendationID int) error {
	return s.userRepo.AddFavorite(ctx, userID, recommendationID)
}

// RemoveFavorite removes a recommendation from user's favorites
func (s *UserService) RemoveFavorite(ctx context.Context, userID, favoriteID int) error {
	return s.userRepo.RemoveFavorite(ctx, userID, favoriteID)
}

// GetUserFavorites retrieves user's favorite recommendations
func (s *UserService) GetUserFavorites(ctx context.Context, userID int) ([]domain.FavoriteOutfit, error) {
	return s.userRepo.GetUserFavorites(ctx, userID)
}

// CreateOutfitPlan creates a new outfit plan
func (s *UserService) CreateOutfitPlan(ctx context.Context, plan *domain.OutfitPlan) error {
	return s.userRepo.CreateOutfitPlan(ctx, plan)
}

// GetUserOutfitPlans retrieves user's outfit plans
func (s *UserService) GetUserOutfitPlans(ctx context.Context, userID int) ([]domain.OutfitPlan, error) {
	return s.userRepo.GetUserOutfitPlans(ctx, userID)
}

// DeleteOutfitPlan deletes an outfit plan
func (s *UserService) DeleteOutfitPlan(ctx context.Context, userID, planID int) error {
	return s.userRepo.DeleteOutfitPlan(ctx, userID, planID)
}

// GetUserStats retrieves user statistics
func (s *UserService) GetUserStats(ctx context.Context, userID int) (*domain.UserStats, error) {
	return s.userRepo.GetUserStats(ctx, userID)
}

// UpdateUserStats updates user statistics
func (s *UserService) UpdateUserStats(ctx context.Context, userID int, stats *domain.UserStats) error {
	return s.userRepo.UpdateUserStats(ctx, userID, stats)
}