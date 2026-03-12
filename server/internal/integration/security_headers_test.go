//go:build integration

package integration_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"

	"outfitstyle/server/internal/api/middleware"
)

// TestMissingSecurityHeaders verifies that security headers are present in responses.
//
// **Validates: Requirements 2.11, 2.12, 2.13**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (headers missing)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (headers present)
func TestMissingSecurityHeaders(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()

	// Apply security headers middleware
	router.Use(middleware.SecurityHeaders())

	router.GET("/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "test"})
	})

	req := httptest.NewRequest("GET", "/test", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Check for required security headers
	requiredHeaders := map[string]string{
		"X-Permitted-Cross-Domain-Policies": "none",
		"Referrer-Policy":                   "strict-origin-when-cross-origin",
		"X-Content-Type-Options":            "nosniff",
		"X-Frame-Options":                   "DENY",
	}

	missingHeaders := []string{}

	for header, expectedValue := range requiredHeaders {
		actualValue := w.Header().Get(header)
		if actualValue == "" {
			missingHeaders = append(missingHeaders, header)
			t.Errorf("VULNERABILITY: Missing security header: %s", header)
		} else if actualValue != expectedValue {
			t.Logf("Header %s present but value differs: got %s, expected %s", header, actualValue, expectedValue)
		} else {
			t.Logf("SUCCESS: Header %s correctly set to %s", header, actualValue)
		}
	}

	if len(missingHeaders) > 0 {
		t.Error("VULNERABILITY CONFIRMED: Security headers missing")
		t.Logf("Missing headers: %v", missingHeaders)
		t.Log("This reduces defense-in-depth against various attacks")
		return
	}

	t.Log("SUCCESS: All required security headers present")
}

// TestHTTPSEnforcement verifies that HTTP requests are redirected to HTTPS.
//
// **Validates: Requirements 2.13**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (no HTTPS redirect)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (HTTP redirected to HTTPS)
func TestHTTPSEnforcement(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()

	// Apply HTTPS redirect middleware
	router.Use(middleware.HTTPSRedirect())

	router.GET("/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "test"})
	})

	// Simulate HTTP request
	req := httptest.NewRequest("GET", "http://example.com/test", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Check for HSTS header
	hstsHeader := w.Header().Get("Strict-Transport-Security")
	if hstsHeader == "" {
		t.Error("VULNERABILITY: Missing HSTS header")
		t.Log("Browsers won't enforce HTTPS-only connections")
	} else {
		t.Logf("HSTS header present: %s", hstsHeader)

		// Check if HSTS has reasonable max-age
		if len(hstsHeader) < 20 {
			t.Error("WARNING: HSTS header may not have sufficient max-age")
		}
	}

	// Check for redirect
	if w.Code == http.StatusMovedPermanently || w.Code == http.StatusPermanentRedirect {
		location := w.Header().Get("Location")
		t.Logf("SUCCESS: HTTP redirected to: %s", location)
	} else if w.Code == http.StatusOK {
		t.Error("VULNERABILITY: HTTP request not redirected to HTTPS")
	}
}
