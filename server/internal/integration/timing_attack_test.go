//go:build integration

package integration_test

import (
	"context"
	"testing"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestTimingAttackVulnerability verifies that secret comparisons use constant-time functions.
//
// **Validates: Requirements 2.15**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (timing differences detectable)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (constant-time comparison)
func TestTimingAttackVulnerability(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	logger := zap.NewNop()
	db, err := dbpg.NewDB(pool.Config().ConnString(), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	userRepo := pg.NewUserRepository(db.Pool())
	authService := services.NewAuthService(userRepo, logger)

	// Create a test user with known password
	testEmail := "timing-test@example.com"
	correctPassword := "CorrectPassword123!"

	err = authService.Register(ctx, testEmail, correctPassword, "Timing Test")
	if err != nil {
		t.Fatalf("Failed to create test user: %v", err)
	}

	// Measure timing for completely wrong password
	wrongPassword := "WrongPassword123!"
	iterations := 100

	var wrongPasswordTotalTime time.Duration
	for i := 0; i < iterations; i++ {
		start := time.Now()
		_ = authService.Login(ctx, testEmail, wrongPassword)
		wrongPasswordTotalTime += time.Since(start)
	}
	wrongPasswordAvg := wrongPasswordTotalTime / time.Duration(iterations)

	// Measure timing for partially correct password (same prefix)
	partialPassword := "CorrectPassword123X"
	var partialPasswordTotalTime time.Duration
	for i := 0; i < iterations; i++ {
		start := time.Now()
		_ = authService.Login(ctx, testEmail, partialPassword)
		partialPasswordTotalTime += time.Since(start)
	}
	partialPasswordAvg := partialPasswordTotalTime / time.Duration(iterations)

	t.Logf("Average time for wrong password: %v", wrongPasswordAvg)
	t.Logf("Average time for partial password: %v", partialPasswordAvg)

	// Calculate timing difference
	timingDiff := wrongPasswordAvg - partialPasswordAvg
	if timingDiff < 0 {
		timingDiff = -timingDiff
	}

	// If timing difference is significant (>10% or >1ms), it's vulnerable
	percentDiff := float64(timingDiff) / float64(wrongPasswordAvg) * 100

	t.Logf("Timing difference: %v (%.2f%%)", timingDiff, percentDiff)

	if percentDiff > 10 || timingDiff > time.Millisecond {
		t.Error("VULNERABILITY CONFIRMED: Timing attack possible")
		t.Logf("Significant timing difference detected: %.2f%%", percentDiff)
		t.Log("Attacker can use timing differences to guess passwords character by character")
		t.Log("Expected: Constant-time comparison using subtle.ConstantTimeCompare or bcrypt")
		return
	}

	t.Log("SUCCESS: No significant timing differences detected")
	t.Log("Password comparison appears to use constant-time algorithm")
}
