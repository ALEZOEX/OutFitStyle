package pg

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type WardrobeRepository struct {
	db *pgxpool.Pool
}

func NewWardrobeRepository(db *pgxpool.Pool) *WardrobeRepository {
	return &WardrobeRepository{db: db}
}

func (r *WardrobeRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.WardrobeItem, error) {
	query := `
		SELECT
			id, user_id, clothing_item_id, custom_name, notes, tags, purchase_date, purchase_price,
			purchase_currency, wear_count, last_worn_at, is_favorite, is_archived, condition,
			created_at, updated_at, item_data
		FROM user_wardrobe
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query wardrobe items by user")
	}
	defer rows.Close()

	var items []domain.WardrobeItem
	for rows.Next() {
		var item domain.WardrobeItem
		var customName *string
		var notes *string
		var tagsJSON []byte
		var purchaseDate *time.Time
		var purchasePrice *float64
		var purchaseCurrency *string
		var lastWornAt *time.Time
		var itemDataJSON []byte
		var createdAt time.Time
		var updatedAt time.Time

		err := rows.Scan(
			&item.ID,
			&item.UserID,
			&item.ClothingItemID,
			&customName,
			&notes,
			&tagsJSON,
			&purchaseDate,
			&purchasePrice,
			&purchaseCurrency,
			&item.WearCount,
			&lastWornAt,
			&item.IsFavorite,
			&item.IsArchived,
			&item.Condition,
			&createdAt,
			&updatedAt,
			&itemDataJSON,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan wardrobe item")
		}

		// Set nullable fields
		item.CustomName = customName
		item.Notes = notes
		item.PurchaseDate = purchaseDate
		item.PurchasePrice = purchasePrice
		item.PurchaseCurrency = purchaseCurrency
		item.LastWornAt = lastWornAt
		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		// Parse tags
		if len(tagsJSON) > 0 {
			err = json.Unmarshal(tagsJSON, &item.Tags)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal tags")
			}
		}

		// Parse item data (the full clothing item)
		if len(itemDataJSON) > 0 {
			err = json.Unmarshal(itemDataJSON, &item.Item)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal clothing item data")
			}
		}

		items = append(items, item)
	}

	return items, nil
}

func (r *WardrobeRepository) AddItem(ctx context.Context, item *domain.WardrobeItem) error {
	query := `
		INSERT INTO user_wardrobe (
			id, user_id, clothing_item_id, custom_name, notes, tags, purchase_date, purchase_price,
			purchase_currency, wear_count, last_worn_at, is_favorite, is_archived, condition,
			created_at, updated_at, item_data
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)
	`

	tagsJSON, err := json.Marshal(item.Tags)
	if err != nil {
		return errors.Wrap(err, "failed to marshal tags")
	}

	itemDataJSON, err := json.Marshal(item.Item)
	if err != nil {
		return errors.Wrap(err, "failed to marshal clothing item data")
	}

	_, err = r.db.Exec(ctx, query,
		item.ID,
		item.UserID,
		item.ClothingItemID,
		item.CustomName,
		item.Notes,
		tagsJSON,
		item.PurchaseDate,
		item.PurchasePrice,
		item.PurchaseCurrency,
		item.WearCount,
		item.LastWornAt,
		item.IsFavorite,
		item.IsArchived,
		item.Condition,
		item.CreatedAt,
		item.UpdatedAt,
		itemDataJSON,
	)
	if err != nil {
		return errors.Wrap(err, "failed to add wardrobe item")
	}

	return nil
}

func (r *WardrobeRepository) RemoveItem(ctx context.Context, userID domain.ID, itemID domain.ID) error {
	query := `DELETE FROM user_wardrobe WHERE user_id = $1 AND id = $2`

	_, err := r.db.Exec(ctx, query, userID, itemID)
	if err != nil {
		return errors.Wrap(err, "failed to remove wardrobe item")
	}

	return nil
}

func (r *WardrobeRepository) UpdateItem(ctx context.Context, item *domain.WardrobeItem) error {
	query := `
		UPDATE user_wardrobe
		SET custom_name = $1, notes = $2, tags = $3, purchase_date = $4, purchase_price = $5,
			purchase_currency = $6, wear_count = $7, last_worn_at = $8, is_favorite = $9,
			is_archived = $10, condition = $11, updated_at = $12, item_data = $13
		WHERE id = $14 AND user_id = $15
	`

	tagsJSON, err := json.Marshal(item.Tags)
	if err != nil {
		return errors.Wrap(err, "failed to marshal tags")
	}

	itemDataJSON, err := json.Marshal(item.Item)
	if err != nil {
		return errors.Wrap(err, "failed to marshal clothing item data")
	}

	_, err = r.db.Exec(ctx, query,
		item.CustomName,
		item.Notes,
		tagsJSON,
		item.PurchaseDate,
		item.PurchasePrice,
		item.PurchaseCurrency,
		item.WearCount,
		item.LastWornAt,
		item.IsFavorite,
		item.IsArchived,
		item.Condition,
		time.Now(),
		itemDataJSON,
		item.ID,
		item.UserID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update wardrobe item")
	}

	return nil
}

func (r *WardrobeRepository) List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) (items []domain.WardrobeItem, total int, err error) {
	// Calculate offset
	offset := (q.Page - 1) * q.Limit

	// Base query
	query := `
		SELECT
			id, user_id, clothing_item_id, custom_name, notes, tags, purchase_date, purchase_price,
			purchase_currency, wear_count, last_worn_at, is_favorite, is_archived, condition,
			created_at, updated_at, item_data
		FROM user_wardrobe
		WHERE user_id = $1
	`
	args := []interface{}{userID}
	argIndex := 2

	// Apply filters
	if q.Category != nil {
		query += fmt.Sprintf(" AND item_data->>'category' = $%d", argIndex)
		args = append(args, *q.Category)
		argIndex++
	}

	if q.Style != nil {
		query += fmt.Sprintf(" AND item_data->>'style' = $%d", argIndex)
		args = append(args, *q.Style)
		argIndex++
	}

	if q.Season != nil {
		query += fmt.Sprintf(" AND item_data->>'season' = $%d", argIndex)
		args = append(args, *q.Season)
		argIndex++
	}

	if q.IsFavorite != nil {
		query += fmt.Sprintf(" AND is_favorite = $%d", argIndex)
		args = append(args, *q.IsFavorite)
		argIndex++
	}

	if q.IsArchived != nil {
		query += fmt.Sprintf(" AND is_archived = $%d", argIndex)
		args = append(args, *q.IsArchived)
		argIndex++
	}

	if q.Search != nil {
		query += fmt.Sprintf(" AND (custom_name ILIKE $%d OR item_data->>'name' ILIKE $%d)", argIndex, argIndex)
		searchTerm := "%" + *q.Search + "%"
		args = append(args, searchTerm)
		argIndex++
	}

	// Apply sorting - validate allowed fields to prevent SQL injection
	orderField := "created_at"
	orderDir := "DESC"

	switch q.Sort {
	case "updated_at":
		orderField = "updated_at"
	case "wear_count":
		orderField = "wear_count"
	case "name":
		orderField = "item_data->>'name'"
	default:
		// Default to a safe field if an invalid sort field is provided
		orderField = "created_at"
	}

	switch q.Order {
	case domain.SortAsc:
		orderDir = "ASC"
	case domain.SortDesc:
		orderDir = "DESC"
	default:
		// Default to descending order if an invalid order is provided
		orderDir = "DESC"
	}

	// Use a switch statement to safely construct the ORDER BY clause
	orderByClause := ""
	switch orderField {
	case "updated_at":
		orderByClause = "ORDER BY updated_at"
	case "wear_count":
		orderByClause = "ORDER BY wear_count"
	case "item_data->>'name'":
		orderByClause = "ORDER BY item_data->>'name'"
	default:
		orderByClause = "ORDER BY created_at"
	}

	// Append direction
	orderByClause += " " + orderDir

	query += fmt.Sprintf(" %s LIMIT $%d OFFSET $%d", orderByClause, argIndex, argIndex+1)
	args = append(args, q.Limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to query wardrobe items")
	}
	defer rows.Close()

	for rows.Next() {
		var item domain.WardrobeItem
		var customName *string
		var notes *string
		var tagsJSON []byte
		var purchaseDate *time.Time
		var purchasePrice *float64
		var purchaseCurrency *string
		var lastWornAt *time.Time
		var itemDataJSON []byte
		var createdAt time.Time
		var updatedAt time.Time

		err := rows.Scan(
			&item.ID,
			&item.UserID,
			&item.ClothingItemID,
			&customName,
			&notes,
			&tagsJSON,
			&purchaseDate,
			&purchasePrice,
			&purchaseCurrency,
			&item.WearCount,
			&lastWornAt,
			&item.IsFavorite,
			&item.IsArchived,
			&item.Condition,
			&createdAt,
			&updatedAt,
			&itemDataJSON,
		)
		if err != nil {
			return nil, 0, errors.Wrap(err, "failed to scan wardrobe item")
		}

		// Set nullable fields
		item.CustomName = customName
		item.Notes = notes
		item.PurchaseDate = purchaseDate
		item.PurchasePrice = purchasePrice
		item.PurchaseCurrency = purchaseCurrency
		item.LastWornAt = lastWornAt
		item.CreatedAt = createdAt
		item.UpdatedAt = updatedAt

		// Parse tags
		if len(tagsJSON) > 0 {
			err = json.Unmarshal(tagsJSON, &item.Tags)
			if err != nil {
				return nil, 0, errors.Wrap(err, "failed to unmarshal tags")
			}
		}

		// Parse item data (the full clothing item)
		if len(itemDataJSON) > 0 {
			err = json.Unmarshal(itemDataJSON, &item.Item)
			if err != nil {
				return nil, 0, errors.Wrap(err, "failed to unmarshal clothing item data")
			}
		}

		items = append(items, item)
	}

	// Get total count
	countQuery := `
		SELECT COUNT(*)
		FROM user_wardrobe
		WHERE user_id = $1
	`
	countArgs := []interface{}{userID}
	countArgIndex := 2

	if q.Category != nil {
		countQuery += fmt.Sprintf(" AND item_data->>'category' = $%d", countArgIndex)
		countArgs = append(countArgs, *q.Category)
		countArgIndex++
	}

	if q.Style != nil {
		countQuery += fmt.Sprintf(" AND item_data->>'style' = $%d", countArgIndex)
		countArgs = append(countArgs, *q.Style)
		countArgIndex++
	}

	if q.Season != nil {
		countQuery += fmt.Sprintf(" AND item_data->>'season' = $%d", countArgIndex)
		countArgs = append(countArgs, *q.Season)
		countArgIndex++
	}

	if q.IsFavorite != nil {
		countQuery += fmt.Sprintf(" AND is_favorite = $%d", countArgIndex)
		countArgs = append(countArgs, *q.IsFavorite)
		countArgIndex++
	}

	if q.IsArchived != nil {
		countQuery += fmt.Sprintf(" AND is_archived = $%d", countArgIndex)
		countArgs = append(countArgs, *q.IsArchived)
		countArgIndex++
	}

	if q.Search != nil {
		countQuery += fmt.Sprintf(" AND (custom_name ILIKE $%d OR item_data->>'name' ILIKE $%d)", countArgIndex, countArgIndex)
		searchTerm := "%" + *q.Search + "%"
		countArgs = append(countArgs, searchTerm)
	}

	err = r.db.QueryRow(ctx, countQuery, countArgs...).Scan(&total)
	if err != nil {
		return nil, 0, errors.Wrap(err, "failed to count wardrobe items")
	}

	return items, total, nil
}

func (r *WardrobeRepository) GetByID(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	query := `
		SELECT
			id, user_id, clothing_item_id, custom_name, notes, tags, purchase_date, purchase_price,
			purchase_currency, wear_count, last_worn_at, is_favorite, is_archived, condition,
			created_at, updated_at, item_data
		FROM user_wardrobe
		WHERE user_id = $1 AND id = $2
	`

	var item domain.WardrobeItem
	var customName *string
	var notes *string
	var tagsJSON []byte
	var purchaseDate *time.Time
	var purchasePrice *float64
	var purchaseCurrency *string
	var lastWornAt *time.Time
	var itemDataJSON []byte
	var createdAt time.Time
	var updatedAt time.Time

	err := r.db.QueryRow(ctx, query, userID, wardrobeID).Scan(
		&item.ID,
		&item.UserID,
		&item.ClothingItemID,
		&customName,
		&notes,
		&tagsJSON,
		&purchaseDate,
		&purchasePrice,
		&purchaseCurrency,
		&item.WearCount,
		&lastWornAt,
		&item.IsFavorite,
		&item.IsArchived,
		&item.Condition,
		&createdAt,
		&updatedAt,
		&itemDataJSON,
	)
	if err != nil {
		if err.Error() == "no rows in result set" || err.Error() == "no rows affected" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get wardrobe item by ID")
	}

	// Set nullable fields
	item.CustomName = customName
	item.Notes = notes
	item.PurchaseDate = purchaseDate
	item.PurchasePrice = purchasePrice
	item.PurchaseCurrency = purchaseCurrency
	item.LastWornAt = lastWornAt
	item.CreatedAt = createdAt
	item.UpdatedAt = updatedAt

	// Parse tags
	if len(tagsJSON) > 0 {
		err = json.Unmarshal(tagsJSON, &item.Tags)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal tags")
		}
	}

	// Parse item data (the full clothing item)
	if len(itemDataJSON) > 0 {
		err = json.Unmarshal(itemDataJSON, &item.Item)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal clothing item data")
		}
	}

	return &item, nil
}

func (r *WardrobeRepository) Add(ctx context.Context, userID domain.ID, clothingItemID domain.ID, customName *string, notes *string, tags []string) (*domain.WardrobeItem, error) {
	id := domain.NewID()
	now := time.Now()

	var itemData domain.ClothingItem
	// We'll need to implement a way to get the clothing item, for now we'll just create a minimal one
	itemData.ID = clothingItemID

	query := `
		INSERT INTO user_wardrobe (
			id, user_id, clothing_item_id, custom_name, notes, tags, wear_count, is_favorite, is_archived, condition, created_at, updated_at, item_data
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
	`

	tagsJSON, err := json.Marshal(tags)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal tags")
	}

	itemDataJSON, err := json.Marshal(itemData)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal clothing item data")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		userID,
		clothingItemID,
		customName,
		notes,
		tagsJSON,
		0,      // wear_count starts at 0
		false,  // is_favorite starts as false
		false,  // is_archived starts as false
		"good", // default condition
		now,
		now,
		itemDataJSON,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to add wardrobe item")
	}

	// Return the created item
	wardrobeItem := &domain.WardrobeItem{
		ID:             id,
		UserID:         userID,
		ClothingItemID: clothingItemID,
		CustomName:     customName,
		Notes:          notes,
		Tags:           tags,
		WearCount:      0,
		IsFavorite:     false,
		IsArchived:     false,
		Condition:      "good",
		CreatedAt:      now,
		UpdatedAt:      now,
		Item:           itemData,
	}

	return wardrobeItem, nil
}

func (r *WardrobeRepository) Update(ctx context.Context, userID domain.ID, wardrobeID domain.ID, patch domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error) {
	// First get the current item
	currentItem, err := r.GetByID(ctx, userID, wardrobeID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get current wardrobe item")
	}
	if currentItem == nil {
		return nil, errors.New("wardrobe item not found")
	}

	// Apply updates from patch
	if patch.CustomName != nil {
		currentItem.CustomName = patch.CustomName
	}
	if patch.Notes != nil {
		currentItem.Notes = patch.Notes
	}
	if patch.Tags != nil {
		currentItem.Tags = patch.Tags
	}
	if patch.PurchasePrice != nil {
		currentItem.PurchasePrice = patch.PurchasePrice
	}
	if patch.Condition != nil {
		currentItem.Condition = *patch.Condition
	}

	// Update the item
	err = r.UpdateItem(ctx, currentItem)
	if err != nil {
		return nil, errors.Wrap(err, "failed to update wardrobe item")
	}

	return currentItem, nil
}

func (r *WardrobeRepository) Delete(ctx context.Context, userID domain.ID, wardrobeID domain.ID) error {
	query := `DELETE FROM user_wardrobe WHERE user_id = $1 AND id = $2`

	_, err := r.db.Exec(ctx, query, userID, wardrobeID)
	if err != nil {
		return errors.Wrap(err, "failed to delete wardrobe item")
	}

	return nil
}

func (r *WardrobeRepository) SetFavorite(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isFavorite bool) error {
	query := `
		UPDATE user_wardrobe
		SET is_favorite = $1, updated_at = $2
		WHERE user_id = $3 AND id = $4
	`

	_, err := r.db.Exec(ctx, query, isFavorite, time.Now(), userID, wardrobeID)
	if err != nil {
		return errors.Wrap(err, "failed to set wardrobe item favorite status")
	}

	return nil
}

func (r *WardrobeRepository) SetArchived(ctx context.Context, userID domain.ID, wardrobeID domain.ID, isArchived bool) error {
	query := `
		UPDATE user_wardrobe
		SET is_archived = $1, updated_at = $2
		WHERE user_id = $3 AND id = $4
	`

	_, err := r.db.Exec(ctx, query, isArchived, time.Now(), userID, wardrobeID)
	if err != nil {
		return errors.Wrap(err, "failed to set wardrobe item archived status")
	}

	return nil
}

func (r *WardrobeRepository) MarkWorn(ctx context.Context, userID domain.ID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	query := `
		UPDATE user_wardrobe
		SET wear_count = wear_count + 1, last_worn_at = $1, updated_at = $2
		WHERE user_id = $3 AND id = $4
		RETURNING
			id, user_id, clothing_item_id, custom_name, notes, tags, purchase_date, purchase_price,
			purchase_currency, wear_count, last_worn_at, is_favorite, is_archived, condition,
			created_at, updated_at, item_data
	`

	var item domain.WardrobeItem
	var customName *string
	var notes *string
	var tagsJSON []byte
	var purchaseDate *time.Time
	var purchasePrice *float64
	var purchaseCurrency *string
	var lastWornAt *time.Time
	var itemDataJSON []byte
	var createdAt time.Time
	var updatedAt time.Time

	now := time.Now()

	err := r.db.QueryRow(ctx, query, now, now, userID, wardrobeID).Scan(
		&item.ID,
		&item.UserID,
		&item.ClothingItemID,
		&customName,
		&notes,
		&tagsJSON,
		&purchaseDate,
		&purchasePrice,
		&purchaseCurrency,
		&item.WearCount,
		&lastWornAt,
		&item.IsFavorite,
		&item.IsArchived,
		&item.Condition,
		&createdAt,
		&updatedAt,
		&itemDataJSON,
	)
	if err != nil {
		if err.Error() == "no rows in result set" || err.Error() == "no rows affected" {
			return nil, errors.New("wardrobe item not found")
		}
		return nil, errors.Wrap(err, "failed to mark wardrobe item as worn")
	}

	// Set nullable fields
	item.CustomName = customName
	item.Notes = notes
	item.PurchaseDate = purchaseDate
	item.PurchasePrice = purchasePrice
	item.PurchaseCurrency = purchaseCurrency
	item.LastWornAt = lastWornAt
	item.CreatedAt = createdAt
	item.UpdatedAt = updatedAt

	// Parse tags
	if len(tagsJSON) > 0 {
		err = json.Unmarshal(tagsJSON, &item.Tags)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal tags")
		}
	}

	// Parse item data (the full clothing item)
	if len(itemDataJSON) > 0 {
		err = json.Unmarshal(itemDataJSON, &item.Item)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal clothing item data")
		}
	}

	return &item, nil
}

func (r *WardrobeRepository) IsInWardrobe(ctx context.Context, userID domain.ID, clothingItemID domain.ID) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM user_wardrobe WHERE user_id = $1 AND clothing_item_id = $2)`

	var exists bool
	err := r.db.QueryRow(ctx, query, userID, clothingItemID).Scan(&exists)
	if err != nil {
		return false, errors.Wrap(err, "failed to check if item is in wardrobe")
	}

	return exists, nil
}
