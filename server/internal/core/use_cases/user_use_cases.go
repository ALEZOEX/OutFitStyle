package usecases

import (
	"context"
	
	"outfitstyle/server/internal/core/domain"
)

// GetUserProfileUseCase handles retrieving user profile
type GetUserProfileUseCase struct {
	UserRepository UserRepository
}

// Execute retrieves a user's profile
func (uc *GetUserProfileUseCase) Execute(ctx context.Context, userID int) (*domain.UserProfile, error) {
	return uc.UserRepository.GetUserProfile(ctx, userID)
}

// UpdateUserProfileUseCase handles updating user profile
type UpdateUserProfileUseCase struct {
	UserRepository UserRepository
}

// Execute updates a user's profile
func (uc *UpdateUserProfileUseCase) Execute(ctx context.Context, profile *domain.UserProfile) error {
	return uc.UserRepository.UpdateUserProfile(ctx, profile)
}

// RateRecommendationUseCase handles rating a recommendation
type RateRecommendationUseCase struct {
	UserRepository UserRepository
}

// Execute saves a user's rating for a recommendation
func (uc *RateRecommendationUseCase) Execute(ctx context.Context, userID, recommendationID, rating int, feedback string) error {
	return uc.UserRepository.RateRecommendation(ctx, userID, recommendationID, rating, feedback)
}