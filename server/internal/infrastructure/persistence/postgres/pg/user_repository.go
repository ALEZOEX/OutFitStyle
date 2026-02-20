// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/core/domain"
)

// UserRepository репозиторий для работы с пользовательскими данными
type UserRepository struct {
	db     *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
	logger *zap.Logger   // Логгер для записи событий
}

// NewUserRepository создает новый экземпляр репозитория пользователей
func NewUserRepository(db *pgxpool.Pool, logger *zap.Logger) *UserRepository {
	return &UserRepository{db: db, logger: logger}
}

// GetUser возвращает пользователя по его идентификатору
func (r *UserRepository) GetUser(ctx context.Context, id domain.ID) (*domain.User, error) {
	query := `
		SELECT
			id, email, password_hash, display_name, avatar_url, gender, date_of_birth AS birth_date,
			default_location, default_latitude, default_longitude, timezone, locale,
			body_measurements, preferences, is_active, is_verified, verified_at,
			oauth_provider, oauth_id, last_login_at, login_count, created_at, updated_at
		FROM users
		WHERE id = $1
	`

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

	err := r.db.QueryRow(ctx, query, id).Scan(
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
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get user by ID")
	}

	// Set nullable fields
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

	// Parse JSON fields
	if len(bodyMeasurementsJSON) > 0 {
		err = json.Unmarshal(bodyMeasurementsJSON, &user.BodyMeasurements)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal body measurements")
		}
	}

	if len(preferencesJSON) > 0 {
		err = json.Unmarshal(preferencesJSON, &user.Preferences)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal preferences")
		}
	}

	return &user, nil
}

// GetUserByEmail возвращает пользователя по его email
func (r *UserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	query := `
		SELECT
			id, email, password_hash, display_name, avatar_url, gender, date_of_birth AS birth_date,
			default_location, default_latitude, default_longitude, timezone, locale,
			body_measurements, preferences, is_active, is_verified, verified_at,
			oauth_provider, oauth_id, last_login_at, login_count, created_at, updated_at
		FROM users
		WHERE email = $1
	`

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

	err := r.db.QueryRow(ctx, query, email).Scan(
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
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get user by email")
	}

	// Set nullable fields
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

	// Parse JSON fields
	if len(bodyMeasurementsJSON) > 0 {
		err = json.Unmarshal(bodyMeasurementsJSON, &user.BodyMeasurements)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal body measurements")
		}
	}

	if len(preferencesJSON) > 0 {
		err = json.Unmarshal(preferencesJSON, &user.Preferences)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal preferences")
		}
	}

	return &user, nil
}

// CreateUser создает нового пользователя в базе данных
func (r *UserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	query := `
		INSERT INTO users (
			id, email, password_hash, display_name, avatar_url, gender, date_of_birth,
			default_location, default_latitude, default_longitude, timezone, locale,
			body_measurements, preferences, is_active, is_verified, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
	`

	displayName := user.DisplayName
	if displayName == nil {
		displayName = new(string)
	}

	bodyMeasurementsJSON, err := json.Marshal(user.BodyMeasurements)
	if err != nil {
		return errors.Wrap(err, "failed to marshal body measurements")
	}

	preferencesJSON, err := json.Marshal(user.Preferences)
	if err != nil {
		return errors.Wrap(err, "failed to marshal preferences")
	}

	_, err = r.db.Exec(ctx, query,
		user.ID,
		user.Email,
		user.PasswordHash,
		displayName,
		user.AvatarURL,
		user.Gender,
		user.BirthDate,
		user.DefaultLocation,
		user.DefaultLatitude,
		user.DefaultLongitude,
		user.Timezone,
		user.Locale,
		bodyMeasurementsJSON,
		preferencesJSON,
		user.IsActive,
		user.IsVerified,
		user.CreatedAt,
		user.UpdatedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to create user")
	}

	return nil
}

// UpdateUser обновляет информацию о пользователе
func (r *UserRepository) UpdateUser(ctx context.Context, user *domain.User) error {
	query := `
		UPDATE users
		SET display_name = $1, avatar_url = $2, gender = $3, date_of_birth = $4,
			default_location = $5, default_latitude = $6, default_longitude = $7,
			timezone = $8, locale = $9, body_measurements = $10, preferences = $11,
			is_active = $12, is_verified = $13, last_login_at = $14, login_count = $15,
			updated_at = $16
		WHERE id = $17
	`

	bodyMeasurementsJSON, err := json.Marshal(user.BodyMeasurements)
	if err != nil {
		return errors.Wrap(err, "failed to marshal body measurements")
	}

	preferencesJSON, err := json.Marshal(user.Preferences)
	if err != nil {
		return errors.Wrap(err, "failed to marshal preferences")
	}

	_, err = r.db.Exec(ctx, query,
		user.DisplayName,
		user.AvatarURL,
		user.Gender,
		user.BirthDate,
		user.DefaultLocation,
		user.DefaultLatitude,
		user.DefaultLongitude,
		user.Timezone,
		user.Locale,
		bodyMeasurementsJSON,
		preferencesJSON,
		user.IsActive,
		user.IsVerified,
		user.LastLoginAt,
		user.LoginCount,
		time.Now(),
		user.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update user")
	}

	return nil
}

// UpdatePassword обновляет пароль пользователя
func (r *UserRepository) UpdatePassword(ctx context.Context, userID domain.ID, newPassword string) error {
	// Хешируем пароль с тем же cost, что и при регистрации (12)
	hash, err := bcrypt.GenerateFromPassword([]byte(newPassword), 12)
	if err != nil {
		return errors.Wrap(err, "failed to hash password")
	}

	query := `
		UPDATE users
		SET password_hash = $1, updated_at = $2
		WHERE id = $3
	`

	_, err = r.db.Exec(ctx, query, string(hash), time.Now(), userID)
	if err != nil {
		return errors.Wrap(err, "failed to update password")
	}

	return nil
}

// GetUserProfile возвращает профиль пользователя
func (r *UserRepository) GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error) {
	return r.GetUser(ctx, userID)
}

// UpdateUserProfile обновляет профиль пользователя
func (r *UserRepository) UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error) {
	// First get the current user
	currentUser, err := r.GetUser(ctx, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get current user")
	}
	if currentUser == nil {
		return nil, errors.New("user not found")
	}

	// Apply updates from patch
	if patch.DisplayName != nil {
		currentUser.DisplayName = patch.DisplayName
	}
	if patch.AvatarURL != nil {
		currentUser.AvatarURL = patch.AvatarURL
	}
	if patch.Gender != nil {
		currentUser.Gender = patch.Gender
	}
	if patch.BirthDate != nil {
		if *patch.BirthDate != "" {
			parsedTime, err := time.Parse("2006-01-02", *patch.BirthDate)
			if err != nil {
				return nil, errors.Wrap(err, "failed to parse birth date")
			}
			currentUser.BirthDate = &parsedTime
		} else {
			currentUser.BirthDate = nil
		}
	}
	if patch.DefaultLocation != nil {
		currentUser.DefaultLocation = patch.DefaultLocation
	}
	if patch.DefaultLatitude != nil {
		currentUser.DefaultLatitude = patch.DefaultLatitude
	}
	if patch.DefaultLongitude != nil {
		currentUser.DefaultLongitude = patch.DefaultLongitude
	}
	if patch.Timezone != nil {
		currentUser.Timezone = *patch.Timezone
	}
	if patch.Locale != nil {
		currentUser.Locale = *patch.Locale
	}

	// Update the user
	err = r.UpdateUser(ctx, currentUser)
	if err != nil {
		return nil, errors.Wrap(err, "failed to update user profile")
	}

	return currentUser, nil
}

// GetUserStats возвращает статистику пользователя
func (r *UserRepository) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error) {
	query := `
		SELECT
			user_id, recommendations_count, wardrobe_size, current_streak, max_streak, last_active_date,
			perfect_ratings_count, weather_types_seen, styles_used, total_points
		FROM user_stats
		WHERE user_id = $1
	`

	var stats domain.UserStats
	var lastActiveDate *time.Time
	var weatherTypesSeenJSON []byte
	var stylesUsedJSON []byte

	err := r.db.QueryRow(ctx, query, userID).Scan(
		&stats.UserID,
		&stats.RecommendationsCount,
		&stats.WardrobeSize,
		&stats.CurrentStreak,
		&stats.MaxStreak,
		&lastActiveDate,
		&stats.PerfectRatingsCount,
		&weatherTypesSeenJSON,
		&stylesUsedJSON,
		&stats.TotalPoints,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			// Return default stats if none exist
			return &domain.UserStats{
				UserID:               userID,
				RecommendationsCount: 0,
				WardrobeSize:         0,
				CurrentStreak:        0,
				MaxStreak:            0,
				PerfectRatingsCount:  0,
				TotalPoints:          0,
			}, nil
		}
		return nil, errors.Wrap(err, "failed to get user stats")
	}

	// Set nullable fields
	stats.LastActiveDate = lastActiveDate

	// Parse JSON fields
	if len(weatherTypesSeenJSON) > 0 {
		err = json.Unmarshal(weatherTypesSeenJSON, &stats.WeatherTypesSeen)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal weather types seen")
		}
	}

	if len(stylesUsedJSON) > 0 {
		err = json.Unmarshal(stylesUsedJSON, &stats.StylesUsed)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal styles used")
		}
	}

	return &stats, nil
}

// GetUserAchievements возвращает достижения пользователя
func (r *UserRepository) GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
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
		return nil, errors.Wrap(err, "failed to query user achievements")
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

// UnlockAchievement разблокирует достижение для пользователя
func (r *UserRepository) UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error {
	query := `
		INSERT INTO user_achievements (
			id, user_id, achievement_id, code, status, progress, unlocked_at, created_at, updated_at
		) SELECT gen_random_uuid(), $1, id, code, 'unlocked', 100, NOW(), NOW(), NOW()
		FROM achievements
		WHERE code = $2
		ON CONFLICT (user_id, achievement_id)
		DO UPDATE SET status = 'unlocked', progress = 100, unlocked_at = NOW(), updated_at = NOW()
	`

	_, err := r.db.Exec(ctx, query, userID, achievementCode)
	if err != nil {
		return errors.Wrap(err, "failed to unlock achievement")
	}

	return nil
}

// UpdatePreferences обновляет пользовательские предпочтения
func (r *UserRepository) UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error) {
	// Get current user
	currentUser, err := r.GetUser(ctx, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get current user")
	}
	if currentUser == nil {
		return nil, errors.New("user not found")
	}

	// Update preferences
	prefsJSON, err := json.Marshal(prefs)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal user preferences")
	}
	currentUser.Preferences = prefsJSON

	// Update the user
	err = r.UpdateUser(ctx, currentUser)
	if err != nil {
		return nil, errors.Wrap(err, "failed to update user preferences")
	}

	return currentUser, nil
}

// UpdateBodyMeasurements обновляет антропометрические данные пользователя
func (r *UserRepository) UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error) {
	// Get current user
	currentUser, err := r.GetUser(ctx, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get current user")
	}
	if currentUser == nil {
		return nil, errors.New("user not found")
	}

	// Update body measurements
	bmJSON, err := json.Marshal(bm)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal body measurements")
	}
	currentUser.BodyMeasurements = bmJSON

	// Update the user
	err = r.UpdateUser(ctx, currentUser)
	if err != nil {
		return nil, errors.Wrap(err, "failed to update body measurements")
	}

	return currentUser, nil
}

// GetDefaultCoords возвращает координаты по умолчанию пользователя
func (r *UserRepository) GetDefaultCoords(ctx context.Context, userID domain.ID) (lat *float64, lon *float64, err error) {
	query := `
		SELECT default_latitude, default_longitude
		FROM users
		WHERE id = $1
	`

	var latitude *float64
	var longitude *float64

	err = r.db.QueryRow(ctx, query, userID).Scan(&latitude, &longitude)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil, nil
		}
		return nil, nil, errors.Wrap(err, "failed to get default coordinates")
	}

	return latitude, longitude, nil
}

// DeleteUser удаляет пользователя из базы данных
func (r *UserRepository) DeleteUser(ctx context.Context, userID domain.ID) error {
	query := `DELETE FROM users WHERE id = $1`

	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return errors.Wrap(err, "failed to delete user")
	}

	return nil
}

// RateRecommendation сохраняет оценку пользователя для рекомендации
func (r *UserRepository) RateRecommendation(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	query := `
		INSERT INTO recommendation_ratings (
			id, user_id, recommendation_id, rating, feedback, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (user_id, recommendation_id)
		DO UPDATE SET rating = $4, feedback = $5, updated_at = $7
	`

	id := domain.NewID()
	now := time.Now()

	_, err := r.db.Exec(ctx, query,
		id,
		userID,
		recommendationID,
		rating,
		&feedback,
		now,
		now,
	)
	if err != nil {
		return errors.Wrap(err, "failed to rate recommendation")
	}

	return nil
}

// GetUserTimezone возвращает часовой пояс пользователя
func (r *UserRepository) GetUserTimezone(ctx context.Context, userID domain.ID) (string, error) {
	query := `SELECT timezone FROM users WHERE id = $1`

	var timezone string
	err := r.db.QueryRow(ctx, query, userID).Scan(&timezone)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return "", nil
		}
		return "", errors.Wrap(err, "failed to get user timezone")
	}

	return timezone, nil
}
