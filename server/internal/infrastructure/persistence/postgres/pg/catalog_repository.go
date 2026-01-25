// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// CatalogRepository репозиторий для работы с каталогом товаров
type CatalogRepository struct {
	db *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
}

// NewCatalogRepository создает новый экземпляр репозитория каталога
func NewCatalogRepository(db *pgxpool.Pool) *CatalogRepository {
	return &CatalogRepository{db: db}
}

// GetItems возвращает элементы каталога с применением фильтров
func (r *CatalogRepository) GetItems(ctx context.Context, filters domain.CatalogFilters) ([]domain.CatalogItem, error) {
	query := `SELECT id, name, category, subcategory, gender, style, usage, season, base_colour, formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern, icon_emoji, source, is_owned, created_at FROM catalog_items WHERE TRUE`
	args := []interface{}{}
	argIndex := 1

	// Apply filters
	if filters.Categories != nil && len(filters.Categories) > 0 {
		query += " AND category = ANY($" + string(rune('0'+argIndex)) + ")"
		args = append(args, filters.Categories)
		argIndex++
	}

	if filters.Subcategories != nil && len(filters.Subcategories) > 0 {
		query += " AND subcategory = ANY($" + string(rune('0'+argIndex)) + ")"
		args = append(args, filters.Subcategories)
		argIndex++
	}

	if filters.Genders != nil && len(filters.Genders) > 0 {
		query += " AND gender = ANY($" + string(rune('0'+argIndex)) + ")"
		args = append(args, filters.Genders)
		argIndex++
	}

	if filters.Styles != nil && len(filters.Styles) > 0 {
		query += " AND style = ANY($" + string(rune('0'+argIndex)) + ")"
		args = append(args, filters.Styles)
		argIndex++
	}

	if filters.Seasons != nil && len(filters.Seasons) > 0 {
		query += " AND season = ANY($" + string(rune('0'+argIndex)) + ")"
		args = append(args, filters.Seasons)
		argIndex++
	}

	if filters.MinTemp != nil {
		query += " AND max_temp >= $" + string(rune('0'+argIndex))
		args = append(args, *filters.MinTemp)
		argIndex++
	}

	if filters.MaxTemp != nil {
		query += " AND min_temp <= $" + string(rune('0'+argIndex))
		args = append(args, *filters.MaxTemp)
		argIndex++
	}

	if filters.MinWarmth != nil {
		query += " AND warmth_level >= $" + string(rune('0'+argIndex))
		args = append(args, *filters.MinWarmth)
		argIndex++
	}

	if filters.MaxWarmth != nil {
		query += " AND warmth_level <= $" + string(rune('0'+argIndex))
		args = append(args, *filters.MaxWarmth)
		argIndex++
	}

	if filters.MinFormality != nil {
		query += " AND formality_level >= $" + string(rune('0'+argIndex))
		args = append(args, *filters.MinFormality)
		argIndex++
	}

	if filters.MaxFormality != nil {
		query += " AND formality_level <= $" + string(rune('0'+argIndex))
		args = append(args, *filters.MaxFormality)
		argIndex++
	}

	if filters.Colors != nil && len(filters.Colors) > 0 {
		query += " AND base_colour = ANY($" + string(rune('0'+argIndex)) + ")"
		args = append(args, filters.Colors)
		argIndex++
	}

	if filters.Materials != nil && len(filters.Materials) > 0 {
		query += " AND materials && $" + string(rune('0'+argIndex)) // Overlap operator
		args = append(args, filters.Materials)
		argIndex++
	}

	// Add pagination
	page := 1
	if filters.Page > 0 {
		page = filters.Page
	}
	limit := 20
	if filters.Limit > 0 {
		limit = filters.Limit
	}
	if limit > 100 {
		limit = 100
	}

	offset := (page - 1) * limit
	query += " LIMIT $" + string(rune('0'+argIndex)) + " OFFSET $" + string(rune('0'+argIndex+1))
	args = append(args, limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query catalog items")
	}
	defer rows.Close()

	var items []domain.CatalogItem
	for rows.Next() {
		var item domain.CatalogItem
		var materialsJSON []byte

		err := rows.Scan(
			&item.ID,
			&item.Name,
			&item.Category,
			&item.Subcategory,
			&item.Gender,
			&item.Style,
			&item.Usage,
			&item.Season,
			&item.BaseColour,
			&item.Formality,
			&item.Warmth,
			&item.MinTemp,
			&item.MaxTemp,
			&materialsJSON,
			&item.Fit,
			&item.Pattern,
			&item.IconEmoji,
			&item.Source,
			&item.IsOwned,
			&item.CreatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan catalog item")
		}

		// Parse materials from JSON
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		items = append(items, item)
	}

	return items, nil
}

func (r *CatalogRepository) GetItemByID(ctx context.Context, itemID domain.ID) (*domain.CatalogItem, error) {
	query := `SELECT id, name, category, subcategory, gender, style, usage, season, base_colour, formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern, icon_emoji, source, is_owned, created_at FROM catalog_items WHERE id = $1`

	var item domain.CatalogItem
	var materialsJSON []byte

	err := r.db.QueryRow(ctx, query, itemID).Scan(
		&item.ID,
		&item.Name,
		&item.Category,
		&item.Subcategory,
		&item.Gender,
		&item.Style,
		&item.Usage,
		&item.Season,
		&item.BaseColour,
		&item.Formality,
		&item.Warmth,
		&item.MinTemp,
		&item.MaxTemp,
		&materialsJSON,
		&item.Fit,
		&item.Pattern,
		&item.IconEmoji,
		&item.Source,
		&item.IsOwned,
		&item.CreatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get catalog item by ID")
	}

	// Parse materials from JSON
	if len(materialsJSON) > 0 {
		err = json.Unmarshal(materialsJSON, &item.Materials)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal materials")
		}
	}

	return &item, nil
}

func (r *CatalogRepository) CreateItem(ctx context.Context, item *domain.CatalogItem) error {
	query := `INSERT INTO catalog_items (id, name, category, subcategory, gender, style, usage, season, base_colour, formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern, icon_emoji, source, is_owned, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)`

	materialsJSON, err := json.Marshal(item.Materials)
	if err != nil {
		return errors.Wrap(err, "failed to marshal materials")
	}

	_, err = r.db.Exec(ctx, query,
		item.ID,
		item.Name,
		item.Category,
		item.Subcategory,
		item.Gender,
		item.Style,
		item.Usage,
		item.Season,
		item.BaseColour,
		item.Formality,
		item.Warmth,
		item.MinTemp,
		item.MaxTemp,
		materialsJSON,
		item.Fit,
		item.Pattern,
		item.IconEmoji,
		item.Source,
		item.IsOwned,
		item.CreatedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to insert catalog item")
	}

	return nil
}

func (r *CatalogRepository) UpdateItem(ctx context.Context, item *domain.CatalogItem) error {
	query := `UPDATE catalog_items SET name=$1, category=$2, subcategory=$3, gender=$4, style=$5, usage=$6, season=$7, base_colour=$8, formality_level=$9, warmth_level=$10, min_temp=$11, max_temp=$12, materials=$13, fit=$14, pattern=$15, icon_emoji=$16, source=$17, is_owned=$18, created_at=$19 WHERE id=$20`

	materialsJSON, err := json.Marshal(item.Materials)
	if err != nil {
		return errors.Wrap(err, "failed to marshal materials")
	}

	_, err = r.db.Exec(ctx, query,
		item.Name,
		item.Category,
		item.Subcategory,
		item.Gender,
		item.Style,
		item.Usage,
		item.Season,
		item.BaseColour,
		item.Formality,
		item.Warmth,
		item.MinTemp,
		item.MaxTemp,
		materialsJSON,
		item.Fit,
		item.Pattern,
		item.IconEmoji,
		item.Source,
		item.IsOwned,
		item.CreatedAt,
		item.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update catalog item")
	}

	return nil
}

func (r *CatalogRepository) DeleteItem(ctx context.Context, itemID domain.ID) error {
	query := `DELETE FROM catalog_items WHERE id = $1`

	tag, err := r.db.Exec(ctx, query, itemID)
	if err != nil {
		return errors.Wrap(err, "failed to delete catalog item")
	}

	if tag.RowsAffected() == 0 {
		return errors.New("no catalog item found with the given ID")
	}

	return nil
}

func (r *CatalogRepository) Search(ctx context.Context, p repositories.CatalogSearchParams) (items []domain.ClothingItem, total int, err error) {
	// Build query with filters
	query := `SELECT id, name, category, subcategory, gender, style, usage, season, base_colour, formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern, icon_emoji, source, is_owned, created_at FROM clothing_items WHERE TRUE`
	countQuery := `SELECT COUNT(*) FROM clothing_items WHERE TRUE`
	args := []interface{}{}
	argIndex := 1

	// Apply search term if provided
	if p.SearchTerm != "" {
		query += " AND (name ILIKE $" + string(rune('0'+argIndex)) + " OR description ILIKE $" + string(rune('0'+argIndex)) + ")"
		countQuery += " AND (name ILIKE $" + string(rune('0'+argIndex)) + " OR description ILIKE $" + string(rune('0'+argIndex)) + ")"
		searchPattern := "%" + p.SearchTerm + "%"
		args = append(args, searchPattern, searchPattern)
		argIndex++
	}

	// Apply filters from ClothingItemFilters
	if p.Filters.Category != nil {
		query += " AND category = $" + string(rune('0'+argIndex))
		countQuery += " AND category = $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.Category)
		argIndex++
	}

	if p.Filters.Subcategory != nil {
		query += " AND subcategory = $" + string(rune('0'+argIndex))
		countQuery += " AND subcategory = $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.Subcategory)
		argIndex++
	}

	if p.Filters.Gender != nil {
		query += " AND gender = $" + string(rune('0'+argIndex))
		countQuery += " AND gender = $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.Gender)
		argIndex++
	}

	if p.Filters.Style != nil {
		query += " AND style = $" + string(rune('0'+argIndex))
		countQuery += " AND style = $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.Style)
		argIndex++
	}

	if p.Filters.MinWarmth != nil {
		query += " AND warmth_level >= $" + string(rune('0'+argIndex))
		countQuery += " AND warmth_level >= $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.MinWarmth)
		argIndex++
	}

	if p.Filters.MaxWarmth != nil {
		query += " AND warmth_level <= $" + string(rune('0'+argIndex))
		countQuery += " AND warmth_level <= $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.MaxWarmth)
		argIndex++
	}

	if p.Filters.Season != nil {
		query += " AND season = $" + string(rune('0'+argIndex))
		countQuery += " AND season = $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.Season)
		argIndex++
	}

	if p.Filters.Materials != nil && len(p.Filters.Materials) > 0 {
		query += " AND materials && $" + string(rune('0'+argIndex)) // Overlap operator
		countQuery += " AND materials && $" + string(rune('0'+argIndex))
		args = append(args, p.Filters.Materials)
		argIndex++
	}

	if p.Filters.Colors != nil && len(p.Filters.Colors) > 0 {
		query += " AND base_colour = ANY($" + string(rune('0'+argIndex)) + ")"
		countQuery += " AND base_colour = ANY($" + string(rune('0'+argIndex)) + ")"
		args = append(args, p.Filters.Colors)
		argIndex++
	}

	if p.Filters.MinTemp != nil {
		query += " AND max_temp >= $" + string(rune('0'+argIndex))
		countQuery += " AND max_temp >= $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.MinTemp)
		argIndex++
	}

	if p.Filters.MaxTemp != nil {
		query += " AND min_temp <= $" + string(rune('0'+argIndex))
		countQuery += " AND min_temp <= $" + string(rune('0'+argIndex))
		args = append(args, *p.Filters.MaxTemp)
		argIndex++
	}

	// Get total count
	err = r.db.QueryRow(ctx, countQuery, args...).Scan(&total)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count catalog items")
	}

	// Add pagination
	page := 1
	if p.Page > 0 {
		page = p.Page
	}
	limit := 20
	if p.Limit > 0 {
		limit = p.Limit
	}
	if limit > 100 {
		limit = 100
	}

	offset := (page - 1) * limit
	query += " LIMIT $" + string(rune('0'+argIndex)) + " OFFSET $" + string(rune('0'+argIndex+1))
	args = append(args, limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query catalog items")
	}
	defer rows.Close()

	for rows.Next() {
		var item domain.ClothingItem
		var materialsJSON []byte

		err := rows.Scan(
			&item.ID,
			&item.Name,
			&item.Category,
			&item.Subcategory,
			&item.Gender,
			&item.Style,
			&item.Usage,
			&item.Season,
			&item.BaseColour,
			&item.FormalityLevel,
			&item.WarmthLevel,
			&item.MinTemp,
			&item.MaxTemp,
			&materialsJSON,
			&item.Fit,
			&item.Pattern,
			&item.IconEmoji,
			&item.Source,
			&item.IsOwned,
			&item.CreatedAt,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan catalog item")
		}

		// Parse materials from JSON
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, 0, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		items = append(items, item)
	}

	return items, total, nil
}

func (r *CatalogRepository) Categories(ctx context.Context) (any, error) {
	query := `SELECT DISTINCT category FROM clothing_items WHERE is_active = true ORDER BY category`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query categories")
	}
	defer rows.Close()

	var categories []string
	for rows.Next() {
		var category string
		err := rows.Scan(&category)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan category")
		}
		categories = append(categories, category)
	}

	return categories, nil
}

func (r *CatalogRepository) GetItem(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	query := `SELECT id, name, description, category, subcategory, min_temp, max_temp, warmth_level, rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern, wear_count, source, owner_id, is_owned, is_active, created_at, updated_at FROM clothing_items WHERE id = $1`

	var item domain.ClothingItem
	var description *string
	var minTemp, maxTemp, warmthLevel, formalityLevel *int16
	var wearCount *int
	var ownerID *uuid.UUID

	err := r.db.QueryRow(ctx, query, id).Scan(
		&item.ID,
		&description,
		&item.Category,
		&item.Subcategory,
		&minTemp,
		&maxTemp,
		&warmthLevel,
		&item.RainOK,
		&item.SnowOK,
		&item.WindOK,
		&item.Style,
		&formalityLevel,
		&item.BaseColour,
		&item.Pattern,
		&wearCount,
		&item.Source,
		&ownerID,
		&item.IsOwned,
		&item.IsActive,
		&item.CreatedAt,
		&item.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get clothing item by ID")
	}

	// Set nullable fields
	if description != nil {
		item.Description = description
	}
	if minTemp != nil {
		item.MinTemp = minTemp
	}
	if maxTemp != nil {
		item.MaxTemp = maxTemp
	}
	if warmthLevel != nil {
		item.WarmthLevel = warmthLevel
	}
	if formalityLevel != nil {
		level := int16(*formalityLevel)
		item.FormalityLevel = &level
	}
	if wearCount != nil {
		item.WearCount = *wearCount
	}
	if ownerID != nil {
		oid := domain.ID(*ownerID)
		item.OwnerID = &oid
	}

	// Load materials separately
	materialsQuery := `SELECT material FROM clothing_item_materials WHERE item_id = $1`
	materialsRows, err := r.db.Query(ctx, materialsQuery, id)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query materials")
	}
	defer materialsRows.Close()

	for materialsRows.Next() {
		var material string
		err := materialsRows.Scan(&material)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan material")
		}
		item.Materials = append(item.Materials, material)
	}

	return &item, nil
}

func (r *CatalogRepository) Similar(ctx context.Context, id domain.ID, limit int) ([]domain.ClothingItem, error) {
	// This is a simplified implementation - in a real system, you'd want to use
	// more sophisticated similarity algorithms based on category, style, colors, etc.
	query := `
		SELECT ci.id, ci.name, ci.description, ci.category, ci.subcategory,
		       ci.min_temp, ci.max_temp, ci.warmth_level, ci.rain_ok, ci.snow_ok, ci.wind_ok,
		       ci.style, ci.formality_level, ci.base_colour, ci.pattern, ci.wear_count,
		       ci.source, ci.owner_id, ci.is_owned, ci.is_active, ci.created_at, ci.updated_at
		FROM clothing_items ci
		WHERE ci.category = (SELECT category FROM clothing_items WHERE id = $1)
		  AND ci.id != $1
		LIMIT $2
	`

	rows, err := r.db.Query(ctx, query, id, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query similar items")
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var description *string
		var minTemp, maxTemp, warmthLevel, formalityLevel *int16
		var wearCount *int
		var ownerID *uuid.UUID

		err := rows.Scan(
			&item.ID,
			&description,
			&item.Category,
			&item.Subcategory,
			&minTemp,
			&maxTemp,
			&warmthLevel,
			&item.RainOK,
			&item.SnowOK,
			&item.WindOK,
			&item.Style,
			&formalityLevel,
			&item.BaseColour,
			&item.Pattern,
			&wearCount,
			&item.Source,
			&ownerID,
			&item.IsOwned,
			&item.IsActive,
			&item.CreatedAt,
			&item.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan similar item")
		}

		// Set nullable fields
		if description != nil {
			item.Description = description
		}
		if minTemp != nil {
			item.MinTemp = minTemp
		}
		if maxTemp != nil {
			item.MaxTemp = maxTemp
		}
		if warmthLevel != nil {
			item.WarmthLevel = warmthLevel
		}
		if formalityLevel != nil {
			level := int16(*formalityLevel)
			item.FormalityLevel = &level
		}
		if wearCount != nil {
			item.WearCount = *wearCount
		}
		if ownerID != nil {
			oid := domain.ID(*ownerID)
			item.OwnerID = &oid
		}

		items = append(items, item)
	}

	return items, nil
}

func (r *CatalogRepository) Click(ctx context.Context, userID *domain.ID, itemID domain.ID) (string, error) {
	// Generate a unique click ID
	clickID := uuid.New().String()

	// Insert click record
	query := `INSERT INTO catalog_item_clicks (click_id, user_id, item_id, clicked_at) VALUES ($1, $2, $3, NOW())`

	var uid *uuid.UUID
	if userID != nil {
		uid = (*uuid.UUID)(userID)
	}

	_, err := r.db.Exec(ctx, query, clickID, uid, itemID)
	if err != nil {
		return "", errors.Wrap(err, "failed to record catalog item click")
	}

	return clickID, nil
}
