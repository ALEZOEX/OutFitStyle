package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type ClothingRepository struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

func NewClothingRepository(db *dbpkg.DB, logger *zap.Logger) repositories.ClothingRepository {
	return &ClothingRepository{db: db, logger: logger}
}

func (r *ClothingRepository) GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	items, err := r.GetByIDs(ctx, []domain.ID{id})
	if err != nil {
		return nil, err
	}
	if len(items) == 0 {
		return nil, nil
	}
	return &items[0], nil
}

func (r *ClothingRepository) GetByIDs(ctx context.Context, ids []domain.ID) ([]domain.ClothingItem, error) {
	if len(ids) == 0 {
		return nil, nil
	}

	q := `
SELECT
	id, name, description,
	category, subcategory,
	min_temp, max_temp, warmth_level,
	rain_ok, snow_ok, wind_ok,
	style, formality_level,
	base_colour, pattern, fit,
	gender, season,
	usage, materials,
	brand,
	image_url, thumbnail_url, icon_emoji,
	source, owner_id, is_owned,
	is_active, created_at, updated_at
FROM clothing_items
WHERE id = ANY($1)
`
	rows, err := r.db.Pool().Query(ctx, q, ids)
	if err != nil {
		return nil, errors.Wrap(err, "query clothing_items by ids")
	}
	defer rows.Close()

	var out []domain.ClothingItem
	for rows.Next() {
		var it domain.ClothingItem
		err := rows.Scan(
			&it.ID, &it.Name, &it.Description,
			&it.Category, &it.Subcategory,
			&it.MinTemp, &it.MaxTemp, &it.WarmthLevel,
			&it.RainOK, &it.SnowOK, &it.WindOK,
			&it.Style, &it.FormalityLevel,
			&it.BaseColour, &it.Pattern, &it.Fit,
			&it.Gender, &it.Season,
			&it.Usage, &it.Materials,
			&it.Brand,
			&it.ImageURL, &it.ThumbnailURL, &it.IconEmoji,
			&it.Source, &it.OwnerID, &it.IsOwned,
			&it.IsActive, &it.CreatedAt, &it.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "scan clothing_item")
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

func (r *ClothingRepository) ListWardrobeCandidates(ctx context.Context, userID domain.ID, limit int) ([]domain.ClothingItem, error) {
	if limit <= 0 {
		limit = 150
	}
	q := `
SELECT
	ci.id, ci.name, ci.description,
	ci.category, ci.subcategory,
	ci.min_temp, ci.max_temp, ci.warmth_level,
	ci.rain_ok, ci.snow_ok, ci.wind_ok,
	ci.style, ci.formality_level,
	ci.base_colour, ci.pattern, ci.fit,
	ci.gender, ci.season,
	ci.usage, ci.materials,
	ci.brand,
	ci.image_url, ci.thumbnail_url, ci.icon_emoji,
	ci.source, ci.owner_id, ci.is_owned,
	ci.is_active, ci.created_at, ci.updated_at
FROM user_wardrobe uw
JOIN clothing_items ci ON ci.id = uw.clothing_item_id
WHERE uw.user_id = $1 AND uw.is_archived = FALSE AND ci.is_active = TRUE
ORDER BY uw.is_favorite DESC, uw.updated_at DESC
LIMIT $2
`
	rows, err := r.db.Pool().Query(ctx, q, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "list wardrobe candidates")
	}
	defer rows.Close()

	var out []domain.ClothingItem
	for rows.Next() {
		var it domain.ClothingItem
		if err := rows.Scan(
			&it.ID, &it.Name, &it.Description,
			&it.Category, &it.Subcategory,
			&it.MinTemp, &it.MaxTemp, &it.WarmthLevel,
			&it.RainOK, &it.SnowOK, &it.WindOK,
			&it.Style, &it.FormalityLevel,
			&it.BaseColour, &it.Pattern, &it.Fit,
			&it.Gender, &it.Season,
			&it.Usage, &it.Materials,
			&it.Brand,
			&it.ImageURL, &it.ThumbnailURL, &it.IconEmoji,
			&it.Source, &it.OwnerID, &it.IsOwned,
			&it.IsActive, &it.CreatedAt, &it.UpdatedAt,
		); err != nil {
			return nil, errors.Wrap(err, "scan wardrobe candidate")
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

func (r *ClothingRepository) ListCatalogCandidates(ctx context.Context, includePartners bool, limit int) ([]domain.ClothingItem, error) {
	if limit <= 0 {
		limit = 150
	}
	// synthetic/manual всегда; partner — по флагу
	where := "ci.is_active = TRUE AND ci.owner_id IS NULL AND ci.source IN ('synthetic','manual')"
	if includePartners {
		where = "ci.is_active = TRUE AND ci.owner_id IS NULL AND ci.source IN ('synthetic','manual','partner')"
	}

	q := fmt.Sprintf(`
SELECT
	ci.id, ci.name, ci.description,
	ci.category, ci.subcategory,
	ci.min_temp, ci.max_temp, ci.warmth_level,
	ci.rain_ok, ci.snow_ok, ci.wind_ok,
	ci.style, ci.formality_level,
	ci.base_colour, ci.pattern, ci.fit,
	ci.gender, ci.season,
	ci.usage, ci.materials,
	ci.brand,
	ci.image_url, ci.thumbnail_url, ci.icon_emoji,
	ci.source, ci.owner_id, ci.is_owned,
	ci.is_active, ci.created_at, ci.updated_at
FROM clothing_items ci
WHERE %s
ORDER BY ci.created_at DESC
LIMIT $1
`, where)

	rows, err := r.db.Pool().Query(ctx, q, limit)
	if err != nil {
		return nil, errors.Wrap(err, "list catalog candidates")
	}
	defer rows.Close()

	var out []domain.ClothingItem
	for rows.Next() {
		var it domain.ClothingItem
		if err := rows.Scan(
			&it.ID, &it.Name, &it.Description,
			&it.Category, &it.Subcategory,
			&it.MinTemp, &it.MaxTemp, &it.WarmthLevel,
			&it.RainOK, &it.SnowOK, &it.WindOK,
			&it.Style, &it.FormalityLevel,
			&it.BaseColour, &it.Pattern, &it.Fit,
			&it.Gender, &it.Season,
			&it.Usage, &it.Materials,
			&it.Brand,
			&it.ImageURL, &it.ThumbnailURL, &it.IconEmoji,
			&it.Source, &it.OwnerID, &it.IsOwned,
			&it.IsActive, &it.CreatedAt, &it.UpdatedAt,
		); err != nil {
			return nil, errors.Wrap(err, "scan catalog candidate")
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

func (r *ClothingRepository) CreateUserItem(ctx context.Context, userID domain.ID, item domain.ClothingItem) (domain.ID, error) {
	// минимально требуемые поля по ТЗ: name, category, subcategory, style
	q := `
INSERT INTO clothing_items (
	name, category, subcategory, style,
	base_colour, pattern, fit,
	source, owner_id, is_owned,
	is_active
)
VALUES ($1,$2,$3,$4,$5,COALESCE($6,'solid'),COALESCE($7,'regular'), 'user', $8, TRUE, TRUE)
RETURNING id
`
	var id domain.ID
	err := r.db.Pool().QueryRow(ctx, q,
		item.Name,
		item.Category,
		item.Subcategory,
		item.Style,
		item.BaseColour,
		item.Pattern,
		item.Fit,
		userID,
	).Scan(&id)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "create user clothing item")
	}
	return id, nil
}

func (r *ClothingRepository) ListWardrobeCandidatesLite(ctx context.Context, userID domain.ID, limit int) ([]domain.CandidateLite, error) {
	if limit <= 0 {
		limit = 150
	}
	q := `
SELECT
	ci.id,
	ci.category, ci.subcategory,
	ci.source,
	ci.min_temp, ci.max_temp, ci.warmth_level,
	ci.rain_ok, ci.snow_ok, ci.wind_ok,
	ci.style, ci.formality_level,
	ci.base_colour, ci.pattern,
	uw.wear_count
FROM user_wardrobe uw
JOIN clothing_items ci ON ci.id = uw.clothing_item_id
WHERE uw.user_id = $1
  AND uw.is_archived = FALSE
  AND ci.is_active = TRUE
ORDER BY uw.is_favorite DESC, uw.updated_at DESC
LIMIT $2
`
	rows, err := r.db.Pool().Query(ctx, q, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "list wardrobe candidates lite")
	}
	defer rows.Close()

	out := make([]domain.CandidateLite, 0, limit)
	for rows.Next() {
		var c domain.CandidateLite
		var wearCount int
		if err := rows.Scan(
			&c.ID,
			&c.Category, &c.Subcategory,
			&c.Source,
			&c.MinTemp, &c.MaxTemp, &c.WarmthLevel,
			&c.RainOK, &c.SnowOK, &c.WindOK,
			&c.Style, &c.FormalityLevel,
			&c.BaseColour, &c.Pattern,
			&wearCount,
		); err != nil {
			return nil, errors.Wrap(err, "scan wardrobe candidate lite")
		}
		c.IsFromWardrobe = true
		c.WearCount = &wearCount
		out = append(out, c)
	}
	return out, rows.Err()
}

func (r *ClothingRepository) ListCatalogCandidatesLite(ctx context.Context, includePartners bool, limit int) ([]domain.CandidateLite, error) {
	if limit <= 0 {
		limit = 150
	}

	// synthetic/manual всегда; partner — по флагу
	where := "ci.is_active = TRUE AND ci.owner_id IS NULL AND ci.source IN ('synthetic','manual')"
	if includePartners {
		where = "ci.is_active = TRUE AND ci.owner_id IS NULL AND ci.source IN ('synthetic','manual','partner')"
	}

	q := `
SELECT
	ci.id,
	ci.category, ci.subcategory,
	ci.source,
	ci.min_temp, ci.max_temp, ci.warmth_level,
	ci.rain_ok, ci.snow_ok, ci.wind_ok,
	ci.style, ci.formality_level,
	ci.base_colour, ci.pattern
FROM clothing_items ci
WHERE ` + where + `
ORDER BY ci.created_at DESC
LIMIT $1
`
	rows, err := r.db.Pool().Query(ctx, q, limit)
	if err != nil {
		return nil, errors.Wrap(err, "list catalog candidates lite")
	}
	defer rows.Close()

	out := make([]domain.CandidateLite, 0, limit)
	for rows.Next() {
		var c domain.CandidateLite
		if err := rows.Scan(
			&c.ID,
			&c.Category, &c.Subcategory,
			&c.Source,
			&c.MinTemp, &c.MaxTemp, &c.WarmthLevel,
			&c.RainOK, &c.SnowOK, &c.WindOK,
			&c.Style, &c.FormalityLevel,
			&c.BaseColour, &c.Pattern,
		); err != nil {
			return nil, errors.Wrap(err, "scan catalog candidate lite")
		}
		c.IsFromWardrobe = false
		c.WearCount = nil
		out = append(out, c)
	}
	return out, rows.Err()
}

func (r *ClothingRepository) _ensureUsed() {
	// avoid unused imports if you tweak
	_ = pgx.ErrNoRows
}