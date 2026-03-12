//go:build integration

package integration_test

import (
	"bytes"
	"context"
	"encoding/json"
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

// TestInputSanitizationGap verifies that input sanitization is consistently applied.
//
// **Validates: Requirements 2.18**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (inconsistent sanitization)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (consistent sanitization)
func TestInputSanitizationGap(t *testing.T) {
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

	// Setup router
	gin.SetMode(gin.TestMode)
	router := gin.New()

	authHandler := handlers.NewAuthHandler(authService, logger)
	router.POST("/api/auth/register", authHandler.Register)

	// Test HTML injection in name field
	maliciousInputs := []struct {
		field string
		value string
		desc  string
	}{
		{"name", "<script>alert('XSS')</script>", "HTML script tag"},
		{"name", "<img src=x onerror=alert('XSS')>", "HTML img tag with onerror"},
		{"name", "'; DROP TABLE users--", "SQL injection attempt"},
		{"name", "../../../etc/passwd", "Path traversal"},
		{"email", "test@example.com<script>alert(1)</script>", "HTML in email"},
	}

	vulnerabilityFound := false

	for _, tc := range maliciousInputs {
		reqBody := map[string]string{
			"email":    "test-" + tc.desc + "@example.com",
			"password": "TestPassword123!",
			"name":     tc.value,
		}

		if tc.field == "email" {
			reqBody["email"] = tc.value
		}

		bodyBytes, _ := json.Marshal(reqBody)
		req := httptest.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(bodyBytes))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		responseBody := w.Body.String()

		// Check if malicious input is reflected unsanitized in response
		if strings.Contains(responseBody, "<script>") ||
		   strings.Contains(responseBody, "onerror=") ||
		   strings.Contains(responseBody, "DROP TABLE") {
			t.Errorf("VULNERABILITY: Unsanitized input in response for %s: %s", tc.desc, tc.value)
			vulnerabilityFound = true
		}

		// If registration succeeded, check database
		if w.Code == http.StatusOK || w.Code == http.StatusCreated {
			var storedName string
			err := pool.QueryRow(ctx, "SELECT name FROM users WHERE email = $1", reqBody["email"]).Scan(&storedName)
			if err == nil {
				if strings.Contains(storedName, "<script>") || strings.Contains(storedName, "onerror=") {
					t.Errorf("VULNERABILITY: Unsanitized input stored in database: %s", storedName)
					vulnerabilityFound = true
				} else {
					t.Logf("SUCCESS: Input sanitized before storage: %s -> %s", tc.value, storedName)
				}

				// Clean up
				_, _ = pool.Exec(ctx, "DELETE FROM users WHERE email = $1", reqBody["email"])
			}
		}
	}

	if vulnerabilityFound {
		t.Error("VULNERABILITY CONFIRMED: Inconsistent input sanitization")
		t.Log("Some endpoints don't properly sanitize user input")
		t.Log("Expected: HTML escaping, SQL parameterization, path validation")
		return
	}

	t.Log("SUCCESS: Input sanitization appears consistent")
}
