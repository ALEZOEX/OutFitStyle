package pg

import (
	"context"
	"fmt"
	"log"

	"outfit-style-rec/server/internal/core/domain"
	"outfit-style-rec/server/internal/core/repo"

	"github.com/jackc/pgx/v5/pgxpool"
)

type SubcategorySpecRepo struct {
	db *pgxpool.Pool
}

func NewSubcategorySpecRepo(db *pgxpool.Pool) *SubcategorySpecRepo {
	return &SubcategorySpecRepo{db: db}
}

func (r *SubcategorySpecRepo) ListAll(ctx context.Context) ([]domain.SubcategorySpec, error) {
	const q = `SELECT category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok FROM subcategory_specs`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var specs []domain.SubcategorySpec
	for rows.Next() {
		var spec domain.SubcategorySpec
		err := rows.Scan(&spec.Category, &spec.Subcategory, &spec.WarmthMin, &spec.TempMinReco, &spec.TempMaxReco,
			&spec.RainOK, &spec.SnowOK, &spec.WindOK)
		if err != nil {
			return nil, err
		}
		specs = append(specs, spec)
	}
	return specs, rows.Err()
}

func (r *SubcategorySpecRepo) Get(ctx context.Context, category, subcategory string) (domain.SubcategorySpec, error) {
	const q = `SELECT category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok FROM subcategory_specs WHERE category = $1 AND subcategory = $2`
	var spec domain.SubcategorySpec
	err := r.db.QueryRow(ctx, q, category, subcategory).Scan(&spec.Category, &spec.Subcategory, &spec.WarmthMin, &spec.TempMinReco, &spec.TempMaxReco,
		&spec.RainOK, &spec.SnowOK, &spec.WindOK)
	return spec, err
}

type ClothingItemRepo struct {
	db *pgxpool.Pool
}

func NewClothingItemRepo(db *pgxpool.Pool) *ClothingItemRepo {
	return &ClothingItemRepo{db: db}
}

func (r *ClothingItemRepo) FindCandidatesByPlan(
	ctx context.Context,
	category string,
	subcategories []string,
	warmthMin int16,
	temp int16,
	limit int,
) ([]domain.ClothingItem, error) {

	const q = `
SELECT id, name, category, subcategory, gender, style, usage, season, base_colour,
       formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern,
       icon_emoji, source, is_owned, created_at
FROM clothing_items
WHERE category = $1
  AND subcategory = ANY($2::text[])
  AND warmth_level >= $3
  AND $4 BETWEEN min_temp AND max_temp
ORDER BY warmth_level DESC, formality_level ASC, id ASC
LIMIT $5;
`
	rows, err := r.db.Query(ctx, q, category, subcategories, warmthMin, temp, limit)
	if err != nil {
		log.Printf("Error querying candidates: %v", err)
		return nil, err
	}
	defer rows.Close()

	var out []domain.ClothingItem
	for rows.Next() {
		var it domain.ClothingItem
		if err := rows.Scan(
			&it.ID, &it.Name, &it.Category, &it.Subcategory, &it.Gender, &it.Style, &it.Usage, &it.Season, &it.BaseColour,
			&it.Formality, &it.Warmth, &it.MinTemp, &it.MaxTemp, &it.Materials, &it.Fit, &it.Pattern,
			&it.IconEmoji, &it.Source, &it.IsOwned, &it.CreatedAt,
		); err != nil {
			log.Printf("Error scanning row: %v", err)
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

func (r *ClothingItemRepo) BulkInsert(ctx context.Context, items []domain.ClothingItem) error {
	// Для больших объёмов лучше COPY FROM, но даю безопасный базовый вариант.
	// Если хочешь — дам отдельный вариант через pgx.CopyFrom для NDJSON 20k/100k.
	const q = `
INSERT INTO clothing_items (
  id, name, category, subcategory, gender, style, usage, season, base_colour,
  formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern,
  icon_emoji, source, is_owned
) VALUES (
  $1,$2,$3,$4,$5,$6,$7,$8,$9,
  $10,$11,$12,$13,$14,$15,$16,
  $17,$18,$19
);
`
	b := &pgxpool.Batch{}
	for _, it := range items {
		b.Queue(q,
			it.ID, it.Name, it.Category, it.Subcategory, it.Gender, it.Style, it.Usage, it.Season, it.BaseColour,
			it.Formality, it.Warmth, it.MinTemp, it.MaxTemp, it.Materials, it.Fit, it.Pattern,
			it.IconEmoji, it.Source, it.IsOwned,
		)
	}
	br := r.db.SendBatch(ctx, b)
	defer br.Close()

	for range items {
		_, err := br.Exec()
		if err != nil {
			return fmt.Errorf("bulk insert failed: %w", err)
		}
	}
	return nil
}

func (r *ClothingItemRepo) GetByID(ctx context.Context, id int64) (domain.ClothingItem, error) {
	const q = `
SELECT id, name, category, subcategory, gender, style, usage, season, base_colour,
       formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern,
       icon_emoji, source, is_owned, created_at
FROM clothing_items
WHERE id = $1;
`
	var it domain.ClothingItem
	err := r.db.QueryRow(ctx, q, id).Scan(
		&it.ID, &it.Name, &it.Category, &it.Subcategory, &it.Gender, &it.Style, &it.Usage, &it.Season, &it.BaseColour,
		&it.Formality, &it.Warmth, &it.MinTemp, &it.MaxTemp, &it.Materials, &it.Fit, &it.Pattern,
		&it.IconEmoji, &it.Source, &it.IsOwned, &it.CreatedAt,
	)
	return it, err
}