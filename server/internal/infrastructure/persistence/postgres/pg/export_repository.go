package pg

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type ExportRepository struct {
	db *dbpkg.DB
}

func NewExportRepository(db *dbpkg.DB) repositories.ExportRepository {
	return &ExportRepository{db: db}
}

func (r *ExportRepository) BuildUserExport(ctx context.Context, userID domain.ID) (any, error) {
	// user
	var userJSON []byte
	if err := r.db.Pool().QueryRow(ctx, `
SELECT to_jsonb(u)
FROM (
SELECT
id, email, display_name, avatar_url, gender, birth_date,
body_measurements, default_location, default_latitude, default_longitude,
timezone, locale, preferences,
is_active, is_verified, verified_at,
oauth_provider, oauth_id,
last_login_at, login_count,
created_at, updated_at
FROM users WHERE id = $1
) u
`, userID).Scan(&userJSON); err != nil {
		return nil, errors.Wrap(err, "export user")
	}

	// wardrobe
	var wardrobeJSON []byte
	_ = r.db.Pool().QueryRow(ctx, `
SELECT COALESCE(jsonb_agg(to_jsonb(x)), '[]'::jsonb)
FROM (
SELECT
uw.id, uw.user_id, uw.clothing_item_id,
uw.custom_name, uw.notes, uw.tags,
uw.purchase_date, uw.purchase_price, uw.purchase_currency,
uw.wear_count, uw.last_worn_at,
uw.is_favorite, uw.is_archived, uw.condition,
uw.created_at, uw.updated_at,
to_jsonb(ci) AS clothing_item
FROM user_wardrobe uw
JOIN clothing_items ci ON ci.id = uw.clothing_item_id
WHERE uw.user_id = $1
ORDER BY uw.created_at DESC
) x
`, userID).Scan(&wardrobeJSON)

	// recommendations (без items таблицы; outfit_data уже содержит)
	var recsJSON []byte
	_ = r.db.Pool().QueryRow(ctx, `
SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
FROM (
SELECT
id, user_id, location, latitude, longitude, occasion,
requested_style, requested_formality,
weather_data, outfit_data,
total_score, style_coherence, color_harmony, weather_match,
model_version, processing_time_ms, ab_test_variant,
user_rating, user_feedback, thermal_feedback, rated_at,
is_favorite, created_at
FROM recommendations
WHERE user_id = $1
ORDER BY created_at DESC
) r
`, userID).Scan(&recsJSON)

	// subscription current (best-effort)
	var subJSON []byte
	_ = r.db.Pool().QueryRow(ctx, `
SELECT COALESCE(to_jsonb(s), '{}'::jsonb)
FROM (
SELECT
us.id, us.user_id, us.billing_cycle, us.started_at, us.current_period_start, us.current_period_end,
us.cancelled_at, us.status, us.auto_renew, us.payment_provider, us.external_subscription_id, us.trial_end,
to_jsonb(sp) AS plan
FROM user_subscriptions us
JOIN subscription_plans sp ON sp.id = us.plan_id
WHERE us.user_id = $1 AND us.status IN ('active','trialing')
ORDER BY us.current_period_end DESC
LIMIT 1
) s
`, userID).Scan(&subJSON)

	var userObj any
	var wardrobeObj any
	var recsObj any
	var subObj any
	_ = json.Unmarshal(userJSON, &userObj)
	_ = json.Unmarshal(wardrobeJSON, &wardrobeObj)
	_ = json.Unmarshal(recsJSON, &recsObj)
	_ = json.Unmarshal(subJSON, &subObj)

	return map[string]any{
		"user":            userObj,
		"wardrobe":        wardrobeObj,
		"recommendations": recsObj,
		"subscription":    subObj,
	}, nil
}
