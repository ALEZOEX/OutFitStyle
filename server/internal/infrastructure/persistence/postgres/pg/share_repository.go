package pg

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"math/big"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type ShareRepository struct {
	db *dbpkg.DB
}

func NewShareRepository(db *dbpkg.DB) repositories.ShareRepository {
	return &ShareRepository{db: db}
}

func (r *ShareRepository) CreateShare(ctx context.Context, userID domain.ID, recommendationID *domain.ID, savedOutfitID *domain.ID, showUserName bool) (string, error) {
	// retry on collision
	for i := 0; i < 5; i++ {
		code, err := generateCode(12)
		if err != nil {
			return "", err
		}

		_, err = r.db.Pool().Exec(ctx, `
INSERT INTO shared_outfits (user_id, recommendation_id, saved_outfit_id, share_code, is_public, show_user_name)
VALUES ($1,$2,$3,$4,TRUE,$5)
`, userID, recommendationID, savedOutfitID, code, showUserName)
		if err == nil {
			return code, nil
		}
		// unique violation -> retry
		if strings.Contains(err.Error(), "duplicate key") {
			continue
		}
		return "", errors.Wrap(err, "create share")
	}
	return "", errors.New("failed to generate unique share code")
}

func (r *ShareRepository) GetByCode(ctx context.Context, code string) (*repositories.SharedOutfitRecord, error) {
	code = strings.TrimSpace(code)
	if code == "" {
		return nil, nil
	}

	q := `
SELECT id, user_id, show_user_name, is_public, recommendation_id, saved_outfit_id, share_code
FROM shared_outfits
WHERE share_code = $1
LIMIT 1
`
	var rec repositories.SharedOutfitRecord
	err := r.db.Pool().QueryRow(ctx, q, code).Scan(
		&rec.ID, &rec.UserID, &rec.ShowUserName, &rec.IsPublic, &rec.RecommendationID, &rec.SavedOutfitID, &rec.ShareCode,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get share by code")
	}
	return &rec, nil
}

func (r *ShareRepository) IncViews(ctx context.Context, code string) error {
	_, err := r.db.Pool().Exec(ctx, `UPDATE shared_outfits SET views_count = views_count + 1 WHERE share_code = $1`, code)
	return errors.Wrap(err, "inc views")
}

func (r *ShareRepository) GetUserDisplayName(ctx context.Context, userID domain.ID) (*string, error) {
	var name *string
	err := r.db.Pool().QueryRow(ctx, `SELECT display_name FROM users WHERE id = $1`, userID).Scan(&name)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get display name")
	}
	return name, nil
}

func (r *ShareRepository) GetRecommendationOutfit(ctx context.Context, recommendationID domain.ID) (any, error) {
	var outfit []byte
	var weather []byte
	err := r.db.Pool().QueryRow(ctx, `
SELECT outfit_data, weather_data
FROM recommendations
WHERE id = $1
`, recommendationID).Scan(&outfit, &weather)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get recommendation outfit")
	}

	// отдаём единым объектом
	var outfitObj any
	_ = json.Unmarshal(outfit, &outfitObj)

	var weatherObj any
	_ = json.Unmarshal(weather, &weatherObj)

	return map[string]any{
		"type":              "recommendation",
		"recommendation_id": recommendationID.String(),
		"weather":           weatherObj,
		"outfit":            outfitObj,
	}, nil
}

func (r *ShareRepository) GetSavedOutfit(ctx context.Context, savedOutfitID domain.ID) (any, error) {
	var items []byte
	var name string
	var desc *string
	err := r.db.Pool().QueryRow(ctx, `
SELECT name, description, items
FROM saved_outfits
WHERE id = $1
`, savedOutfitID).Scan(&name, &desc, &items)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get saved outfit")
	}

	var itemsObj any
	_ = json.Unmarshal(items, &itemsObj)

	return map[string]any{
		"type":            "saved_outfit",
		"saved_outfit_id": savedOutfitID.String(),
		"name":            name,
		"description":     desc,
		"items":           itemsObj,
	}, nil
}

func generateCode(n int) (string, error) {
	const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // без похожих символов
	var b strings.Builder
	b.Grow(n)
	for i := 0; i < n; i++ {
		x, err := rand.Int(rand.Reader, big.NewInt(int64(len(alphabet))))
		if err != nil {
			return "", err
		}
		b.WriteByte(alphabet[x.Int64()])
	}
	return b.String(), nil
}
