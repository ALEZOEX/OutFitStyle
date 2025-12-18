package pg

import (
	"context"
	"encoding/json"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type SavedOutfitRepository struct{ db *dbpkg.DB }

func NewSavedOutfitRepository(db *dbpkg.DB) repositories.SavedOutfitRepository { return &SavedOutfitRepository{db: db} }

func (r *SavedOutfitRepository) List(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT id, user_id, name, description, items, occasions, seasons, min_temp, max_temp, thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
FROM saved_outfits
WHERE user_id = $1
ORDER BY created_at DESC
`, userID)
	if err != nil { return nil, errors.Wrap(err, "list saved_outfits") }
	defer rows.Close()

	var out []domain.SavedOutfit
	for rows.Next() {
		var s domain.SavedOutfit
		var items []byte
		if err := rows.Scan(&s.ID, &s.UserID, &s.Name, &s.Description, &items, &s.Occasions, &s.Seasons, &s.MinTemp, &s.MaxTemp, &s.ThumbnailURL, &s.IsFavorite, &s.TimesWorn, &s.LastWornAt, &s.CreatedAt); err != nil {
			return nil, errors.Wrap(err, "scan saved_outfit")
		}
		var obj any
		_ = json.Unmarshal(items, &obj)
		s.Items = obj
		out = append(out, s)
	}
	return out, rows.Err()
}

func (r *SavedOutfitRepository) Create(ctx context.Context, userID domain.ID, req domain.SavedOutfitCreateRequest) (*domain.SavedOutfit, error) {
	itemsJSON, _ := json.Marshal(req.Items)

	var s domain.SavedOutfit
	var items []byte
	err := r.db.Pool().QueryRow(ctx, `
INSERT INTO saved_outfits (user_id, name, description, items, occasions, seasons)
VALUES ($1,$2,$3,$4,$5,$6)
RETURNING id, user_id, name, description, items, occasions, seasons, min_temp, max_temp, thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
`, userID, req.Name, req.Description, itemsJSON, req.Occasions, req.Seasons).Scan(
		&s.ID, &s.UserID, &s.Name, &s.Description, &items, &s.Occasions, &s.Seasons, &s.MinTemp, &s.MaxTemp, &s.ThumbnailURL, &s.IsFavorite, &s.TimesWorn, &s.LastWornAt, &s.CreatedAt,
	)
	if err != nil { return nil, errors.Wrap(err, "create saved_outfit") }
	var obj any
	_ = json.Unmarshal(items, &obj)
	s.Items = obj
	return &s, nil
}

func (r *SavedOutfitRepository) Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error) {
	var s domain.SavedOutfit
	var items []byte
	err := r.db.Pool().QueryRow(ctx, `
SELECT id, user_id, name, description, items, occasions, seasons, min_temp, max_temp, thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
FROM saved_outfits
WHERE id=$1 AND user_id=$2
`, id, userID).Scan(
		&s.ID, &s.UserID, &s.Name, &s.Description, &items, &s.Occasions, &s.Seasons, &s.MinTemp, &s.MaxTemp, &s.ThumbnailURL, &s.IsFavorite, &s.TimesWorn, &s.LastWornAt, &s.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) { return nil, nil }
		return nil, errors.Wrap(err, "get saved_outfit")
	}
	var obj any
	_ = json.Unmarshal(items, &obj)
	s.Items = obj
	return &s, nil
}

func (r *SavedOutfitRepository) Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.SavedOutfitUpdateRequest) (*domain.SavedOutfit, error) {
	var itemsJSON any
	if req.Items != nil {
		b, _ := json.Marshal(req.Items)
		itemsJSON = b
	}
	_, err := r.db.Pool().Exec(ctx, `
UPDATE saved_outfits
SET
name = COALESCE($1, name),
description = COALESCE($2, description),
items = COALESCE($3::jsonb, items),
occasions = COALESCE($4, occasions),
seasons = COALESCE($5, seasons),
is_favorite = COALESCE($6, is_favorite)
WHERE id=$7 AND user_id=$8
`, req.Name, req.Description, itemsJSON, req.Occasions, req.Seasons, req.IsFavorite, id, userID)
	if err != nil { return nil, errors.Wrap(err, "update saved_outfit") }
	return r.Get(ctx, userID, id)
}

func (r *SavedOutfitRepository) Delete(ctx context.Context, userID domain.ID, id domain.ID) error {
	cmd, err := r.db.Pool().Exec(ctx, `DELETE FROM saved_outfits WHERE id=$1 AND user_id=$2`, id, userID)
	if err != nil { return errors.Wrap(err, "delete saved_outfit") }
	if cmd.RowsAffected() == 0 { return repositories.ErrNotFound }
	return nil
}

func (r *SavedOutfitRepository) MarkWorn(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error) {
	_, err := r.db.Pool().Exec(ctx, `
UPDATE saved_outfits
SET times_worn = times_worn + 1, last_worn_at = NOW()
WHERE id=$1 AND user_id=$2
`, id, userID)
	if err != nil { return nil, errors.Wrap(err, "mark worn") }
	return r.Get(ctx, userID, id)
}