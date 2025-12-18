package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type UserRepository struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

func NewUserRepository(db *dbpkg.DB, logger *zap.Logger) repositories.UserRepository {
	return &UserRepository{db: db, logger: logger}
}

func (r *UserRepository) GetUser(ctx context.Context, userID domain.ID) (*domain.User, error) {
	return r.getUserBy(ctx, "id", userID.String())
}

func (r *UserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	return r.getUserBy(ctx, "email", email)
}

func (r *UserRepository) getUserBy(ctx context.Context, field string, value any) (*domain.User, error) {
	q := `
SELECT
id, email, password_hash,
display_name, avatar_url, gender, birth_date,
default_location, default_latitude, default_longitude,
timezone, locale,
body_measurements, preferences,
is_active, is_verified, verified_at,
oauth_provider, oauth_id,
last_login_at, login_count,
created_at, updated_at
FROM users
WHERE ` + field + ` = $1
`
	row := r.db.Pool().QueryRow(ctx, q, value)

	var u domain.User
	var (
		id uuid.UUID
		displayName, avatarURL, gender, defaultLocation *string
		birthDate *time.Time
		defLat, defLon *float64
		verifiedAt *time.Time
		oauthProvider, oauthID *string
		lastLoginAt *time.Time
		bodyMeasurements, preferences []byte
	)

	err := row.Scan(
		&id, &u.Email, &u.PasswordHash,
		&displayName, &avatarURL, &gender, &birthDate,
		&defaultLocation, &defLat, &defLon,
		&u.Timezone, &u.Locale,
		&bodyMeasurements, &preferences,
		&u.IsActive, &u.IsVerified, &verifiedAt,
		&oauthProvider, &oauthID,
		&lastLoginAt, &u.LoginCount,
		&u.CreatedAt, &u.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get user")
	}

	u.ID = id
	u.DisplayName = displayName
	u.AvatarURL = avatarURL
	u.Gender = gender
	u.BirthDate = birthDate
	u.DefaultLocation = defaultLocation
	u.DefaultLatitude = defLat
	u.DefaultLongitude = defLon
	u.VerifiedAt = verifiedAt
	u.OAuthProvider = oauthProvider
	u.OAuthID = oauthID
	u.LastLoginAt = lastLoginAt
	if len(bodyMeasurements) > 0 {
		u.BodyMeasurements = bodyMeasurements
	}
	if len(preferences) > 0 {
		u.Preferences = preferences
	}

	return &u, nil
}

func (r *UserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	q := `
INSERT INTO users (email, password_hash, display_name, locale, timezone, is_active, is_verified)
VALUES ($1,$2,$3,$4,$5,true,false)
RETURNING id, created_at, updated_at
`
	if user.Locale == "" {
		user.Locale = "ru"
	}
	if user.Timezone == "" {
		user.Timezone = "Europe/Moscow"
	}

	var id uuid.UUID
	err := r.db.Pool().QueryRow(ctx, q,
		user.Email,
		user.PasswordHash,
		user.DisplayName,
		user.Locale,
		user.Timezone,
	).Scan(&id, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		if pgErr, ok := err.(*pgconn.PgError); ok && pgErr.Code == "23505" {
			if pgErr.ConstraintName == "users_email_key" {
				return repositories.ErrEmailAlreadyExists
			}
		}
		return errors.Wrap(err, "create user")
	}

	user.ID = id
	return nil
}

func (r *UserRepository) UpdateUser(ctx context.Context, user *domain.User) error {
	// Обновляем только безопасный набор полей (без пароля — он через отдельный flow).
	q := `
UPDATE users
SET
display_name = $1,
avatar_url = $2,
gender = $3,
birth_date = $4,
default_location = $5,
default_latitude = $6,
default_longitude = $7,
timezone = $8,
locale = $9,
preferences = COALESCE($10, preferences),
body_measurements = COALESCE($11, body_measurements),
updated_at = NOW()
WHERE id = $12
`
	_, err := r.db.Pool().Exec(ctx, q,
		user.DisplayName,
		user.AvatarURL,
		user.Gender,
		user.BirthDate,
		user.DefaultLocation,
		user.DefaultLatitude,
		user.DefaultLongitude,
		user.Timezone,
		user.Locale,
		nullableJSON(user.Preferences),
		nullableJSON(user.BodyMeasurements),
		user.ID,
	)
	return errors.Wrap(err, "update user")
}

func (r *UserRepository) GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error) {
	return r.GetUser(ctx, userID)
}

func (r *UserRepository) UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error) {
	u, err := r.GetUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, repositories.ErrNotFound
	}

	if patch.DisplayName != nil {
		u.DisplayName = patch.DisplayName
	}
	if patch.AvatarURL != nil {
		u.AvatarURL = patch.AvatarURL
	}
	if patch.Gender != nil {
		u.Gender = patch.Gender
	}
	if patch.DefaultLocation != nil {
		u.DefaultLocation = patch.DefaultLocation
	}
	if patch.DefaultLatitude != nil {
		u.DefaultLatitude = patch.DefaultLatitude
	}
	if patch.DefaultLongitude != nil {
		u.DefaultLongitude = patch.DefaultLongitude
	}
	if patch.Timezone != nil {
		u.Timezone = *patch.Timezone
	}
	if patch.Locale != nil {
		u.Locale = *patch.Locale
	}

	// birth_date в patch строкой — парсинг удобнее делать в handler; тут пропускаем.

	if err := r.UpdateUser(ctx, u); err != nil {
		return nil, err
	}
	return r.GetUser(ctx, userID)
}

func (r *UserRepository) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error) {
	q := `
SELECT
user_id,
recommendations_count,
wardrobe_size,
current_streak,
max_streak,
last_active_date,
perfect_ratings_count,
weather_types_seen,
styles_used,
total_points
FROM user_stats
WHERE user_id = $1
`
	row := r.db.Pool().QueryRow(ctx, q, userID)

	var s domain.UserStats
	var lastActiveDate *time.Time
	var weatherTypes, stylesUsed []string

	err := row.Scan(
		&s.UserID,
		&s.RecommendationsCount,
		&s.WardrobeSize,
		&s.CurrentStreak,
		&s.MaxStreak,
		&lastActiveDate,
		&s.PerfectRatingsCount,
		&weatherTypes,
		&stylesUsed,
		&s.TotalPoints,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get user_stats")
	}

	s.LastActiveDate = lastActiveDate
	s.WeatherTypesSeen = weatherTypes
	s.StylesUsed = stylesUsed
	return &s, nil
}

func (r *UserRepository) GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	q := `
SELECT
a.id, a.code, a.name, a.description, COALESCE(a.icon_emoji,''), a.points,
ua.unlocked_at, ua.progress
FROM user_achievements ua
JOIN achievements a ON a.id = ua.achievement_id
WHERE ua.user_id = $1
ORDER BY ua.unlocked_at DESC NULLS LAST, a.sort_order ASC
`
	rows, err := r.db.Pool().Query(ctx, q, userID)
	if err != nil {
		return nil, errors.Wrap(err, "query user achievements")
	}
	defer rows.Close()

	var out []domain.Achievement
	for rows.Next() {
		var a domain.Achievement
		err := rows.Scan(
			&a.ID,
			&a.Code,
			&a.Name,
			&a.Description,
			&a.IconEmoji,
			&a.Points,
			&a.UnlockedAt,
			&a.Progress,
		)
		if err != nil {
			return nil, errors.Wrap(err, "scan achievement")
		}
		out = append(out, a)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "rows achievements")
	}
	return out, nil
}

func (r *UserRepository) UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error {
	var achievementID uuid.UUID
	err := r.db.Pool().QueryRow(ctx, `SELECT id FROM achievements WHERE code = $1`, achievementCode).Scan(&achievementID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return repositories.ErrNotFound
		}
		return errors.Wrap(err, "find achievement id")
	}

	_, err = r.db.Pool().Exec(ctx, `
INSERT INTO user_achievements (user_id, achievement_id, unlocked_at, progress)
VALUES ($1,$2,NOW(),0)
ON CONFLICT (user_id, achievement_id) DO NOTHING
`, userID, achievementID)
	return errors.Wrap(err, "unlock achievement")
}

func (r *UserRepository) DeleteUser(ctx context.Context, userID domain.ID) error {
	cmd, err := r.db.Pool().Exec(ctx, `DELETE FROM users WHERE id = $1`, userID)
	if err != nil {
		return errors.Wrap(err, "delete user")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *UserRepository) UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error) {
	b, err := json.Marshal(prefs)
	if err != nil {
		return nil, errors.Wrap(err, "marshal preferences")
	}

	// merge: preferences = preferences || patch
	_, err = r.db.Pool().Exec(ctx, `
UPDATE users
SET preferences = COALESCE(preferences, '{}'::jsonb) || $1::jsonb,
    updated_at = NOW()
WHERE id = $2
`, b, userID)
	if err != nil {
		return nil, errors.Wrap(err, "update preferences")
	}
	return r.GetUser(ctx, userID)
}

func (r *UserRepository) UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error) {
	b, err := json.Marshal(bm)
	if err != nil {
		return nil, errors.Wrap(err, "marshal body_measurements")
	}

	_, err = r.db.Pool().Exec(ctx, `
UPDATE users
SET body_measurements = COALESCE(body_measurements, '{}'::jsonb) || $1::jsonb,
    updated_at = NOW()
WHERE id = $2
`, b, userID)
	if err != nil {
		return nil, errors.Wrap(err, "update body_measurements")
	}
	return r.GetUser(ctx, userID)
}

func (r *UserRepository) GetDefaultCoords(ctx context.Context, userID domain.ID) (*float64, *float64, error) {
	var lat *float64
	var lon *float64
	err := r.db.Pool().QueryRow(ctx, `
SELECT default_latitude, default_longitude
FROM users
WHERE id = $1
`, userID).Scan(&lat, &lon)
	if err != nil {
		return nil, nil, errors.Wrap(err, "get default coords")
	}
	return lat, lon, nil
}

func (r *UserRepository) GetUserTimezone(ctx context.Context, userID domain.ID) (string, error) {
	var tz string
	err := r.db.Pool().QueryRow(ctx, `
SELECT COALESCE(timezone, 'Europe/Moscow')
FROM users
WHERE id = $1
`, userID).Scan(&tz)
	if err != nil {
		return "Europe/Moscow", errors.Wrap(err, "get timezone")
	}
	if tz == "" {
		tz = "Europe/Moscow"
	}
	return tz, nil
}

func nullableJSON(b []byte) any {
	if len(b) == 0 {
		return nil
	}
	return b
}
