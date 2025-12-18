package pg

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type AchievementEngineRepository struct {
	db *dbpkg.DB
}

func NewAchievementEngineRepository(db *dbpkg.DB) repositories.AchievementEngineRepository {
	return &AchievementEngineRepository{db: db}
}

func (r *AchievementEngineRepository) ListActiveDefinitions(ctx context.Context) ([]repositories.AchievementDef, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT id, code, condition_type, condition_value, points
FROM achievements
WHERE is_active = TRUE
ORDER BY sort_order ASC, created_at ASC
`)
	if err != nil {
		return nil, errors.Wrap(err, "list achievements defs")
	}
	defer rows.Close()

	var out []repositories.AchievementDef
	for rows.Next() {
		var a repositories.AchievementDef
		if err := rows.Scan(&a.ID, &a.Code, &a.ConditionType, &a.ConditionValue, &a.Points); err != nil {
			return nil, errors.Wrap(err, "scan achievement def")
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

func (r *AchievementEngineRepository) ListUnlockedCodes(ctx context.Context, userID domain.ID) (map[string]bool, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT a.code
FROM user_achievements ua
JOIN achievements a ON a.id = ua.achievement_id
WHERE ua.user_id = $1 AND ua.unlocked_at IS NOT NULL
`, userID)
	if err != nil {
		return nil, errors.Wrap(err, "list unlocked codes")
	}
	defer rows.Close()

	out := map[string]bool{}
	for rows.Next() {
		var code string
		if err := rows.Scan(&code); err != nil {
			return nil, errors.Wrap(err, "scan unlocked code")
		}
		out[code] = true
	}
	return out, rows.Err()
}

func (r *AchievementEngineRepository) UpsertProgress(ctx context.Context, userID domain.ID, achievementID domain.ID, progress int, unlock bool) error {
	// unlock=true -> set unlocked_at if null
	_, err := r.db.Pool().Exec(ctx, `
INSERT INTO user_achievements (user_id, achievement_id, progress, unlocked_at)
VALUES ($1,$2,$3, CASE WHEN $4 THEN NOW() ELSE NULL END)
ON CONFLICT (user_id, achievement_id) DO UPDATE
SET progress = GREATEST(user_achievements.progress, EXCLUDED.progress),
    unlocked_at = CASE
      WHEN user_achievements.unlocked_at IS NULL AND $4 THEN NOW()
      ELSE user_achievements.unlocked_at
    END
`, userID, achievementID, progress, unlock)
	return errors.Wrap(err, "upsert user_achievement")
}