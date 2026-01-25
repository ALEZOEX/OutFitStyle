package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type PersonalizationRepository struct {
	db *pgxpool.Pool
}

func NewPersonalizationRepository(db *pgxpool.Pool) *PersonalizationRepository {
	return &PersonalizationRepository{db: db}
}

func (r *PersonalizationRepository) GetUserStylePreferences(ctx context.Context, userID domain.ID) (*domain.UserStylePreferences, error) {
	query := `
		SELECT 
			id, user_id, preferred_styles, disliked_styles, preferred_colors, 
			disliked_colors, preferred_brands, disliked_brands, max_price, 
			min_quality_rating, preferred_fit, preferred_materials, created_at, updated_at
		FROM user_style_preferences
		WHERE user_id = $1
	`

	var prefs domain.UserStylePreferences
	var maxPrice *float64
	var minQualityRating *float64
	var preferredFit *string
	var preferredStylesJSON []byte
	var dislikedStylesJSON []byte
	var preferredColorsJSON []byte
	var dislikedColorsJSON []byte
	var preferredBrandsJSON []byte
	var dislikedBrandsJSON []byte
	var preferredMaterialsJSON []byte

	err := r.db.QueryRow(ctx, query, userID).Scan(
		&prefs.ID,
		&prefs.UserID,
		&preferredStylesJSON,
		&dislikedStylesJSON,
		&preferredColorsJSON,
		&dislikedColorsJSON,
		&preferredBrandsJSON,
		&dislikedBrandsJSON,
		&maxPrice,
		&minQualityRating,
		&preferredFit,
		&preferredMaterialsJSON,
		&prefs.CreatedAt,
		&prefs.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			// Return default preferences if none exist
			return &domain.UserStylePreferences{
				ID:        domain.NewID(),
				UserID:    userID,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}, nil
		}
		return nil, errors.Wrap(err, "failed to get user style preferences")
	}

	// Parse JSON arrays
	if len(preferredStylesJSON) > 0 {
		err = json.Unmarshal(preferredStylesJSON, &prefs.PreferredStyles)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal preferred styles")
		}
	}

	if len(dislikedStylesJSON) > 0 {
		err = json.Unmarshal(dislikedStylesJSON, &prefs.DislikedStyles)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal disliked styles")
		}
	}

	if len(preferredColorsJSON) > 0 {
		err = json.Unmarshal(preferredColorsJSON, &prefs.PreferredColors)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal preferred colors")
		}
	}

	if len(dislikedColorsJSON) > 0 {
		err = json.Unmarshal(dislikedColorsJSON, &prefs.DislikedColors)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal disliked colors")
		}
	}

	if len(preferredBrandsJSON) > 0 {
		err = json.Unmarshal(preferredBrandsJSON, &prefs.PreferredBrands)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal preferred brands")
		}
	}

	if len(dislikedBrandsJSON) > 0 {
		err = json.Unmarshal(dislikedBrandsJSON, &prefs.DislikedBrands)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal disliked brands")
		}
	}

	if len(preferredMaterialsJSON) > 0 {
		err = json.Unmarshal(preferredMaterialsJSON, &prefs.PreferredMaterials)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal preferred materials")
		}
	}

	// Set nullable fields
	prefs.MaxPrice = maxPrice
	prefs.MinQualityRating = minQualityRating
	prefs.PreferredFit = preferredFit

	return &prefs, nil
}

func (r *PersonalizationRepository) UpdateUserStylePreferences(ctx context.Context, userID domain.ID, prefs domain.UserStylePreferences) error {
	query := `
		INSERT INTO user_style_preferences (
			id, user_id, preferred_styles, disliked_styles, preferred_colors,
			disliked_colors, preferred_brands, disliked_brands, max_price,
			min_quality_rating, preferred_fit, preferred_materials, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		ON CONFLICT (user_id)
		DO UPDATE SET
			preferred_styles = $3, disliked_styles = $4, preferred_colors = $5,
			disliked_colors = $6, preferred_brands = $7, disliked_brands = $8,
			max_price = $9, min_quality_rating = $10, preferred_fit = $11,
			preferred_materials = $12, updated_at = $14
	`

	id := domain.NewID()
	now := time.Now()

	preferredStylesJSON, err := json.Marshal(prefs.PreferredStyles)
	if err != nil {
		return errors.Wrap(err, "failed to marshal preferred styles")
	}

	dislikedStylesJSON, err := json.Marshal(prefs.DislikedStyles)
	if err != nil {
		return errors.Wrap(err, "failed to marshal disliked styles")
	}

	preferredColorsJSON, err := json.Marshal(prefs.PreferredColors)
	if err != nil {
		return errors.Wrap(err, "failed to marshal preferred colors")
	}

	dislikedColorsJSON, err := json.Marshal(prefs.DislikedColors)
	if err != nil {
		return errors.Wrap(err, "failed to marshal disliked colors")
	}

	preferredBrandsJSON, err := json.Marshal(prefs.PreferredBrands)
	if err != nil {
		return errors.Wrap(err, "failed to marshal preferred brands")
	}

	dislikedBrandsJSON, err := json.Marshal(prefs.DislikedBrands)
	if err != nil {
		return errors.Wrap(err, "failed to marshal disliked brands")
	}

	preferredMaterialsJSON, err := json.Marshal(prefs.PreferredMaterials)
	if err != nil {
		return errors.Wrap(err, "failed to marshal preferred materials")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		userID,
		preferredStylesJSON,
		dislikedStylesJSON,
		preferredColorsJSON,
		dislikedColorsJSON,
		preferredBrandsJSON,
		dislikedBrandsJSON,
		prefs.MaxPrice,
		prefs.MinQualityRating,
		prefs.PreferredFit,
		preferredMaterialsJSON,
		now,
		now,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update user style preferences")
	}

	return nil
}

func (r *PersonalizationRepository) GetUserWeatherPreferences(ctx context.Context, userID domain.ID) (*domain.UserWeatherPreferences, error) {
	query := `
		SELECT 
			id, user_id, preferred_temperature, temperature_sensitivity, 
			preferred_weather, max_wind_speed, max_humidity, created_at, updated_at
		FROM user_weather_preferences
		WHERE user_id = $1
	`

	var prefs domain.UserWeatherPreferences
	var preferredTemperature *float64
	var preferredWeatherJSON []byte

	err := r.db.QueryRow(ctx, query, userID).Scan(
		&prefs.ID,
		&prefs.UserID,
		&preferredTemperature,
		&prefs.TemperatureSensitivity,
		&preferredWeatherJSON,
		&prefs.MaxWindSpeed,
		&prefs.MaxHumidity,
		&prefs.CreatedAt,
		&prefs.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			// Return default preferences if none exist
			return &domain.UserWeatherPreferences{
				ID:        domain.NewID(),
				UserID:    userID,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}, nil
		}
		return nil, errors.Wrap(err, "failed to get user weather preferences")
	}

	// Parse preferred weather
	if len(preferredWeatherJSON) > 0 {
		err = json.Unmarshal(preferredWeatherJSON, &prefs.PreferredWeather)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal preferred weather")
		}
	}

	// Set nullable fields
	prefs.PreferredTemperature = preferredTemperature

	return &prefs, nil
}

func (r *PersonalizationRepository) GetUserPreferences(ctx context.Context, userID domain.ID) (domain.UserPreferences, error) {
	// Get style preferences
	stylePrefs, err := r.GetUserStylePreferences(ctx, userID)
	if err != nil {
		return domain.UserPreferences{}, errors.Wrap(err, "failed to get user style preferences")
	}

	// Get weather preferences
	weatherPrefs, err := r.GetUserWeatherPreferences(ctx, userID)
	if err != nil {
		return domain.UserPreferences{}, errors.Wrap(err, "failed to get user weather preferences")
	}

	// Combine into a single UserPreferences struct
	prefs := domain.UserPreferences{
		PreferredStyles:        stylePrefs.PreferredStyles,
		AvoidStyles:            stylePrefs.DislikedStyles,
		ColorPreferences:       stylePrefs.PreferredColors,
		AvoidColors:            stylePrefs.DislikedColors,
		PreferredCategories:    stylePrefs.PreferredBrands, // Using brands as categories temporarily
		FormalityDefault:       nil,                        // Need to add this to domain if needed
		TemperatureSensitivity: &weatherPrefs.TemperatureSensitivity,
		NotificationsEnabled:   nil, // Need to add this to domain if needed
		MorningReminderTime:    nil, // Need to add this to domain if needed
		WeeklyDigest:           nil, // Need to add this to domain if needed
	}

	return prefs, nil
}

func (r *PersonalizationRepository) GetRecentItems(ctx context.Context, userID domain.ID, limit int) ([]domain.ID, error) {
	query := `
		SELECT item_id
		FROM user_item_interactions
		WHERE user_id = $1 AND interaction_type = 'wear' OR interaction_type = 'view'
		ORDER BY created_at DESC
		LIMIT $2
	`

	rows, err := r.db.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query recent items")
	}
	defer rows.Close()

	var itemIDs []domain.ID
	for rows.Next() {
		var itemID uuid.UUID
		err := rows.Scan(&itemID)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan item ID")
		}
		itemIDs = append(itemIDs, domain.ID(itemID))
	}

	return itemIDs, nil
}

func (r *PersonalizationRepository) GetRatedItems(ctx context.Context, userID domain.ID, highMin int, lowMax int, limit int) (high []domain.ID, low []domain.ID, err error) {
	// Query for highly rated items
	highQuery := `
		SELECT item_id
		FROM user_item_ratings
		WHERE user_id = $1 AND rating >= $2
		ORDER BY rating DESC
		LIMIT $3
	`

	highRows, err := r.db.Query(ctx, highQuery, userID, highMin, limit)
	if err != nil {
		return nil, nil, errors.Wrap(err, "failed to query highly rated items")
	}
	defer highRows.Close()

	var highIDs []domain.ID
	for highRows.Next() {
		var itemID uuid.UUID
		err := highRows.Scan(&itemID)
		if err != nil {
			return nil, nil, errors.Wrap(err, "failed to scan high-rated item ID")
		}
		highIDs = append(highIDs, domain.ID(itemID))
	}

	// Query for low rated items
	lowQuery := `
		SELECT item_id
		FROM user_item_ratings
		WHERE user_id = $1 AND rating <= $2
		ORDER BY rating ASC
		LIMIT $3
	`

	lowRows, err := r.db.Query(ctx, lowQuery, userID, lowMax, limit)
	if err != nil {
		return nil, nil, errors.Wrap(err, "failed to query low rated items")
	}
	defer lowRows.Close()

	var lowIDs []domain.ID
	for lowRows.Next() {
		var itemID uuid.UUID
		err := lowRows.Scan(&itemID)
		if err != nil {
			return nil, nil, errors.Wrap(err, "failed to scan low-rated item ID")
		}
		lowIDs = append(lowIDs, domain.ID(itemID))
	}

	return highIDs, lowIDs, nil
}

func (r *PersonalizationRepository) GetStyleDistribution(ctx context.Context, userID domain.ID, limit int) (map[string]float64, error) {
	query := `
		SELECT 
			ci.style,
			COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_item_interactions WHERE user_id = $1) as percentage
		FROM user_item_interactions ui
		JOIN clothing_items ci ON ui.item_id = ci.id
		WHERE ui.user_id = $1
		GROUP BY ci.style
		ORDER BY percentage DESC
		LIMIT $2
	`

	rows, err := r.db.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query style distribution")
	}
	defer rows.Close()

	distribution := make(map[string]float64)
	for rows.Next() {
		var style string
		var percentage float64

		err := rows.Scan(&style, &percentage)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan style distribution")
		}

		distribution[style] = percentage
	}

	return distribution, nil
}

func (r *PersonalizationRepository) GetItemRatingsMap(ctx context.Context, userID domain.ID, itemIDs []domain.ID) (map[domain.ID]float64, error) {
	if len(itemIDs) == 0 {
		return make(map[domain.ID]float64), nil
	}

	query := `
		SELECT item_id, rating
		FROM user_item_ratings
		WHERE user_id = $1 AND item_id = ANY($2)
	`

	rows, err := r.db.Query(ctx, query, userID, itemIDs)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query item ratings")
	}
	defer rows.Close()

	ratingsMap := make(map[domain.ID]float64)
	for rows.Next() {
		var itemID uuid.UUID
		var rating float64

		err := rows.Scan(&itemID, &rating)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan item rating")
		}

		ratingsMap[domain.ID(itemID)] = rating
	}

	return ratingsMap, nil
}

func (r *PersonalizationRepository) UpdateUserWeatherPreferences(ctx context.Context, userID domain.ID, prefs domain.UserWeatherPreferences) error {
	query := `
		INSERT INTO user_weather_preferences (
			id, user_id, preferred_temperature, temperature_sensitivity, 
			preferred_weather, max_wind_speed, max_humidity, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (user_id)
		DO UPDATE SET
			preferred_temperature = $3, temperature_sensitivity = $4,
			preferred_weather = $5, max_wind_speed = $6, max_humidity = $7, updated_at = $9
	`

	id := domain.NewID()
	now := time.Now()

	preferredWeatherJSON, err := json.Marshal(prefs.PreferredWeather)
	if err != nil {
		return errors.Wrap(err, "failed to marshal preferred weather")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		userID,
		prefs.PreferredTemperature,
		prefs.TemperatureSensitivity,
		preferredWeatherJSON,
		prefs.MaxWindSpeed,
		prefs.MaxHumidity,
		now,
		now,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update user weather preferences")
	}

	return nil
}
