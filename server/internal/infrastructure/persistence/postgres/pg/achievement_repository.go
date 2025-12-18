package pg

import (
	"context"

	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type AchievementRepository struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

func NewAchievementRepository(db *dbpkg.DB, logger *zap.Logger) repositories.AchievementRepository {
	return &AchievementRepository{db: db, logger: logger}
}

func (r *AchievementRepository) ListAll(ctx context.Context) ([]domain.Achievement, error) {
	q := `
		SELECT id, code, name, description, COALESCE(icon_emoji,''), points
		FROM achievements
		WHERE is_active = TRUE
		ORDER BY sort_order ASC, created_at ASC
	`
	rows, err := r.db.Pool().Query(ctx, q)
	if err != nil {
		return nil, errors.Wrap(err, "list achievements")
	}
	defer rows.Close()

	var out []domain.Achievement
	for rows.Next() {
		var a domain.Achievement
		if err := rows.Scan(&a.ID, &a.Code, &a.Name, &a.Description, &a.IconEmoji, &a.Points); err != nil {
			return nil, errors.Wrap(err, "scan achievement")
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

func (r *AchievementRepository) ListMy(ctx context.Context, userID domain.ID) (unlocked []domain.Achievement, inProgress []domain.Achievement, totalPoints int, err error) {
	// unlocked
	qUnlocked := `
		SELECT a.id, a.code, a.name, a.description, COALESCE(a.icon_emoji,''), a.points, ua.unlocked_at, ua.progress
		FROM user_achievements ua
		JOIN achievements a ON a.id = ua.achievement_id
		WHERE ua.user_id = $1 AND ua.unlocked_at IS NOT NULL
		ORDER BY ua.unlocked_at DESC
	`
	rows, err := r.db.Pool().Query(ctx, qUnlocked, userID)
	if err != nil {
		return nil, nil, 0, errors.Wrap(err, "list unlocked achievements")
	}
	for rows.Next() {
		var a domain.Achievement
		if err := rows.Scan(&a.ID, &a.Code, &a.Name, &a.Description, &a.IconEmoji, &a.Points, &a.UnlockedAt, &a.Progress); err != nil {
			rows.Close()
			return nil, nil, 0, errors.Wrap(err, "scan unlocked achievement")
		}
		totalPoints += a.Points
		unlocked = append(unlocked, a)
	}
	rows.Close()

	// in progress (прогресс > 0 и еще не unlocked)
	qProgress := `
		SELECT a.id, a.code, a.name, a.description, COALESCE(a.icon_emoji,''), a.points, ua.unlocked_at, ua.progress
		FROM user_achievements ua
		JOIN achievements a ON a.id = ua.achievement_id
		WHERE ua.user_id = $1 AND ua.unlocked_at IS NULL AND ua.progress > 0
		ORDER BY ua.created_at DESC
	`
	rows2, err := r.db.Pool().Query(ctx, qProgress, userID)
	if err != nil {
		return unlocked, nil, totalPoints, errors.Wrap(err, "list in-progress achievements")
	}
	defer rows2.Close()

	for rows2.Next() {
		var a domain.Achievement
		if err := rows2.Scan(&a.ID, &a.Code, &a.Name, &a.Description, &a.IconEmoji, &a.Points, &a.UnlockedAt, &a.Progress); err != nil {
			return unlocked, nil, totalPoints, errors.Wrap(err, "scan in-progress achievement")
		}
		inProgress = append(inProgress, a)
	}

	return unlocked, inProgress, totalPoints, rows2.Err()
}