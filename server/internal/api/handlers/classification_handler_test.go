package handlers

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gorilla/mux"
	"github.com/stretchr/testify/assert"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/persistence/postgres"
)

func TestClassificationHandler_GetMetrics(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewClassificationHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/classification/metrics", nil)
	w := httptest.NewRecorder()

	handler.GetMetrics(w, req)

	assert.Equal(t, http.StatusOK, w.Code, "Expected status 200 OK")
}

func TestClassificationHandler_GetCategoryBreakdown(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewClassificationHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/classification/category/upper/breakdown", nil)
	w := httptest.NewRecorder()

	// Set up mux vars
	req = mux.SetURLVars(req, map[string]string{"category": "upper"})

	handler.GetCategoryBreakdown(w, req)

	assert.Equal(t, http.StatusOK, w.Code, "Expected status 200 OK")
}

func TestClassificationHandler_GetCategoryBreakdown_MissingCategory(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewClassificationHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/classification/category//breakdown", nil)
	w := httptest.NewRecorder()

	// Set up mux vars with empty category
	req = mux.SetURLVars(req, map[string]string{"category": ""})

	handler.GetCategoryBreakdown(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code, "Expected status 400 Bad Request")
}

func TestClassificationHandler_ExportAuditTrail(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewClassificationHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/classification/audit/export", nil)
	w := httptest.NewRecorder()

	handler.ExportAuditTrail(w, req)

	assert.Equal(t, http.StatusOK, w.Code, "Expected status 200 OK")
	assert.Contains(t, w.Header().Get("Content-Type"), "text/csv", "Expected CSV content type")
}

func TestClassificationHandler_ExportAuditTrail_WithDateFilters(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewClassificationHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/classification/audit/export?from=2024-01-01&to=2024-12-31", nil)
	w := httptest.NewRecorder()

	handler.ExportAuditTrail(w, req)

	assert.Equal(t, http.StatusOK, w.Code, "Expected status 200 OK")
	assert.Contains(t, w.Header().Get("Content-Type"), "text/csv", "Expected CSV content type")
}

func TestClassificationHandler_ExportAuditTrail_InvalidDateFormat(t *testing.T) {
	// Skip if no database connection available
	db := postgres.GetDB()
	if db == nil {
		t.Skip("Database not available, skipping integration test")
	}

	logger := zap.NewNop()
	handler := NewClassificationHandler(db, logger)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/classification/audit/export?from=invalid-date", nil)
	w := httptest.NewRecorder()

	handler.ExportAuditTrail(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code, "Expected status 400 Bad Request for invalid date format")
}
