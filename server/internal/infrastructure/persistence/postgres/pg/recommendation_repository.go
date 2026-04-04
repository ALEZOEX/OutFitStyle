package pg

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/cache"
)

type RecommendationRepository struct {
	db    *pgxpool.Pool
	cache *cache.RepositoryCache
}

func NewRecommendationRepository(db *pgxpool.Pool, redisClient *redis.Client, logger interface{}) *RecommendationRepository {
	var zapLogger *zap.Logger
	if l, ok := logger.(*zap.Logger); ok {
		zapLogger = l
	} else {
		// Create a default logger if the passed logger is not a zap logger
		zapLogger = zap.NewNop()
	}

	return &RecommendationRepository{
		db:    db,
		cache: cache.NewRepositoryCache(redisClient, zapLogger),
	}
}

func (r *RecommendationRepository) Create(ctx context.Context, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	// Реализация осталась прежней
	return r.createWithSessionInternal(ctx, nil, rec, items)
}

func (r *RecommendationRepository) CreateWithSession(ctx context.Context, session *repositories.RecommendationSession, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	return r.createWithSessionInternal(ctx, session, rec, items)
}

func (r *RecommendationRepository) createWithSessionInternal(ctx context.Context, session *repositories.RecommendationSession, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to begin transaction: %w", err)
	}

	defer func() {
		if err != nil {
			_ = tx.Rollback(ctx)
		}
	}()

	// Создаем сессию, если она передана
	var sessionID *uuid.UUID
	if session != nil {
		sessionUUID := uuid.New()
		sessionID = &sessionUUID

		weatherData := session.WeatherData
		if weatherData == nil {
			weatherData = []byte("{}")
		}

		userPrefs := session.UserPreferences
		if userPrefs == nil {
			userPrefs = []byte("{}")
		}

		// DEBUG: Логирование weatherData перед вставкой
		fmt.Printf("[DEBUG] weatherData: %s\n", string(weatherData))
		fmt.Printf("[DEBUG] userPrefs: %s\n", string(userPrefs))

		_, err = tx.Exec(ctx, `
			INSERT INTO recommendation_sessions (
				id, user_id, context_hash, model_version, weather_data, user_preferences
			) VALUES ($1, $2, $3, $4, $5, $6)
		`, sessionID, session.UserID, session.ContextHash, session.ModelVersion, weatherData, userPrefs)
		if err != nil {
			return domain.NilID, fmt.Errorf("failed to insert recommendation session: %w", err)
		}
	}

	// Insert recommendation
	recID := domain.NewID()
	outfitScore := 0.0
	if rec.TotalScore != nil {
		outfitScore = *rec.TotalScore
	}

	algorithm := "default"
	if rec.ModelVersion != nil {
		algorithm = *rec.ModelVersion
	}

	location := ""
	if rec.Location != nil {
		location = *rec.Location
	}

	city := ""
	if rec.City != nil {
		city = *rec.City
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO recommendations (
			id, user_id, city, temperature, weather, outfit_score, ml_powered, algorithm, location
		) VALUES ($1, $2, $3, $4, $5::jsonb, $6, $7, $8, $9)
	`, recID, rec.UserID, city, 0.0, "{}", outfitScore, true, algorithm, location)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to insert recommendation: %w", err)
	}

	// Insert recommendation items
	for i, item := range items {
		var score *float64
		if item.Score != nil {
			score = item.Score
		}

		rank := i + 1 // Устанавливаем ранг на основе порядка в массиве

		_, err = tx.Exec(ctx, `
			INSERT INTO recommendation_items (
				id, recommendation_id, clothing_item_id, category, source, is_from_wardrobe, alternatives_json, session_id, score, rank
			) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9)
			ON CONFLICT (recommendation_id, clothing_item_id)
			DO UPDATE SET
				category = EXCLUDED.category,
				source = EXCLUDED.source,
				is_from_wardrobe = EXCLUDED.is_from_wardrobe,
				alternatives_json = EXCLUDED.alternatives_json,
				session_id = EXCLUDED.session_id,
				score = EXCLUDED.score,
				rank = EXCLUDED.rank
		`,
			recID, item.ClothingItemID, item.Category, item.Source, item.IsFromWardrobe, item.AlternativesJSON, sessionID, score, rank)
		if err != nil {
			return domain.NilID, fmt.Errorf("failed to insert recommendation item: %w", err)
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
	`, rec.UserID)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to update user stats: %w", err)
	}

	// Commit transaction
	if err = tx.Commit(ctx); err != nil {
		return domain.NilID, fmt.Errorf("failed to commit transaction: %w", err)
	}

	return recID, nil
}

func (r *RecommendationRepository) CreateRecommendation(ctx context.Context, rec *domain.RecommendationResponse) (*domain.RecommendationResponse, error) {
	query := `
		INSERT INTO recommendations (
			id, user_id, city, weather, outfit, created_at, source, score, outfit_score, algorithm, items, location, temperature, feels_like, wind_speed, min_temp, max_temp, will_rain, will_snow, humidity, timestamp, ml_powered
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22)
	`

	id := domain.NewID()
	now := time.Now()

	weatherJSON, err := json.Marshal(rec.Weather)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal weather data")
	}

	outfitJSON, err := json.Marshal(rec.Outfit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal outfit data")
	}

	itemsJSON, err := json.Marshal(rec.Items)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal items data")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		rec.UserID,
		rec.City,
		weatherJSON,
		outfitJSON,
		now,
		rec.Source,
		rec.Score,
		rec.OutfitScore,
		rec.Algorithm,
		itemsJSON,
		rec.Location,
		rec.Temperature,
		rec.FeelsLike,
		rec.WindSpeed,
		rec.MinTemp,
		rec.MaxTemp,
		rec.WillRain,
		rec.WillSnow,
		rec.Humidity,
		rec.Timestamp,
		rec.MLPowered,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to create recommendation")
	}

	rec.ID = id
	rec.CreatedAt = now

	return rec, nil
}

func (r *RecommendationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.RecommendationRecord, error) {
	cacheKey := r.cache.GenerateKey("recommendation:id", id)

	var cachedRec domain.RecommendationRecord
	err := r.cache.Get(ctx, cacheKey, &cachedRec)
	if err == nil && cachedRec.ID != domain.NilID {
		// Return cached recommendation if found
		return &cachedRec, nil
	}

	query := `
		SELECT
			id, user_id, city, weather, outfit, created_at, source, score, outfit_score, algorithm, items, location, temperature, feels_like, wind_speed, min_temp, max_temp, will_rain, will_snow, humidity, timestamp, ml_powered
		FROM recommendations
		WHERE id = $1
	`

	var rec domain.RecommendationRecord
	var weatherJSON []byte
	var outfitJSON []byte
	var itemsJSON []byte
	var createdAt time.Time
	var timestamp time.Time

	err = r.db.QueryRow(ctx, query, id).Scan(
		&rec.ID,
		&rec.UserID,
		&rec.City,
		&weatherJSON,
		&outfitJSON,
		&createdAt,
		&rec.Source,
		&rec.Score,
		&rec.OutfitScore,
		&rec.Algorithm,
		&itemsJSON,
		&rec.Location,
		&rec.Temperature,
		&rec.FeelsLike,
		&rec.WindSpeed,
		&rec.MinTemp,
		&rec.MaxTemp,
		&rec.WillRain,
		&rec.WillSnow,
		&rec.Humidity,
		&timestamp,
		&rec.MLPowered,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get recommendation by ID")
	}

	// Parse JSON fields
	if len(weatherJSON) > 0 {
		err = json.Unmarshal(weatherJSON, &rec.Weather)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal weather data")
		}
	}

	if len(outfitJSON) > 0 {
		err = json.Unmarshal(outfitJSON, &rec.Outfit)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal outfit data")
		}
	}

	if len(itemsJSON) > 0 {
		err = json.Unmarshal(itemsJSON, &rec.Items)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal items data")
		}
	}

	rec.CreatedAt = createdAt
	if !timestamp.IsZero() {
		rec.Timestamp = &timestamp
	}

	// Cache the result
	go func() {
		// Use background context to avoid cancellation issues
		bgCtx := context.Background()
		_ = r.cache.Set(bgCtx, cacheKey, &rec, 10*time.Minute)
	}()

	return &rec, nil
}

// GetByUserAndID gets a recommendation by its ID and verifies it belongs to the user
func (r *RecommendationRepository) GetByUserAndID(ctx context.Context, userID, id domain.ID) (*domain.RecommendationRecord, error) {
	query := `
		SELECT
			id, user_id, city, weather, outfit, created_at, source, score, outfit_score, algorithm, items, location, temperature, feels_like, wind_speed, min_temp, max_temp, will_rain, will_snow, humidity, timestamp, ml_powered
		FROM recommendations
		WHERE user_id = $1 AND id = $2
	`

	var rec domain.RecommendationRecord
	var weatherJSON []byte
	var outfitJSON []byte
	var itemsJSON []byte
	var createdAt time.Time
	var timestamp *time.Time

	err := r.db.QueryRow(ctx, query, userID, id).Scan(
		&rec.ID,
		&rec.UserID,
		&rec.City,
		&weatherJSON,
		&outfitJSON,
		&createdAt,
		&rec.Source,
		&rec.Score,
		&rec.OutfitScore,
		&rec.Algorithm,
		&itemsJSON,
		&rec.Location,
		&rec.Temperature,
		&rec.FeelsLike,
		&rec.WindSpeed,
		&rec.MinTemp,
		&rec.MaxTemp,
		&rec.WillRain,
		&rec.WillSnow,
		&rec.Humidity,
		&timestamp,
		&rec.MLPowered,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get recommendation by user and ID")
	}

	// Handle nullable timestamp
	rec.Timestamp = timestamp

	// Parse JSON fields
	if len(weatherJSON) > 0 {
		err = json.Unmarshal(weatherJSON, &rec.Weather)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal weather data")
		}
	}

	if len(outfitJSON) > 0 {
		err = json.Unmarshal(outfitJSON, &rec.Outfit)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal outfit data")
		}
	}

	// Всегда загружаем предметы из recommendation_items (itemsJSON в recommendations пуст)
	rows, qErr := r.db.Query(ctx, `
		SELECT ri.id, ri.clothing_item_id, ci.name, ri.category, ri.is_from_wardrobe, ri.score, ri.rank
		FROM recommendation_items ri
		LEFT JOIN clothing_items ci ON ri.clothing_item_id = ci.id
		WHERE ri.recommendation_id = $1
		ORDER BY ri.rank
	`, id)
	if qErr != nil {
		return nil, errors.Wrap(qErr, "failed to query recommendation items")
	}
	defer rows.Close()

	for rows.Next() {
		var item domain.RecommendationItem
		var name *string
		var isFromWardrobe bool
		var score *float64
		var rank *int
		if err := rows.Scan(&item.ID, &item.ClothingItemID, &name, &item.Category, &isFromWardrobe, &score, &rank); err != nil {
			return nil, errors.Wrap(err, "failed to scan recommendation item")
		}
		if name != nil {
			item.Name = *name
		}
		if score != nil {
			item.Score = *score
		}
		rec.Items = append(rec.Items, item)
	}

	rec.CreatedAt = createdAt
	if timestamp != nil {
		rec.Timestamp = timestamp
	}

	return &rec, nil
}

func (r *RecommendationRepository) GetByUser(ctx context.Context, userID domain.ID, limit, offset int) ([]domain.Recommendation, error) {
	query := `
		SELECT
			id, user_id, city, weather, outfit, created_at, source, score, outfit_score, algorithm, items, location, temperature, feels_like, wind_speed, min_temp, max_temp, will_rain, will_snow, humidity, timestamp, ml_powered
		FROM recommendations
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query recommendations by user")
	}
	defer rows.Close()

	var recommendations []domain.Recommendation
	for rows.Next() {
		var rec domain.Recommendation
		var weatherJSON []byte
		var outfitJSON []byte
		var itemsJSON []byte
		var createdAt time.Time
		var timestamp time.Time

		err := rows.Scan(
			&rec.ID,
			&rec.UserID,
			&rec.City,
			&weatherJSON,
			&outfitJSON,
			&createdAt,
			&rec.Source,
			&rec.Score,
			&rec.OutfitScore,
			&rec.Algorithm,
			&itemsJSON,
			&rec.Location,
			&rec.Temperature,
			&rec.FeelsLike,
			&rec.WindSpeed,
			&rec.MinTemp,
			&rec.MaxTemp,
			&rec.WillRain,
			&rec.WillSnow,
			&rec.Humidity,
			&timestamp,
			&rec.MLPowered,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan recommendation")
		}

		// Parse JSON fields
		if len(weatherJSON) > 0 {
			err = json.Unmarshal(weatherJSON, &rec.Weather)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal weather data")
			}
		}

		if len(outfitJSON) > 0 {
			err = json.Unmarshal(outfitJSON, &rec.Outfit)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal outfit data")
			}
		}

		if len(itemsJSON) > 0 {
			err = json.Unmarshal(itemsJSON, &rec.Items)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal items data")
			}
		}

		rec.CreatedAt = createdAt
		if !timestamp.IsZero() {
			rec.Timestamp = &timestamp
		}

		recommendations = append(recommendations, rec)
	}

	return recommendations, nil
}

func (r *RecommendationRepository) GetByUserAndDateRange(ctx context.Context, userID domain.ID, from, to *string) ([]domain.Recommendation, error) {
	query := `
		SELECT
			id, user_id, city, weather, outfit, created_at, source, score, outfit_score, algorithm, items, location, temperature, feels_like, wind_speed, min_temp, max_temp, will_rain, will_snow, humidity, timestamp, ml_powered
		FROM recommendations
		WHERE user_id = $1
	`
	args := []interface{}{userID}
	argIndex := 2

	if from != nil {
		query += fmt.Sprintf(" AND created_at >= $%d", argIndex)
		args = append(args, *from)
		argIndex++
	}

	if to != nil {
		query += fmt.Sprintf(" AND created_at <= $%d", argIndex)
		args = append(args, *to)
	}

	query += " ORDER BY created_at DESC"

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query recommendations by user and date range")
	}
	defer rows.Close()

	var recommendations []domain.Recommendation
	for rows.Next() {
		var rec domain.Recommendation
		var weatherJSON []byte
		var outfitJSON []byte
		var itemsJSON []byte
		var createdAt time.Time
		var timestamp time.Time

		err := rows.Scan(
			&rec.ID,
			&rec.UserID,
			&rec.City,
			&weatherJSON,
			&outfitJSON,
			&createdAt,
			&rec.Source,
			&rec.Score,
			&rec.OutfitScore,
			&rec.Algorithm,
			&itemsJSON,
			&rec.Location,
			&rec.Temperature,
			&rec.FeelsLike,
			&rec.WindSpeed,
			&rec.MinTemp,
			&rec.MaxTemp,
			&rec.WillRain,
			&rec.WillSnow,
			&rec.Humidity,
			&timestamp,
			&rec.MLPowered,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan recommendation")
		}

		// Parse JSON fields
		if len(weatherJSON) > 0 {
			err = json.Unmarshal(weatherJSON, &rec.Weather)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal weather data")
			}
		}

		if len(outfitJSON) > 0 {
			err = json.Unmarshal(outfitJSON, &rec.Outfit)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal outfit data")
			}
		}

		if len(itemsJSON) > 0 {
			err = json.Unmarshal(itemsJSON, &rec.Items)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal items data")
			}
		}

		rec.CreatedAt = createdAt
		if !timestamp.IsZero() {
			rec.Timestamp = &timestamp
		}

		recommendations = append(recommendations, rec)
	}

	return recommendations, nil
}

func (r *RecommendationRepository) Update(ctx context.Context, rec *domain.Recommendation) error {
	query := `
		UPDATE recommendations
		SET city = $1, weather = $2, outfit = $3, source = $4, score = $5, outfit_score = $6, algorithm = $7, items = $8, location = $9, temperature = $10, feels_like = $11, wind_speed = $12, min_temp = $13, max_temp = $14, will_rain = $15, will_snow = $16, humidity = $17, timestamp = $18, ml_powered = $19, updated_at = $20
		WHERE id = $21
	`

	weatherJSON, err := json.Marshal(rec.Weather)
	if err != nil {
		return errors.Wrap(err, "failed to marshal weather data")
	}

	outfitJSON, err := json.Marshal(rec.Outfit)
	if err != nil {
		return errors.Wrap(err, "failed to marshal outfit data")
	}

	itemsJSON, err := json.Marshal(rec.Items)
	if err != nil {
		return errors.Wrap(err, "failed to marshal items data")
	}

	_, err = r.db.Exec(ctx, query,
		rec.City,
		weatherJSON,
		outfitJSON,
		rec.Source,
		rec.Score,
		rec.OutfitScore,
		rec.Algorithm,
		itemsJSON,
		rec.Location,
		rec.Temperature,
		rec.FeelsLike,
		rec.WindSpeed,
		rec.MinTemp,
		rec.MaxTemp,
		rec.WillRain,
		rec.WillSnow,
		rec.Humidity,
		rec.Timestamp,
		rec.MLPowered,
		time.Now(),
		rec.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update recommendation")
	}

	return nil
}

func (r *RecommendationRepository) Delete(ctx context.Context, id domain.ID) error {
	query := `DELETE FROM recommendations WHERE id = $1`

	_, err := r.db.Exec(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete recommendation")
	}

	return nil
}

// DeleteByUserAndID deletes a recommendation by its ID and verifies it belongs to the user
func (r *RecommendationRepository) DeleteByUserAndID(ctx context.Context, userID, id domain.ID) error {
	query := `DELETE FROM recommendations WHERE user_id = $1 AND id = $2`

	tag, err := r.db.Exec(ctx, query, userID, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete recommendation by user and ID")
	}

	if tag.RowsAffected() == 0 {
		return errors.New("no recommendation found with the given ID for this user")
	}

	return nil
}

func (r *RecommendationRepository) GetItemRows(ctx context.Context, recommendationID domain.ID) ([]repositories.RecommendationItemRow, error) {
	query := `
		SELECT
			id, recommendation_id, clothing_item_id, score, category, created_at
		FROM recommendation_items
		WHERE recommendation_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, recommendationID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query recommendation item rows")
	}
	defer rows.Close()

	var items []repositories.RecommendationItemRow
	for rows.Next() {
		var item repositories.RecommendationItemRow
		var createdAt time.Time

		err := rows.Scan(
			&item.ID,
			&item.RecommendationID,
			&item.ClothingItemID,
			&item.Score,
			&item.Category,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan recommendation item row")
		}

		item.CreatedAt = createdAt
		items = append(items, item)
	}

	return items, nil
}

func (r *RecommendationRepository) SetRating(ctx context.Context, userID, recommendationID domain.ID, rating int, thermalFeedback *string, feedback *string) (bool, error) {
	query := `
		INSERT INTO recommendation_ratings (
			id, user_id, recommendation_id, rating, thermal_feedback, feedback, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (user_id, recommendation_id)
		DO UPDATE SET
			rating = $4, thermal_feedback = $5, feedback = $6, updated_at = $8
	`

	id := domain.NewID()
	now := time.Now()

	_, err := r.db.Exec(ctx, query,
		id,
		userID,
		recommendationID,
		rating,
		thermalFeedback,
		feedback,
		now,
		now,
	)
	if err != nil {
		return false, errors.Wrap(err, "failed to set recommendation rating")
	}

	return true, nil
}

func (r *RecommendationRepository) SetFavorite(ctx context.Context, userID, recommendationID domain.ID, isFavorite bool) error {
	query := `
		INSERT INTO recommendation_favorites (
			id, user_id, recommendation_id, is_favorite, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (user_id, recommendation_id)
		DO UPDATE SET
			is_favorite = $4, updated_at = $6
	`

	id := domain.NewID()
	now := time.Now()

	_, err := r.db.Exec(ctx, query,
		id,
		userID,
		recommendationID,
		isFavorite,
		now,
		now,
	)
	if err != nil {
		return errors.Wrap(err, "failed to set recommendation favorite status")
	}

	return nil
}

func (r *RecommendationRepository) ListFavorites(ctx context.Context, userID domain.ID, limit int) ([]domain.RecommendationRecord, error) {
	query := `
		SELECT
			r.id, r.user_id, r.city, r.weather, r.outfit, r.created_at, r.source, r.score, r.outfit_score, r.algorithm, r.items, r.location, r.temperature, r.feels_like, r.wind_speed, r.min_temp, r.max_temp, r.will_rain, r.will_snow, r.humidity, r.timestamp, r.ml_powered
		FROM recommendations r
		JOIN recommendation_favorites rf ON r.id = rf.recommendation_id
		WHERE rf.user_id = $1 AND rf.is_favorite = true
		ORDER BY r.created_at DESC
		LIMIT $2
	`

	rows, err := r.db.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query favorite recommendations")
	}
	defer rows.Close()

	var recommendations []domain.RecommendationRecord
	for rows.Next() {
		var rec domain.RecommendationRecord
		var weatherJSON []byte
		var outfitJSON []byte
		var itemsJSON []byte
		var createdAt time.Time
		var timestamp time.Time

		err := rows.Scan(
			&rec.ID,
			&rec.UserID,
			&rec.City,
			&weatherJSON,
			&outfitJSON,
			&createdAt,
			&rec.Source,
			&rec.Score,
			&rec.OutfitScore,
			&rec.Algorithm,
			&itemsJSON,
			&rec.Location,
			&rec.Temperature,
			&rec.FeelsLike,
			&rec.WindSpeed,
			&rec.MinTemp,
			&rec.MaxTemp,
			&rec.WillRain,
			&rec.WillSnow,
			&rec.Humidity,
			&timestamp,
			&rec.MLPowered,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan favorite recommendation")
		}

		// Parse JSON fields
		if len(weatherJSON) > 0 {
			err = json.Unmarshal(weatherJSON, &rec.Weather)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal weather data")
			}
		}

		if len(outfitJSON) > 0 {
			err = json.Unmarshal(outfitJSON, &rec.Outfit)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal outfit data")
			}
		}

		if len(itemsJSON) > 0 {
			err = json.Unmarshal(itemsJSON, &rec.Items)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal items data")
			}
		}

		rec.CreatedAt = createdAt
		if !timestamp.IsZero() {
			rec.Timestamp = &timestamp
		}

		recommendations = append(recommendations, rec)
	}

	return recommendations, nil
}

func (r *RecommendationRepository) ListByUser(ctx context.Context, userID domain.ID, q domain.RecommendationListQuery) ([]domain.RecommendationRecord, int, error) {
	// Calculate offset
	offset := (q.Page - 1) * q.Limit

	// Base query
	query := `
		SELECT
			id, user_id, city, weather, outfit, created_at, source, score, outfit_score, algorithm, items, location, temperature, feels_like, wind_speed, min_temp, max_temp, will_rain, will_snow, humidity, timestamp, ml_powered
		FROM recommendations
		WHERE user_id = $1
	`
	args := []interface{}{userID}
	argIndex := 2

	// Apply filters
	if q.FromDate != nil {
		query += fmt.Sprintf(" AND created_at >= $%d", argIndex)
		args = append(args, *q.FromDate)
		argIndex++
	}

	if q.ToDate != nil {
		query += fmt.Sprintf(" AND created_at <= $%d", argIndex)
		args = append(args, *q.ToDate)
		argIndex++
	}

	if q.MinRating != nil {
		query += fmt.Sprintf(" AND score >= $%d", argIndex)
		args = append(args, *q.MinRating)
		argIndex++
	}

	var limitOffsetIndex int
	if q.IsFavorite != nil {
		query += fmt.Sprintf(` AND id IN (
			SELECT recommendation_id FROM recommendation_favorites
			WHERE user_id = $1 AND is_favorite = $%d
		)`, argIndex)
		args = append(args, *q.IsFavorite)
		limitOffsetIndex = argIndex + 1
	} else {
		limitOffsetIndex = argIndex
	}

	query += " ORDER BY created_at DESC LIMIT $" + fmt.Sprintf("%d", limitOffsetIndex) + " OFFSET $" + fmt.Sprintf("%d", limitOffsetIndex+1)
	args = append(args, q.Limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query recommendations by user with filters")
	}
	defer rows.Close()

	var recommendations []domain.RecommendationRecord
	for rows.Next() {
		var rec domain.RecommendationRecord
		var weatherJSON []byte
		var outfitJSON []byte
		var itemsJSON []byte
		var createdAt time.Time
		var timestamp *time.Time

		err := rows.Scan(
			&rec.ID,
			&rec.UserID,
			&rec.City,
			&weatherJSON,
			&outfitJSON,
			&createdAt,
			&rec.Source,
			&rec.Score,
			&rec.OutfitScore,
			&rec.Algorithm,
			&itemsJSON,
			&rec.Location,
			&rec.Temperature,
			&rec.FeelsLike,
			&rec.WindSpeed,
			&rec.MinTemp,
			&rec.MaxTemp,
			&rec.WillRain,
			&rec.WillSnow,
			&rec.Humidity,
			&timestamp,
			&rec.MLPowered,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan recommendation")
		}

		// Parse JSON fields
		if len(weatherJSON) > 0 {
			err = json.Unmarshal(weatherJSON, &rec.Weather)
			if err != nil {
				return nil, 0, errors.Wrap(err, "failed to unmarshal weather data")
			}
		}

		if len(outfitJSON) > 0 {
			err = json.Unmarshal(outfitJSON, &rec.Outfit)
			if err != nil {
				return nil, 0, errors.Wrap(err, "failed to unmarshal outfit data")
			}
		}

		if len(itemsJSON) > 0 {
			err = json.Unmarshal(itemsJSON, &rec.Items)
			if err != nil {
				return nil, 0, errors.Wrap(err, "failed to unmarshal items data")
			}
		}

		rec.CreatedAt = createdAt
		if timestamp != nil {
			rec.Timestamp = timestamp
		}

		recommendations = append(recommendations, rec)
	}

	// Загружаем ВСЕ items одним запросом (оптимизация N+1)
	if len(recommendations) > 0 {
		// Строим запрос с UNNEST для pgx
		placeholders := make([]string, len(recommendations))
		args := make([]interface{}, len(recommendations))
		for i, rec := range recommendations {
			placeholders[i] = fmt.Sprintf("$%d", i+1)
			args[i] = rec.ID.String()
		}

		query := fmt.Sprintf(`
			SELECT ri.recommendation_id, ri.id, ri.clothing_item_id, ci.name, ri.category, ri.is_from_wardrobe, ri.score, ri.rank
			FROM recommendation_items ri
			LEFT JOIN clothing_items ci ON ri.clothing_item_id = ci.id
			WHERE ri.recommendation_id IN (%s)
			ORDER BY ri.recommendation_id, ri.rank
		`, strings.Join(placeholders, ","))

		itemRows, qErr := r.db.Query(ctx, query, args...)
		if qErr == nil {
			defer itemRows.Close()
			itemsByRec := map[domain.ID][]domain.RecommendationItem{}
			for itemRows.Next() {
				var recID domain.ID
				var item domain.RecommendationItem
				var name *string
				var isFromWardrobe bool
				var score *float64
				var rank *int
				if err := itemRows.Scan(&recID, &item.ID, &item.ClothingItemID, &name, &item.Category, &isFromWardrobe, &score, &rank); err == nil {
					if name != nil {
						item.Name = *name
					}
					if score != nil {
						item.Score = *score
					}
					itemsByRec[recID] = append(itemsByRec[recID], item)
				}
			}
			// Присваиваем items каждой рекомендации
			for i, rec := range recommendations {
				recommendations[i].Items = itemsByRec[rec.ID]
			}
		}
	}

	// Get total count
	countQuery := `
		SELECT COUNT(*)
		FROM recommendations r
		WHERE user_id = $1
	`
	countArgs := []interface{}{userID}
	countArgIndex := 2

	if q.FromDate != nil {
		countQuery += fmt.Sprintf(" AND created_at >= $%d", countArgIndex)
		countArgs = append(countArgs, *q.FromDate)
		countArgIndex++
	}

	if q.ToDate != nil {
		countQuery += fmt.Sprintf(" AND created_at <= $%d", countArgIndex)
		countArgs = append(countArgs, *q.ToDate)
		countArgIndex++
	}

	if q.Occasion != nil {
		countQuery += fmt.Sprintf(" AND occasion = $%d", countArgIndex)
		countArgs = append(countArgs, *q.Occasion)
		countArgIndex++
	}

	if q.MinRating != nil {
		countQuery += fmt.Sprintf(" AND score >= $%d", countArgIndex)
		countArgs = append(countArgs, *q.MinRating)
		countArgIndex++
	}

	if q.IsFavorite != nil {
		countQuery += fmt.Sprintf(` AND id IN (
			SELECT recommendation_id FROM recommendation_favorites
			WHERE user_id = $1 AND is_favorite = $%d
		)`, countArgIndex)
		countArgs = append(countArgs, *q.IsFavorite)
	}

	var total int
	err = r.db.QueryRow(ctx, countQuery, countArgs...).Scan(&total)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count recommendations")
	}

	return recommendations, total, nil
}

func (r *RecommendationRepository) CreateSession(ctx context.Context, session *repositories.RecommendationSession) (domain.ID, error) {
	sessionID := domain.NewID()

	weatherData := session.WeatherData
	if weatherData == nil {
		weatherData = []byte("{}")
	}

	userPrefs := session.UserPreferences
	if userPrefs == nil {
		userPrefs = []byte("{}")
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO recommendation_sessions (
			id, user_id, context_hash, model_version, weather_data, user_preferences
		) VALUES ($1, $2, $3, $4, $5, $6)
	`, sessionID, session.UserID, session.ContextHash, session.ModelVersion, weatherData, userPrefs)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to insert recommendation session: %w", err)
	}

	return sessionID, nil
}
