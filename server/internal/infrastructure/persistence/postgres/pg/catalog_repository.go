package pg

import (
	"context"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type CatalogRepository struct{ db *dbpkg.DB }

func NewCatalogRepository(db *dbpkg.DB) repositories.CatalogRepository {
	return &CatalogRepository{db: db}
}

func (r *CatalogRepository) Search(ctx context.Context, p repositories.CatalogSearchParams) ([]domain.ClothingItem, int, error) {
	limit := p.Limit
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	page := p.Page
	if page <= 0 {
		page = 1
	}
	offset := (page - 1) * limit

	where := []string{
		"ci.is_active = TRUE",
		"ci.owner_id IS NULL", // catalog only
		"ci.source IN ('synthetic','manual','partner')",
	}
	args := []any{}
	arg := 1

	add := func(cond string, v any) {
		where = append(where, fmt.Sprintf(cond, arg))
		args = append(args, v)
		arg++
	}

	if p.Q != nil && strings.TrimSpace(*p.Q) != "" {
		q := strings.TrimSpace(*p.Q)
		add("(ci.name ILIKE '%%' || $%d || '%%' OR ci.subcategory ILIKE '%%' || $%d || '%%')", q)
	}
	if p.Category != nil && *p.Category != "" {
		add("ci.category = $%d", *p.Category)
	}
	if p.Subcategory != nil && *p.Subcategory != "" {
		add("ci.subcategory = $%d", *p.Subcategory)
	}
	if p.Style != nil && *p.Style != "" {
		add("ci.style = $%d", *p.Style)
	}
	if p.Color != nil && *p.Color != "" {
		add("ci.base_colour = $%d", *p.Color)
	}
	if p.MinPrice != nil {
		add("ci.partner_price >= $%d", *p.MinPrice)
	}
	if p.MaxPrice != nil {
		add("ci.partner_price <= $%d", *p.MaxPrice)
	}
	joinPartner := ""
	if p.Partner != nil && *p.Partner != "" {
		joinPartner = "JOIN partners p ON p.id = ci.partner_id"
		add("p.code = $%d", *p.Partner)
	}

	// total
	countQ := fmt.Sprintf(`SELECT COUNT(*) FROM clothing_items ci %s WHERE %s`, joinPartner, strings.Join(where, " AND "))
	var total int
	if err := r.db.Pool().QueryRow(ctx, countQ, args...).Scan(&total); err != nil {
		return nil, 0, errors.Wrap(err, "catalog count")
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
%s
WHERE %s
ORDER BY ci.created_at DESC
LIMIT %d OFFSET %d
`, joinPartner, strings.Join(where, " AND "), limit, offset)

	rows, err := r.db.Pool().Query(ctx, q, args...)
	if err != nil {
		return nil, 0, errors.Wrap(err, "catalog search")
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
			return nil, 0, errors.Wrap(err, "scan catalog item")
		}
		out = append(out, it)
	}
	return out, total, rows.Err()
}

func (r *CatalogRepository) Categories(ctx context.Context) (any, error) {
	// Берём из subcategory_specs + группируем по category (минимально).
	rows, err := r.db.Pool().Query(ctx, `SELECT category, subcategory FROM subcategory_specs ORDER BY category, subcategory`)
	if err != nil {
		return nil, errors.Wrap(err, "categories")
	}
	defer rows.Close()

	type cat struct {
		Code          string   `json:"code"`
		Name          string   `json:"name"`
		Icon          string   `json:"icon"`
		Subcategories []string `json:"subcategories"`
	}
	m := map[string]*cat{}

	icon := map[string]string{
		"outerwear": "🧥",
		"upper":     "👕",
		"lower":     "👖",
		"footwear":  "👟",
		"accessory": "🎒",
	}
	name := map[string]string{
		"outerwear": "Верхняя одежда",
		"upper":     "Верх",
		"lower":     "Низ",
		"footwear":  "Обувь",
		"accessory": "Аксессуары",
	}

	for rows.Next() {
		var c, s string
		if err := rows.Scan(&c, &s); err != nil {
			return nil, errors.Wrap(err, "scan categories")
		}
		if m[c] == nil {
			m[c] = &cat{Code: c, Name: name[c], Icon: icon[c], Subcategories: []string{}}
		}
		m[c].Subcategories = append(m[c].Subcategories, s)
	}
	out := []cat{}
	for _, k := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		if m[k] != nil {
			out = append(out, *m[k])
		}
	}
	return map[string]any{"categories": out}, nil
}

func (r *CatalogRepository) GetItem(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	row := r.db.Pool().QueryRow(ctx, `
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
WHERE id=$1
`, id)

	var it domain.ClothingItem
	if err := row.Scan(
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
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get catalog item")
	}
	return &it, nil
}

func (r *CatalogRepository) Similar(ctx context.Context, id domain.ID, limit int) ([]domain.ClothingItem, error) {
	if limit <= 0 {
		limit = 10
	}
	item, err := r.GetItem(ctx, id)
	if err != nil || item == nil {
		return nil, err
	}

	rows, err := r.db.Pool().Query(ctx, `
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
WHERE id <> $1
  AND owner_id IS NULL
  AND category = $2
  AND subcategory = $3
  AND is_active = TRUE
ORDER BY created_at DESC
LIMIT $4
`, id, item.Category, item.Subcategory, limit)
	if err != nil {
		return nil, errors.Wrap(err, "similar")
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
			return nil, errors.Wrap(err, "scan similar")
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

func (r *CatalogRepository) Click(ctx context.Context, userID *domain.ID, itemID domain.ID) (string, error) {
	// redirect_url = partner_url (если есть)
	var partnerURL *string
	err := r.db.Pool().QueryRow(ctx, `SELECT partner_url FROM clothing_items WHERE id=$1`, itemID).Scan(&partnerURL)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return "", repositories.ErrNotFound
		}
		return "", errors.Wrap(err, "get partner_url")
	}
	if partnerURL == nil || *partnerURL == "" {
		return "", errors.New("partner_url not available")
	}

	// record click (best-effort)
	_, _ = r.db.Pool().Exec(ctx, `
INSERT INTO affiliate_clicks (user_id, partner_id, clothing_item_id, clicked_at)
SELECT $1, ci.partner_id, ci.id, NOW()
FROM clothing_items ci
WHERE ci.id = $2
`, userID, itemID)

	return *partnerURL, nil
}
