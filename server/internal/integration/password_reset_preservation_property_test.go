//go:build integration

package integration_test

// Preservation Property Tests for Password Reset Code Validation Bugfix
//
// These tests verify that existing password reset flow behaviors continue to work
// exactly as before implementing the code verification fix.
//
// **Property 2: Preservation - Existing Password Reset Flow Behavior**
//
// The tests use property-based testing (testing/quick) to generate multiple test cases
// and verify that password reset behavior is preserved across all inputs that do NOT
// involve the code verification step.
//
// IMPORTANT: These tests MUST PASS on UNFIXED code to establish the baseline behavior
// that must be preserved when implementing the code verification fix.
//
// Test Coverage:
// - Email submission with valid email sends code and returns success (Requirement 3.1)
// - Final password reset with valid code updates password successfully (Requirement 3.2)
// - Rate limiting enforces 5 attempts per 15 minutes on final reset (Requirement 3.4)
//
// To run this test:
// 1. Start the test database: docker-compose -f docker-compose.dev.yml up -d postgres redis
// 2. Set DATABASE_URL: export DATABASE_URL="postgres://postgres@localhost:5433/outfitstyle?sslmode=disable"
// 3. Set REDIS_URL: export REDIS_URL="redis://localhost:6380"
// 4. Run the test: cd server && go test -v -tags=integration ./internal/integration -run TestPasswordResetPreservation

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"testing/quick"
	"time"

	"github.com/gorilla/mux"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)
// TestPasswordResetPreservation_EmailSubmission tests that email submission
// with valid email sends code and returns success.
//
// **Validates: Requirements 3.1**
//
// Property 2: Preservation - Existing Password Reset Flow Behavior
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPasswordResetPreservation_EmailSubmission(t *testing.T) {
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

	// Setup Redis
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6380"
	}
	opts, err := redis.ParseURL(redisURL)
	if err != nil {
		t.Fatalf("parse redis url: %v", err)
	}
	redisClient := redis.NewClient(opts)
	defer redisClient.Close()

	// Test Redis connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := redisClient.Ping(ctx).Err(); err != nil {
		t.Skipf("Redis not available: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	authHandler := handlers.NewAuthHandler(
		nil,           // auth service (not needed for password reset)
		nil,           // lockout service (not needed for password reset)
		0,             // lockout duration
		redisClient,   // redis client
		userRepo,      // user repository
		nil,           // smtp service (not needed for test)
		logger,        // logger
		false,         // cookie secure
	)

	// Setup: Create test server
	router := mux.NewRouter()
	router.HandleFunc("/api/v1/auth/forgot-password", authHandler.ForgotPassword).Methods(http.MethodPost)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Property: For all requests with valid email, forgot password returns success
	property := func() bool {
		// Generate a valid user
		uid := insertTestUser(t, pool)

		// Get user email
		var email string
		err := pool.QueryRow(context.Background(), "SELECT email FROM users WHERE id = $1", uid).Scan(&email)
		if err != nil {
			t.Logf("get user email failed: %v", err)
			return false
		}

		// Make forgot password request
		reqBody := map[string]string{"email": email}
		body, _ := json.Marshal(reqBody)

		req, err := http.NewRequest(http.MethodPost, srv.URL+"/api/v1/auth/forgot-password", bytes.NewReader(body))
		if err != nil {
			t.Logf("create request failed: %v", err)
			return false
		}
		req.Header.Set("Content-Type", "application/json")

		client := &http.Client{}
		res, err := client.Do(req)
		if err != nil {
			t.Logf("execute request failed: %v", err)
			return false
		}
		defer res.Body.Close()

		// Property holds: Email submission returns success (200 OK)
		if res.StatusCode != http.StatusOK {
			t.Logf("expected 200, got %d", res.StatusCode)
			return false
		}

		// Verify code was stored in Redis
		codeKey := fmt.Sprintf("password_reset:%s", email)
		code, err := redisClient.Get(context.Background(), codeKey).Result()
		if err != nil {
			t.Logf("code not stored in redis: %v", err)
			return false
		}

		// Verify code is 6 digits
		if len(code) != 6 {
			t.Logf("code length is not 6: %s", code)
			return false
		}

		// Clean up Redis
		redisClient.Del(context.Background(), codeKey)
		redisClient.Del(context.Background(), fmt.Sprintf("forgot_password_rate:%s", email))

		return true
	}

	// Run property-based test with multiple iterations
	config := &quick.Config{MaxCount: 5}
	if err := quick.Check(property, config); err != nil {
		t.Errorf("Property violated: Email submission failed: %v", err)
	}
}

// TestPasswordResetPreservation_FinalPasswordReset tests that final password reset
// with valid code updates password successfully.
//
// **Validates: Requirements 3.2**
//
// Property 2: Preservation - Existing Password Reset Flow Behavior
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPasswordResetPreservation_FinalPasswordReset(t *testing.T) {
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

	// Setup Redis
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6380"
	}
	opts, err := redis.ParseURL(redisURL)
	if err != nil {
		t.Fatalf("parse redis url: %v", err)
	}
	redisClient := redis.NewClient(opts)
	defer redisClient.Close()

	// Test Redis connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := redisClient.Ping(ctx).Err(); err != nil {
		t.Skipf("Redis not available: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	authHandler := handlers.NewAuthHandler(
		nil,           // auth service (not needed for password reset)
		nil,           // lockout service (not needed for password reset)
		0,             // lockout duration
		redisClient,   // redis client
		userRepo,      // user repository
		nil,           // smtp service (not needed for test)
		logger,        // logger
		false,         // cookie secure
	)

	// Setup: Create test server
	router := mux.NewRouter()
	router.HandleFunc("/api/v1/auth/reset-password", authHandler.ResetPassword).Methods(http.MethodPost)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Property: For all requests with valid code, password reset succeeds
	property := func() bool {
		// Generate a valid user
		uid := insertTestUser(t, pool)

		// Get user email
		var email string
		err := pool.QueryRow(context.Background(), "SELECT email FROM users WHERE id = $1", uid).Scan(&email)
		if err != nil {
			t.Logf("get user email failed: %v", err)
			return false
		}

		// Store a valid code in Redis
		code := "123456"
		codeKey := fmt.Sprintf("password_reset:%s", email)
		if err := redisClient.Set(context.Background(), codeKey, code, 15*time.Minute).Err(); err != nil {
			t.Logf("store code in redis failed: %v", err)
			return false
		}

		// Make reset password request
		reqBody := map[string]string{
			"email":        email,
			"code":         code,
			"new_password": "NewPassword123!",
		}
		body, _ := json.Marshal(reqBody)

		req, err := http.NewRequest(http.MethodPost, srv.URL+"/api/v1/auth/reset-password", bytes.NewReader(body))
		if err != nil {
			t.Logf("create request failed: %v", err)
			return false
		}
		req.Header.Set("Content-Type", "application/json")

		client := &http.Client{}
		res, err := client.Do(req)
		if err != nil {
			t.Logf("execute request failed: %v", err)
			return false
		}
		defer res.Body.Close()

		// Property holds: Password reset returns success (200 OK)
		if res.StatusCode != http.StatusOK {
			t.Logf("expected 200, got %d", res.StatusCode)
			return false
		}

		// Verify code was deleted from Redis (one-time use)
		_, err = redisClient.Get(context.Background(), codeKey).Result()
		if err != redis.Nil {
			t.Logf("code should be deleted from redis after use")
			return false
		}

		// Clean up Redis
		redisClient.Del(context.Background(), fmt.Sprintf("password_reset_attempts:%s", email))

		return true
	}

	// Run property-based test with multiple iterations
	config := &quick.Config{MaxCount: 5}
	if err := quick.Check(property, config); err != nil {
		t.Errorf("Property violated: Final password reset failed: %v", err)
	}
}

// TestPasswordResetPreservation_RateLimiting tests that rate limiting enforces
// 5 attempts per 15 minutes on final password reset.
//
// **Validates: Requirements 3.4**
//
// Property 2: Preservation - Existing Password Reset Flow Behavior
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPasswordResetPreservation_RateLimiting(t *testing.T) {
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

	// Setup Redis
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6380"
	}
	opts, err := redis.ParseURL(redisURL)
	if err != nil {
		t.Fatalf("parse redis url: %v", err)
	}
	redisClient := redis.NewClient(opts)
	defer redisClient.Close()

	// Test Redis connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := redisClient.Ping(ctx).Err(); err != nil {
		t.Skipf("Redis not available: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	authHandler := handlers.NewAuthHandler(
		nil,           // auth service (not needed for password reset)
		nil,           // lockout service (not needed for password reset)
		0,             // lockout duration
		redisClient,   // redis client
		userRepo,      // user repository
		nil,           // smtp service (not needed for test)
		logger,        // logger
		false,         // cookie secure
	)

	// Setup: Create test server
	router := mux.NewRouter()
	router.HandleFunc("/api/v1/auth/reset-password", authHandler.ResetPassword).Methods(http.MethodPost)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Generate a valid user
	uid := insertTestUser(t, pool)

	// Get user email
	var email string
	err = pool.QueryRow(context.Background(), "SELECT email FROM users WHERE id = $1", uid).Scan(&email)
	if err != nil {
		t.Fatalf("get user email failed: %v", err)
	}

	// Store a valid code in Redis
	code := "123456"
	codeKey := fmt.Sprintf("password_reset:%s", email)
	if err := redisClient.Set(context.Background(), codeKey, code, 15*time.Minute).Err(); err != nil {
		t.Fatalf("store code in redis failed: %v", err)
	}

	// Make 5 failed attempts with wrong code
	for i := 0; i < 5; i++ {
		reqBody := map[string]string{
			"email":        email,
			"code":         "000000", // Wrong code
			"new_password": "NewPassword123!",
		}
		body, _ := json.Marshal(reqBody)

		req, err := http.NewRequest(http.MethodPost, srv.URL+"/api/v1/auth/reset-password", bytes.NewReader(body))
		if err != nil {
			t.Fatalf("create request failed: %v", err)
		}
		req.Header.Set("Content-Type", "application/json")

		client := &http.Client{}
		res, err := client.Do(req)
		if err != nil {
			t.Fatalf("execute request failed: %v", err)
		}
		res.Body.Close()

		// First 5 attempts should return 400 (invalid code)
		if res.StatusCode != http.StatusBadRequest {
			t.Errorf("attempt %d: expected 400, got %d", i+1, res.StatusCode)
		}
	}

	// 6th attempt should be rate limited (429 Too Many Requests)
	reqBody := map[string]string{
		"email":        email,
		"code":         "000000",
		"new_password": "NewPassword123!",
	}
	body, _ := json.Marshal(reqBody)

	req, err := http.NewRequest(http.MethodPost, srv.URL+"/api/v1/auth/reset-password", bytes.NewReader(body))
	if err != nil {
		t.Fatalf("create request failed: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	res, err := client.Do(req)
	if err != nil {
		t.Fatalf("execute request failed: %v", err)
	}
	defer res.Body.Close()

	// Property holds: 6th attempt returns 429 (rate limited)
	if res.StatusCode != http.StatusTooManyRequests {
		t.Errorf("expected 429 (rate limited), got %d", res.StatusCode)
	}

	// Clean up Redis
	redisClient.Del(context.Background(), codeKey)
	redisClient.Del(context.Background(), fmt.Sprintf("password_reset_attempts:%s", email))
}

// TestPasswordResetPreservation_ForgotPasswordRateLimiting tests that rate limiting
// enforces 3 requests per 15 minutes on forgot password endpoint.
//
// **Validates: Requirements 3.1**
//
// Property 2: Preservation - Existing Password Reset Flow Behavior
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve)
func TestPasswordResetPreservation_ForgotPasswordRateLimiting(t *testing.T) {
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

	// Setup Redis
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6380"
	}
	opts, err := redis.ParseURL(redisURL)
	if err != nil {
		t.Fatalf("parse redis url: %v", err)
	}
	redisClient := redis.NewClient(opts)
	defer redisClient.Close()

	// Test Redis connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := redisClient.Ping(ctx).Err(); err != nil {
		t.Skipf("Redis not available: %v", err)
	}

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	authHandler := handlers.NewAuthHandler(
		nil,           // auth service (not needed for password reset)
		nil,           // lockout service (not needed for password reset)
		0,             // lockout duration
		redisClient,   // redis client
		userRepo,      // user repository
		nil,           // smtp service (not needed for test)
		logger,        // logger
		false,         // cookie secure
	)

	// Setup: Create test server
	router := mux.NewRouter()
	router.HandleFunc("/api/v1/auth/forgot-password", authHandler.ForgotPassword).Methods(http.MethodPost)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// Generate a valid user
	uid := insertTestUser(t, pool)

	// Get user email
	var email string
	err = pool.QueryRow(context.Background(), "SELECT email FROM users WHERE id = $1", uid).Scan(&email)
	if err != nil {
		t.Fatalf("get user email failed: %v", err)
	}

	// Make 3 requests (should all succeed)
	for i := 0; i < 3; i++ {
		reqBody := map[string]string{"email": email}
		body, _ := json.Marshal(reqBody)

		req, err := http.NewRequest(http.MethodPost, srv.URL+"/api/v1/auth/forgot-password", bytes.NewReader(body))
		if err != nil {
			t.Fatalf("create request failed: %v", err)
		}
		req.Header.Set("Content-Type", "application/json")

		client := &http.Client{}
		res, err := client.Do(req)
		if err != nil {
			t.Fatalf("execute request failed: %v", err)
		}
		res.Body.Close()

		// First 3 requests should succeed (200 OK)
		if res.StatusCode != http.StatusOK {
			t.Errorf("request %d: expected 200, got %d", i+1, res.StatusCode)
		}
	}

	// 4th request should still return 200 (but silently rate limited)
	// The implementation returns success to not reveal rate limiting
	reqBody := map[string]string{"email": email}
	body, _ := json.Marshal(reqBody)

	req, err := http.NewRequest(http.MethodPost, srv.URL+"/api/v1/auth/forgot-password", bytes.NewReader(body))
	if err != nil {
		t.Fatalf("create request failed: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	res, err := client.Do(req)
	if err != nil {
		t.Fatalf("execute request failed: %v", err)
	}
	defer res.Body.Close()

	// Property holds: 4th request returns 200 (silently rate limited)
	if res.StatusCode != http.StatusOK {
		t.Errorf("expected 200 (silently rate limited), got %d", res.StatusCode)
	}

	// Verify no new code was generated (rate limited)
	codeKey := fmt.Sprintf("password_reset:%s", email)
	ttl := redisClient.TTL(context.Background(), codeKey).Val()

	// The TTL should be close to 15 minutes from the 3rd request
	// If a new code was generated, TTL would be reset to 15 minutes
	// We check that TTL is less than 14 minutes (allowing for some time passage)
	if ttl > 14*time.Minute {
		t.Errorf("new code was generated despite rate limiting")
	}

	// Clean up Redis
	redisClient.Del(context.Background(), codeKey)
	redisClient.Del(context.Background(), fmt.Sprintf("forgot_password_rate:%s", email))
}
