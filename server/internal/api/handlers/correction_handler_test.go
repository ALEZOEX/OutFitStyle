package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gorilla/mux"
	"github.com/stretchr/testify/assert"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/persistence/postgres"
)

func TestCorrectionHandler_ListClothingItems(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewCorrectionHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/clothing-items", nil)
	w := httptest.NewRecorder()

	handler.ListClothingItems(w, req)

	assert.Equal(t, http.StatusOK, w.Code, "Expected status 200 OK")
}

func TestCorrectionHandler_ListClothingItems_WithFilters(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewCorrectionHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/clothing-items?category=upper&page=1&limit=10", nil)
	w := httptest.NewRecorder()

	handler.ListClothingItems(w, req)

	assert.Equal(t, http.StatusOK, w.Code, "Expected status 200 OK")
}

func TestCorrectionHandler_UpdateItemCategory_InvalidCategory(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewCorrectionHandler(db, logger)

	reqBody := UpdateCategoryRequest{
		Category: "invalid_category",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPatch, "/api/v1/clothing-items/550e8400-e29b-41d4-a716-446655440000/category", bytes.NewReader(body))
	w := httptest.NewRecorder()

	// Set up mux vars
	req = mux.SetURLVars(req, map[string]string{"id": "550e8400-e29b-41d4-a716-446655440000"})

	handler.UpdateItemCategory(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code, "Expected status 400 Bad Request for invalid category")
}

func TestCorrectionHandler_UpdateItemCategory_InvalidItemID(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewCorrectionHandler(db, logger)

	reqBody := UpdateCategoryRequest{
		Category: "upper",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPatch, "/api/v1/clothing-items/invalid-id/category", bytes.NewReader(body))
	w := httptest.NewRecorder()

	// Set up mux vars with invalid ID
	req = mux.SetURLVars(req, map[string]string{"id": "invalid-id"})

	handler.UpdateItemCategory(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code, "Expected status 400 Bad Request for invalid item ID")
}

func TestCorrectionHandler_BulkUpdateCategories_EmptyItemIDs(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewCorrectionHandler(db, logger)

	reqBody := BulkUpdateRequest{
		ItemIDs:  []string{},
		Category: "upper",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/clothing-items/bulk-update", bytes.NewReader(body))
	w := httptest.NewRecorder()

	handler.BulkUpdateCategories(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code, "Expected status 400 Bad Request for empty item IDs")
}

func TestCorrectionHandler_BulkUpdateCategories_InvalidCategory(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewCorrectionHandler(db, logger)

	reqBody := BulkUpdateRequest{
		ItemIDs:  []string{"550e8400-e29b-41d4-a716-446655440000"},
		Category: "invalid_category",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/clothing-items/bulk-update", bytes.NewReader(body))
	w := httptest.NewRecorder()

	handler.BulkUpdateCategories(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code, "Expected status 400 Bad Request for invalid category")
}
