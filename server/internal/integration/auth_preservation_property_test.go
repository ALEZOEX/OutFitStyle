//go:build integration

package integration_test

// Preservation Property Tests for Web Client Cookie Authentication Bugfix
//
// These tests verify that existing authentication methods (Bearer token, API key)
// continue to work exactly as before implementing the cookie authentication fix.
//
// **Property 2: Preservation - Header-Based Authentication Unchanged**
//
// The tests use property-based testing (testing/quick) to generate multiple test cases
// and verify that authentication behavior is preserved across all inputs that do NOT
// involve cookie-based authentication.
//
// IMPORTANT: These tests MUST PASS on UNFIXED code to establish the baseline behavior
// that must be preserved when implementing the cookie authentication fix.
//
// Test Coverage:
// - Bearer token authentication (Requirement 3.1)
// - API key authentication (Requirement 3.2)
// - No credentials rejection (Requirement 3.3)
// - Invalid credentials rejection (Requirement 3.4)
//
// To run this test:
// 1. Start the test database: docker-compose -f docker-compose.dev.yml up -d postgres
// 2. Set DATABASE_URL: export DATABASE_URL="postgres://postgres@localhost:5433/outfitstyle?sslmode=disable"
// 3. Run the test: cd server && go test -v -tags=integration ./internal/integration -run TestPreservation

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"testing/quick"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestPreservation_BearerTokenAuthentication tests that Bearer token authentication
// continues to work exactly as before the fix.
//
// **Validates: Requirements 3.1**
//
// Property 2: Preservation - Header-Based Authentication Unchanged
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPreservation_BearerTokenAuthentication(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	// Setup: Create test infrastructure
	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	tokenService, err := services.NewTokenService(services.TokenServiceConfig{
		JWTSecret:  "test-secret-key-minimum-32-chars-long-for-security",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	})
	if err != nil {
		t.Fatalf("create token service: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	authService := services.NewAuthService(userRepo, sessionRepo, tokenService, nil, nil, logger)

	// Setup: Create test server with auth middleware
	router := mux.NewRouter()
	router.Use(middleware.AuthMiddleware(authService, nil))
	router.HandleFunc("/api/v1/test", func(w http.ResponseWriter, r *http.Request) {
		userID, hasUserID := middleware.GetUserIDFromContext(r.Context())
		sessID, hasSessionID := middleware.GetSessionIDFromContext(r.Context())

		if !hasUserID || !hasSessionID || userID == domain.NilID || sessID == domain.NilID {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	}).Methods(http.MethodGet)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Property: For all requests with valid Bearer token, authentication succeeds
	property := func() bool {
		// Generate a valid user and session
		uid := insertTestUser(t, pool)
		sessionID := domain.NewID()

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		expiresAt := time.Now().Add(24 * time.Hour)
		_, err := pool.Exec(ctx, `
			INSERT INTO sessions (id, user_id, refresh_token_hash, device_info, ip_address, user_agent, expires_at, last_used_at, created_at, updated_at)
			VALUES ($1, $2, 'test_hash', 'web/Chrome', '127.0.0.1', 'Mozilla/5.0', $3, NOW(), NOW(), NOW())
		`, sessionID, uid, expiresAt)
		if err != nil {
			t.Logf("insert session failed: %v", err)
			return false
		}

		// Generate valid access token
		accessToken, _, err := tokenService.GenerateAccessToken(uid, sessionID)
		if err != nil {
			t.Logf("generate token failed: %v", err)
			return false
		}

		// Make request with Bearer token
		req, err := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/test", nil)
		if err != nil {
			t.Logf("create request failed: %v", err)
			return false
		}

		req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", accessToken))

		client := &http.Client{}
		res, err := client.Do(req)
		if err != nil {
			t.Logf("execute request failed: %v", err)
			return false
		}
		defer res.Body.Close()

		// Property holds: Bearer token authentication succeeds
		return res.StatusCode == http.StatusOK
	}

	// Run property-based test with multiple iterations
	config := &quick.Config{MaxCount: 10}
	if err := quick.Check(property, config); err != nil {
		t.Errorf("Property violated: Bearer token authentication failed: %v", err)
	}
}

// TestPreservation_APIKeyAuthentication tests that API key authentication
// continues to work exactly as before the fix.
//
// **Validates: Requirements 3.2**
//
// Property 2: Preservation - Header-Based Authentication Unchanged
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPreservation_APIKeyAuthentication(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	// Setup: Create test infrastructure
	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	tokenService, err := services.NewTokenService(services.TokenServiceConfig{
		JWTSecret:  "test-secret-key-minimum-32-chars-long-for-security",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	})
	if err != nil {
		t.Fatalf("create token service: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	authService := services.NewAuthService(userRepo, sessionRepo, tokenService, nil, nil, logger)

	apiKeyRepo := pg.NewAPIKeyRepository(db.Pool())
	apiKeyService := services.NewAPIKeyService(apiKeyRepo, "test-pepper")

	// Setup: Create test integration client with unique slug
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	clientID := domain.NewID()
	clientSlug := "test-client-" + clientID.String()
	_, err = pool.Exec(ctx, `
		INSERT INTO integration_clients (id, slug, name, is_active, rate_limit_per_minute, rate_limit_per_day, created_at, updated_at)
		VALUES ($1, $2, 'Test Client', true, 100, 10000, NOW(), NOW())
	`, clientID, clientSlug)
	if err != nil {
		t.Fatalf("insert integration client: %v", err)
	}

	// Create API key using the service to ensure proper format and hashing
	keyName := "Test Key"
	createReq := domain.APIKeyCreateRequest{
		Name:        &keyName,
		Description: nil,
		Permissions: []string{"read", "write"},
	}

	apiKeyResp, err := apiKeyService.Create(ctx, clientID, createReq)
	if err != nil {
		t.Fatalf("create api key: %v", err)
	}

	apiKey := apiKeyResp.Token // This is the actual token to use in requests

	// Setup: Create test server with auth middleware
	router := mux.NewRouter()
	router.Use(middleware.AuthMiddleware(authService, apiKeyService))
	router.HandleFunc("/api/v1/test", func(w http.ResponseWriter, r *http.Request) {
		clientID, hasClientID := middleware.GetClientIDFromContext(r.Context())
		apiKeyID, hasAPIKeyID := middleware.GetAPIKeyIDFromContext(r.Context())

		if !hasClientID || !hasAPIKeyID || clientID == domain.NilID || apiKeyID == domain.NilID {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	}).Methods(http.MethodGet)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Property: For all requests with valid API key, authentication succeeds
	property := func() bool {
		req, err := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/test", nil)
		if err != nil {
			t.Logf("create request failed: %v", err)
			return false
		}

		req.Header.Set("X-API-Key", apiKey)

		client := &http.Client{}
		res, err := client.Do(req)
		if err != nil {
			t.Logf("execute request failed: %v", err)
			return false
		}
		defer res.Body.Close()

		// Property holds: API key authentication succeeds
		return res.StatusCode == http.StatusOK
	}

	// Run property-based test with multiple iterations
	config := &quick.Config{MaxCount: 10}
	if err := quick.Check(property, config); err != nil {
		t.Errorf("Property violated: API key authentication failed: %v", err)
	}
}

// TestPreservation_NoCredentials tests that requests with no credentials
// continue to return 401 Unauthorized.
//
// **Validates: Requirements 3.3**
//
// Property 2: Preservation - Header-Based Authentication Unchanged
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPreservation_NoCredentials(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	// Setup: Create test infrastructure
	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	tokenService, err := services.NewTokenService(services.TokenServiceConfig{
		JWTSecret:  "test-secret-key-minimum-32-chars-long-for-security",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	})
	if err != nil {
		t.Fatalf("create token service: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	authService := services.NewAuthService(userRepo, sessionRepo, tokenService, nil, nil, logger)

	// Setup: Create test server with auth middleware
	router := mux.NewRouter()
	router.Use(middleware.AuthMiddleware(authService, nil))
	router.HandleFunc("/api/v1/test", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	}).Methods(http.MethodGet)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Property: For all requests with no credentials, authentication fails with 401
	property := func() bool {
		req, err := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/test", nil)
		if err != nil {
			t.Logf("create request failed: %v", err)
			return false
		}

		// No Authorization header, no X-API-Key header, no cookies

		client := &http.Client{}
		res, err := client.Do(req)
		if err != nil {
			t.Logf("execute request failed: %v", err)
			return false
		}
		defer res.Body.Close()

		// Property holds: No credentials returns 401
		return res.StatusCode == http.StatusUnauthorized
	}

	// Run property-based test with multiple iterations
	config := &quick.Config{MaxCount: 10}
	if err := quick.Check(property, config); err != nil {
		t.Errorf("Property violated: No credentials should return 401: %v", err)
	}
}

// TestPreservation_InvalidCredentials tests that requests with invalid or expired
// credentials continue to return 401 Unauthorized.
//
// **Validates: Requirements 3.4**
//
// Property 2: Preservation - Header-Based Authentication Unchanged
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPreservation_InvalidCredentials(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	// Setup: Create test infrastructure
	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	tokenService, err := services.NewTokenService(services.TokenServiceConfig{
		JWTSecret:  "test-secret-key-minimum-32-chars-long-for-security",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	})
	if err != nil {
		t.Fatalf("create token service: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	authService := services.NewAuthService(userRepo, sessionRepo, tokenService, nil, nil, logger)

	// Setup: Create test server with auth middleware
	router := mux.NewRouter()
	router.Use(middleware.AuthMiddleware(authService, nil))
	router.HandleFunc("/api/v1/test", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	}).Methods(http.MethodGet)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Test invalid Bearer tokens
	t.Run("InvalidBearerToken", func(t *testing.T) {
		property := func() bool {
			req, err := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/test", nil)
			if err != nil {
				t.Logf("create request failed: %v", err)
				return false
			}

			// Set invalid Bearer token
			req.Header.Set("Authorization", "Bearer invalid-token-12345")

			client := &http.Client{}
			res, err := client.Do(req)
			if err != nil {
				t.Logf("execute request failed: %v", err)
				return false
			}
			defer res.Body.Close()

			// Property holds: Invalid token returns 401
			return res.StatusCode == http.StatusUnauthorized
		}

		config := &quick.Config{MaxCount: 10}
		if err := quick.Check(property, config); err != nil {
			t.Errorf("Property violated: Invalid Bearer token should return 401: %v", err)
		}
	})

	// Test invalid API keys
	t.Run("InvalidAPIKey", func(t *testing.T) {
		property := func() bool {
			req, err := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/test", nil)
			if err != nil {
				t.Logf("create request failed: %v", err)
				return false
			}

			// Set invalid API key
			req.Header.Set("X-API-Key", "invalid-api-key-12345")

			client := &http.Client{}
			res, err := client.Do(req)
			if err != nil {
				t.Logf("execute request failed: %v", err)
				return false
			}
			defer res.Body.Close()

			// Property holds: Invalid API key returns 401
			return res.StatusCode == http.StatusUnauthorized
		}

		config := &quick.Config{MaxCount: 10}
		if err := quick.Check(property, config); err != nil {
			t.Errorf("Property violated: Invalid API key should return 401: %v", err)
		}
	})
}
