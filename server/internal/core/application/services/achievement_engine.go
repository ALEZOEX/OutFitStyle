package services

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type AchievementEngine struct {
	repo     repositories.AchievementEngineRepository
	userRepo repositories.UserRepository
	notif    *NotificationService // можно nil
}

func NewAchievementEngine(repo repositories.AchievementEngineRepository, userRepo repositories.UserRepository, notif *NotificationService) *AchievementEngine {
	return &AchievementEngine{repo: repo, userRepo: userRepo, notif: notif}
}

func (e *AchievementEngine) Evaluate(ctx context.Context, userID domain.ID) ([]string, error) {
	stats, err := e.userRepo.GetUserStats(ctx, userID)
	if err != nil {
		return nil, err
	}
	if stats == nil {
		return nil, nil
	}

	defs, err := e.repo.ListActiveDefinitions(ctx)
	if err != nil {
		return nil, err
	}

	unlocked, err := e.repo.ListUnlockedCodes(ctx, userID)
	if err != nil {
		return nil, err
	}

	newUnlocked := []string{}

	for _, a := range defs {
		if unlocked[a.Code] {
			continue
		}
		progress := progressFromStats(a.ConditionType, stats)
		unlockNow := progress >= a.ConditionValue

		if err := e.repo.UpsertProgress(ctx, userID, a.ID, progress, unlockNow); err != nil {
			return nil, err
		}

		if unlockNow {
			newUnlocked = append(newUnlocked, a.Code)
			if e.notif != nil {
				title := "Достижение разблокировано"
				body := "Вы получили: " + a.Code
				_, _ = e.notif.CreateAndDispatch(ctx, userID, "achievement", title, &body, map[string]any{
					"achievement_code": a.Code,
				})
			}
		}
	}

	return newUnlocked, nil
}

func progressFromStats(conditionType string, s *domain.UserStats) int {
	switch conditionType {
	case "recommendations_count":
		return s.RecommendationsCount
	case "wardrobe_size":
		return s.WardrobeSize
	case "streak_days":
		return s.CurrentStreak
	case "perfect_ratings":
		return s.PerfectRatingsCount
	case "weather_types":
		return len(s.WeatherTypesSeen)
	case "styles_used":
		return len(s.StylesUsed)
	default:
		return 0
	}
}

var ErrAchievementEngine = errors.New("achievement engine error")