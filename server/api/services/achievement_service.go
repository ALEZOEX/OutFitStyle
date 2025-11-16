package services

import (
	"database/sql"
	"log"
)

type AchievementService struct {
	db *sql.DB
}

func NewAchievementService(db *sql.DB) *AchievementService {
	return &AchievementService{db: db}
}

// UnlockAchievement разблокирует достижение для пользователя
func (s *AchievementService) UnlockAchievement(userID int, achievementID string) error {
	query := `
		INSERT INTO user_achievements (user_id, achievement_id, unlocked_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (user_id, achievement_id) DO UPDATE
		SET unlocked_at = NOW()
		WHERE user_achievements.unlocked_at IS NULL
	`
	_, err := s.db.Exec(query, userID, achievementID)
	if err != nil {
		log.Printf("Ошибка разблокировки достижения %s для пользователя %d: %v", achievementID, userID, err)
		return err
	}

	log.Printf("Достижение %s разблокировано для пользователя %d", achievementID, userID)
	return nil
}

// UpdateAchievementProgress обновляет прогресс достижения для пользователя
func (s *AchievementService) UpdateAchievementProgress(userID int, achievementID string, increment int) error {
	query := `
		INSERT INTO user_achievements (user_id, achievement_id, progress)
		VALUES ($1, $2, $3)
		ON CONFLICT (user_id, achievement_id) DO UPDATE
		SET progress = user_achievements.progress + $3
	`
	_, err := s.db.Exec(query, userID, achievementID, increment)
	if err != nil {
		log.Printf("Ошибка обновления прогресса достижения %s для пользователя %d: %v", achievementID, userID, err)
		return err
	}

	// Проверяем, достиг ли пользователь необходимого прогресса
	requiredCount, err := s.getRequiredCount(achievementID)
	if err != nil {
		return err
	}

	currentProgress, err := s.getCurrentProgress(userID, achievementID)
	if err != nil {
		return err
	}

	if currentProgress >= requiredCount {
		return s.UnlockAchievement(userID, achievementID)
	}

	return nil
}

// getRequiredCount получает необходимое количество для достижения
func (s *AchievementService) getRequiredCount(achievementID string) (int, error) {
	var requiredCount int
	query := "SELECT required_count FROM achievement_definitions WHERE id = $1"
	err := s.db.QueryRow(query, achievementID).Scan(&requiredCount)
	if err != nil {
		log.Printf("Ошибка получения необходимого количества для достижения %s: %v", achievementID, err)
		return 0, err
	}
	return requiredCount, nil
}

// getCurrentProgress получает текущий прогресс пользователя по достижению
func (s *AchievementService) getCurrentProgress(userID int, achievementID string) (int, error) {
	var progress int
	query := "SELECT progress FROM user_achievements WHERE user_id = $1 AND achievement_id = $2"
	err := s.db.QueryRow(query, userID, achievementID).Scan(&progress)
	if err != nil && err != sql.ErrNoRows {
		log.Printf("Ошибка получения текущего прогресса по достижению %s для пользователя %d: %v", achievementID, userID, err)
		return 0, err
	}
	return progress, nil
}

// IsAchievementUnlocked проверяет, разблокировано ли достижение для пользователя
func (s *AchievementService) IsAchievementUnlocked(userID int, achievementID string) (bool, error) {
	var unlockedAt interface{}
	query := "SELECT unlocked_at FROM user_achievements WHERE user_id = $1 AND achievement_id = $2"
	err := s.db.QueryRow(query, userID, achievementID).Scan(&unlockedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return false, nil
		}
		log.Printf("Ошибка проверки разблокировки достижения %s для пользователя %d: %v", achievementID, userID, err)
		return false, err
	}
	return unlockedAt != nil, nil
}