package postgres

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// UserRepository implements the UserRepository interface for PostgreSQL.
type UserRepository struct {
	db     *DB
	logger *zap.Logger
}

// NewUserRepository creates a new user repository.
func NewUserRepository(db *DB, logger *zap.Logger) repositories.UserRepository {
	return &UserRepository{
		db:     db,
		logger: logger,
	}
}

// GetUser retrieves a user by ID.
func (r *UserRepository) GetUser(ctx context.Context, userID int) (*domain.User, error) {
	query := `
		SELECT id, email, username, created_at, updated_at, is_verified
		FROM users
		WHERE id = $1
	`

	row := r.db.pool.QueryRow(ctx, query, userID)
	user := domain.User{}

	err := row.Scan(
		&user.ID,
		&user.Email,
		&user.Username,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.IsVerified,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // No user found, not an error
		}
		return nil, errors.Wrap(err, "failed to get user")
	}

	return &user, nil
}

// GetUserByEmail retrieves a user by email.
func (r *UserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	query := `
		SELECT id, email, username, password, created_at, updated_at, is_verified
		FROM users
		WHERE email = $1
	`

	row := r.db.pool.QueryRow(ctx, query, email)
	user := domain.User{}

	err := row.Scan(
		&user.ID,
		&user.Email,
		&user.Username,
		&user.Password,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.IsVerified,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // No user found, not an error
		}
		return nil, errors.Wrap(err, "failed to get user by email")
	}

	return &user, nil
}

// CreateUser creates a new user.
func (r *UserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	query := `
		INSERT INTO users (email, username, password, is_verified, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`

	now := time.Now()
	user.CreatedAt = now
	user.UpdatedAt = now

	err := r.db.pool.QueryRow(ctx, query,
		user.Email,
		user.Username,
		user.Password, // Already hashed
		user.IsVerified,
		user.CreatedAt,
		user.UpdatedAt,
	).Scan(&user.ID)

	if err != nil {
		// Проверяем, не дубликат ли email (unique_violation: 23505)
		if pgErr, ok := err.(*pgconn.PgError); ok && pgErr.Code == "23505" {
			if pgErr.ConstraintName == "users_email_key" {
				return repositories.ErrEmailAlreadyExists
			}
		}
		return errors.Wrap(err, "failed to create user")
	}

	r.logger.Info("Created new user",
		zap.Int64("user_id", int64(user.ID)),
		zap.String("email", user.Email),
	)
	return nil
}

// UpdateUser updates an existing user.
func (r *UserRepository) UpdateUser(ctx context.Context, user *domain.User) error {
	query := `
		UPDATE users
		SET email = $1, username = $2, password = $3, is_verified = $4, updated_at = $5
		WHERE id = $6
	`

	user.UpdatedAt = time.Now()

	_, err := r.db.pool.Exec(ctx, query,
		user.Email,
		user.Username,
		user.Password,
		user.IsVerified,
		user.UpdatedAt,
		user.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update user")
	}

	r.logger.Info("Updated user", zap.Int64("user_id", int64(user.ID)))
	return nil
}

// GetUserProfile retrieves a user's profile.
func (r *UserRepository) GetUserProfile(ctx context.Context, userID int) (*domain.UserProfile, error) {
	query := `
		SELECT id, user_id, style_preferences, size, height, weight, 
		       COALESCE(preferred_colors, '[]'::jsonb)::jsonb as preferred_colors,
		       COALESCE(disliked_colors, '[]'::jsonb)::jsonb as disliked_colors,
		       created_at, updated_at
		FROM user_profiles
		WHERE user_id = $1
	`

	row := r.db.pool.QueryRow(ctx, query, userID)
	profile := domain.UserProfile{}
	var preferredColorsJSON, dislikedColorsJSON []byte

	err := row.Scan(
		&profile.ID,
		&profile.UserID,
		&profile.StylePreferences,
		&profile.Size,
		&profile.Height,
		&profile.Weight,
		&preferredColorsJSON,
		&dislikedColorsJSON,
		&profile.CreatedAt,
		&profile.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // No profile found, not an error
		}
		return nil, errors.Wrap(err, "failed to get user profile")
	}

	// Parse JSON arrays
	if preferredColorsJSON != nil {
		if err := json.Unmarshal(preferredColorsJSON, &profile.PreferredColors); err != nil {
			return nil, errors.Wrap(err, "failed to parse preferred colors")
		}
	}

	if dislikedColorsJSON != nil {
		if err := json.Unmarshal(dislikedColorsJSON, &profile.DislikedColors); err != nil {
			return nil, errors.Wrap(err, "failed to parse disliked colors")
		}
	}

	return &profile, nil
}

// UpdateUserProfile updates a user's profile.
func (r *UserRepository) UpdateUserProfile(ctx context.Context, profile *domain.UserProfile) error {
	var (
		preferredColorsJSON []byte
		dislikedColorsJSON  []byte
		err                 error
	)

	if profile.PreferredColors != nil {
		preferredColorsJSON, err = json.Marshal(profile.PreferredColors)
		if err != nil {
			return errors.Wrap(err, "failed to marshal preferred colors")
		}
	}

	if profile.DislikedColors != nil {
		dislikedColorsJSON, err = json.Marshal(profile.DislikedColors)
		if err != nil {
			return errors.Wrap(err, "failed to marshal disliked colors")
		}
	}

	query := `
		UPDATE user_profiles
		SET style_preferences = $1, size = $2, height = $3, weight = $4,
		    preferred_colors = $5, disliked_colors = $6, updated_at = NOW()
		WHERE user_id = $7
	`

	_, err = r.db.pool.Exec(ctx, query,
		profile.StylePreferences,
		profile.Size,
		profile.Height,
		profile.Weight,
		preferredColorsJSON,
		dislikedColorsJSON,
		profile.UserID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update user profile")
	}

	return nil
}

// GetUserAchievements retrieves a user's achievements.
func (r *UserRepository) GetUserAchievements(ctx context.Context, userID int) ([]domain.Achievement, error) {
	query := `
		SELECT a.id, a.code, a.name, a.description, a.icon, a.created_at
		FROM achievements a
		JOIN user_achievements ua ON a.id = ua.achievement_id
		WHERE ua.user_id = $1
		ORDER BY ua.unlocked_at DESC
	`

	rows, err := r.db.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user achievements")
	}
	defer rows.Close()

	var achievements []domain.Achievement
	for rows.Next() {
		var a domain.Achievement
		err = rows.Scan(
			&a.ID,
			&a.Code,
			&a.Name,
			&a.Description,
			&a.Icon,
			&a.CreatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan achievement")
		}
		achievements = append(achievements, a)
	}

	if err = rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating achievements")
	}

	return achievements, nil
}

// UnlockAchievement unlocks an achievement for a user.
func (r *UserRepository) UnlockAchievement(ctx context.Context, userID int, achievementCode string) error {
	// First get the achievement ID
	var achievementID int
	err := r.db.pool.QueryRow(ctx, `
		SELECT id FROM achievements WHERE code = $1
	`, achievementCode).Scan(&achievementID)
	if err != nil {
		if err == pgx.ErrNoRows {
			return errors.Errorf("achievement %s not found", achievementCode)
		}
		return errors.Wrap(err, "failed to find achievement")
	}

	// Insert the achievement
	_, err = r.db.pool.Exec(ctx, `
		INSERT INTO user_achievements (user_id, achievement_id, unlocked_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (user_id, achievement_id) DO NOTHING
	`, userID, achievementID)
	if err != nil {
		return errors.Wrap(err, "failed to unlock achievement")
	}

	r.logger.Info("🏆 Achievement unlocked",
		zap.Int64("user_id", int64(userID)),
		zap.String("achievement_code", achievementCode),
	)

	return nil
}

// RateRecommendation saves a user's rating for a recommendation.
func (r *UserRepository) RateRecommendation(ctx context.Context, userID, recommendationID, rating int, feedback string) error {
	if rating < 1 || rating > 5 {
		return errors.New("rating must be between 1 and 5")
	}

	// Check if recommendation exists and belongs to user
	var exists bool
	err := r.db.pool.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM recommendations r
			JOIN recommendation_items ri ON r.id = ri.recommendation_id
			WHERE r.id = $1 AND r.user_id = $2
		)
	`, recommendationID, userID).Scan(&exists)
	if err != nil {
		return errors.Wrap(err, "failed to check recommendation existence")
	}

	if !exists {
		return errors.New("recommendation not found or does not belong to user")
	}

	// Insert or update rating
	_, err = r.db.pool.Exec(ctx, `
		INSERT INTO user_ratings (user_id, recommendation_id, rating, feedback, created_at)
		VALUES ($1, $2, $3, $4, NOW())
		ON CONFLICT (user_id, recommendation_id) 
		DO UPDATE SET rating = $3, feedback = $4, created_at = NOW()
	`, userID, recommendationID, rating, feedback)
	if err != nil {
		return errors.Wrap(err, "failed to save rating")
	}

	// Update user stats
	_, err = r.db.pool.Exec(ctx, `
		UPDATE user_stats
		SET average_rating = (
			SELECT AVG(rating) FROM user_ratings WHERE user_id = $1
		)
		WHERE user_id = $1
	`, userID)
	if err != nil {
		return errors.Wrap(err, "failed to update average rating")
	}

	return nil
}

// GetUserRatings retrieves user's ratings.
func (r *UserRepository) GetUserRatings(ctx context.Context, userID int) ([]domain.UserRating, error) {
	query := `
		SELECT id, user_id, recommendation_id, rating, feedback, created_at
		FROM user_ratings
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user ratings")
	}
	defer rows.Close()

	var ratings []domain.UserRating
	for rows.Next() {
		var rating domain.UserRating
		err = rows.Scan(
			&rating.ID,
			&rating.UserID,
			&rating.RecommendationID,
			&rating.Rating,
			&rating.Feedback,
			&rating.CreatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan rating")
		}
		ratings = append(ratings, rating)
	}

	if err = rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating ratings")
	}

	return ratings, nil
}

// AddFavorite adds a recommendation to user's favorites.
func (r *UserRepository) AddFavorite(ctx context.Context, userID, recommendationID int) error {
	_, err := r.db.pool.Exec(ctx, `
		INSERT INTO favorite_outfits (user_id, recommendation_id, created_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (user_id, recommendation_id) DO NOTHING
	`, userID, recommendationID)
	if err != nil {
		return errors.Wrap(err, "failed to add favorite")
	}

	return nil
}

// RemoveFavorite removes a recommendation from user's favorites.
func (r *UserRepository) RemoveFavorite(ctx context.Context, userID, favoriteID int) error {
	result, err := r.db.pool.Exec(ctx, `
		DELETE FROM favorite_outfits
		WHERE id = $1 AND user_id = $2
	`, favoriteID, userID)
	if err != nil {
		return errors.Wrap(err, "failed to remove favorite")
	}

	if result.RowsAffected() == 0 {
		return errors.New("favorite not found or not owned by user")
	}

	return nil
}

// GetUserFavorites retrieves user's favorite recommendations.
func (r *UserRepository) GetUserFavorites(ctx context.Context, userID int) ([]domain.FavoriteOutfit, error) {
	query := `
		SELECT id, user_id, recommendation_id, created_at
		FROM favorite_outfits
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query favorites")
	}
	defer rows.Close()

	var favorites []domain.FavoriteOutfit
	for rows.Next() {
		var f domain.FavoriteOutfit
		err = rows.Scan(
			&f.ID,
			&f.UserID,
			&f.RecommendationID,
			&f.CreatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan favorite")
		}
		favorites = append(favorites, f)
	}

	if err = rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating favorites")
	}

	return favorites, nil
}

// CreateOutfitPlan creates a new outfit plan.
func (r *UserRepository) CreateOutfitPlan(ctx context.Context, plan *domain.OutfitPlan) error {
	itemIDsJSON, err := json.Marshal(plan.ItemIDs)
	if err != nil {
		return errors.Wrap(err, "failed to marshal item IDs")
	}

	const query = `
		INSERT INTO outfit_plans (user_id, date, item_ids, notes, created_at, updated_at)
		VALUES ($1, $2, $3, $4, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`

	if err := r.db.pool.QueryRow(ctx, query,
		plan.UserID,
		plan.Date,
		itemIDsJSON,
		plan.Notes,
	).Scan(&plan.ID, &plan.CreatedAt, &plan.UpdatedAt); err != nil {
		return errors.Wrap(err, "failed to create outfit plan")
	}

	return nil
}

// GetOutfitPlans retrieves outfit plans for a user in the given date range.
func (r *UserRepository) GetOutfitPlans(ctx context.Context, userID int, startDate, endDate time.Time) ([]domain.OutfitPlan, error) {
	const query = `
		SELECT id, user_id, date, item_ids, notes, created_at, updated_at
		FROM outfit_plans
		WHERE user_id = $1
		  AND date >= $2
		  AND date <= $3
		  AND deleted_at IS NULL
		ORDER BY date ASC
	`

	rows, err := r.db.pool.Query(ctx, query, userID, startDate, endDate)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query outfit plans")
	}
	defer rows.Close()

	var plans []domain.OutfitPlan
	for rows.Next() {
		var plan domain.OutfitPlan
		var itemIDsJSON []byte

		if err := rows.Scan(
			&plan.ID,
			&plan.UserID,
			&plan.Date,
			&itemIDsJSON,
			&plan.Notes,
			&plan.CreatedAt,
			&plan.UpdatedAt,
		); err != nil {
			return nil, errors.Wrap(err, "failed to scan outfit plan")
		}

		if len(itemIDsJSON) > 0 {
			if err := json.Unmarshal(itemIDsJSON, &plan.ItemIDs); err != nil {
				return nil, errors.Wrap(err, "failed to parse item IDs")
			}
		}

		plans = append(plans, plan)
	}

	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating outfit plans")
	}

	return plans, nil
}

// GetUserOutfitPlans retrieves all user's outfit plans (without date filter).
func (r *UserRepository) GetUserOutfitPlans(ctx context.Context, userID int) ([]domain.OutfitPlan, error) {
	const query = `
		SELECT id, user_id, date, item_ids, notes, created_at, updated_at
		FROM outfit_plans
		WHERE user_id = $1
		  AND deleted_at IS NULL
		ORDER BY date ASC
	`

	rows, err := r.db.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query outfit plans")
	}
	defer rows.Close()

	var plans []domain.OutfitPlan
	for rows.Next() {
		var plan domain.OutfitPlan
		var itemIDsJSON []byte

		if err := rows.Scan(
			&plan.ID,
			&plan.UserID,
			&plan.Date,
			&itemIDsJSON,
			&plan.Notes,
			&plan.CreatedAt,
			&plan.UpdatedAt,
		); err != nil {
			return nil, errors.Wrap(err, "failed to scan outfit plan")
		}

		if len(itemIDsJSON) > 0 {
			if err := json.Unmarshal(itemIDsJSON, &plan.ItemIDs); err != nil {
				return nil, errors.Wrap(err, "failed to parse item IDs")
			}
		}

		plans = append(plans, plan)
	}

	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating outfit plans")
	}

	return plans, nil
}

// DeleteOutfitPlan performs a soft delete of an outfit plan.
func (r *UserRepository) DeleteOutfitPlan(ctx context.Context, userID, planID int) error {
	const query = `
		UPDATE outfit_plans
		SET deleted_at = NOW()
		WHERE id = $1
		  AND user_id = $2
		  AND deleted_at IS NULL
	`

	cmdTag, err := r.db.pool.Exec(ctx, query, planID, userID)
	if err != nil {
		return errors.Wrap(err, "failed to delete outfit plan")
	}

	if cmdTag.RowsAffected() == 0 {
		return errors.New("outfit plan not found or not owned by user")
	}

	return nil
}

// GetUserStats retrieves user statistics.
func (r *UserRepository) GetUserStats(ctx context.Context, userID int) (*domain.UserStats, error) {
	query := `
		SELECT total_recommendations, average_rating, favorite_count,
		       achievement_count, last_active, most_used_category
		FROM user_stats
		WHERE user_id = $1
	`

	row := r.db.pool.QueryRow(ctx, query, userID)
	stats := domain.UserStats{}

	err := row.Scan(
		&stats.TotalRecommendations,
		&stats.AverageRating,
		&stats.FavoriteCount,
		&stats.AchievementCount,
		&stats.LastActive,
		&stats.MostUsedCategory,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // No stats found, not an error
		}
		return nil, errors.Wrap(err, "failed to get user stats")
	}

	return &stats, nil
}

// UpdateUserStats updates user statistics.
func (r *UserRepository) UpdateUserStats(ctx context.Context, userID int, stats *domain.UserStats) error {
	query := `
		UPDATE user_stats
		SET total_recommendations = $1,
		    average_rating = $2,
		    favorite_count = $3,
		    achievement_count = $4,
		    last_active = $5,
		    most_used_category = $6
		WHERE user_id = $7
	`

	_, err := r.db.pool.Exec(ctx, query,
		stats.TotalRecommendations,
		stats.AverageRating,
		stats.FavoriteCount,
		stats.AchievementCount,
		stats.LastActive,
		stats.MostUsedCategory,
		userID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update user stats")
	}

	return nil
}
