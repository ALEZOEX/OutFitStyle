// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

// AchievementRepository репозиторий для работы с достижениями пользователей
type AchievementRepository struct {
	db     *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
	logger *zap.Logger   // Логгер для записи событий
}

// NewAchievementRepository создает новый экземпляр репозитория достижений
func NewAchievementRepository(db *pgxpool.Pool, logger *zap.Logger) *AchievementRepository {
	return &AchievementRepository{db: db, logger: logger}
}

// GetByUser возвращает все достижения для конкретного пользователя
// Включает информацию о статусе и прогрессе достижений
func (r *AchievementRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	query := `
		SELECT
			a.id, a.code, a.name, a.description, a.icon_emoji, a.points,
			ua.status, ua.progress, ua.unlocked_at
		FROM achievements a
		LEFT JOIN user_achievements ua ON a.id = ua.achievement_id AND ua.user_id = $1
		WHERE a.is_active = true
		ORDER BY a.created_at
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query achievements for user")
	}
	defer rows.Close()

	var achievements []domain.Achievement
	for rows.Next() {
		var ach domain.Achievement
		var status *string
		var progress *int
		var unlockedAt *time.Time

		err := rows.Scan(
			&ach.ID,
			&ach.Code,
			&ach.Name,
			&ach.Description,
			&ach.IconEmoji,
			&ach.Points,
			&status,
			&progress,
			&unlockedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan achievement")
		}

		// Set unlocked_at if achievement was unlocked
		if unlockedAt != nil && status != nil && *status == string(domain.AchievementStatusUnlocked) {
			ach.UnlockedAt = unlockedAt
		}

		// Set progress if available
		if progress != nil {
			ach.Progress = *progress
		}

		achievements = append(achievements, ach)
	}

	return achievements, nil
}

func (r *AchievementRepository) GetByID(ctx context.Context, achievementID string) (*domain.Achievement, error) {
	query := `
		SELECT id, code, name, description, icon_emoji, points, created_at
		FROM achievements
		WHERE id = $1 AND is_active = true
		LIMIT 1
	`

	var ach domain.Achievement
	var createdAt time.Time

	err := r.db.QueryRow(ctx, query, achievementID).Scan(
		&ach.ID,
		&ach.Code,
		&ach.Name,
		&ach.Description,
		&ach.IconEmoji,
		&ach.Points,
		&createdAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get achievement by ID")
	}

	return &ach, nil
}

// GrantToUser выдает достижение пользователю
// Устанавливает статус достижения как разблокированное с полным прогрессом
func (r *AchievementRepository) GrantToUser(ctx context.Context, userID domain.ID, achievementCode string) error {
	query := `
		INSERT INTO user_achievements (user_id, achievement_id, code, status, progress, created_at, updated_at)
		SELECT $1, id, code, 'unlocked', 100, NOW(), NOW()
		FROM achievements
		WHERE code = $2 AND is_active = true
		ON CONFLICT (user_id, achievement_id)
		DO UPDATE SET
			status = 'unlocked',
			progress = 100,
			updated_at = NOW()
	`

	_, err := r.db.Exec(ctx, query, userID, achievementCode)
	if err != nil {
		return errors.Wrap(err, "failed to grant achievement to user")
	}

	return nil
}

// GetUserProgress возвращает прогресс конкретного достижения для пользователя
// Возвращает текущий и целевой прогресс
func (r *AchievementRepository) GetUserProgress(ctx context.Context, userID domain.ID, achievementCode string) (*domain.AchievementProgress, error) {
	query := `
		SELECT progress, status
		FROM user_achievements
		WHERE user_id = $1 AND code = $2
	`

	var progress int
	var status string

	err := r.db.QueryRow(ctx, query, userID, achievementCode).Scan(&progress, &status)
	if err != nil {
		if err.Error() == "no rows in result set" {
			// Return default progress if not found
			return &domain.AchievementProgress{Current: 0, Target: 100}, nil
		}
		return nil, errors.Wrap(err, "failed to get user achievement progress")
	}

	// Assuming target is 100 for all achievements (this could be configurable)
	target := 100
	if status == string(domain.AchievementStatusUnlocked) {
		progress = target // If unlocked, progress should equal target
	}

	return &domain.AchievementProgress{Current: progress, Target: target}, nil
}

func (r *AchievementRepository) ListAll(ctx context.Context) ([]domain.Achievement, error) {
	query := `
		SELECT id, code, name, description, icon_emoji, points, created_at
		FROM achievements
		WHERE is_active = true
		ORDER BY created_at
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to list all achievements")
	}
	defer rows.Close()

	var achievements []domain.Achievement
	for rows.Next() {
		var ach domain.Achievement
		var createdAt time.Time

		err := rows.Scan(
			&ach.ID,
			&ach.Code,
			&ach.Name,
			&ach.Description,
			&ach.IconEmoji,
			&ach.Points,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan achievement")
		}

		achievements = append(achievements, ach)
	}

	return achievements, nil
}

func (r *AchievementRepository) ListMy(ctx context.Context, userID domain.ID) (unlocked []domain.Achievement, inProgress []domain.Achievement, totalPoints int, err error) {
	query := `
		SELECT
			a.id, a.code, a.name, a.description, a.icon_emoji, a.points,
			ua.status, ua.progress
		FROM achievements a
		INNER JOIN user_achievements ua ON a.id = ua.achievement_id
		WHERE ua.user_id = $1 AND a.is_active = true
		ORDER BY a.created_at
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, nil, 0, errors.Wrap(err, "failed to list user achievements")
	}
	defer rows.Close()

	unlocked = []domain.Achievement{}
	inProgress = []domain.Achievement{}
	totalPoints = 0

	for rows.Next() {
		var ach domain.Achievement
		var status string
		var progress int

		err := rows.Scan(
			&ach.ID,
			&ach.Code,
			&ach.Name,
			&ach.Description,
			&ach.IconEmoji,
			&ach.Points,
			&status,
			&progress,
		)
		if err != nil {
			return nil, nil, 0, errors.Wrap(err, "failed to scan achievement")
		}

		if status == string(domain.AchievementStatusUnlocked) {
			unlocked = append(unlocked, ach)
			totalPoints += ach.Points
		} else if status == string(domain.AchievementStatusInProgress) {
			ach.Progress = progress
			inProgress = append(inProgress, ach)
		}
	}

	return unlocked, inProgress, totalPoints, nil
}
