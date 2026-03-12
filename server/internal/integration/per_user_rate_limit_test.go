//go:build integration

package integration_test

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gorilla/mux"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestPerUserRateLimitEvasion verifies that rate limits are applied per authenticated user.
//
// **Validates: Requirements 2.17**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (no per-user rate limiting)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (per-user limits enforced)
func TestPerUserRateLimitEvasion(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	logger := zap.NewNop()
	db, err := dbpg.NewDB(pool.Config().ConnString(), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	// Setup Redis for rate limiting
	redisClient := redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
		DB:   1, // Use test database
	})
	defer redisClient.Close()

	// Clear Redis before test
	ctx := context.Background()
	redisClient.FlushDB(ctx)

	// Setup rate limit violation repository
	rateLimitRepo := pg.NewRateLimitViolationRepository(db.Pool())
	limiter := middleware.NewRedisRateLimiter(redisClient, rateLimitRepo)

	// Create test user
	userID := insertTestUser(t, pool)

	// Setup router with per-user rate limiting
	// Use very low limits for testing: 10 requests per hour for authenticated users
	config := middleware.PerUserRateLimitConfig{
		AuthenticatedLimit:  10,
		AuthenticatedWindow: time.Hour,
		AnonymousLimit:      5,
		AnonymousWindow:     time.Hour,
		ReadLimit:           20,
		ReadWindow:          time.Hour,
		WriteLimit:          10,
		WriteWindow:         time.Hour,
	}

	router := mux.NewRouter()
	router.Use(middleware.PerUserRateLimitMiddleware(limiter, config))

	// Add a test endpoint that sets user_id in context
	router.HandleFunc("/api/wardrobe", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"items":[]}`))
	}).Methods(http.MethodGet)

	// Make many requests from the same user but different IPs
	successCount := 0
	blockedCount := 0

	t.Log("Sending 50 requests from same user but different IPs...")

	for i := 0; i < 50; i++ {
		req := httptest.NewRequest("GET", "/api/wardrobe", nil)

		// Simulate different IPs to bypass IP-based rate limiting
		ipAddr := fmt.Sprintf("192.168.%d.%d", i/256, i%256)
		req.Header.Set("X-Forwarded-For", ipAddr)
		req.Header.Set("Authorization", "Bearer user-"+userID.String())

		// Set user_id in context (simulating authentication middleware)
		ctx := middleware.WithUserID(req.Context(), userID)
		req = req.WithContext(ctx)

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		if w.Code == http.StatusOK {
			successCount++
		} else if w.Code == http.StatusTooManyRequests {
			blockedCount++
		}

		time.Sleep(5 * time.Millisecond)
	}

	t.Logf("Results: %d successful, %d blocked", successCount, blockedCount)

	// With per-user rate limiting, we should see blocks after the limit (10 requests)
	// Even though IPs are different, the user ID is the same
	if successCount > 15 {
		t.Error("VULNERABILITY CONFIRMED: No per-user rate limiting")
		t.Logf("User made %d requests by changing IPs (expected max ~10)", successCount)
		t.Log("Rate limiting should be based on authenticated user ID, not just IP")
		return
	}

	if blockedCount > 30 {
		t.Logf("SUCCESS: Per-user rate limiting enforced - %d requests blocked", blockedCount)
	} else {
		t.Errorf("Expected more blocks (got %d), per-user rate limiting may not be working correctly", blockedCount)
	}
}
