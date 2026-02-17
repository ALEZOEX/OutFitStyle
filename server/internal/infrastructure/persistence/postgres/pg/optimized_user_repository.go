// Пакет pg предоставляет репозитории для работы с PostgreSQL
package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

// OptimizedUserRepository оптимизированный репозиторий с batch загрузкой
// Решает проблему N+1 queries через массовую загрузку данных
type OptimizedUserRepository struct {
	db     *pgxpool.Pool
	logger *zap.Logger
}

// NewOptimizedUserRepository создает оптимизированный репозиторий
func NewOptimizedUserRepository(db *pgxpool.Pool, logger *zap.Logger) *OptimizedUserRepository {
	return &OptimizedUserRepository{db: db, logger: logger}
}

// GetUsersBatch массово загружает пользователей по списку ID
// Решает проблему N+1: вместо N запросов выполняет 1 запрос с WHERE IN
func (r *OptimizedUserRepository) GetUsersBatch(ctx context.Context, ids []domain.ID) (map[domain.ID]*domain.User, error) {
	if len(ids) == 0 {
		return make(map[domain.ID]*domain.User), nil
	}

	// Удаляем дубликаты ID
	uniqueIDs := make(map[domain.ID]struct{})
	for _, id := range ids {
		uniqueIDs[id] = struct{}{}
	}

	idArray := make([]domain.ID, 0, len(uniqueIDs))
	for id := range uniqueIDs {
		idArray = append(idArray, id)
	}

	query := `
		SELECT
			id, email, password_hash, display_name, avatar_url, gender, date_of_birth AS birth_date,
			default_location, default_latitude, default_longitude, timezone, locale,
			body_measurements, preferences, is_active, is_verified, verified_at,
			oauth_provider, oauth_id, last_login_at, login_count, created_at, updated_at
		FROM users
		WHERE id = ANY($1)
	`

	rows, err := r.db.Query(ctx, query, pgx.Array(idArray))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := make(map[domain.ID]*domain.User, len(idArray))

	for rows.Next() {
		var user domain.User
		var displayName *string
		var avatarURL *string
		var gender *string
		var birthDate *time.Time
		var defaultLocation *string
		var defaultLatitude *float64
		var defaultLongitude *float64
		var bodyMeasurementsJSON []byte
		var preferencesJSON []byte
		var verifiedAt *time.Time
		var oauthProvider *string
		var oauthID *string
		var lastLoginAt *time.Time
		var createdAt time.Time
		var updatedAt time.Time

		err := rows.Scan(
			&user.ID,
			&user.Email,
			&user.PasswordHash,
			&displayName,
			&avatarURL,
			&gender,
			&birthDate,
			&defaultLocation,
			&defaultLatitude,
			&defaultLongitude,
			&user.Timezone,
			&user.Locale,
			&bodyMeasurementsJSON,
			&preferencesJSON,
			&user.IsActive,
			&user.IsVerified,
			&verifiedAt,
			&oauthProvider,
			&oauthID,
			&lastLoginAt,
			&user.LoginCount,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, err
		}

		user.DisplayName = displayName
		user.AvatarURL = avatarURL
		user.Gender = gender
		user.BirthDate = birthDate
		user.DefaultLocation = defaultLocation
		user.DefaultLatitude = defaultLatitude
		user.DefaultLongitude = defaultLongitude
		user.VerifiedAt = verifiedAt
		user.OAuthProvider = oauthProvider
		user.OAuthID = oauthID
		user.LastLoginAt = lastLoginAt
		user.CreatedAt = createdAt
		user.UpdatedAt = updatedAt

		result[user.ID] = &user
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	r.logger.Debug("Batch loaded users",
		zap.Int("requested", len(ids)),
		zap.Int("loaded", len(result)),
	)

	return result, nil
}

// GetUserProfilesBatch массово загружает профили пользователей
func (r *OptimizedUserRepository) GetUserProfilesBatch(ctx context.Context, userIDs []domain.ID) (map[domain.ID]*domain.UserProfile, error) {
	if len(userIDs) == 0 {
		return make(map[domain.ID]*domain.UserProfile), nil
	}

	query := `
		SELECT id, user_id, style_preferences, size, height, weight,
		       COALESCE(preferred_colors, '[]'::jsonb)::jsonb as preferred_colors,
		       COALESCE(disliked_colors, '[]'::jsonb)::jsonb as disliked_colors,
		       created_at, updated_at
		FROM user_profiles
		WHERE user_id = ANY($1)
	`

	rows, err := r.db.Query(ctx, query, pgx.Array(userIDs))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := make(map[domain.ID]*domain.UserProfile)

	for rows.Next() {
		var profile domain.UserProfile
		var preferredColorsJSON []byte
		var dislikedColorsJSON []byte

		err := rows.Scan(
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
			return nil, err
		}

		// Parse JSON arrays
		if preferredColorsJSON != nil {
			var colors []string
			if err := json.Unmarshal(preferredColorsJSON, &colors); err != nil {
				return nil, err
			}
			profile.PreferredColors = colors
		}

		if dislikedColorsJSON != nil {
			var colors []string
			if err := json.Unmarshal(dislikedColorsJSON, &colors); err != nil {
				return nil, err
			}
			profile.DislikedColors = colors
		}

		result[profile.UserID] = &profile
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	r.logger.Debug("Batch loaded user profiles",
		zap.Int("requested", len(userIDs)),
		zap.Int("loaded", len(result)),
	)

	return result, nil
}

// GetUserStatsBatch массово загружает статистику пользователей
func (r *OptimizedUserRepository) GetUserStatsBatch(ctx context.Context, userIDs []domain.ID) (map[domain.ID]*domain.UserStats, error) {
	if len(userIDs) == 0 {
		return make(map[domain.ID]*domain.UserStats), nil
	}

	query := `
		SELECT user_id, total_recommendations, saved_outfits_count, shared_outfits_count,
		       achievements_count, total_logins, last_active, created_at
		FROM user_stats
		WHERE user_id = ANY($1)
	`

	rows, err := r.db.Query(ctx, query, pgx.Array(userIDs))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := make(map[domain.ID]*domain.UserStats)

	for rows.Next() {
		var stats domain.UserStats
		var lastActive *time.Time
		var createdAt *time.Time

		err := rows.Scan(
			&stats.UserID,
			&stats.TotalRecommendations,
			&stats.SavedOutfitsCount,
			&stats.SharedOutfitsCount,
			&stats.AchievementsCount,
			&stats.TotalLogins,
			&lastActive,
			&createdAt,
		)
		if err != nil {
			return nil, err
		}

		stats.LastActive = lastActive
		stats.CreatedAt = createdAt

		result[stats.UserID] = &stats
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	r.logger.Debug("Batch loaded user stats",
		zap.Int("requested", len(userIDs)),
		zap.Int("loaded", len(result)),
	)

	return result, nil
}
