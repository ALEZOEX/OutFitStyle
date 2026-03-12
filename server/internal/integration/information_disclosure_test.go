//go:build integration

package integration_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/core/application/services"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestInformationDisclosure verifies that error messages don't expose internal details.
//
// **Validates: Requirements 2.11**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (internal details exposed)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (generic error messages)
func TestInformationDisclosure(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	logger := zap.NewNop()
	db, err := dbpg.NewDB(pool.Config().ConnString(), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	userRepo := pg.NewUserRepository(db.Pool())
	authService := services.NewAuthService(userRepo, logger)

	// Create a test user
	testEmail := "existing@example.com"
	err = authService.Register(ctx, testEmail, "TestPassword123!", "Test User")
	if err != nil {
		t.Fatalf("Failed to create test user: %v", err)
	}

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()

	authHandler := handlers.NewAuthHandler(authService, logger)
	router.POST("/api/auth/register", authHandler.Register)

	// Try to register with duplicate email (should trigger database error)
	reqBody := `{"email":"` + testEmail + `","password":"AnotherPass123!","name":"Another User"}`
	req := httptest.NewRequest("POST", "/api/auth/register", strings.NewReader(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	responseBody := w.Body.String()
	t.Logf("Response status: %d", w.Code)
	t.Logf("Response body: %s", responseBody)

	// Check for information disclosure
	sensitivePatterns := []string{
		"pq:",                    // PostgreSQL error prefix
		"duplicate key",          // Database constraint error
		"violates",              // Database constraint violation
		"constraint",            // Database constraint
		"users_email_key",       // Table/constraint names
		"stack trace",           // Stack traces
		"panic",                 // Panic messages
		"internal/",             // Internal package paths
		"outfitstyle/server/",   // Application paths
	}

	vulnerabilityFound := false
	exposedInfo := []string{}

	for _, pattern := range sensitivePatterns {
		if strings.Contains(strings.ToLower(responseBody), strings.ToLower(pattern)) {
			vulnerabilityFound = true
			exposedInfo = append(exposedInfo, pattern)
		}
	}

	if vulnerabilityFound {
		t.Error("VULNERABILITY CONFIRMED: Error response exposes internal details")
		t.Logf("Exposed information patterns: %v", exposedInfo)
		t.Log("Database errors, stack traces, or internal paths should not be visible to clients")
		t.Log("Expected: Generic error message like 'Registration failed' or 'Email already in use'")
		return
	}

	t.Log("SUCCESS: Error message does not expose internal details")
	t.Log("Response contains generic, user-friendly error message")
}
