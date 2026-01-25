package domain

import "time"

// AchievementStatus статус достижения
type AchievementStatus string

const (
	// AchievementStatusLocked статус "заблокировано" - достижение недоступно пользователю
	AchievementStatusLocked AchievementStatus = "locked"
	// AchievementStatusUnlocked статус "разблокировано" - достижение получено пользователем
	AchievementStatusUnlocked AchievementStatus = "unlocked"
	// AchievementStatusInProgress статус "в процессе" - пользователь начал выполнять достижение
	AchievementStatusInProgress AchievementStatus = "in_progress"
)

// AchievementProgress структура для отслеживания прогресса достижения
type AchievementProgress struct {
	Current int `json:"current"` // Текущий прогресс
	Target  int `json:"target"`  // Целевое значение для получения достижения
}

// UserAchievement структура для представления достижения пользователя
type UserAchievement struct {
	ID            ID                `json:"id"`                    // Уникальный идентификатор записи
	UserID        ID                `json:"user_id"`               // Идентификатор пользователя
	AchievementID ID                `json:"achievement_id"`        // Идентификатор достижения
	Code          string            `json:"code"`                  // Код достижения
	Status        AchievementStatus `json:"status"`                // Статус достижения
	Progress      int               `json:"progress"`              // Прогресс выполнения
	UnlockedAt    *time.Time        `json:"unlocked_at,omitempty"` // Время разблокировки (если разблокировано)
	CreatedAt     time.Time         `json:"created_at"`            // Время создания записи
	UpdatedAt     time.Time         `json:"updated_at"`            // Время последнего обновления
}

// Achievement структура для представления базового достижения
type Achievement struct {
	ID          ID         `json:"id"`                    // Уникальный идентификатор достижения
	Code        string     `json:"code"`                  // Уникальный код достижения
	Name        string     `json:"name"`                  // Название достижения
	Description string     `json:"description"`           // Описание достижения
	IconEmoji   string     `json:"icon_emoji"`            // Эмодзи для отображения
	Points      int        `json:"points"`                // Количество очков за достижение
	UnlockedAt  *time.Time `json:"unlocked_at,omitempty"` // Время получения (если получено)
	Progress    int        `json:"progress,omitempty"`    // Прогресс выполнения (если в процессе)
}
