package services

import (
	"context"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// Константы для порогов рангов достижений
const (
	RankBronzeThreshold   = 0
	RankSilverThreshold   = 200
	RankGoldThreshold     = 500
	RankPlatinumThreshold = 1000
)

// UserAchievementResult структура для возврата результатов метода My
type UserAchievementResult struct {
	Unlocked    []domain.Achievement
	InProgress  []domain.Achievement
	TotalPoints int
	Rank        string
}

type AchievementsService struct {
	repo repositories.AchievementRepository
}

func NewAchievementsService(repo repositories.AchievementRepository) *AchievementsService {
	return &AchievementsService{repo: repo}
}

func (s *AchievementsService) ListAll(ctx context.Context) ([]domain.Achievement, error) {
	return s.repo.ListAll(ctx)
}

// determineRank определяет ранг пользователя на основе набранных очков
func determineRank(totalPoints int) string {
	switch {
	case totalPoints >= RankPlatinumThreshold:
		return "platinum"
	case totalPoints >= RankGoldThreshold:
		return "gold"
	case totalPoints >= RankSilverThreshold:
		return "silver"
	default:
		return "bronze"
	}
}

func (s *AchievementsService) My(ctx context.Context, userID domain.ID) (*UserAchievementResult, error) {
	unlocked, inProgress, totalPoints, err := s.repo.ListMy(ctx, userID)
	if err != nil {
		return nil, err
	}

	rank := determineRank(totalPoints)

	return &UserAchievementResult{
		Unlocked:    unlocked,
		InProgress:  inProgress,
		TotalPoints: totalPoints,
		Rank:        rank,
	}, nil
}
