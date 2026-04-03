// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/cache"
)

// ClothingRepository репозиторий для работы с элементами одежды
type ClothingRepository struct {
	db    *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
	cache *cache.RepositoryCache
}

// NewClothingRepository создает новый экземпляр репозитория элементов одежды
func NewClothingRepository(db *pgxpool.Pool, redisClient *redis.Client, logger interface{}) *ClothingRepository {
	var zapLogger *zap.Logger
	if l, ok := logger.(*zap.Logger); ok {
		zapLogger = l
	} else {
		// Create a default logger if the passed logger is not a zap logger
		zapLogger = zap.NewNop()
	}

	return &ClothingRepository{
		db:    db,
		cache: cache.NewRepositoryCache(redisClient, zapLogger),
	}
}

// GetByID возвращает элемент одежды по его идентификатору
func (r *ClothingRepository) GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	cacheKey := r.cache.GenerateKey("clothing:item:id", id)

	var cachedItem domain.ClothingItem
	err := r.cache.Get(ctx, cacheKey, &cachedItem)
	if err == nil && cachedItem.ID != domain.NilID {
		// Return cached item if found
		return &cachedItem, nil
	}

	query := `
		SELECT
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		FROM clothing_items
		WHERE id = $1 AND is_active = true
	`

	var item domain.ClothingItem
	var description *string
	var minTemp, maxTemp, warmthLevel *int16
	var formalityLevel *int16
	var baseColour *string
	var usageJSON []byte
	var materialsJSON []byte
	var ownerID *uuid.UUID
	var createdAt, updatedAt time.Time

	err = r.db.QueryRow(ctx, query, id).Scan(
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
		&baseColour,
		&item.Pattern,
		&usageJSON,
		&materialsJSON,
		&item.Fit,
		&item.IconEmoji,
		&item.Source,
		&ownerID,
		&item.IsOwned,
		&item.IsActive,
		&createdAt,
		&updatedAt,
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
		item.FormalityLevel = formalityLevel
	}
	if baseColour != nil {
		item.BaseColour = baseColour
	}
	if ownerID != nil {
		oid := domain.ID(*ownerID)
		item.OwnerID = &oid
	}

	// Parse usage and materials from JSON
	if len(usageJSON) > 0 {
		err = json.Unmarshal(usageJSON, &item.Usage)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal usage")
		}
	}
	if len(materialsJSON) > 0 {
		err = json.Unmarshal(materialsJSON, &item.Materials)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal materials")
		}
	}

	item.CreatedAt = createdAt
	item.UpdatedAt = updatedAt

	// Cache the result
	go func() {
		// Use background context to avoid cancellation issues
		bgCtx := context.Background()
		_ = r.cache.Set(bgCtx, cacheKey, &item, 15*time.Minute)
	}()

	return &item, nil
}

func (r *ClothingRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error) {
	query := `
		SELECT
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		FROM clothing_items
		WHERE owner_id = $1 AND is_active = true
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query clothing items by user")
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var description *string
		var minTemp, maxTemp, warmthLevel *int16
		var formalityLevel *int16
		var baseColour *string
		var usageJSON []byte
		var materialsJSON []byte
		var ownerID *uuid.UUID
		var createdAt, updatedAt time.Time

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
			&baseColour,
			&item.Pattern,
			&usageJSON,
			&materialsJSON,
			&item.Fit,
			&item.IconEmoji,
			&item.Source,
			&ownerID,
			&item.IsOwned,
			&item.IsActive,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item")
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if ownerID != nil {
			oid := domain.ID(*ownerID)
			item.OwnerID = &oid
		}

		// Parse usage and materials from JSON
		if len(usageJSON) > 0 {
			err = json.Unmarshal(usageJSON, &item.Usage)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal usage")
			}
		}
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		items = append(items, item)
	}

	return items, nil
}

func (r *ClothingRepository) Create(ctx context.Context, item *domain.ClothingItem) error {
	query := `
		INSERT INTO clothing_items (
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25)
	`

	description := item.Description
	minTemp := item.MinTemp
	maxTemp := item.MaxTemp
	warmthLevel := item.WarmthLevel
	formalityLevel := item.FormalityLevel
	baseColour := item.BaseColour
	if description == nil {
		description = new(string)
	}
	if baseColour == nil {
		baseColour = new(string)
	}

	usageJSON, err := json.Marshal(item.Usage)
	if err != nil {
		return errors.Wrap(err, "failed to marshal usage")
	}

	materialsJSON, err := json.Marshal(item.Materials)
	if err != nil {
		return errors.Wrap(err, "failed to marshal materials")
	}

	var ownerID *uuid.UUID
	if item.OwnerID != nil {
		uid := uuid.UUID(*item.OwnerID)
		ownerID = &uid
	}

	_, err = r.db.Exec(ctx, query,
		item.ID,
		item.Name,
		description,
		item.Category,
		item.Subcategory,
		minTemp,
		maxTemp,
		warmthLevel,
		item.RainOK,
		item.SnowOK,
		item.WindOK,
		item.Style,
		formalityLevel,
		baseColour,
		item.Pattern,
		usageJSON,
		materialsJSON,
		item.Fit,
		item.IconEmoji,
		item.Source,
		ownerID,
		item.IsOwned,
		item.IsActive,
		item.CreatedAt,
		item.UpdatedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to insert clothing item")
	}

	// Invalidate cache for this item
	go func() {
		// Use background context to avoid cancellation issues
		bgCtx := context.Background()
		cacheKey := r.cache.GenerateKey("clothing:item:id", item.ID)
		_ = r.cache.Delete(bgCtx, cacheKey)

		// Also invalidate related caches
		if item.OwnerID != nil {
			_ = r.cache.InvalidatePattern(bgCtx, r.cache.GenerateKey("clothing:user:", *item.OwnerID))
		}
	}()

	return nil
}

func (r *ClothingRepository) Update(ctx context.Context, item *domain.ClothingItem) error {
	query := `
		UPDATE clothing_items SET
			name = $1, description = $2, category = $3, subcategory = $4,
			min_temp = $5, max_temp = $6, warmth_level = $7, rain_ok = $8,
			snow_ok = $9, wind_ok = $10, style = $11, formality_level = $12,
			base_colour = $13, pattern = $14, usage = $15, materials = $16,
			fit = $17, icon_emoji = $18, source = $19, owner_id = $20,
			is_owned = $21, is_active = $22, updated_at = $23
		WHERE id = $24
	`

	description := item.Description
	minTemp := item.MinTemp
	maxTemp := item.MaxTemp
	warmthLevel := item.WarmthLevel
	formalityLevel := item.FormalityLevel
	baseColour := item.BaseColour
	if description == nil {
		description = new(string)
	}
	if baseColour == nil {
		baseColour = new(string)
	}

	usageJSON, err := json.Marshal(item.Usage)
	if err != nil {
		return errors.Wrap(err, "failed to marshal usage")
	}

	materialsJSON, err := json.Marshal(item.Materials)
	if err != nil {
		return errors.Wrap(err, "failed to marshal materials")
	}

	var ownerID *uuid.UUID
	if item.OwnerID != nil {
		uid := uuid.UUID(*item.OwnerID)
		ownerID = &uid
	}

	_, err = r.db.Exec(ctx, query,
		item.Name,
		description,
		item.Category,
		item.Subcategory,
		minTemp,
		maxTemp,
		warmthLevel,
		item.RainOK,
		item.SnowOK,
		item.WindOK,
		item.Style,
		formalityLevel,
		baseColour,
		item.Pattern,
		usageJSON,
		materialsJSON,
		item.Fit,
		item.IconEmoji,
		item.Source,
		ownerID,
		item.IsOwned,
		item.IsActive,
		time.Now(),
		item.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update clothing item")
	}

	// Invalidate cache for this item
	go func() {
		// Use background context to avoid cancellation issues
		bgCtx := context.Background()
		cacheKey := r.cache.GenerateKey("clothing:item:id", item.ID)
		_ = r.cache.Delete(bgCtx, cacheKey)

		// Also invalidate related caches
		if item.OwnerID != nil {
			_ = r.cache.InvalidatePattern(bgCtx, r.cache.GenerateKey("clothing:user:", *item.OwnerID))
		}
	}()

	return nil
}

func (r *ClothingRepository) CreateUserItem(ctx context.Context, userID domain.ID, item domain.ClothingItem) (domain.ID, error) {
	// Generate new ID for the item
	item.ID = domain.NewID()
	item.OwnerID = &userID
	item.IsOwned = true
	item.IsActive = true
	item.CreatedAt = time.Now()
	item.UpdatedAt = time.Now()

	err := r.Create(ctx, &item)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to create user clothing item")
	}

	return item.ID, nil
}

func (r *ClothingRepository) Delete(ctx context.Context, id domain.ID) error {
	query := `UPDATE clothing_items SET is_active = false, updated_at = NOW() WHERE id = $1`

	tag, err := r.db.Exec(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete clothing item")
	}

	if tag.RowsAffected() == 0 {
		return errors.New("no clothing item found with the given ID")
	}

	// Invalidate cache for this item
	go func() {
		// Use background context to avoid cancellation issues
		bgCtx := context.Background()
		cacheKey := r.cache.GenerateKey("clothing:item:id", id)
		_ = r.cache.Delete(bgCtx, cacheKey)
	}()

	return nil
}

func (r *ClothingRepository) GetByCategory(ctx context.Context, userID domain.ID, category string) ([]domain.ClothingItem, error) {
	query := `
		SELECT
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		FROM clothing_items
		WHERE owner_id = $1 AND category = $2 AND is_active = true
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID, category)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query clothing items by category")
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var description *string
		var minTemp, maxTemp, warmthLevel *int16
		var formalityLevel *int16
		var baseColour *string
		var usageJSON []byte
		var materialsJSON []byte
		var ownerID *uuid.UUID
		var createdAt, updatedAt time.Time

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
			&baseColour,
			&item.Pattern,
			&usageJSON,
			&materialsJSON,
			&item.Fit,
			&item.IconEmoji,
			&item.Source,
			&ownerID,
			&item.IsOwned,
			&item.IsActive,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item")
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if ownerID != nil {
			oid := domain.ID(*ownerID)
			item.OwnerID = &oid
		}

		// Parse usage and materials from JSON
		if len(usageJSON) > 0 {
			err = json.Unmarshal(usageJSON, &item.Usage)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal usage")
			}
		}
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		items = append(items, item)
	}

	return items, nil
}

func (r *ClothingRepository) GetByIDs(ctx context.Context, ids []domain.ID) ([]domain.ClothingItem, error) {
	if len(ids) == 0 {
		return []domain.ClothingItem{}, nil
	}

	query := `
		SELECT
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		FROM clothing_items
		WHERE id = ANY($1) AND is_active = true
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, ids)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query clothing items by IDs")
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var description *string
		var minTemp, maxTemp, warmthLevel *int16
		var formalityLevel *int16
		var baseColour, pattern *string
		var usageJSON []byte
		var materials []string
		var ownerID *uuid.UUID
		var createdAt, updatedAt time.Time

		err := rows.Scan(
			&item.ID,
			&item.Name,
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
			&baseColour,
			&pattern,
			&usageJSON,
			&materials,
			&item.Fit,
			&item.IconEmoji,
			&item.Source,
			&ownerID,
			&item.IsOwned,
			&item.IsActive,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item")
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if pattern != nil {
			item.Pattern = *pattern
		}
		if ownerID != nil {
			oid := domain.ID(*ownerID)
			item.OwnerID = &oid
		}

		// Parse usage and materials from JSON
		if len(usageJSON) > 0 {
			err = json.Unmarshal(usageJSON, &item.Usage)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal usage")
			}
		}
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		items = append(items, item)
	}

	return items, nil
}

func (r *ClothingRepository) ListWardrobeCandidates(ctx context.Context, userID domain.ID, limit int) ([]domain.ClothingItem, error) {
	query := `
		SELECT
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		FROM clothing_items
		WHERE owner_id = $1 AND is_active = true
		ORDER BY created_at DESC
		LIMIT $2
	`

	rows, err := r.db.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query wardrobe candidate items")
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var description *string
		var minTemp, maxTemp, warmthLevel *int16
		var formalityLevel *int16
		var baseColour *string
		var usageJSON []byte
		var materialsJSON []byte
		var ownerID *uuid.UUID
		var createdAt, updatedAt time.Time

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
			&baseColour,
			&item.Pattern,
			&usageJSON,
			&materialsJSON,
			&item.Fit,
			&item.IconEmoji,
			&item.Source,
			&ownerID,
			&item.IsOwned,
			&item.IsActive,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item")
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if ownerID != nil {
			oid := domain.ID(*ownerID)
			item.OwnerID = &oid
		}

		// Parse usage and materials from JSON
		if len(usageJSON) > 0 {
			err = json.Unmarshal(usageJSON, &item.Usage)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal usage")
			}
		}
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		items = append(items, item)
	}

	return items, nil
}

func (r *ClothingRepository) ListCatalogCandidates(ctx context.Context, includePartners bool, limit int) ([]domain.ClothingItem, error) {
	query := `
		SELECT
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		FROM clothing_items
		WHERE is_active = true
	`
	args := []interface{}{}
	argIndex := 1

	if !includePartners {
		query += " AND source != 'partner'"
	}

	query += " ORDER BY created_at DESC LIMIT $" + fmt.Sprintf("%d", argIndex)
	args = append(args, limit)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query catalog candidate items")
	}
	defer rows.Close()

	var items []domain.ClothingItem
	for rows.Next() {
		var item domain.ClothingItem
		var description *string
		var minTemp, maxTemp, warmthLevel *int16
		var formalityLevel *int16
		var baseColour *string
		var usageJSON []byte
		var materialsJSON []byte
		var ownerID *uuid.UUID
		var createdAt, updatedAt time.Time

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
			&baseColour,
			&item.Pattern,
			&usageJSON,
			&materialsJSON,
			&item.Fit,
			&item.IconEmoji,
			&item.Source,
			&ownerID,
			&item.IsOwned,
			&item.IsActive,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item")
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if ownerID != nil {
			oid := domain.ID(*ownerID)
			item.OwnerID = &oid
		}

		// Parse usage and materials from JSON
		if len(usageJSON) > 0 {
			err = json.Unmarshal(usageJSON, &item.Usage)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal usage")
			}
		}
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		items = append(items, item)
	}

	return items, nil
}

func (r *ClothingRepository) ListWardrobeCandidatesLite(ctx context.Context, userID domain.ID, limit int) ([]domain.CandidateLite, error) {
	query := `
		SELECT
			id, category, subcategory, source, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			wear_count, is_owned
		FROM clothing_items
		WHERE owner_id = $1 AND is_active = true
		ORDER BY created_at DESC
		LIMIT $2
	`

	rows, err := r.db.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query wardrobe candidate items (lite)")
	}
	defer rows.Close()

	var items []domain.CandidateLite
	for rows.Next() {
		var item domain.CandidateLite
		var minTemp, maxTemp, warmthLevel *int
		var formalityLevel *int
		var baseColour, pattern *string

		err := rows.Scan(
			&item.ID,
			&item.Category,
			&item.Subcategory,
			&item.Source,
			&minTemp,
			&maxTemp,
			&warmthLevel,
			&item.RainOK,
			&item.SnowOK,
			&item.WindOK,
			&item.Style,
			&formalityLevel,
			&baseColour,
			&pattern,
			&item.WearCount,
			&item.IsFromWardrobe,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item (lite)")
		}

		// Set nullable fields
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if pattern != nil {
			item.Pattern = *pattern
		}

		// Set IsFromWardrobe to true since these are wardrobe items
		item.IsFromWardrobe = true

		items = append(items, item)
	}

	return items, nil
}

func (r *ClothingRepository) ListCatalogCandidatesLite(ctx context.Context, includePartners bool, limit int) ([]domain.CandidateLite, error) {
	query := `
		SELECT
			id, category, subcategory, source, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			wear_count, is_owned
		FROM clothing_items
		WHERE is_active = true
	`
	args := []interface{}{}
	argIndex := 1

	if !includePartners {
		query += " AND source != 'partner'"
	}

	query += " ORDER BY created_at DESC LIMIT $" + fmt.Sprintf("%d", argIndex)
	args = append(args, limit)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query catalog candidate items (lite)")
	}
	defer rows.Close()

	var items []domain.CandidateLite
	for rows.Next() {
		var item domain.CandidateLite
		var minTemp, maxTemp, warmthLevel *int
		var formalityLevel *int
		var baseColour, pattern *string

		err := rows.Scan(
			&item.ID,
			&item.Category,
			&item.Subcategory,
			&item.Source,
			&minTemp,
			&maxTemp,
			&warmthLevel,
			&item.RainOK,
			&item.SnowOK,
			&item.WindOK,
			&item.Style,
			&formalityLevel,
			&baseColour,
			&pattern,
			&item.WearCount,
			&item.IsFromWardrobe,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item (lite)")
		}

		// Set nullable fields
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if pattern != nil {
			item.Pattern = *pattern
		}

		// Set IsFromWardrobe to false since these are catalog items
		item.IsFromWardrobe = false

		items = append(items, item)
	}

	return items, nil
}

// GetItemsByCategory возвращает предметы одежды пользователя, сгруппированные по категориям
func (r *ClothingRepository) GetItemsByCategory(ctx context.Context, userID domain.ID) (map[string][]domain.ClothingItem, error) {
	query := `
		SELECT
			id, name, description, category, subcategory, min_temp, max_temp, warmth_level,
			rain_ok, snow_ok, wind_ok, style, formality_level, base_colour, pattern,
			usage, materials, fit, icon_emoji, source, owner_id, is_owned, is_active,
			created_at, updated_at
		FROM clothing_items
		WHERE owner_id = $1 AND is_active = true
		ORDER BY category, created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query clothing items by category")
	}
	defer rows.Close()

	// Группируем предметы по категориям
	itemsByCategory := make(map[string][]domain.ClothingItem)

	for rows.Next() {
		var item domain.ClothingItem
		var description *string
		var minTemp, maxTemp, warmthLevel *int16
		var formalityLevel *int16
		var baseColour *string
		var usageJSON []byte
		var materialsJSON []byte
		var ownerID *uuid.UUID
		var createdAt, updatedAt time.Time

		err := rows.Scan(
			&item.ID,
			&item.Name,
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
			&baseColour,
			&item.Pattern,
			&usageJSON,
			&materialsJSON,
			&item.Fit,
			&item.IconEmoji,
			&item.Source,
			&ownerID,
			&item.IsOwned,
			&item.IsActive,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan clothing item")
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
			item.FormalityLevel = formalityLevel
		}
		if baseColour != nil {
			item.BaseColour = baseColour
		}
		if ownerID != nil {
			oid := domain.ID(*ownerID)
			item.OwnerID = &oid
		}

		// Parse usage and materials from JSON
		if len(usageJSON) > 0 {
			err = json.Unmarshal(usageJSON, &item.Usage)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal usage")
			}
		}
		if len(materialsJSON) > 0 {
			err = json.Unmarshal(materialsJSON, &item.Materials)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal materials")
			}
		}

		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		// Добавляем предмет в соответствующую категорию
		itemsByCategory[item.Category] = append(itemsByCategory[item.Category], item)
	}

	// Проверяем ошибки после итерации
	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "error iterating clothing items")
	}

	// Возвращаем пустую мапу, если нет предметов (не ошибку)
	return itemsByCategory, nil
}
