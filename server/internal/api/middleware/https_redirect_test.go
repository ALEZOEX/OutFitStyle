package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHTTPSRedirectMiddleware_Development(t *testing.T) {
	// In development, HTTP should be allowed
	middleware := HTTPSRedirectMiddleware("development")

	handler := middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}))

	req := httptest.NewRequest("GET", "http://example.com/test", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rec.Code)
	}
	if rec.Body.String() != "OK" {
		t.Errorf("Expected body 'OK', got '%s'", rec.Body.String())
	}
}

func TestHTTPSRedirectMiddleware_Production_HTTP(t *testing.T) {
	// In production, HTTP should redirect to HTTPS
	middleware := HTTPSRedirectMiddleware("production")

	handler := middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}))

	req := httptest.NewRequest("GET", "http://example.com/test?foo=bar", nil)
	req.Host = "example.com"
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusMovedPermanently {
		t.Errorf("Expected status 301, got %d", rec.Code)
	}

	location := rec.Header().Get("Location")
	expected := "https://example.com/test?foo=bar"
	if location != expected {
		t.Errorf("Expected Location '%s', got '%s'", expected, location)
	}
}

func TestHTTPSRedirectMiddleware_Production_HTTPS(t *testing.T) {
	// In production, HTTPS should pass through
	middleware := HTTPSRedirectMiddleware("production")

	handler := middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}))

	req := httptest.NewRequest("GET", "https://example.com/test", nil)
	req.Header.Set("X-Forwarded-Proto", "https")
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rec.Code)
	}
	if rec.Body.String() != "OK" {
		t.Errorf("Expected body 'OK', got '%s'", rec.Body.String())
	}
}

func TestHTTPSRedirectMiddleware_XForwardedProto(t *testing.T) {
	// Test X-Forwarded-Proto header (common with reverse proxies)
	middleware := HTTPSRedirectMiddleware("production")

	handler := middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}))

	// HTTP via X-Forwarded-Proto should redirect
	req := httptest.NewRequest("GET", "http://example.com/test", nil)
	req.Host = "example.com"
	req.Header.Set("X-Forwarded-Proto", "http")
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusMovedPermanently {
		t.Errorf("Expected status 301, got %d", rec.Code)
	}
}

func TestHTTPSRedirectMiddleware_Local(t *testing.T) {
	// In local environment, HTTP should be allowed
	middleware := HTTPSRedirectMiddleware("local")

	handler := middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}))

	req := httptest.NewRequest("GET", "http://localhost:8080/test", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rec.Code)
	}
}
