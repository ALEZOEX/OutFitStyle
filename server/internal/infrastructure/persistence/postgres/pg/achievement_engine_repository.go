// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// AchievementEngineRepository репозиторий для работы с достижениями пользователей
type AchievementEngineRepository struct {
	db *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
}

// NewAchievementEngineRepository создает новый экземпляр репозитория достижений
func NewAchievementEngineRepository(db *pgxpool.Pool) *AchievementEngineRepository {
	return &AchievementEngineRepository{db: db}
}

// ListActiveDefinitions возвращает список активных определений достижений
// Используется для получения всех активных достижений в системе
func (r *AchievementEngineRepository) ListActiveDefinitions(ctx context.Context) ([]repositories.AchievementDef, error) {
	query := `
		SELECT
			id, code, condition_type, condition_value, points
		FROM achievement_definitions
		WHERE is_active = true
		ORDER BY created_at
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to list active achievement definitions")
	}
	defer rows.Close()

	var defs []repositories.AchievementDef
	for rows.Next() {
		var def repositories.AchievementDef

		err := rows.Scan(
			&def.ID,
			&def.Code,
			&def.ConditionType,
			&def.ConditionValue,
			&def.Points,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan achievement definition")
		}

		defs = append(defs, def)
	}

	return defs, nil
}

// ListUnlockedCodes возвращает список разблокированных кодов достижений для пользователя
// Используется для проверки, какие достижения уже получены пользователем
func (r *AchievementEngineRepository) ListUnlockedCodes(ctx context.Context, userID domain.ID) (map[string]bool, error) {
	query := `
		SELECT ad.code
		FROM user_achievements ua
		JOIN achievement_definitions ad ON ua.achievement_id = ad.id
		WHERE ua.user_id = $1 AND ua.status = 'unlocked'
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to list unlocked achievement codes")
	}
	defer rows.Close()

	unlockedCodes := make(map[string]bool)
	for rows.Next() {
		var code string
		err := rows.Scan(&code)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan achievement code")
		}
		unlockedCodes[code] = true
	}

	return unlockedCodes, nil
}

// UpsertProgress обновляет или создает прогресс достижения для пользователя
// Если unlock=true, устанавливает статус как разблокированное
func (r *AchievementEngineRepository) UpsertProgress(ctx context.Context, userID domain.ID, achievementID domain.ID, progress int, unlock bool) error {
	query := `
		INSERT INTO user_achievements (
			id, user_id, achievement_id, status, progress, unlocked_at, created_at, updated_at
		) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (user_id, achievement_id)
		DO UPDATE SET
			status = $3,
			progress = $4,
			unlocked_at = $5,
			updated_at = $7
	`

	var unlockedAt *time.Time
	if unlock {
		now := time.Now()
		unlockedAt = &now
	}

	_, err := r.db.Exec(ctx, query,
		userID,
		achievementID,
		"unlocked", // status
		progress,
		unlockedAt,
		time.Now(), // created_at
		time.Now(), // updated_at
	)
	if err != nil {
		return errors.Wrap(err, "failed to upsert achievement progress")
	}

	return nil
}
