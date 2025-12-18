package services

import (
	"context"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type UserService struct {
	userRepo repositories.UserRepository
	logger   *zap.Logger
}

func NewUserService(userRepo repositories.UserRepository, logger *zap.Logger) *UserService {
	return &UserService{userRepo: userRepo, logger: logger}
}

func (s *UserService) GetUserProfile(ctx context.Context, userID domain.ID) (*domain.UserProfileResponse, error) {
	u, err := s.userRepo.GetUserProfile(ctx, userID)
	if err != nil {
		return nil, err
	}
	stats, _ := s.userRepo.GetUserStats(ctx, userID) // stats может быть nil — это нормально
	return &domain.UserProfileResponse{User: u, Stats: stats}, nil
}

func (s *UserService) UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.UserProfileResponse, error) {
	u, err := s.userRepo.UpdateUserProfile(ctx, userID, patch)
	if err != nil {
		return nil, err
	}
	stats, _ := s.userRepo.GetUserStats(ctx, userID)
	return &domain.UserProfileResponse{User: u, Stats: stats}, nil
}

func (s *UserService) GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	return s.userRepo.GetUserAchievements(ctx, userID)
}

func (s *UserService) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error) {
	return s.userRepo.GetUserStats(ctx, userID)
}

func (s *UserService) UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.UserProfileResponse, error) {
	u, err := s.userRepo.UpdatePreferences(ctx, userID, prefs)
	if err != nil {
		return nil, err
	}
	stats, _ := s.userRepo.GetUserStats(ctx, userID)
	return &domain.UserProfileResponse{User: u, Stats: stats}, nil
}

func (s *UserService) UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.UserProfileResponse, error) {
	u, err := s.userRepo.UpdateBodyMeasurements(ctx, userID, bm)
	if err != nil {
		return nil, err
	}
	stats, _ := s.userRepo.GetUserStats(ctx, userID)
	return &domain.UserProfileResponse{User: u, Stats: stats}, nil
}
