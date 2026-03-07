//go:build integration

package integration_test

// To run this test:
// 1. Start the test database: docker-compose -f docker-compose.dev.yml up -d postgres
// 2. Set DATABASE_URL: export DATABASE_URL="postgres://postgres@localhost:5433/outfitstyle?sslmode=disable"
// 3. Run the test: cd server && go test -v -tags=integration ./internal/integration -run TestBugCondition_CookieBasedAuthenticationRejection

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestBugCondition_CookieBasedAuthenticationRejection is a bug exploration test
// that demonstrates the authentication bug where valid access_token cookies
// are rejected with 401 Unauthorized.
//
// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6**
//
// CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists.
// DO NOT attempt to fix the test or the code when it fails.
// The test encodes the expected behavior - it will validate the fix when it passes.
//
// EXPECTED OUTCOME: Test FAILS with 401 Unauthorized (this is correct - it proves the bug exists)
func TestBugCondition_CookieBasedAuthenticationRejection(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	// Setup: Create test user and session
	uid := insertTestUser(t, pool)
	sessionID := domain.NewID()

	// Insert a valid session for the user
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	expiresAt := time.Now().Add(24 * time.Hour)
	_, err := pool.Exec(ctx, `
		INSERT INTO sessions (id, user_id, refresh_token_hash, device_info, ip_address, user_agent, expires_at, last_used_at, created_at)
		VALUES ($1, $2, 'test_hash', 'Chrome', '127.0.0.1', 'Mozilla/5.0', $3, NOW(), NOW())
	`, sessionID, uid, expiresAt)
	if err != nil {
		t.Fatalf("insert session: %v", err)
	}

	// Setup: Create token service and generate valid access token
	tokenService, err := services.NewTokenService(services.TokenServiceConfig{
		JWTSecret:  "test-secret-key-minimum-32-chars-long-for-security",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	})
	if err != nil {
		t.Fatalf("create token service: %v", err)
	}

	accessToken, _, err := tokenService.GenerateAccessToken(uid, sessionID)
	if err != nil {
		t.Fatalf("generate access token: %v", err)
	}

	// Setup: Create auth service and middleware
	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	authService := services.NewAuthService(userRepo, sessionRepo, tokenService, nil, nil, logger)

	// Setup: Create test server with auth middleware
	router := mux.NewRouter()
	router.Use(middleware.AuthMiddleware(authService, nil))

	// Register test endpoints
	endpoints := []string{
		"/api/v1/wardrobe",
		"/api/v1/recommendations",
		"/api/v1/notifications",
		"/api/v1/achievements",
	}

	for _, endpoint := range endpoints {
		path := endpoint
		router.HandleFunc(path, func(w http.ResponseWriter, r *http.Request) {
			// Extract userID and sessionID from context to verify authentication
			userID, hasUserID := middleware.GetUserIDFromContext(r.Context())
			sessID, hasSessionID := middleware.GetSessionIDFromContext(r.Context())

			if !hasUserID || !hasSessionID || userID == domain.NilID || sessID == domain.NilID {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}

			w.WriteHeader(http.StatusOK)
			w.Write([]byte(`{"status":"ok"}`))
		}).Methods(http.MethodGet)
	}

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Test: Make requests with valid access_token cookie but no Authorization header
	// This is the bug condition - these requests should succeed but will fail with 401
	for _, endpoint := range endpoints {
		t.Run(endpoint, func(t *testing.T) {
			req, err := http.NewRequest(http.MethodGet, srv.URL+endpoint, nil)
			if err != nil {
				t.Fatalf("create request: %v", err)
			}

			// Set the access_token cookie (simulating web client behavior)
			req.AddCookie(&http.Cookie{
				Name:     "access_token",
				Value:    accessToken,
				HttpOnly: true,
				Secure:   false, // false for testing
				SameSite: http.SameSiteStrictMode,
			})

			// DO NOT set Authorization header - this is the bug condition
			// The middleware should check cookies but currently doesn't

			client := &http.Client{}
			res, err := client.Do(req)
			if err != nil {
				t.Fatalf("execute request: %v", err)
			}
			defer res.Body.Close()

			// EXPECTED BEHAVIOR (after fix): 200 OK with proper authentication
			// ACTUAL BEHAVIOR (before fix): 401 Unauthorized
			//
			// This assertion will FAIL on unfixed code, confirming the bug exists
			if res.StatusCode != http.StatusOK {
				t.Logf("COUNTEREXAMPLE FOUND: %s with valid access_token cookie returns %d instead of 200", endpoint, res.StatusCode)
				t.Logf("Bug confirmed: Middleware does not check cookies for authentication")
				t.Errorf("Expected status 200 OK, got %d - this confirms the bug exists", res.StatusCode)
			}
		})
	}
}
