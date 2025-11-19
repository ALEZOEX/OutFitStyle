package postgres

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"
	
	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"
	"go.uber.org/zap"
	
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/application/repositories"
)

// RecommendationRepository implements the RecommendationRepository interface for PostgreSQL
type RecommendationRepository struct {
	db     *DB
	logger *zap.Logger
}

// NewRecommendationRepository creates a new recommendation repository
func NewRecommendationRepository(db *DB, logger *zap.Logger) repositories.RecommendationRepository {
	return &RecommendationRepository{
		db:     db,
		logger: logger,
	}
}

// CreateRecommendation saves a recommendation to the database
func (r *RecommendationRepository) CreateRecommendation(
	ctx context.Context,
	recommendation *domain.RecommendationResponse,
) (int, error) {
	tx, err := r.db.pool.Begin(ctx)
	if err != nil {
		return 0, errors.Wrap(err, "failed to begin transaction")
	}
	defer func() {
		if err != nil {
			tx.Rollback(ctx)
		}
	}()
	
	// Insert recommendation
	recommendationID := 0
	outfitScore := 0.0
	if recommendation.OutfitScore != nil {
		outfitScore = *recommendation.OutfitScore
	}
	
	err = tx.QueryRow(ctx, `
		INSERT INTO recommendations (
			user_id, temperature, weather, outfit_score, ml_powered, algorithm, location,
			min_temp, max_temp, will_rain, will_snow
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id
	`,
		recommendation.UserID,
		recommendation.Temperature,
		recommendation.Weather,
		outfitScore,
		recommendation.MLPowered,
		recommendation.Algorithm,
		recommendation.Location,
		recommendation.MinTemp,
		recommendation.MaxTemp,
		recommendation.WillRain,
		recommendation.WillSnow,
	).Scan(&recommendationID)
	
	if err != nil {
		return 0, errors.Wrap(err, "failed to insert recommendation")
	}
	
	// Insert recommendation items
	for _, item := range recommendation.Recommendations {
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
			item.MLSore,
			item.Confidence,
		)
		if err != nil {
			return 0, errors.Wrap(err, "failed to insert recommendation item")
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
	`, recommendation.UserID)
	
	if err != nil {
		return 0, errors.Wrap(err, "failed to update user stats")
	}
	
	// Commit transaction
	if err = tx.Commit(ctx); err != nil {
		return 0, errors.Wrap(err, "failed to commit transaction")
	}
	
	return recommendationID, nil
}

// GetRecommendationByID retrieves a specific recommendation by ID
func (r *RecommendationRepository) GetRecommendationByID(ctx context.Context, id int) (*domain.RecommendationResponse, error) {
	query := `
		SELECT 
			r.id, r.user_id, r.temperature, r.weather, r.outfit_score, r.ml_powered, 
			r.algorithm, r.location, r.created_at, r.min_temp, r.max_temp, r.will_rain, r.will_snow,
			COALESCE(
				JSON_AGG(
					JSON_BUILD_OBJECT(
						'id', ri.clothing_item_id,
						'name', ri.name,
						'category', ri.category,
						'icon_emoji', ri.icon_emoji,
						'ml_score', ri.ml_score,
						'confidence', ri.confidence
					)
				) FILTER (WHERE ri.id IS NOT NULL),
				'[]'
			) as items
		FROM recommendations r
		LEFT JOIN recommendation_items ri ON r.id = ri.recommendation_id
		WHERE r.id = $1
		GROUP BY r.id, r.user_id, r.temperature, r.weather, r.outfit_score, r.ml_powered, 
		         r.algorithm, r.location, r.created_at, r.min_temp, r.max_temp, r.will_rain, r.will_snow
	`
	
	row := r.db.pool.QueryRow(ctx, query, id)
	item := domain.RecommendationResponse{}
	var itemsJSON []byte
	var outfitScore sql.NullFloat64
	
	err := row.Scan(
		&item.ID,
		&item.UserID,
		&item.Temperature,
		&item.Weather,
		&outfitScore,
		&item.MLPowered,
		&item.Algorithm,
		&item.Location,
		&item.Timestamp,
		&item.MinTemp,
		&item.MaxTemp,
		&item.WillRain,
		&item.WillSnow,
		&itemsJSON,
	)
	
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.New("recommendation not found")
		}
		return nil, errors.Wrap(err, "failed to get recommendation by ID")
	}
	
	// Handle nullable outfit score
	if outfitScore.Valid {
		item.OutfitScore = &outfitScore.Float64
	}
	
	var items []domain.ClothingItem
	if err := json.Unmarshal(itemsJSON, &items); err != nil {
		return nil, errors.Wrap(err, "failed to unmarshal items JSON")
	}
	item.Recommendations = items
	
	return &item, nil
}

// GetUserRecommendations retrieves recommendation history for a user
func (r *RecommendationRepository) GetUserRecommendations(ctx context.Context, userID int, limit int) ([]domain.RecommendationResponse, error) {
	query := `
		SELECT 
			r.id, r.user_id, r.temperature, r.weather, r.outfit_score, r.ml_powered, 
			r.algorithm, r.location, r.created_at, r.min_temp, r.max_temp, r.will_rain, r.will_snow,
			COALESCE(
				JSON_AGG(
					JSON_BUILD_OBJECT(
						'id', ri.clothing_item_id,
						'name', ri.name,
						'category', ri.category,
						'icon_emoji', ri.icon_emoji,
						'ml_score', ri.ml_score,
						'confidence', ri.confidence
					)
				) FILTER (WHERE ri.id IS NOT NULL),
				'[]'
			) as items
		FROM recommendations r
		LEFT JOIN recommendation_items ri ON r.id = ri.recommendation_id
		WHERE r.user_id = $1
		GROUP BY r.id, r.user_id, r.temperature, r.weather, r.outfit_score, r.ml_powered, 
		         r.algorithm, r.location, r.created_at, r.min_temp, r.max_temp, r.will_rain, r.will_snow
		ORDER BY r.created_at DESC
		LIMIT $2
	`
	
	rows, err := r.db.pool.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query recommendation history")
	}
	defer rows.Close()
	
	var history []domain.RecommendationResponse
	for rows.Next() {
		var item domain.RecommendationResponse
		var itemsJSON []byte
		var outfitScore sql.NullFloat64
		
		err = rows.Scan(
			&item.ID,
			&item.UserID,
			&item.Temperature,
			&item.Weather,
			&outfitScore,
			&item.MLPowered,
			&item.Algorithm,
			&item.Location,
			&item.Timestamp,
			&item.MinTemp,
			&item.MaxTemp,
			&item.WillRain,
			&item.WillSnow,
			&itemsJSON,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan recommendation history row")
		}
		
		// Handle nullable outfit score
		if outfitScore.Valid {
			item.OutfitScore = &outfitScore.Float64
		}
		
		var items []domain.ClothingItem
		if err := json.Unmarshal(itemsJSON, &items); err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal items JSON")
		}
		item.Recommendations = items
		history = append(history, item)
	}
	
	if err = rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating recommendation history rows")
	}
	
	return history, nil
}

// CreateOutfitSet saves an outfit set to the database
func (r *RecommendationRepository) CreateOutfitSet(ctx context.Context, outfit *domain.OutfitSet) (int, error) {
	// Convert slice to JSON
	itemsJSON, err := json.Marshal(outfit.Items)
	if err != nil {
		return 0, errors.Wrap(err, "failed to marshal outfit items")
	}
	
	query := `
		INSERT INTO outfit_sets (items, confidence, reason, created_at)
		VALUES ($1, $2, $3, NOW())
		RETURNING id
	`
	
	var outfitID int
	err = r.db.pool.QueryRow(ctx, query, itemsJSON, outfit.Confidence, outfit.Reason).Scan(&outfitID)
	if err != nil {
		return 0, errors.Wrap(err, "failed to insert outfit set")
	}
	
	return outfitID, nil
}

// GetOutfitSetByID retrieves an outfit set by ID
func (r *RecommendationRepository) GetOutfitSetByID(ctx context.Context, id int) (*domain.OutfitSet, error) {
	query := `
		SELECT id, items, confidence, reason, created_at
		FROM outfit_sets
		WHERE id = $1
	`
	
	row := r.db.pool.QueryRow(ctx, query, id)
	outfit := domain.OutfitSet{}
	var itemsJSON []byte
	
	err := row.Scan(
		&outfit.ID,
		&itemsJSON,
		&outfit.Confidence,
		&outfit.Reason,
		&outfit.CreatedAt,
	)
	
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.New("outfit set not found")
		}
		return nil, errors.Wrap(err, "failed to get outfit set by ID")
	}
	
	// Parse JSON array
	if itemsJSON != nil {
		if err := json.Unmarshal(itemsJSON, &outfit.Items); err != nil {
			return nil, errors.Wrap(err, "failed to parse outfit items")
		}
	}
	
	return &outfit, nil
}

// GetClothingItemByID retrieves a clothing item by ID
func (r *RecommendationRepository) GetClothingItemByID(ctx context.Context, id int) (*domain.ClothingItem, error) {
	query := `
		SELECT id, user_id, name, category, subcategory, icon_emoji, ml_score, confidence, weather_suitability
		FROM clothing_items
		WHERE id = $1
	`
	
	row := r.db.pool.QueryRow(ctx, query, id)
	item := domain.ClothingItem{}
	
	err := row.Scan(
		&item.ID,
		&item.UserID,
		&item.Name,
		&item.Category,
		&item.Subcategory,
		&item.IconEmoji,
		&item.MLSore,
		&item.Confidence,
		&item.WeatherSuitability,
	)
	
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.New("clothing item not found")
		}
		return nil, errors.Wrap(err, "failed to get clothing item by ID")
	}
	
	return &item, nil
}

// GetUserClothingItems retrieves all clothing items for a user
func (r *RecommendationRepository) GetUserClothingItems(ctx context.Context, userID int) ([]domain.ClothingItem, error) {
	query := `
		SELECT id, user_id, name, category, subcategory, icon_emoji, ml_score, confidence, weather_suitability
		FROM clothing_items
		WHERE user_id = $1
		ORDER BY category, name
	`
	
	rows, err := r.db.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query clothing items")
	}
	defer rows.Close()
	
	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		err = rows.Scan(
			&item.ID,
			&item.UserID,
			&item.Name,
			&item.Category,
			&item.Subcategory,
			&item.IconEmoji,
			&item.MLSore,
			&item.Confidence,
			&item.WeatherSuitability,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item")
		}
		items = append(items, item)
	}
	
	if err = rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating clothing items")
	}
	
	return items, nil
}

// CreateClothingItem creates a new clothing item
func (r *RecommendationRepository) CreateClothingItem(ctx context.Context, item *domain.ClothingItem) (int, error) {
	query := `
		INSERT INTO clothing_items (
			user_id, name, category, subcategory, icon_emoji, ml_score, confidence, weather_suitability
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id
	`
	
	var itemID int
	err := r.db.pool.QueryRow(ctx, query,
		item.UserID,
		item.Name,
		item.Category,
		item.Subcategory,
		item.IconEmoji,
		item.MLSore,
		item.Confidence,
		item.WeatherSuitability,
	).Scan(&itemID)
	
	if err != nil {
		return 0, errors.Wrap(err, "failed to insert clothing item")
	}
	
	return itemID, nil
}