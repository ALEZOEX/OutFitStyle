package services

import (
	"context"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type AchievementsService struct {
	repo repositories.AchievementRepository
}

func NewAchievementsService(repo repositories.AchievementRepository) *AchievementsService {
	return &AchievementsService{repo: repo}
}

func (s *AchievementsService) ListAll(ctx context.Context) ([]domain.Achievement, error) {
	return s.repo.ListAll(ctx)
}

func (s *AchievementsService) My(ctx context.Context, userID domain.ID) (unlocked []domain.Achievement, inProgress []domain.Achievement, totalPoints int, rank string, err error) {
	u, p, total, err := s.repo.ListMy(ctx, userID)
	if err != nil {
		return nil, nil, 0, "", err
	}

	// MVP ранк по total_points (позже можно усложнить)
	rank = "bronze"
	if total >= 200 {
		rank = "silver"
	}
	if total >= 500 {
		rank = "gold"
	}
	if total >= 1000 {
		rank = "platinum"
	}

	return u, p, total, rank, nil
}