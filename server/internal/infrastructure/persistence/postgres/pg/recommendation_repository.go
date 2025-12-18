package pg

import (
	"context"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type RecommendationRepository struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

func NewRecommendationRepository(db *dbpkg.DB, logger *zap.Logger) repositories.RecommendationRepository {
	return &RecommendationRepository{db: db, logger: logger}
}

func (r *RecommendationRepository) Create(ctx context.Context, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	tx, err := r.db.Pool().Begin(ctx)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "begin tx")
	}
	defer func() { _ = tx.Rollback(ctx) }()

	q := `
INSERT INTO recommendations (
	user_id,
	location, latitude, longitude,
	occasion, requested_style, requested_formality,
	weather_data, outfit_data,
	total_score, style_coherence, color_harmony, weather_match,
	model_version, processing_time_ms, ab_test_variant,
	is_favorite
)
VALUES (
	$1,
	$2,$3,$4,
	$5,$6,$7,
	$8,$9,
	$10,$11,$12,$13,
	$14,$15,$16,
	$17
)
RETURNING id, created_at
`
	err = tx.QueryRow(ctx, q,
		rec.UserID,
		rec.Location, rec.Latitude, rec.Longitude,
		rec.Occasion, rec.RequestedStyle, rec.RequestedFormality,
		rec.WeatherData, rec.OutfitData,
		rec.TotalScore, rec.StyleCoherence, rec.ColorHarmony, rec.WeatherMatch,
		rec.ModelVersion, rec.ProcessingTimeMs, rec.ABTestVariant,
		rec.IsFavorite,
	).Scan(&rec.ID, &rec.CreatedAt)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "insert recommendation")
	}

	if len(items) > 0 {
		for _, it := range items {
			_, err := tx.Exec(ctx, `
INSERT INTO recommendation_items (
	recommendation_id, clothing_item_id,
	category, layer_position, score,
	source, is_from_wardrobe,
	alternatives
)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
`, rec.ID, it.ClothingItemID, it.Category, it.LayerPosition, it.Score, it.Source, it.IsFromWardrobe, nullJSON(it.AlternativesJSON))
			if err != nil {
				return domain.ID{}, errors.Wrap(err, "insert recommendation_item")
			}
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return domain.ID{}, errors.Wrap(err, "commit tx")
	}

	return rec.ID, nil
}

func (r *RecommendationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.RecommendationRecord, error) {
	q := `
SELECT
	id, user_id,
	location, latitude, longitude,
	occasion, requested_style, requested_formality,
	weather_data, outfit_data,
	total_score, style_coherence, color_harmony, weather_match,
	model_version, processing_time_ms, ab_test_variant,
	user_rating, user_feedback, thermal_feedback, rated_at,
	is_favorite,
	created_at
	FROM recommendations
	WHERE id = $1
`
	var rec domain.RecommendationRecord
	err := r.db.Pool().QueryRow(ctx, q, id).Scan(
		&rec.ID, &rec.UserID,
		&rec.Location, &rec.Latitude, &rec.Longitude,
		&rec.Occasion, &rec.RequestedStyle, &rec.RequestedFormality,
		&rec.WeatherData, &rec.OutfitData,
		&rec.TotalScore, &rec.StyleCoherence, &rec.ColorHarmony, &rec.WeatherMatch,
		&rec.ModelVersion, &rec.ProcessingTimeMs, &rec.ABTestVariant,
		&rec.UserRating, &rec.UserFeedback, &rec.ThermalFeedback, &rec.RatedAt,
		&rec.IsFavorite,
		&rec.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get recommendation by id")
	}
	return &rec, nil
}

func (r *RecommendationRepository) ListByUser(ctx context.Context, userID domain.ID, q domain.RecommendationListQuery) ([]domain.RecommendationRecord, int, error) {
	limit := q.Limit
	if limit <= 0 { limit = 20 }
	if limit > 100 { limit = 100 }
	page := q.Page
	if page <= 0 { page = 1 }
	offset := (page - 1) * limit

	where := []string{"user_id = $1"}
	args := []any{userID}
	argN := 2

	add := func(cond string, v any) {
		where = append(where, cond)
		args = append(args, v)
		argN++
	}

	// даты (YYYY-MM-DD)
	if q.FromDate != nil && *q.FromDate != "" {
		add("created_at >= $"+itoa(argN)+"::date", *q.FromDate)
	}
	if q.ToDate != nil && *q.ToDate != "" {
		add("created_at < ($"+itoa(argN)+"::date + INTERVAL '1 day')", *q.ToDate)
	}
	if q.Occasion != nil && *q.Occasion != "" {
		add("occasion = $"+itoa(argN), *q.Occasion)
	}
	if q.MinRating != nil {
		add("user_rating >= $"+itoa(argN), *q.MinRating)
	}
	if q.IsFavorite != nil {
		add("is_favorite = $"+itoa(argN), *q.IsFavorite)
	}

	whereSQL := strings.Join(where, " AND ")

	// total
	var total int
	if err := r.db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM recommendations WHERE `+whereSQL, args...).Scan(&total); err != nil {
		return nil, 0, errors.Wrap(err, "count recommendations")
	}

	// list
	sql := `
SELECT
id, user_id,
location, latitude, longitude,
occasion, requested_style, requested_formality,
weather_data, outfit_data,
total_score, style_coherence, color_harmony, weather_match,
model_version, processing_time_ms, ab_test_variant,
user_rating, user_feedback, thermal_feedback, rated_at,
is_favorite,
created_at
FROM recommendations
WHERE ` + whereSQL + `
ORDER BY created_at DESC
LIMIT $` + itoa(argN) + ` OFFSET $` + itoa(argN+1)

	args = append(args, limit, offset)

	rows, err := r.db.Pool().Query(ctx, sql, args...)
	if err != nil {
		return nil, 0, errors.Wrap(err, "list recommendations")
	}
	defer rows.Close()

	out := make([]domain.RecommendationRecord, 0, limit)
	for rows.Next() {
		var rec domain.RecommendationRecord
		if err := rows.Scan(
&rec.ID, &rec.UserID,
&rec.Location, &rec.Latitude, &rec.Longitude,
&rec.Occasion, &rec.RequestedStyle, &rec.RequestedFormality,
&rec.WeatherData, &rec.OutfitData,
&rec.TotalScore, &rec.StyleCoherence, &rec.ColorHarmony, &rec.WeatherMatch,
&rec.ModelVersion, &rec.ProcessingTimeMs, &rec.ABTestVariant,
&rec.UserRating, &rec.UserFeedback, &rec.ThermalFeedback, &rec.RatedAt,
&rec.IsFavorite,
&rec.CreatedAt,
); err != nil {
			return nil, 0, errors.Wrap(err, "scan recommendation")
		}
		out = append(out, rec)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Wrap(err, "rows recommendations")
	}

	return out, total, nil
}


func (r *RecommendationRepository) GetItemRows(ctx context.Context, recommendationID domain.ID) ([]repositories.RecommendationItemRow, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT clothing_item_id, category, source, is_from_wardrobe, alternatives
FROM recommendation_items
WHERE recommendation_id = $1
ORDER BY created_at ASC
`, recommendationID)
	if err != nil {
		return nil, errors.Wrap(err, "get recommendation_items rows")
	}
	defer rows.Close()

	var out []repositories.RecommendationItemRow
	for rows.Next() {
		var row repositories.RecommendationItemRow
		if err := rows.Scan(&row.ClothingItemID, &row.Category, &row.Source, &row.IsFromWardrobe, &row.AlternativesJSON); err != nil {
			return nil, errors.Wrap(err, "scan recommendation_item row")
		}
		out = append(out, row)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "rows recommendation_items")
	}
	return out, nil
}

func (r *RecommendationRepository) SetRating(ctx context.Context, userID, recommendationID domain.ID, rating int, thermalFeedback *string, feedback *string) (bool, error) {
	tx, err := r.db.Pool().Begin(ctx)
	if err != nil {
		return false, errors.Wrap(err, "begin tx")
	}
	defer func() { _ = tx.Rollback(ctx) }()

	// 1) узнаём старый рейтинг (чтобы корректно обновлять perfect_ratings_count)
	var oldRating *int
	_ = tx.QueryRow(ctx, `
SELECT user_rating
FROM recommendations
WHERE id = $1 AND user_id = $2
`, recommendationID, userID).Scan(&oldRating)

	// 2) обновляем рекомендацию
	cmd, err := tx.Exec(ctx, `
UPDATE recommendations
SET user_rating = $1, thermal_feedback = $2, user_feedback = $3, rated_at = NOW()
WHERE id = $4 AND user_id = $5
`, rating, thermalFeedback, feedback, recommendationID, userID)
	if err != nil {
		return false, errors.Wrap(err, "update recommendation rating")
	}
	if cmd.RowsAffected() == 0 {
		return false, repositories.ErrNotFound
	}

	// 3) пишем feedback по каждой вещи (user_item_ratings)
	_, err = tx.Exec(ctx, `
INSERT INTO user_item_ratings (user_id, clothing_item_id, recommendation_id, rating, context)
SELECT $1, ri.clothing_item_id, $2, $3, NULL
FROM recommendation_items ri
WHERE ri.recommendation_id = $2
ON CONFLICT (user_id, clothing_item_id)
DO UPDATE SET rating = EXCLUDED.rating, recommendation_id = EXCLUDED.recommendation_id, updated_at = NOW()
`, userID, recommendationID, rating)
	if err != nil {
		return false, errors.Wrap(err, "upsert user_item_ratings")
	}

	// 4) ensure user_stats exists
	_, _ = tx.Exec(ctx, `
INSERT INTO user_stats (user_id) VALUES ($1)
ON CONFLICT (user_id) DO NOTHING
`, userID)

	changedToPerfect := false
	wasPerfect := (oldRating != nil && *oldRating == 5)
	nowPerfect := (rating == 5)

	if !wasPerfect && nowPerfect {
		changedToPerfect = true
		_, _ = tx.Exec(ctx, `
UPDATE user_stats
SET perfect_ratings_count = perfect_ratings_count + 1,
    updated_at = NOW()
WHERE user_id = $1
`, userID)
	}
	if wasPerfect && !nowPerfect {
		_, _ = tx.Exec(ctx, `
UPDATE user_stats
SET perfect_ratings_count = GREATEST(0, perfect_ratings_count - 1),
    updated_at = NOW()
WHERE user_id = $1
`, userID)
	}

	// 5) styles_used / weather_types_seen (лучше, чем ничего)
	_, _ = tx.Exec(ctx, `
UPDATE user_stats us
SET
  styles_used = CASE
    WHEN r.requested_style IS NOT NULL AND r.requested_style <> '' AND NOT (r.requested_style = ANY(us.styles_used))
      THEN array_append(us.styles_used, r.requested_style)
    ELSE us.styles_used
  END,
  weather_types_seen = CASE
    WHEN COALESCE(r.weather_data->>'weather_main','') <> '' AND NOT ((r.weather_data->>'weather_main') = ANY(us.weather_types_seen))
      THEN array_append(us.weather_types_seen, (r.weather_data->>'weather_main'))
    ELSE us.weather_types_seen
  END,
  updated_at = NOW()
FROM recommendations r
WHERE us.user_id = $1 AND r.id = $2
`, userID, recommendationID)

	if err := tx.Commit(ctx); err != nil {
		return false, errors.Wrap(err, "commit tx")
	}
	return changedToPerfect, nil
}

func (r *RecommendationRepository) SetFavorite(ctx context.Context, userID, recommendationID domain.ID, isFavorite bool) error {
	q := `UPDATE recommendations SET is_favorite = $1 WHERE id = $2 AND user_id = $3`
	cmd, err := r.db.Pool().Exec(ctx, q, isFavorite, recommendationID, userID)
	if err != nil {
		return errors.Wrap(err, "set favorite")
	}
	if cmd.RowsAffected() == 0 {
		return repositories.ErrNotFound
	}
	return nil
}

func (r *RecommendationRepository) ListFavorites(ctx context.Context, userID domain.ID, limit int) ([]domain.RecommendationRecord, error) {
	if limit <= 0 {
		limit = 50
	}
	q := `
SELECT
	id, user_id,
	location, latitude, longitude,
	occasion, requested_style, requested_formality,
	weather_data, outfit_data,
	total_score, style_coherence, color_harmony, weather_match,
	model_version, processing_time_ms, ab_test_variant,
	user_rating, user_feedback, thermal_feedback, rated_at,
	is_favorite,
	created_at
FROM recommendations
WHERE user_id = $1 AND is_favorite = TRUE
ORDER BY created_at DESC
LIMIT $2
`
	rows, err := r.db.Pool().Query(ctx, q, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "list favorites")
	}
	defer rows.Close()

	var out []domain.RecommendationRecord
	for rows.Next() {
		var rec domain.RecommendationRecord
		if err := rows.Scan(
			&rec.ID, &rec.UserID,
			&rec.Location, &rec.Latitude, &rec.Longitude,
			&rec.Occasion, &rec.RequestedStyle, &rec.RequestedFormality,
			&rec.WeatherData, &rec.OutfitData,
			&rec.TotalScore, &rec.StyleCoherence, &rec.ColorHarmony, &rec.WeatherMatch,
			&rec.ModelVersion, &rec.ProcessingTimeMs, &rec.ABTestVariant,
			&rec.UserRating, &rec.UserFeedback, &rec.ThermalFeedback, &rec.RatedAt,
			&rec.IsFavorite,
			&rec.CreatedAt,
		); err != nil {
			return nil, errors.Wrap(err, "scan favorite")
		}
		out = append(out, rec)
	}
	return out, rows.Err()
}

