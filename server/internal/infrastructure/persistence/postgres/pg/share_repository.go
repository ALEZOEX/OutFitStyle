package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type ShareRepository struct {
	db *pgxpool.Pool
}

func NewShareRepository(db *pgxpool.Pool) *ShareRepository {
	return &ShareRepository{db: db}
}

func (r *ShareRepository) CreateShareLink(ctx context.Context, link *domain.ShareLink) error {
	query := `
		INSERT INTO share_links (
			id, user_id, resource_id, resource_type, share_token, is_public, view_count, max_views, expires_at, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	`

	_, err := r.db.Exec(ctx, query,
		link.ID,
		link.UserID,
		link.ResourceID,
		link.ResourceType,
		link.ShareToken,
		link.IsPublic,
		link.ViewCount,
		link.MaxViews,
		link.ExpiresAt,
		link.CreatedAt,
		link.UpdatedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to create share link")
	}

	return nil
}

func (r *ShareRepository) GetByOwner(ctx context.Context, ownerID domain.ID) ([]domain.ShareLink, error) {
	query := `
		SELECT 
			id, user_id, resource_id, resource_type, share_token, is_public, view_count, max_views, expires_at, created_at, updated_at
		FROM share_links
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, ownerID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query share links by owner")
	}
	defer rows.Close()

	var links []domain.ShareLink
	for rows.Next() {
		var link domain.ShareLink
		var maxViews *int
		var expiresAt *time.Time

		err := rows.Scan(
			&link.ID,
			&link.UserID,
			&link.ResourceID,
			&link.ResourceType,
			&link.ShareToken,
			&link.IsPublic,
			&link.ViewCount,
			&maxViews,
			&expiresAt,
			&link.CreatedAt,
			&link.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan share link")
		}

		// Set nullable fields
		link.MaxViews = maxViews
		link.ExpiresAt = expiresAt

		links = append(links, link)
	}

	return links, nil
}

func (r *ShareRepository) UpdateShareLink(ctx context.Context, link *domain.ShareLink) error {
	query := `
		UPDATE share_links
		SET resource_id = $1, resource_type = $2, share_token = $3, is_public = $4, 
			view_count = $5, max_views = $6, expires_at = $7, updated_at = $8
		WHERE id = $9
	`

	_, err := r.db.Exec(ctx, query,
		link.ResourceID,
		link.ResourceType,
		link.ShareToken,
		link.IsPublic,
		link.ViewCount,
		link.MaxViews,
		link.ExpiresAt,
		time.Now(),
		link.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update share link")
	}

	return nil
}

func (r *ShareRepository) CreateShare(ctx context.Context, userID domain.ID, recommendationID *domain.ID, savedOutfitID *domain.ID, showUserName bool) (string, error) {
	// Generate a unique share code
	shareCode := uuid.New().String()

	// Determine resource type and ID
	var resourceID string
	var resourceType string

	if recommendationID != nil {
		resourceID = recommendationID.String()
		resourceType = "recommendation"
	} else if savedOutfitID != nil {
		resourceID = savedOutfitID.String()
		resourceType = "saved_outfit"
	} else {
		return "", errors.New("either recommendationID or savedOutfitID must be provided")
	}

	// Create share link
	link := &domain.ShareLink{
		ID:           domain.NewID(),
		UserID:       userID,
		ResourceID:   resourceID,
		ResourceType: resourceType,
		ShareToken:   shareCode,
		IsPublic:     true,
		ViewCount:    0,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	err := r.CreateShareLink(ctx, link)
	if err != nil {
		return "", errors.Wrap(err, "failed to create share link")
	}

	return shareCode, nil
}

func (r *ShareRepository) GetByCode(ctx context.Context, code string) (*repositories.SharedOutfitRecord, error) {
	query := `
		SELECT 
			sl.id, sl.user_id, sl.resource_id, sl.resource_type, sl.share_token, 
			sl.is_public, sl.view_count, sl.max_views, sl.expires_at, sl.created_at, sl.updated_at,
			u.display_name
		FROM share_links sl
		LEFT JOIN users u ON sl.user_id = u.id
		WHERE sl.share_token = $1
	`

	var record repositories.SharedOutfitRecord
	var maxViews *int
	var expiresAt *time.Time
	var displayName *string

	err := r.db.QueryRow(ctx, query, code).Scan(
		&record.ID,
		&record.UserID,
		&record.ResourceID,
		&record.ResourceType,
		&record.ShareToken,
		&record.IsPublic,
		&record.ViewCount,
		&maxViews,
		&expiresAt,
		&record.CreatedAt,
		&record.UpdatedAt,
		&displayName,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get share by code")
	}

	// Set nullable fields
	record.MaxViews = maxViews
	record.ExpiresAt = expiresAt
	record.DisplayName = displayName

	return &record, nil
}

func (r *ShareRepository) IncViews(ctx context.Context, code string) error {
	query := `
		UPDATE share_links
		SET view_count = view_count + 1, updated_at = $1
		WHERE share_token = $2
	`

	_, err := r.db.Exec(ctx, query, time.Now(), code)
	if err != nil {
		return errors.Wrap(err, "failed to increment share views")
	}

	return nil
}

func (r *ShareRepository) GetUserDisplayName(ctx context.Context, userID domain.ID) (*string, error) {
	query := `SELECT display_name FROM users WHERE id = $1`

	var displayName *string
	err := r.db.QueryRow(ctx, query, userID).Scan(&displayName)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get user display name")
	}

	return displayName, nil
}

func (r *ShareRepository) GetRecommendationOutfit(ctx context.Context, recommendationID domain.ID) (any, error) {
	query := `
		SELECT outfit
		FROM recommendations
		WHERE id = $1
	`

	var outfitJSON []byte
	err := r.db.QueryRow(ctx, query, recommendationID).Scan(&outfitJSON)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get recommendation outfit")
	}

	var outfit any
	err = json.Unmarshal(outfitJSON, &outfit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to unmarshal recommendation outfit")
	}

	return outfit, nil
}

func (r *ShareRepository) GetSavedOutfit(ctx context.Context, savedOutfitID domain.ID) (any, error) {
	query := `
		SELECT items
		FROM saved_outfits
		WHERE id = $1
	`

	var itemsJSON []byte
	err := r.db.QueryRow(ctx, query, savedOutfitID).Scan(&itemsJSON)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get saved outfit")
	}

	var items any
	err = json.Unmarshal(itemsJSON, &items)
	if err != nil {
		return nil, errors.Wrap(err, "failed to unmarshal saved outfit items")
	}

	return items, nil
}
