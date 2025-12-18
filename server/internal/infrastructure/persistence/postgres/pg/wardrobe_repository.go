package pg

import (
	"context"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type WardrobeRepository struct {
	db *dbpkg.DB
}

func NewWardrobeRepository(db *dbpkg.DB) repositories.WardrobeRepository {
	return &WardrobeRepository{db: db}
}

func (r *WardrobeRepository) List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) ([]domain.WardrobeItem, int, error) {
	limit := q.Limit
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	page := q.Page
	if page <= 0 {
		page = 1
	}
	offset := (page - 1) * limit

	where := []string{"uw.user_id = $1"}
	args := []any{userID}
	argN := 2

	add := func(cond string, v any) {
		where = append(where, "("+cond+")")
		args = append(args, v)
		argN++
	}

	if q.IsFavorite != nil {
		add("uw.is_favorite = $"+itoa(argN), *q.IsFavorite)
	}
	if q.IsArchived != nil {
		add("uw.is_archived = $"+itoa(argN), *q.IsArchived)
	}
	if q.Category != nil && *q.Category != "" {
		add("ci.category = $"+itoa(argN), *q.Category)
	}
	if q.Style != nil && *q.Style != "" {
		add("ci.style = $"+itoa(argN), *q.Style)
	}
	if q.Season != nil && *q.Season != "" {
		add("ci.season = $"+itoa(argN), *q.Season)
	}
	if q.Search != nil && strings.TrimSpace(*q.Search) != "" {
		s := strings.TrimSpace(*q.Search)
		// trigram индексы помогут
		add("(ci.name ILIKE '%' || $"+itoa(argN)+" || '%' OR COALESCE(uw.custom_name,'') ILIKE '%' || $"+itoa(argN)+" || '%')", s)
	}

	whereSQL := strings.Join(where, " AND ")

	// total
	var total int
	countQ := `
SELECT COUNT(*)
FROM user_wardrobe uw
JOIN clothing_items ci ON ci.id = uw.clothing_item_id
WHERE ` + whereSQL
	if err := r.db.Pool().QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, errors.Wrap(err, "count wardrobe")
	}

	sortCol := wardrobeSortColumn(q.Sort)
	order := "DESC"
	if strings.ToLower(string(q.Order)) == "asc" {
		order = "ASC"
	}

	// list
	qSQL := `
SELECT
uw.id, uw.user_id, uw.clothing_item_id,
uw.custom_name, uw.notes, uw.tags,
uw.purchase_date, uw.purchase_price, uw.purchase_currency,
uw.wear_count, uw.last_worn_at,
uw.is_favorite, uw.is_archived, uw.condition,
uw.created_at, uw.updated_at,

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
WHERE ` + whereSQL + `
ORDER BY ` + sortCol + ` ` + order + `
LIMIT $` + itoa(argN) + ` OFFSET $` + itoa(argN+1)

	args = append(args, limit, offset)

	rows, err := r.db.Pool().Query(ctx, qSQL, args...)
	if err != nil {
		return nil, 0, errors.Wrap(err, "list wardrobe")
	}
	defer rows.Close()

	out := make([]domain.WardrobeItem, 0, limit)
	for rows.Next() {
		var wi domain.WardrobeItem
		var ci domain.ClothingItem

		if err := rows.Scan(
&wi.ID, &wi.UserID, &wi.ClothingItemID,
&wi.CustomName, &wi.Notes, &wi.Tags,
&wi.PurchaseDate, &wi.PurchasePrice, &wi.PurchaseCurrency,
&wi.WearCount, &wi.LastWornAt,
&wi.IsFavorite, &wi.IsArchived, &wi.Condition,
&wi.CreatedAt, &wi.UpdatedAt,

&ci.ID, &ci.Name, &ci.Description,
&ci.Category, &ci.Subcategory,
&ci.MinTemp, &ci.MaxTemp, &ci.WarmthLevel,
&ci.RainOK, &ci.SnowOK, &ci.WindOK,
&ci.Style, &ci.FormalityLevel,
&ci.BaseColour, &ci.Pattern, &ci.Fit,
&ci.Gender, &ci.Season,
&ci.Usage, &ci.Materials,
&ci.Brand,
&ci.ImageURL, &ci.ThumbnailURL, &ci.IconEmoji,
&ci.Source, &ci.OwnerID, &ci.IsOwned,
&ci.IsActive, &ci.CreatedAt, &ci.UpdatedAt,
); err != nil {
			return nil, 0, errors.Wrap(err, "scan wardrobe row")
		}

		wi.Item = ci
		out = append(out, wi)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Wrap(err, "rows wardrobe")
	}

	return out, total, nil
}

func wardrobeSortColumn(sort string) string {
	switch strings.ToLower(strings.TrimSpace(sort)) {
	case "created_at":
		return "uw.created_at"
	case "wear_count":
		return "uw.wear_count"
	case "name":
		return "ci.name"
	case "updated_at":
		fallthrough
	default:
		return "uw.updated_at"
	}
}

func (r *WardrobeRepository) GetByID(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	q := `
SELECT
	uw.id, uw.user_id, uw.clothing_item_id,
	uw.custom_name, uw.notes, uw.tags,
	uw.purchase_date, uw.purchase_price, uw.purchase_currency,
	uw.wear_count, uw.last_worn_at,
	uw.is_favorite, uw.is_archived, uw.condition,
	uw.created_at, uw.updated_at,

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
WHERE uw.id = $1 AND uw.user_id = $2
`
	var wi domain.WardrobeItem
	var ci domain.ClothingItem
	err := r.db.Pool().QueryRow(ctx, q, wardrobeID, userID).Scan(
		&wi.ID, &wi.UserID, &wi.ClothingItemID,
		&wi.CustomName, &wi.Notes, &wi.Tags,
		&wi.PurchaseDate, &wi.PurchasePrice, &wi.PurchaseCurrency,
		&wi.WearCount, &wi.LastWornAt,
		&wi.IsFavorite, &wi.IsArchived, &wi.Condition,
		&wi.CreatedAt, &wi.UpdatedAt,

		&ci.ID, &ci.Name, &ci.Description,
		&ci.Category, &ci.Subcategory,
		&ci.MinTemp, &ci.MaxTemp, &ci.WarmthLevel,
		&ci.RainOK, &ci.SnowOK, &ci.WindOK,
		&ci.Style, &ci.FormalityLevel,
		&ci.BaseColour, &ci.Pattern, &ci.Fit,
		&ci.Gender, &ci.Season,
		&ci.Usage, &ci.Materials,
		&ci.Brand,
		&ci.ImageURL, &ci.ThumbnailURL, &ci.IconEmoji,
		&ci.Source, &ci.OwnerID, &ci.IsOwned,
		&ci.IsActive, &ci.CreatedAt, &ci.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get wardrobe by id")
	}
	wi.Item = ci
	return &wi, nil
}

func (r *WardrobeRepository) Add(ctx context.Context, userID domain.ID, clothingItemID domain.ID, customName *string, notes *string, tags []string) (*domain.WardrobeItem, error) {
	q := `
INSERT INTO user_wardrobe (user_id, clothing_item_id, custom_name, notes, tags)
VALUES ($1,$2,$3,$4,$5)
ON CONFLICT (user_id, clothing_item_id)
DO UPDATE SET is_archived = FALSE, updated_at = NOW()
RETURNING id
`
	var wardrobeID domain.ID
	err := r.db.Pool().QueryRow(ctx, q, userID, clothingItemID, customName, notes, tags).Scan(&wardrobeID)
	if err != nil {
		return nil, errors.Wrap(err, "add wardrobe")
	}
	return r.GetByID(ctx, userID, wardrobeID)
}

func (r *WardrobeRepository) Update(ctx context.Context, userID domain.ID, wardrobeID domain.ID, patch domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error) {
	q := `
UPDATE user_wardrobe
SET
	custom_name = COALESCE($1, custom_name),
	notes = COALESCE($2, notes),
	tags = COALESCE($3, tags),
	purchase_price = COALESCE($4, purchase_price),
	condition = COALESCE($5, condition),
	updated_at = NOW()
WHERE id = $6 AND user_id = $7
`
	cmd, err := r.db.Pool().Exec(ctx, q, patch.CustomName, patch.Notes, patch.Tags, patch.PurchasePrice, patch.Condition, wardrobeID, userID)
	if err != nil {
		return nil, errors.Wrap(err, "update wardrobe")
	}
	if cmd.RowsAffected() == 0 {
		return nil, nil
	}
	return r.GetByID(ctx, userID, wardrobeID)
}

func (r *WardrobeRepository) Delete(ctx context.Context, userID domain.ID, wardrobeID domain.ID) error {
	q := `DELETE FROM user_wardrobe WHERE id = $1 AND user_id = $2`
	cmd, err := r.db.Pool().Exec(ctx, q, wardrobeID, userID)
	if err != nil {
		return errors.Wrap(err, "delete wardrobe")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *WardrobeRepository) SetFavorite(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isFavorite bool) error {
	q := `UPDATE user_wardrobe SET is_favorite = $1, updated_at = NOW() WHERE id = $2 AND user_id = $3`
	cmd, err := r.db.Pool().Exec(ctx, q, isFavorite, wardrobeID, userID)
	if err != nil {
		return errors.Wrap(err, "set wardrobe favorite")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *WardrobeRepository) SetArchived(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isArchived bool) error {
	q := `UPDATE user_wardrobe SET is_archived = $1, updated_at = NOW() WHERE id = $2 AND user_id = $3`
	cmd, err := r.db.Pool().Exec(ctx, q, isArchived, wardrobeID, userID)
	if err != nil {
		return errors.Wrap(err, "set wardrobe archived")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *WardrobeRepository) MarkWorn(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	q := `
UPDATE user_wardrobe
SET wear_count = wear_count + 1, last_worn_at = NOW(), updated_at = NOW()
WHERE id = $1 AND user_id = $2
`
	cmd, err := r.db.Pool().Exec(ctx, q, wardrobeID, userID)
	if err != nil {
		return nil, errors.Wrap(err, "mark worn")
	}
	if cmd.RowsAffected() == 0 {
		return nil, nil
	}
	return r.GetByID(ctx, userID, wardrobeID)
}

func (r *WardrobeRepository) IsInWardrobe(ctx context.Context, userID domain.ID, clothingItemID domain.ID) (bool, error) {
	var exists bool
	err := r.db.Pool().QueryRow(ctx, `
SELECT EXISTS(SELECT 1 FROM user_wardrobe WHERE user_id = $1 AND clothing_item_id = $2 AND is_archived = FALSE)
`, userID, clothingItemID).Scan(&exists)
	return exists, errors.Wrap(err, "is in wardrobe")
}

