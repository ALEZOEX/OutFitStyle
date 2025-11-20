package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

var dbInstance *DB

type DB struct {
	pool   *pgxpool.Pool
	logger *zap.Logger
}

func NewDB(connectionString string, logger *zap.Logger) (*DB, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if !strings.Contains(connectionString, "sslmode=") {
		if strings.Contains(connectionString, "?") {
			connectionString += "&sslmode=disable"
		} else {
			connectionString += "?sslmode=disable"
		}
	}

	poolConfig, err := pgxpool.ParseConfig(connectionString)
	if err != nil {
		return nil, fmt.Errorf("failed to parse connection string: %w", err)
	}

	// Configure pool settings
	poolConfig.MaxConns = 25
	poolConfig.MinConns = 5
	poolConfig.MaxConnLifetime = time.Hour
	poolConfig.MaxConnIdleTime = 30 * time.Minute
	poolConfig.HealthCheckPeriod = time.Minute
	poolConfig.ConnConfig.ConnectTimeout = 5 * time.Second

	if poolConfig.ConnConfig.RuntimeParams == nil {
		poolConfig.ConnConfig.RuntimeParams = make(map[string]string)
	}
	poolConfig.ConnConfig.RuntimeParams["application_name"] = "outfitstyle-api"

	pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to create connection pool: %w", err)
	}

	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	logger.Info("✅ Connected to PostgreSQL database",
		zap.String("host", poolConfig.ConnConfig.Host),
		zap.Int("port", int(poolConfig.ConnConfig.Port)),
	)

	db := &DB{pool: pool, logger: logger}
	dbInstance = db
	return db, nil
}

func GetDB() *DB {
	return dbInstance
}

func (d *DB) Close() {
	if d.pool != nil {
		d.pool.Close()
		d.logger.Info("🔌 Database connection closed")
	}
}

func (d *DB) Ping() error {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	return d.pool.Ping(ctx)
}

func (d *DB) GetUserProfile(userID int) (*domain.UserProfile, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		SELECT id, user_id, style_preferences, size, height, weight, 
		       COALESCE(preferred_colors, '[]'::jsonb)::jsonb as preferred_colors,
		       COALESCE(disliked_colors, '[]'::jsonb)::jsonb as disliked_colors,
		       created_at, updated_at
		FROM user_profiles
		WHERE user_id = $1
	`

	row := d.pool.QueryRow(ctx, query, userID)
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
		return nil, fmt.Errorf("failed to get user profile: %w", err)
	}

	// Parse JSON arrays
	if preferredColorsJSON != nil {
		if err := json.Unmarshal(preferredColorsJSON, &profile.PreferredColors); err != nil {
			return nil, fmt.Errorf("failed to parse preferred colors: %w", err)
		}
	}

	if dislikedColorsJSON != nil {
		if err := json.Unmarshal(dislikedColorsJSON, &profile.DislikedColors); err != nil {
			return nil, fmt.Errorf("failed to parse disliked colors: %w", err)
		}
	}

	return &profile, nil
}

func (d *DB) SaveRecommendation(
	userID int,
	weather *domain.WeatherData,
	recommendation *domain.RecommendationResponse,
) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	tx, err := d.pool.Begin(ctx)
	if err != nil {
		return 0, fmt.Errorf("failed to begin transaction: %w", err)
	}

	defer func() {
		if err != nil {
			_ = tx.Rollback(ctx)
		}
	}()

	// Insert recommendation
	recommendationID := 0
	outfitScore := recommendation.OutfitScore

	err = tx.QueryRow(ctx, `
		INSERT INTO recommendations (
			user_id, temperature, weather, outfit_score, ml_powered, algorithm, location
		) VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id
	`,
		userID,
		weather.Temperature,
		weather.Weather,
		outfitScore,
		true, // ML powered
		recommendation.Algorithm,
		weather.Location,
	).Scan(&recommendationID)
	if err != nil {
		return 0, fmt.Errorf("failed to insert recommendation: %w", err)
	}

	// Insert recommendation items
	for _, item := range recommendation.Items {
		_, err = tx.Exec(ctx, `
			INSERT INTO recommendation_items (
				recommendation_id, clothing_item_id, name, category, icon_emoji, ml_score, confidence
			) VALUES ($1, $2, $3, $4, $5, $6, $7)
			ON CONFLICT (recommendation_id, clothing_item_id) 
			DO UPDATE SET 
				name = EXCLUDED.name,
				category = EXCLUDED.category,
				icon_emoji = EXCLUDED.icon_emoji,
				ml_score = EXCLUDED.ml_score,
				confidence = EXCLUDED.confidence
		`,
			recommendationID,
			item.ID,
			item.Name,
			item.Category,
			item.IconEmoji,
			item.MLScore, // ИСПРАВЛЕНО: было item.MLSore
			item.Confidence,
		)
		if err != nil {
			return 0, fmt.Errorf("failed to insert recommendation item: %w", err)
		}
	}

	// Update user stats
	_, err = tx.Exec(ctx, `
		INSERT INTO user_stats (user_id, total_recommendations, last_active)
		VALUES ($1, 1, NOW())
		ON CONFLICT (user_id) 
		DO UPDATE SET 
			total_recommendations = user_stats.total_recommendations + 1,
			last_active = NOW()
	`, userID)
	if err != nil {
		return 0, fmt.Errorf("failed to update user stats: %w", err)
	}

	// Commit transaction
	if err = tx.Commit(ctx); err != nil {
		return 0, fmt.Errorf("failed to commit transaction: %w", err)
	}

	return recommendationID, nil
}

// HealthCheck implements the health check for the database.
func (d *DB) HealthCheck() error {
	return d.Ping()
}
