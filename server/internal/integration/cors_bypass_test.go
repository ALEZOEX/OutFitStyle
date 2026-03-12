//go:build integration

package integration_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
)

// TestCORSBypass verifies that the CORS middleware properly restricts
// cross-origin requests with credentials to allowed origins only.
//
// **Validates: Requirements 2.2**
//
// This test verifies that wildcard origin with credentials is not allowed,
// preventing CSRF attacks from arbitrary origins.
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (evil.com request succeeds)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (evil.com request blocked)
func TestCORSBypass(t *testing.T) {
	logger := zap.NewNop()

	// Create a test router with CORS middleware
	gin.SetMode(gin.TestMode)
	router := gin.New()

	// Apply CORS middleware (this should be the actual middleware from the app)
	router.Use(middleware.CORS())

	// Add a test endpoint that requires authentication
	router.GET("/api/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "success"})
	})

	// Test 1: Request from evil origin with credentials
	req := httptest.NewRequest("GET", "/api/test", nil)
	req.Header.Set("Origin", "http://evil.com")
	req.Header.Set("Cookie", "session=test-session-token")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Check CORS headers
	allowOrigin := w.Header().Get("Access-Control-Allow-Origin")
	allowCredentials := w.Header().Get("Access-Control-Allow-Credentials")

	logger.Info("CORS response",
		zap.String("origin", "http://evil.com"),
		zap.String("allow_origin", allowOrigin),
		zap.String("allow_credentials", allowCredentials),
		zap.Int("status", w.Code))

	// SECURITY CHECK: Evil origin should NOT be allowed with credentials
	if allowOrigin == "*" && allowCredentials == "true" {
		t.Error("VULNERABILITY CONFIRMED: Wildcard origin allowed with credentials - CSRF attack possible")
		t.Logf("This allows any origin to make authenticated requests, enabling CSRF attacks")
		return
	}

	if allowOrigin == "http://evil.com" && allowCredentials == "true" {
		t.Error("VULNERABILITY CONFIRMED: Evil origin allowed with credentials")
		t.Logf("Unauthorized origin should not be in allowed list")
		return
	}

	// If we reach here, the vulnerability is fixed
	t.Log("SUCCESS: CORS properly restricts evil origin with credentials")

	// Test 2: Verify allowed origins still work
	req2 := httptest.NewRequest("GET", "/api/test", nil)
	req2.Header.Set("Origin", "https://outfitstyle.com")
	req2.Header.Set("Cookie", "session=test-session-token")

	w2 := httptest.NewRecorder()
	router.ServeHTTP(w2, req2)

	allowOrigin2 := w2.Header().Get("Access-Control-Allow-Origin")
	allowCredentials2 := w2.Header().Get("Access-Control-Allow-Credentials")

	if allowOrigin2 != "https://outfitstyle.com" || allowCredentials2 != "true" {
		t.Error("REGRESSION: Allowed origin no longer works properly")
	}
}
