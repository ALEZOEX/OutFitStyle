// Package pg contains implementations of repositories for working with PostgreSQL
// Implements repository interfaces using the pgx library
package pg

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// AchievementEngineRepository repository for working with user achievements
type AchievementEngineRepository struct {
	db *pgxpool.Pool // Pool of connections to PostgreSQL database
}

// NewAchievementEngineRepository creates a new instance of achievement repository
func NewAchievementEngineRepository(db *pgxpool.Pool) *AchievementEngineRepository {
	return &AchievementEngineRepository{db: db}
}

// ListActiveDefinitions returns a list of active achievement definitions
// Used to retrieve all active achievements in the system
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

// ListUnlockedCodes returns a list of unlocked achievement codes for a user
// Used to check which achievements have already been earned by the user
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

// UpsertProgress updates or creates achievement progress for a user
// If unlock=true, sets the status as unlocked
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
