package handlers

import (
	"context"
	"encoding/csv"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/persistence/postgres"
	resp "outfitstyle/server/internal/pkg/http"
)

// ClassificationHandler handles classification dashboard API requests
type ClassificationHandler struct {
	db     *postgres.DB
	logger *zap.Logger
}

// NewClassificationHandler creates a new classification handler
func NewClassificationHandler(db *postgres.DB, logger *zap.Logger) *ClassificationHandler {
	return &ClassificationHandler{
		db:     db,
		logger: logger,
	}
}

// MetricsResponse represents the dashboard metrics response
type MetricsResponse struct {
	TotalItems        int                       `json:"total_items"`
	CategoryDist      map[string]int            `json:"category_distribution"`
	CategoryPercent   map[string]float64        `json:"category_percentages"`
	SubcategoryMap    map[string][]SubcatInfo   `json:"subcategory_mappings"`
	UnmappedSubcats   []UnmappedInfo            `json:"unmapped_subcategories"`
	LastImportAt      *time.Time                `json:"last_import_at"`
	ManualCorrections int                       `json:"manual_corrections"`
}

// SubcatInfo represents subcategory information
type SubcatInfo struct {
	Subcategory string `json:"subcategory"`
	Count       int    `json:"count"`
}

// UnmappedInfo represents unmapped subcategory information
type UnmappedInfo struct {
	Subcategory string `json:"subcategory"`
	Count       int    `json:"count"`
	FallbackCat string `json:"fallback_category"`
}

// CategoryBreakdownResponse represents the category breakdown response
type CategoryBreakdownResponse struct {
	Category      string       `json:"category"`
	TotalCount    int          `json:"total_count"`
	Subcategories []SubcatInfo `json:"subcategories"`
}


// GetMetrics handles GET /api/v1/classification/metrics
func (h *ClassificationHandler) GetMetrics(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	// Get total items count
	var totalItems int
	err := h.db.Pool().QueryRow(ctx, `
		SELECT COUNT(*) FROM clothing_items WHERE is_active = true
	`).Scan(&totalItems)
	if err != nil {
		h.logger.Error("Failed to get total items count", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get metrics"))
		return
	}

	// Get category distribution
	categoryDist := make(map[string]int)
	categoryPercent := make(map[string]float64)

	rows, err := h.db.Pool().Query(ctx, `
		SELECT category, COUNT(*) as count
		FROM clothing_items
		WHERE is_active = true
		GROUP BY category
		ORDER BY category
	`)
	if err != nil {
		h.logger.Error("Failed to get category distribution", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get metrics"))
		return
	}
	defer rows.Close()

	for rows.Next() {
		var category string
		var count int
		if err := rows.Scan(&category, &count); err != nil {
			h.logger.Error("Failed to scan category distribution", zap.Error(err))
			continue
		}
		categoryDist[category] = count
		if totalItems > 0 {
			categoryPercent[category] = float64(count) / float64(totalItems) * 100.0
		}
	}

	// Get subcategory mappings per category
	subcategoryMap := make(map[string][]SubcatInfo)

	rows, err = h.db.Pool().Query(ctx, `
		SELECT category, subcategory, COUNT(*) as count
		FROM clothing_items
		WHERE is_active = true
		GROUP BY category, subcategory
		ORDER BY category, count DESC
	`)
	if err != nil {
		h.logger.Error("Failed to get subcategory mappings", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get metrics"))
		return
	}
	defer rows.Close()

	for rows.Next() {
		var category, subcategory string
		var count int
		if err := rows.Scan(&category, &subcategory, &count); err != nil {
			h.logger.Error("Failed to scan subcategory mapping", zap.Error(err))
			continue
		}
		subcategoryMap[category] = append(subcategoryMap[category], SubcatInfo{
			Subcategory: subcategory,
			Count:       count,
		})
	}

	// Get unmapped subcategories
	unmappedSubcats := []UnmappedInfo{}

	rows, err = h.db.Pool().Query(ctx, `
		SELECT subcategory, category, COUNT(*) as count
		FROM clothing_items
		WHERE is_active = true
		  AND classification_source = 'mapping'
		GROUP BY subcategory, category
		ORDER BY count DESC
	`)
	if err != nil {
		h.logger.Error("Failed to get unmapped subcategories", zap.Error(err))
	} else {
		defer rows.Close()
		for rows.Next() {
			var subcategory, category string
			var count int
			if err := rows.Scan(&subcategory, &category, &count); err != nil {
				h.logger.Error("Failed to scan unmapped subcategory", zap.Error(err))
				continue
			}
			unmappedSubcats = append(unmappedSubcats, UnmappedInfo{
				Subcategory: subcategory,
				Count:       count,
				FallbackCat: category,
			})
		}
	}

	// Get last import timestamp
	var lastImportAt *time.Time
	err = h.db.Pool().QueryRow(ctx, `
		SELECT completed_at
		FROM import_metadata
		WHERE status = 'completed'
		ORDER BY completed_at DESC
		LIMIT 1
	`).Scan(&lastImportAt)
	if err != nil {
		h.logger.Warn("Failed to get last import timestamp", zap.Error(err))
	}

	// Get manual corrections count
	var manualCorrections int
	err = h.db.Pool().QueryRow(ctx, `
		SELECT COUNT(DISTINCT item_id)
		FROM category_audit
		WHERE changed_by NOT IN ('import', 'ml_classifier')
	`).Scan(&manualCorrections)
	if err != nil {
		h.logger.Warn("Failed to get manual corrections count", zap.Error(err))
		manualCorrections = 0
	}

	response := MetricsResponse{
		TotalItems:        totalItems,
		CategoryDist:      categoryDist,
		CategoryPercent:   categoryPercent,
		SubcategoryMap:    subcategoryMap,
		UnmappedSubcats:   unmappedSubcats,
		LastImportAt:      lastImportAt,
		ManualCorrections: manualCorrections,
	}

	resp.Success(w, response)
}


// GetCategoryBreakdown handles GET /api/v1/classification/category/{category}/breakdown
func (h *ClassificationHandler) GetCategoryBreakdown(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	category := vars["category"]

	if category == "" {
		resp.Error(w, http.StatusBadRequest, fmt.Errorf("category is required"))
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	// Get total count for this category
	var totalCount int
	err := h.db.Pool().QueryRow(ctx, `
		SELECT COUNT(*)
		FROM clothing_items
		WHERE category = $1 AND is_active = true
	`, category).Scan(&totalCount)
	if err != nil {
		h.logger.Error("Failed to get category total count",
			zap.Error(err),
			zap.String("category", category))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get category breakdown"))
		return
	}

	// Get subcategory breakdown
	subcategories := []SubcatInfo{}

	rows, err := h.db.Pool().Query(ctx, `
		SELECT subcategory, COUNT(*) as count
		FROM clothing_items
		WHERE category = $1 AND is_active = true
		GROUP BY subcategory
		ORDER BY count DESC
	`, category)
	if err != nil {
		h.logger.Error("Failed to get subcategory breakdown",
			zap.Error(err),
			zap.String("category", category))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to get category breakdown"))
		return
	}
	defer rows.Close()

	for rows.Next() {
		var subcategory string
		var count int
		if err := rows.Scan(&subcategory, &count); err != nil {
			h.logger.Error("Failed to scan subcategory", zap.Error(err))
			continue
		}
		subcategories = append(subcategories, SubcatInfo{
			Subcategory: subcategory,
			Count:       count,
		})
	}

	response := CategoryBreakdownResponse{
		Category:      category,
		TotalCount:    totalCount,
		Subcategories: subcategories,
	}

	resp.Success(w, response)
}


// ExportAuditTrail handles GET /api/v1/classification/audit/export
func (h *ClassificationHandler) ExportAuditTrail(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 30*time.Second)
	defer cancel()

	// Parse date range filters
	fromStr := r.URL.Query().Get("from")
	toStr := r.URL.Query().Get("to")

	var fromDate, toDate *time.Time

	if fromStr != "" {
		parsed, err := time.Parse("2006-01-02", fromStr)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid from date format, use YYYY-MM-DD"))
			return
		}
		fromDate = &parsed
	}

	if toStr != "" {
		parsed, err := time.Parse("2006-01-02", toStr)
		if err != nil {
			resp.Error(w, http.StatusBadRequest, fmt.Errorf("invalid to date format, use YYYY-MM-DD"))
			return
		}
		endOfDay := parsed.Add(24*time.Hour - time.Second)
		toDate = &endOfDay
	}

	// Build query with optional date filters
	query := `
		SELECT
			ca.id,
			ca.item_id,
			ci.name as item_name,
			ca.old_category,
			ca.new_category,
			ca.changed_by,
			ca.changed_at,
			ca.reason,
			ca.confidence
		FROM category_audit ca
		LEFT JOIN clothing_items ci ON ca.item_id = ci.id
		WHERE 1=1
	`
	args := []interface{}{}
	argCount := 1

	if fromDate != nil {
		query += fmt.Sprintf(" AND ca.changed_at >= $%d", argCount)
		args = append(args, fromDate)
		argCount++
	}

	if toDate != nil {
		query += fmt.Sprintf(" AND ca.changed_at <= $%d", argCount)
		args = append(args, toDate)
		argCount++
	}

	query += " ORDER BY ca.changed_at DESC"

	rows, err := h.db.Pool().Query(ctx, query, args...)
	if err != nil {
		h.logger.Error("Failed to query audit trail", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, fmt.Errorf("failed to export audit trail"))
		return
	}
	defer rows.Close()

	// Set CSV headers
	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=audit_trail_%s.csv", time.Now().Format("20060102_150405")))

	csvWriter := csv.NewWriter(w)
	defer csvWriter.Flush()

	// Write CSV header
	if err := csvWriter.Write([]string{
		"audit_id",
		"item_id",
		"item_name",
		"old_category",
		"new_category",
		"changed_by",
		"changed_at",
		"reason",
		"confidence",
	}); err != nil {
		h.logger.Error("Failed to write CSV header", zap.Error(err))
		return
	}

	// Write data rows
	for rows.Next() {
		var auditID, itemID string
		var itemName *string
		var oldCategory, newCategory, changedBy string
		var changedAt time.Time
		var reason *string
		var confidence *float64

		if err := rows.Scan(&auditID, &itemID, &itemName, &oldCategory, &newCategory, &changedBy, &changedAt, &reason, &confidence); err != nil {
			h.logger.Error("Failed to scan audit row", zap.Error(err))
			continue
		}

		itemNameStr := ""
		if itemName != nil {
			itemNameStr = *itemName
		}

		reasonStr := ""
		if reason != nil {
			reasonStr = *reason
		}

		confidenceStr := ""
		if confidence != nil {
			confidenceStr = strconv.FormatFloat(*confidence, 'f', 3, 64)
		}

		if err := csvWriter.Write([]string{
			auditID,
			itemID,
			itemNameStr,
			oldCategory,
			newCategory,
			changedBy,
			changedAt.Format(time.RFC3339),
			reasonStr,
			confidenceStr,
		}); err != nil {
			h.logger.Error("Failed to write CSV row", zap.Error(err))
			continue
		}
	}

	if err := rows.Err(); err != nil {
		h.logger.Error("Error iterating audit rows", zap.Error(err))
	}
}

// RegisterRoutes registers the classification handler routes
func (h *ClassificationHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/metrics", h.GetMetrics).Methods(http.MethodGet)
	r.HandleFunc("/category/{category}/breakdown", h.GetCategoryBreakdown).Methods(http.MethodGet)
	r.HandleFunc("/audit/export", h.ExportAuditTrail).Methods(http.MethodGet)
}
