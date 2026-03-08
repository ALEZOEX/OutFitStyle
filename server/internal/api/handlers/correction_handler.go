package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
	"github.com/jackc/pgx/v5"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/persistence/postgres"
	resp "outfitstyle/server/internal/pkg/http"
)

// CorrectionHandler handles manual correction tool API requests
type CorrectionHandler struct {
	db     *postgres.DB
	logger *zap.Logger
}

// NewCorrectionHandler creates a new correction handler
func NewCorrectionHandler(db *postgres.DB, logger *zap.Logger) *CorrectionHandler {
	return &CorrectionHandler{
		db:     db,
		logger: logger,
	}
}

// ClothingItemDTO represents a clothing item for the correction tool
type ClothingItemDTO struct {
	ID            string     `json:"id"`
	Name          string     `json:"name"`
	Category      string     `json:"category"`
	Subcategory   string     `json:"subcategory"`
	Materials     []string   `json:"materials"`
	Style         string     `json:"style"`
	Source        string     `json:"source"`
	Confidence    *float64   `json:"confidence,omitempty"`
	LastCorrected *time.Time `json:"last_corrected,omitempty"`
}

// ListItemsResponse represents the paginated list response
type ListItemsResponse struct {
	Items      []ClothingItemDTO `json:"items"`
	Total      int               `json:"total"`
	Page       int               `json:"page"`
	TotalPages int               `json:"total_pages"`
}

// UpdateCategoryRequest represents a category update request
type UpdateCategoryRequest struct {
	Category string  `json:"category"`
	Reason   *string `json:"reason,omitempty"`
}

// BulkUpdateRequest represents a bulk category update request
type BulkUpdateRequest struct {
	ItemIDs  []string `json:"item_ids"`
	Category string   `json:"category"`
	Reason   *string  `json:"reason,omitempty"`
}

// ListClothingItems handles GET /api/v1/clothing-items
func (h *CorrectionHandler) ListClothingItems(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	// Parse query parameters
	category := r.URL.Query().Get("category")
	subcategory := r.URL.Query().Get("subcategory")
	source := r.URL.Query().Get("source")
	confidenceStr := r.URL.Query().Get("confidence")

	pageStr := r.URL.Query().Get("page")
	limitStr := r.URL.Query().Get("limit")

	// Default pagination values
	page := 1
	limit := 50

	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}
	}

	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 && l <= 100 {
			limit = l
		}
	}

	offset := (page - 1) * limit

	// Build query with filters
	query := `
		SELECT
			ci.id,
			ci.name,
			ci.category,
			ci.subcategory,
			ci.materials,
			ci.style,
			ci.source,
			ci.classification_confidence,
			MAX(ca.changed_at) as last_corrected
		FROM clothing_items ci
		LEFT JOIN category_audit ca ON ci.id = ca.item_id
			AND ca.changed_by NOT IN ('import', 'ml_classifier')
		WHERE ci.is_active = true
	`

	countQuery := `
		SELECT COUNT(DISTINCT ci.id)
		FROM clothing_items ci
		WHERE ci.is_active = true
	`

	args := []interface{}{}
	argCount := 1

	// Add filters
	if category != "" {
		query += fmt.Sprintf(" AND ci.category = $%d", argCount)
		countQuery += fmt.Sprintf(" AND ci.category = $%d", argCount)
		args = append(args, category)
		argCount++
	}

	if subcategory != "" {
		query += fmt.Sprintf(" AND ci.subcategory = $%d", argCount)
		countQuery += fmt.Sprintf(" AND ci.subcategory = $%d", argCount)
		args = append(args, subcategory)
		argCount++
	}

	if source != "" {
		query += fmt.Sprintf(" AND ci.source = $%d", argCount)
		countQuery += fmt.Sprintf(" AND ci.source = $%d", argCount)
		args = append(args, source)
		argCount++
	}

	if confidenceStr != "" {
		confidence, err := strconv.ParseFloat(confidenceStr, 64)
		if err == nil {
			query += fmt.Sprintf(" AND ci.classification_confidence >= $%d", argCount)
			countQuery += fmt.Sprintf(" AND ci.classification_confidence >= $%d", argCount)
			args = append(args, confidence)
			argCount++
		}
	}

	// Get total count
	var total int
	err := h.db.Pool().QueryRow(ctx, countQuery, args...).Scan(&total)
	if err != nil {
		h.logger.Error("Failed to get total count", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to list items"))
		return
	}

	// Add grouping, ordering, and pagination to main query
	query += `
		GROUP BY ci.id, ci.name, ci.category, ci.subcategory, ci.materials, ci.style, ci.source, ci.classification_confidence
		ORDER BY ci.name
	`
	query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argCount, argCount+1)
	args = append(args, limit, offset)

	// Execute query
	rows, err := h.db.Pool().Query(ctx, query, args...)
	if err != nil {
		h.logger.Error("Failed to query clothing items", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to list items"))
		return
	}
	defer rows.Close()

	items := []ClothingItemDTO{}
	for rows.Next() {
		var item ClothingItemDTO
		var materials []string
		var lastCorrected *time.Time

		err := rows.Scan(
			&item.ID,
			&item.Name,
			&item.Category,
			&item.Subcategory,
			&materials,
			&item.Style,
			&item.Source,
			&item.Confidence,
			&lastCorrected,
		)
		if err != nil {
			h.logger.Error("Failed to scan item", zap.Error(err))
			continue
		}

		item.Materials = materials
		item.LastCorrected = lastCorrected
		items = append(items, item)
	}

	totalPages := (total + limit - 1) / limit

	response := ListItemsResponse{
		Items:      items,
		Total:      total,
		Page:       page,
		TotalPages: totalPages,
	}

	resp.Success(w, response)
}

// UpdateItemCategory handles PATCH /api/v1/clothing-items/{id}/category
func (h *CorrectionHandler) UpdateItemCategory(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	itemIDStr := vars["id"]

	itemID, err := uuid.Parse(itemIDStr)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid item ID"))
		return
	}

	var req UpdateCategoryRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid request body"))
		return
	}

	// Validate category
	validCategories := map[string]bool{
		"outerwear": true,
		"upper":     true,
		"lower":     true,
		"footwear":  true,
		"accessory": true,
	}

	if !validCategories[req.Category] {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid category value, must be one of: outerwear, upper, lower, footwear, accessory"))
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	// Start transaction
	tx, err := h.db.Pool().Begin(ctx)
	if err != nil {
		h.logger.Error("Failed to begin transaction", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to update category"))
		return
	}
	defer tx.Rollback(ctx)

	// Get current category
	var oldCategory string
	err = tx.QueryRow(ctx, `
		SELECT category FROM clothing_items WHERE id = $1 AND is_active = true
	`, itemID).Scan(&oldCategory)
	if err != nil {
		if err == pgx.ErrNoRows {
			resp.Error(w, http.StatusNotFound, fmt.Errorf("item not found"))
			return
		}
		h.logger.Error("Failed to get current category", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to update category"))
		return
	}

	// Update category and classification_source
	_, err = tx.Exec(ctx, `
		UPDATE clothing_items
		SET category = $1, classification_source = 'manual', updated_at = now()
		WHERE id = $2
	`, req.Category, itemID)
	if err != nil {
		h.logger.Error("Failed to update category", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to update category"))
		return
	}

	// Create audit record
	// TODO: Get actual user ID from authentication context
	changedBy := "manual_user" // Placeholder for user ID

	_, err = tx.Exec(ctx, `
		INSERT INTO category_audit (item_id, old_category, new_category, changed_by, reason)
		VALUES ($1, $2, $3, $4, $5)
	`, itemID, oldCategory, req.Category, changedBy, req.Reason)
	if err != nil {
		h.logger.Error("Failed to create audit record", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to update category"))
		return
	}

	// Commit transaction
	if err := tx.Commit(ctx); err != nil {
		h.logger.Error("Failed to commit transaction", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to update category"))
		return
	}

	resp.Success(w, map[string]string{
		"message": "Category updated successfully",
	})
}

// BulkUpdateCategories handles POST /api/v1/clothing-items/bulk-update
func (h *CorrectionHandler) BulkUpdateCategories(w http.ResponseWriter, r *http.Request) {
	var req BulkUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid request body"))
		return
	}

	// Validate request
	if len(req.ItemIDs) == 0 {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("item_ids cannot be empty"))
		return
	}

	// Validate category
	validCategories := map[string]bool{
		"outerwear": true,
		"upper":     true,
		"lower":     true,
		"footwear":  true,
		"accessory": true,
	}

	if !validCategories[req.Category] {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid category value, must be one of: outerwear, upper, lower, footwear, accessory"))
		return
	}

	// Parse item IDs
	itemIDs := make([]uuid.UUID, 0, len(req.ItemIDs))
	for _, idStr := range req.ItemIDs {
		id, err := uuid.Parse(idStr)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid item ID: %s", idStr))
			return
		}
		itemIDs = append(itemIDs, id)
	}

	ctx, cancel := context.WithTimeout(r.Context(), 30*time.Second)
	defer cancel()

	// Start transaction
	tx, err := h.db.Pool().Begin(ctx)
	if err != nil {
		h.logger.Error("Failed to begin transaction", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to bulk update"))
		return
	}
	defer tx.Rollback(ctx)

	// Verify all items exist and get their current categories
	placeholders := make([]string, len(itemIDs))
	args := make([]interface{}, len(itemIDs))
	for i, id := range itemIDs {
		placeholders[i] = fmt.Sprintf("$%d", i+1)
		args[i] = id
	}

	query := fmt.Sprintf(`
		SELECT id, category
		FROM clothing_items
		WHERE id IN (%s) AND is_active = true
	`, strings.Join(placeholders, ","))

	rows, err := tx.Query(ctx, query, args...)
	if err != nil {
		h.logger.Error("Failed to verify items", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to bulk update"))
		return
	}

	itemCategories := make(map[uuid.UUID]string)
	for rows.Next() {
		var id uuid.UUID
		var category string
		if err := rows.Scan(&id, &category); err != nil {
			rows.Close()
			h.logger.Error("Failed to scan item", zap.Error(err))
			resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to bulk update"))
			return
		}
		itemCategories[id] = category
	}
	rows.Close()

	// Check if all items were found
	if len(itemCategories) != len(itemIDs) {
		resp.Error(w, http.StatusNotFound, fmt.Errorf("one or more items not found"))
		return
	}

	// Update all items
	updateQuery := fmt.Sprintf(`
		UPDATE clothing_items
		SET category = $1, classification_source = 'manual', updated_at = now()
		WHERE id IN (%s)
	`, strings.Join(placeholders, ","))

	updateArgs := make([]interface{}, len(itemIDs)+1)
	updateArgs[0] = req.Category
	for i, id := range itemIDs {
		updateArgs[i+1] = id
	}

	_, err = tx.Exec(ctx, updateQuery, updateArgs...)
	if err != nil {
		h.logger.Error("Failed to bulk update categories", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to bulk update"))
		return
	}

	// Create audit records for all items
	// TODO: Get actual user ID from authentication context
	changedBy := "manual_user" // Placeholder for user ID

	for _, id := range itemIDs {
		oldCategory := itemCategories[id]
		_, err = tx.Exec(ctx, `
			INSERT INTO category_audit (item_id, old_category, new_category, changed_by, reason)
			VALUES ($1, $2, $3, $4, $5)
		`, id, oldCategory, req.Category, changedBy, req.Reason)
		if err != nil {
			h.logger.Error("Failed to create audit record",
				zap.Error(err),
				zap.String("item_id", id.String()))
			resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to bulk update"))
			return
		}
	}

	// Commit transaction
	if err := tx.Commit(ctx); err != nil {
		h.logger.Error("Failed to commit transaction", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to bulk update"))
		return
	}

	resp.Success(w, map[string]interface{}{
		"message":       "Categories updated successfully",
		"updated_count": len(itemIDs),
	})
}

// RegisterRoutes registers the correction handler routes
func (h *CorrectionHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.ListClothingItems).Methods(http.MethodGet)
	r.HandleFunc("/{id}/category", h.UpdateItemCategory).Methods(http.MethodPatch)
	r.HandleFunc("/bulk-update", h.BulkUpdateCategories).Methods(http.MethodPost)
}
