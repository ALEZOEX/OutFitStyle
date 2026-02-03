package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type SavedOutfitRepository struct {
	db *pgxpool.Pool
}

func NewSavedOutfitRepository(db *pgxpool.Pool) *SavedOutfitRepository {
	return &SavedOutfitRepository{db: db}
}

func (r *SavedOutfitRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error) {
	query := `
		SELECT
			id, user_id, name, description, items, occasions, seasons, min_temp, max_temp,
			thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
		FROM saved_outfits
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query saved outfits by user")
	}
	defer rows.Close()

	var outfits []domain.SavedOutfit
	for rows.Next() {
		var outfit domain.SavedOutfit
		var description *string
		var itemsJSON []byte
		var occasionsJSON []byte
		var seasonsJSON []byte
		var minTemp *int
		var maxTemp *int
		var thumbnailURL *string
		var lastWornAt *time.Time
		var createdAt time.Time

		err := rows.Scan(
			&outfit.ID,
			&outfit.UserID,
			&outfit.Name,
			&description,
			&itemsJSON,
			&occasionsJSON,
			&seasonsJSON,
			&minTemp,
			&maxTemp,
			&thumbnailURL,
			&outfit.IsFavorite,
			&outfit.TimesWorn,
			&lastWornAt,
			&createdAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan saved outfit")
		}

		// Set nullable fields
		outfit.Description = description
		outfit.MinTemp = minTemp
		outfit.MaxTemp = maxTemp
		outfit.ThumbnailURL = thumbnailURL
		outfit.LastWornAt = lastWornAt
		outfit.CreatedAt = createdAt

		// Parse JSON fields
		if len(itemsJSON) > 0 {
			err = json.Unmarshal(itemsJSON, &outfit.Items)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal items")
			}
		}

		if len(occasionsJSON) > 0 {
			err = json.Unmarshal(occasionsJSON, &outfit.Occasions)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal occasions")
			}
		}

		if len(seasonsJSON) > 0 {
			err = json.Unmarshal(seasonsJSON, &outfit.Seasons)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal seasons")
			}
		}

		outfits = append(outfits, outfit)
	}

	return outfits, nil
}

func (r *SavedOutfitRepository) GetByID(ctx context.Context, outfitID domain.ID) (*domain.SavedOutfit, error) {
	query := `
		SELECT
			id, user_id, name, description, items, occasions, seasons, min_temp, max_temp,
			thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
		FROM saved_outfits
		WHERE id = $1
	`

	var outfit domain.SavedOutfit
	var description *string
	var itemsJSON []byte
	var occasionsJSON []byte
	var seasonsJSON []byte
	var minTemp *int
	var maxTemp *int
	var thumbnailURL *string
	var lastWornAt *time.Time
	var createdAt time.Time

	err := r.db.QueryRow(ctx, query, outfitID).Scan(
		&outfit.ID,
		&outfit.UserID,
		&outfit.Name,
		&description,
		&itemsJSON,
		&occasionsJSON,
		&seasonsJSON,
		&minTemp,
		&maxTemp,
		&thumbnailURL,
		&outfit.IsFavorite,
		&outfit.TimesWorn,
		&lastWornAt,
		&createdAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get saved outfit by ID")
	}

	// Set nullable fields
	outfit.Description = description
	outfit.MinTemp = minTemp
	outfit.MaxTemp = maxTemp
	outfit.ThumbnailURL = thumbnailURL
	outfit.LastWornAt = lastWornAt
	outfit.CreatedAt = createdAt

	// Parse JSON fields
	if len(itemsJSON) > 0 {
		err = json.Unmarshal(itemsJSON, &outfit.Items)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal items")
		}
	}

	if len(occasionsJSON) > 0 {
		err = json.Unmarshal(occasionsJSON, &outfit.Occasions)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal occasions")
		}
	}

	if len(seasonsJSON) > 0 {
		err = json.Unmarshal(seasonsJSON, &outfit.Seasons)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal seasons")
		}
	}

	return &outfit, nil
}

// GetByUserAndID gets a saved outfit by its ID and verifies it belongs to the user
func (r *SavedOutfitRepository) GetByUserAndID(ctx context.Context, userID, outfitID domain.ID) (*domain.SavedOutfit, error) {
	query := `
		SELECT
			id, user_id, name, description, items, occasions, seasons, min_temp, max_temp,
			thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
		FROM saved_outfits
		WHERE user_id = $1 AND id = $2
	`

	var outfit domain.SavedOutfit
	var description *string
	var itemsJSON []byte
	var occasionsJSON []byte
	var seasonsJSON []byte
	var minTemp *int
	var maxTemp *int
	var thumbnailURL *string
	var lastWornAt *time.Time
	var createdAt time.Time

	err := r.db.QueryRow(ctx, query, userID, outfitID).Scan(
		&outfit.ID,
		&outfit.UserID,
		&outfit.Name,
		&description,
		&itemsJSON,
		&occasionsJSON,
		&seasonsJSON,
		&minTemp,
		&maxTemp,
		&thumbnailURL,
		&outfit.IsFavorite,
		&outfit.TimesWorn,
		&lastWornAt,
		&createdAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get saved outfit by user and ID")
	}

	// Set nullable fields
	outfit.Description = description
	outfit.MinTemp = minTemp
	outfit.MaxTemp = maxTemp
	outfit.ThumbnailURL = thumbnailURL
	outfit.LastWornAt = lastWornAt
	outfit.CreatedAt = createdAt

	// Parse JSON fields
	if len(itemsJSON) > 0 {
		err = json.Unmarshal(itemsJSON, &outfit.Items)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal items")
		}
	}

	if len(occasionsJSON) > 0 {
		err = json.Unmarshal(occasionsJSON, &outfit.Occasions)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal occasions")
		}
	}

	if len(seasonsJSON) > 0 {
		err = json.Unmarshal(seasonsJSON, &outfit.Seasons)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal seasons")
		}
	}

	return &outfit, nil
}

func (r *SavedOutfitRepository) List(ctx context.Context, userID domain.ID) ([]domain.SavedOutfit, error) {
	return r.GetByUser(ctx, userID)
}

func (r *SavedOutfitRepository) Create(ctx context.Context, userID domain.ID, req domain.SavedOutfitCreateRequest) (*domain.SavedOutfit, error) {
	id := domain.NewID()
	now := time.Now()

	query := `
		INSERT INTO saved_outfits (
			id, user_id, name, description, items, occasions, seasons, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	description := req.Description
	if description == nil {
		description = new(string)
	}

	itemsJSON, err := json.Marshal(req.Items)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal items")
	}

	occasionsJSON, err := json.Marshal(req.Occasions)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal occasions")
	}

	seasonsJSON, err := json.Marshal(req.Seasons)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal seasons")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		userID,
		req.Name,
		description,
		itemsJSON,
		occasionsJSON,
		seasonsJSON,
		now,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to create saved outfit")
	}

	// Return the created outfit
	outfit := &domain.SavedOutfit{
		ID:          id,
		UserID:      userID,
		Name:        req.Name,
		Description: req.Description,
		Items:       req.Items,
		Occasions:   req.Occasions,
		Seasons:     req.Seasons,
		CreatedAt:   now,
		IsFavorite:  false,
		TimesWorn:   0,
	}

	return outfit, nil
}

func (r *SavedOutfitRepository) Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error) {
	query := `
		SELECT
			id, user_id, name, description, items, occasions, seasons, min_temp, max_temp,
			thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
		FROM saved_outfits
		WHERE user_id = $1 AND id = $2
	`

	var outfit domain.SavedOutfit
	var description *string
	var itemsJSON []byte
	var occasionsJSON []byte
	var seasonsJSON []byte
	var minTemp *int
	var maxTemp *int
	var thumbnailURL *string
	var lastWornAt *time.Time
	var createdAt time.Time

	err := r.db.QueryRow(ctx, query, userID, id).Scan(
		&outfit.ID,
		&outfit.UserID,
		&outfit.Name,
		&description,
		&itemsJSON,
		&occasionsJSON,
		&seasonsJSON,
		&minTemp,
		&maxTemp,
		&thumbnailURL,
		&outfit.IsFavorite,
		&outfit.TimesWorn,
		&lastWornAt,
		&createdAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get saved outfit")
	}

	// Set nullable fields
	outfit.Description = description
	outfit.MinTemp = minTemp
	outfit.MaxTemp = maxTemp
	outfit.ThumbnailURL = thumbnailURL
	outfit.LastWornAt = lastWornAt
	outfit.CreatedAt = createdAt

	// Parse JSON fields
	if len(itemsJSON) > 0 {
		err = json.Unmarshal(itemsJSON, &outfit.Items)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal items")
		}
	}

	if len(occasionsJSON) > 0 {
		err = json.Unmarshal(occasionsJSON, &outfit.Occasions)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal occasions")
		}
	}

	if len(seasonsJSON) > 0 {
		err = json.Unmarshal(seasonsJSON, &outfit.Seasons)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal seasons")
		}
	}

	return &outfit, nil
}

func (r *SavedOutfitRepository) Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.SavedOutfitUpdateRequest) (*domain.SavedOutfit, error) {
	query := `
		UPDATE saved_outfits
		SET name = COALESCE($1, name),
			description = COALESCE($2, description),
			items = COALESCE($3, items),
			occasions = COALESCE($4, occasions),
			seasons = COALESCE($5, seasons),
			is_favorite = COALESCE($6, is_favorite),
			updated_at = NOW()
		WHERE user_id = $7 AND id = $8
	`

	var name *string
	var description *string
	var itemsJSON []byte
	var occasionsJSON []byte
	var seasonsJSON []byte
	var isFavorite *bool

	if req.Name != nil {
		name = req.Name
	}
	if req.Description != nil {
		description = req.Description
	}
	if req.Items != nil {
		itemsJSON, _ = json.Marshal(req.Items)
	}
	if req.Occasions != nil {
		occasionsJSON, _ = json.Marshal(req.Occasions)
	}
	if req.Seasons != nil {
		seasonsJSON, _ = json.Marshal(req.Seasons)
	}
	if req.IsFavorite != nil {
		isFavorite = req.IsFavorite
	}

	_, err := r.db.Exec(ctx, query,
		name,
		description,
		itemsJSON,
		occasionsJSON,
		seasonsJSON,
		isFavorite,
		userID,
		id,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to update saved outfit")
	}

	// Return the updated outfit
	return r.Get(ctx, userID, id)
}

func (r *SavedOutfitRepository) Delete(ctx context.Context, userID domain.ID, id domain.ID) error {
	query := `DELETE FROM saved_outfits WHERE user_id = $1 AND id = $2`

	_, err := r.db.Exec(ctx, query, userID, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete saved outfit")
	}

	return nil
}

func (r *SavedOutfitRepository) MarkWorn(ctx context.Context, userID domain.ID, id domain.ID) (*domain.SavedOutfit, error) {
	query := `
		UPDATE saved_outfits
		SET times_worn = times_worn + 1, last_worn_at = $1, updated_at = $2
		WHERE user_id = $3 AND id = $4
		RETURNING id, user_id, name, description, items, occasions, seasons, min_temp, max_temp,
			thumbnail_url, is_favorite, times_worn, last_worn_at, created_at
	`

	var outfit domain.SavedOutfit
	var description *string
	var itemsJSON []byte
	var occasionsJSON []byte
	var seasonsJSON []byte
	var minTemp *int
	var maxTemp *int
	var thumbnailURL *string
	var lastWornAt *time.Time
	var createdAt time.Time

	now := time.Now()

	err := r.db.QueryRow(ctx, query, now, now, userID, id).Scan(
		&outfit.ID,
		&outfit.UserID,
		&outfit.Name,
		&description,
		&itemsJSON,
		&occasionsJSON,
		&seasonsJSON,
		&minTemp,
		&maxTemp,
		&thumbnailURL,
		&outfit.IsFavorite,
		&outfit.TimesWorn,
		&lastWornAt,
		&createdAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, errors.New("saved outfit not found")
		}
		return nil, errors.Wrap(err, "failed to mark saved outfit as worn")
	}

	// Set nullable fields
	outfit.Description = description
	outfit.MinTemp = minTemp
	outfit.MaxTemp = maxTemp
	outfit.ThumbnailURL = thumbnailURL
	outfit.LastWornAt = lastWornAt
	outfit.CreatedAt = createdAt

	// Parse JSON fields
	if len(itemsJSON) > 0 {
		err = json.Unmarshal(itemsJSON, &outfit.Items)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal items")
		}
	}

	if len(occasionsJSON) > 0 {
		err = json.Unmarshal(occasionsJSON, &outfit.Occasions)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal occasions")
		}
	}

	if len(seasonsJSON) > 0 {
		err = json.Unmarshal(seasonsJSON, &outfit.Seasons)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal seasons")
		}
	}

	return &outfit, nil
}
