package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"outfitstyle/server/internal/core/domain"

	"go.uber.org/zap"
)

// ClothingItemRepository реализует интерфейс repository для ClothingItem
type ClothingItemRepository struct {
	db     *DB
	logger *zap.Logger
}

// NewClothingItemRepository создает новый репозиторий для вещей
func NewClothingItemRepository(db *DB, logger *zap.Logger) *ClothingItemRepository {
	return &ClothingItemRepository{
		db:     db,
		logger: logger,
	}
}

// Интерфейс, который должен реализовать репозиторий
type IClothingItemRepository interface {
	GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error)
	GetByUser(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error)
	Create(ctx context.Context, item *domain.ClothingItem) error
	Update(ctx context.Context, item *domain.ClothingItem) error
	Delete(ctx context.Context, id domain.ID) error
	GetByFilters(ctx context.Context, filters domain.ClothingItemFilters) ([]domain.ClothingItem, error)
	LinkToWardrobe(ctx context.Context, userID, itemID domain.ID) error
	UnlinkFromWardrobe(ctx context.Context, userID, itemID domain.ID) error
}

// GetByID возвращает вещь по ID
func (r *ClothingItemRepository) GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	query := `
		SELECT
			ci.id, ci.user_id, ci.name, cc.name as category, ci.subcategory,
			ci.icon_emoji, ci.ml_score, ci.confidence, ci.weather_suitability,
			ci.gender, ci.master_category, ci.season, ci.base_colour,
			ci.usage, ci.source, ci.is_owned, ci.owner_user_id
		FROM clothing_items ci
		LEFT JOIN clothing_categories cc ON ci.category_id = cc.id
		WHERE ci.id = $1
	`

	var item domain.ClothingItem
	var category *string
	var subcategory *string
	var iconEmoji *string
	var mlScore *float64
	var confidence *float64
	var weatherSuitability *string
	var gender *string
	var masterCategory *string
	var season *string
	var baseColour *string
	var usage *string
	var source string
	var isOwned bool
	var ownerUserID *int64

	err := r.db.pool.QueryRow(ctx, query, id).Scan(
		&item.ID, &item.UserID, &item.Name, &category, &subcategory,
		&iconEmoji, &mlScore, &confidence, &weatherSuitability,
		&gender, &masterCategory, &season, &baseColour,
		&usage, &source, &isOwned, &ownerUserID,
	)

	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("clothing item with id %d not found", id)
		}
		return nil, fmt.Errorf("failed to scan clothing item: %w", err)
	}

	if category != nil {
		item.Category = *category
	}
	if subcategory != nil {
		item.Subcategory = *subcategory
	}
	if iconEmoji != nil {
		item.IconEmoji = *iconEmoji
	}
	if mlScore != nil {
		item.MLScore = *mlScore
	}
	if confidence != nil {
		item.Confidence = *confidence
	}
	if weatherSuitability != nil {
		item.WeatherSuitability = *weatherSuitability
	}
	if gender != nil {
		item.Gender = gender
	}
	if masterCategory != nil {
		item.MasterCategory = masterCategory
	}
	if season != nil {
		item.Season = season
	}
	if baseColour != nil {
		item.BaseColour = baseColour
	}
	if usage != nil {
		item.Usage = usage
	}
	item.Source = source
	item.IsOwned = isOwned
	if ownerUserID != nil {
		id := domain.ID(*ownerUserID)
		item.OwnerUserID = &id
	}

	return &item, nil
}

// GetByUser возвращает вещи пользователя
func (r *ClothingItemRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error) {
	query := `
		SELECT
			ci.id, ci.user_id, ci.name, cc.name as category, ci.subcategory,
			ci.icon_emoji, ci.ml_score, ci.confidence, ci.weather_suitability,
			ci.gender, ci.master_category, ci.season, ci.base_colour,
			ci.usage, ci.source, ci.is_owned, ci.owner_user_id
		FROM clothing_items ci
		LEFT JOIN clothing_categories cc ON ci.category_id = cc.id
		WHERE ci.user_id = $1
	`

	rows, err := r.db.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var category *string
		var subcategory *string
		var iconEmoji *string
		var mlScore *float64
		var confidence *float64
		var weatherSuitability *string
		var gender *string
		var masterCategory *string
		var season *string
		var baseColour *string
		var usage *string
		var source string
		var isOwned bool
		var ownerUserID *int64

		err := rows.Scan(
			&item.ID, &item.UserID, &item.Name, &category, &subcategory,
			&iconEmoji, &mlScore, &confidence, &weatherSuitability,
			&gender, &masterCategory, &season, &baseColour,
			&usage, &source, &isOwned, &ownerUserID,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan clothing item: %w", err)
		}

		if category != nil {
			item.Category = *category
		}
		if subcategory != nil {
			item.Subcategory = *subcategory
		}
		if iconEmoji != nil {
			item.IconEmoji = *iconEmoji
		}
		if mlScore != nil {
			item.MLScore = *mlScore
		}
		if confidence != nil {
			item.Confidence = *confidence
		}
		if weatherSuitability != nil {
			item.WeatherSuitability = *weatherSuitability
		}
		if gender != nil {
			item.Gender = gender
		}
		if masterCategory != nil {
			item.MasterCategory = masterCategory
		}
		if season != nil {
			item.Season = season
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if usage != nil {
			item.Usage = usage
		}
		item.Source = source
		item.IsOwned = isOwned
		if ownerUserID != nil {
			id := domain.ID(*ownerUserID)
			item.OwnerUserID = &id
		}

		items = append(items, item)
	}

	return items, nil
}

// Create создает новую вещь
func (r *ClothingItemRepository) Create(ctx context.Context, item *domain.ClothingItem) error {
	query := `
		INSERT INTO clothing_items (
			user_id, name, category_id, subcategory, icon_emoji, ml_score,
			confidence, weather_suitability, gender, master_category, season,
			base_colour, usage, source, is_owned, owner_user_id, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, NOW(), NOW())
		RETURNING id
	`

	var categoryID *int
	if item.CategoryID != 0 {
		categoryID = &item.CategoryID
	}

	var subcategory *string
	if item.Subcategory != "" {
		subcategory = &item.Subcategory
	}

	var iconEmoji *string
	if item.IconEmoji != "" {
		iconEmoji = &item.IconEmoji
	}

	var mlScore *float64
	if item.MLScore != 0 {
		mlScore = &item.MLScore
	}

	var confidence *float64
	if item.Confidence != 0 {
		confidence = &item.Confidence
	}

	var weatherSuitability *string
	if item.WeatherSuitability != "" {
		weatherSuitability = &item.WeatherSuitability
	}

	var gender *string
	if item.Gender != nil {
		gender = item.Gender
	}

	var masterCategory *string
	if item.MasterCategory != nil {
		masterCategory = item.MasterCategory
	}

	var season *string
	if item.Season != nil {
		season = item.Season
	}

	var baseColour *string
	if item.BaseColour != nil {
		baseColour = item.BaseColour
	}

	var usage *string
	if item.Usage != nil {
		usage = item.Usage
	}

	var ownerUserID *domain.ID
	if item.OwnerUserID != nil {
		ownerUserID = item.OwnerUserID
	}

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	err := r.db.pool.QueryRow(ctx, query,
		item.UserID, item.Name, categoryID, subcategory, iconEmoji,
		mlScore, confidence, weatherSuitability, gender, masterCategory,
		season, baseColour, usage, item.Source, item.IsOwned, ownerUserID,
	).Scan(&item.ID)

	if err != nil {
		return fmt.Errorf("failed to create clothing item: %w", err)
	}

	return nil
}

// Update обновляет существующую вещь
func (r *ClothingItemRepository) Update(ctx context.Context, item *domain.ClothingItem) error {
	query := `
		UPDATE clothing_items SET
			user_id = $2, name = $3, category_id = $4, subcategory = $5,
			icon_emoji = $6, ml_score = $7, confidence = $8,
			weather_suitability = $9, gender = $10, master_category = $11,
			season = $12, base_colour = $13, usage = $14, source = $15,
			is_owned = $16, owner_user_id = $17, updated_at = NOW()
		WHERE id = $1
	`

	var categoryID *int
	if item.CategoryID != 0 {
		categoryID = &item.CategoryID
	}

	var subcategory *string
	if item.Subcategory != "" {
		subcategory = &item.Subcategory
	}

	var iconEmoji *string
	if item.IconEmoji != "" {
		iconEmoji = &item.IconEmoji
	}

	var mlScore *float64
	if item.MLScore != 0 {
		mlScore = &item.MLScore
	}

	var confidence *float64
	if item.Confidence != 0 {
		confidence = &item.Confidence
	}

	var weatherSuitability *string
	if item.WeatherSuitability != "" {
		weatherSuitability = &item.WeatherSuitability
	}

	var gender *string
	if item.Gender != nil {
		gender = item.Gender
	}

	var masterCategory *string
	if item.MasterCategory != nil {
		masterCategory = item.MasterCategory
	}

	var season *string
	if item.Season != nil {
		season = item.Season
	}

	var baseColour *string
	if item.BaseColour != nil {
		baseColour = item.BaseColour
	}

	var usage *string
	if item.Usage != nil {
		usage = item.Usage
	}

	var ownerUserID *domain.ID
	if item.OwnerUserID != nil {
		ownerUserID = item.OwnerUserID
	}

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	tag, err := r.db.pool.Exec(ctx, query,
		item.ID, item.UserID, item.Name, categoryID, subcategory, iconEmoji,
		mlScore, confidence, weatherSuitability, gender, masterCategory,
		season, baseColour, usage, item.Source, item.IsOwned, ownerUserID,
	)

	if err != nil {
		return fmt.Errorf("failed to update clothing item: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return fmt.Errorf("clothing item with id %d not found", item.ID)
	}

	return nil
}

// Delete удаляет вещь
func (r *ClothingItemRepository) Delete(ctx context.Context, id domain.ID) error {
	query := "DELETE FROM clothing_items WHERE id = $1"

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	tag, err := r.db.pool.Exec(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete clothing item: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return fmt.Errorf("clothing item with id %d not found", id)
	}

	return nil
}

// ClothingItemFilters определяет фильтры для поиска вещей
type ClothingItemFilters struct {
	UserID       *domain.ID
	CategoryID   *int
	Gender       *string
	Season       *string
	Source       *string
	IsOwned      *bool
	Temperature  *float64  // Для фильтрации по температуре
	MaxTemp      *float64  // Для фильтрации по температуре
	MinTemp      *float64  // Для фильтрации по температуре
}

// GetByFilters возвращает вещи по фильтрам
func (r *ClothingItemRepository) GetByFilters(ctx context.Context, filters domain.ClothingItemFilters) ([]domain.ClothingItem, error) {
	// Строим запрос вручную, без Squirrel, для совместимости с pgx
	query := `
		SELECT
			ci.id, ci.user_id, ci.name, cc.name as category, ci.subcategory,
			ci.icon_emoji, ci.ml_score, ci.confidence, ci.weather_suitability,
			ci.gender, ci.master_category, ci.season, ci.base_colour,
			ci.usage, ci.source, ci.is_owned, ci.owner_user_id
		FROM clothing_items ci
		LEFT JOIN clothing_categories cc ON ci.category_id = cc.id
		WHERE 1=1
	`

	var args []interface{}
	argCount := 1

	if filters.UserID != nil {
		query += fmt.Sprintf(" AND ci.user_id = $%d", argCount)
		args = append(args, *filters.UserID)
		argCount++
	}
	if filters.CategoryID != nil && *filters.CategoryID != 0 {
		query += fmt.Sprintf(" AND ci.category_id = $%d", argCount)
		args = append(args, *filters.CategoryID)
		argCount++
	}
	if filters.Gender != nil {
		query += fmt.Sprintf(" AND ci.gender = $%d", argCount)
		args = append(args, *filters.Gender)
		argCount++
	}
	if filters.Season != nil {
		query += fmt.Sprintf(" AND ci.season = $%d", argCount)
		args = append(args, *filters.Season)
		argCount++
	}
	if filters.Source != nil {
		query += fmt.Sprintf(" AND ci.source = $%d", argCount)
		args = append(args, *filters.Source)
		argCount++
	}
	if filters.IsOwned != nil {
		query += fmt.Sprintf(" AND ci.is_owned = $%d", argCount)
		args = append(args, *filters.IsOwned)
		argCount++
	}

	rows, err := r.db.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var category *string
		var subcategory *string
		var iconEmoji *string
		var mlScore *float64
		var confidence *float64
		var weatherSuitability *string
		var gender *string
		var masterCategory *string
		var season *string
		var baseColour *string
		var usage *string
		var source string
		var isOwned bool
		var ownerUserID *int64

		err := rows.Scan(
			&item.ID, &item.UserID, &item.Name, &category, &subcategory,
			&iconEmoji, &mlScore, &confidence, &weatherSuitability,
			&gender, &masterCategory, &season, &baseColour,
			&usage, &source, &isOwned, &ownerUserID,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan clothing item: %w", err)
		}

		if category != nil {
			item.Category = *category
		}
		if subcategory != nil {
			item.Subcategory = *subcategory
		}
		if iconEmoji != nil {
			item.IconEmoji = *iconEmoji
		}
		if mlScore != nil {
			item.MLScore = *mlScore
		}
		if confidence != nil {
			item.Confidence = *confidence
		}
		if weatherSuitability != nil {
			item.WeatherSuitability = *weatherSuitability
		}
		if gender != nil {
			item.Gender = gender
		}
		if masterCategory != nil {
			item.MasterCategory = masterCategory
		}
		if season != nil {
			item.Season = season
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if usage != nil {
			item.Usage = usage
		}
		item.Source = source
		item.IsOwned = isOwned
		if ownerUserID != nil {
			id := domain.ID(*ownerUserID)
			item.OwnerUserID = &id
		}

		items = append(items, item)
	}

	return items, nil
}

// LinkToWardrobe связывает вещь с гардеробом пользователя
func (r *ClothingItemRepository) LinkToWardrobe(ctx context.Context, userID, itemID domain.ID) error {
	query := `
		INSERT INTO wardrobe_items (user_id, clothing_item_id)
		VALUES ($1, $2)
		ON CONFLICT (user_id, clothing_item_id) DO NOTHING
	`

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	_, err := r.db.pool.Exec(ctx, query, userID, itemID)
	if err != nil {
		return fmt.Errorf("failed to link clothing item to wardrobe: %w", err)
	}

	return nil
}

// UnlinkFromWardrobe отвязывает вещь от гардероба пользователя
func (r *ClothingItemRepository) UnlinkFromWardrobe(ctx context.Context, userID, itemID domain.ID) error {
	query := "DELETE FROM wardrobe_items WHERE user_id = $1 AND clothing_item_id = $2"

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	tag, err := r.db.pool.Exec(ctx, query, userID, itemID)
	if err != nil {
		return fmt.Errorf("failed to unlink clothing item from wardrobe: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return fmt.Errorf("wardrobe item link not found")
	}

	return nil
}