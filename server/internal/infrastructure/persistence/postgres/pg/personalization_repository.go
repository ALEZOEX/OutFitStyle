package pg

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type PersonalizationRepository struct {
	db *dbpkg.DB
}

func NewPersonalizationRepository(db *dbpkg.DB) repositories.PersonalizationRepository {
	return &PersonalizationRepository{db: db}
}

func (r *PersonalizationRepository) GetUserPreferences(ctx context.Context, userID domain.ID) (domain.UserPreferences, error) {
	var b []byte
	err := r.db.Pool().QueryRow(ctx, `SELECT preferences FROM users WHERE id = $1`, userID).Scan(&b)
	if err != nil {
		return domain.UserPreferences{}, errors.Wrap(err, "load preferences")
	}
	if len(b) == 0 {
		return domain.UserPreferences{}, nil
	}

	var prefs domain.UserPreferences
	if e := json.Unmarshal(b, &prefs); e != nil {
		// не ломаем рекомендацию из-за кривого JSON
		return domain.UserPreferences{}, nil
	}
	return prefs, nil
}

func (r *PersonalizationRepository) GetRecentItems(ctx context.Context, userID domain.ID, limit int) ([]domain.ID, error) {
	if limit <= 0 {
		limit = 50
	}

	rows, err := r.db.Pool().Query(ctx, `
SELECT ri.clothing_item_id
FROM recommendations rec
JOIN recommendation_items ri ON ri.recommendation_id = rec.id
WHERE rec.user_id = $1
ORDER BY rec.created_at DESC
LIMIT $2
`, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "recent items")
	}
	defer rows.Close()

	seen := map[domain.ID]bool{}
	out := make([]domain.ID, 0, limit)
	for rows.Next() {
		var id domain.ID
		if err := rows.Scan(&id); err != nil {
			return nil, errors.Wrap(err, "scan recent item")
		}
		if seen[id] {
			continue
		}
		seen[id] = true
		out = append(out, id)
	}
	return out, rows.Err()
}

func (r *PersonalizationRepository) GetRatedItems(ctx context.Context, userID domain.ID, highMin int, lowMax int, limit int) ([]domain.ID, []domain.ID, error) {
	if limit <= 0 {
		limit = 50
	}
	if highMin <= 0 {
		highMin = 4
	}
	if lowMax <= 0 {
		lowMax = 2
	}

	high := []domain.ID{}
	low := []domain.ID{}

	rows, err := r.db.Pool().Query(ctx, `
SELECT clothing_item_id, rating
FROM user_item_ratings
WHERE user_id = $1 AND rating IS NOT NULL
ORDER BY updated_at DESC
LIMIT $2
`, userID, limit*3)
	if err != nil {
		return nil, nil, errors.Wrap(err, "rated items")
	}
	defer rows.Close()

	for rows.Next() {
		var id domain.ID
		var rating *int
		if err := rows.Scan(&id, &rating); err != nil {
			return nil, nil, errors.Wrap(err, "scan rated item")
		}
		if rating == nil {
			continue
		}
		if *rating >= highMin && len(high) < limit {
			high = append(high, id)
		}
		if *rating <= lowMax && len(low) < limit {
			low = append(low, id)
		}
		if len(high) >= limit && len(low) >= limit {
			break
		}
	}
	return high, low, rows.Err()
}

func (r *PersonalizationRepository) GetStyleDistribution(ctx context.Context, userID domain.ID, limit int) (map[string]float64, error) {
	if limit <= 0 {
		limit = 200
	}

	rows, err := r.db.Pool().Query(ctx, `
SELECT COALESCE(requested_style, ''), COUNT(*)
FROM recommendations
WHERE user_id = $1
GROUP BY requested_style
ORDER BY COUNT(*) DESC
LIMIT $2
`, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "style distribution")
	}
	defer rows.Close()

	counts := map[string]float64{}
	total := 0.0

	for rows.Next() {
		var style string
		var c int
		if err := rows.Scan(&style, &c); err != nil {
			return nil, errors.Wrap(err, "scan style distribution")
		}
		style = strings.TrimSpace(style)
		if style == "" {
			continue
		}
		counts[style] += float64(c)
		total += float64(c)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	if total <= 0 {
		return map[string]float64{}, nil
	}

	// нормализуем в доли
	out := map[string]float64{}
	for k, v := range counts {
		out[k] = v / total
	}
	return out, nil
}

func (r *PersonalizationRepository) GetItemRatingsMap(ctx context.Context, userID domain.ID, itemIDs []domain.ID) (map[domain.ID]float64, error) {
	out := map[domain.ID]float64{}
	if len(itemIDs) == 0 {
		return out, nil
	}

	rows, err := r.db.Pool().Query(ctx, `
SELECT clothing_item_id, rating
FROM user_item_ratings
WHERE user_id = $1 AND clothing_item_id = ANY($2) AND rating IS NOT NULL
`, userID, itemIDs)
	if err != nil {
		return nil, errors.Wrap(err, "item ratings map")
	}
	defer rows.Close()

	for rows.Next() {
		var id domain.ID
		var rating int
		if err := rows.Scan(&id, &rating); err != nil {
			return nil, errors.Wrap(err, "scan rating map")
		}
		out[id] = float64(rating)
	}
	return out, rows.Err()
}
