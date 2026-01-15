package usecases

import (
	"context"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// GetUserProfileUseCase handles retrieving user profile
type GetUserProfileUseCase struct {
	UserRepository repositories.UserRepository
}

// Execute retrieves a user's profile
func (uc *GetUserProfileUseCase) Execute(
	ctx context.Context,
	userID domain.ID,
) (*domain.User, error) {
	return uc.UserRepository.GetUserProfile(ctx, userID)
}

// UpdateUserProfileUseCase handles updating user profile
type UpdateUserProfileUseCase struct {
	UserRepository repositories.UserRepository
}

// Execute updates a user's profile
func (uc *UpdateUserProfileUseCase) Execute(
	ctx context.Context,
	userID domain.ID,
	patch domain.UserProfileUpdate,
) (*domain.User, error) {
	return uc.UserRepository.UpdateUserProfile(ctx, userID, patch)
}

// RateRecommendationUseCase handles rating a recommendation
type RateRecommendationUseCase struct {
	UserRepository repositories.UserRepository
}

// Execute saves a user's rating for a recommendation
func (uc *RateRecommendationUseCase) Execute(
	ctx context.Context,
	userID, recommendationID domain.ID,
	rating int,
	feedback string,
) error {
	return uc.UserRepository.RateRecommendation(ctx, userID, recommendationID, rating, feedback)
}
