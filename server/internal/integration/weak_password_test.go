//go:build integration

package integration_test

import (
	"context"
	"testing"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/application/services"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestWeakPasswordAcceptance verifies that the registration system
// enforces strong password requirements.
//
// **Validates: Requirements 2.3**
//
// This test verifies that weak passwords are rejected with clear error messages.
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (weak password accepted)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (weak password rejected)
func TestWeakPasswordAcceptance(t *testing.T) {
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

	// Test weak passwords that should be rejected
	weakPasswords := []struct {
		password string
		reason   string
	}{
		{"password123", "common password with only lowercase and numbers"},
		{"12345678", "only numbers, minimum length"},
		{"abcdefgh", "only lowercase letters"},
		{"Password", "no numbers or special characters"},
		{"Pass1!", "too short (less than 12 characters)"},
		{"qwerty123456", "common keyboard pattern"},
	}

	vulnerabilityFound := false

	for _, tc := range weakPasswords {
		email := "test-" + tc.password + "@example.com"

		err := authService.Register(ctx, email, tc.password, "Test User")

		if err == nil {
			// Weak password was accepted - vulnerability confirmed
			t.Errorf("VULNERABILITY CONFIRMED: Weak password accepted: %s (%s)", tc.password, tc.reason)
			vulnerabilityFound = true

			// Clean up the user
			_, _ = pool.Exec(ctx, "DELETE FROM users WHERE email = $1", email)
		} else {
			t.Logf("Password rejected (good): %s - %v", tc.password, err)
		}
	}

	if vulnerabilityFound {
		t.Log("SECURITY ISSUE: System accepts weak passwords that don't meet strong requirements")
		t.Log("Expected requirements: min 12 chars, uppercase, lowercase, number, special character")
		return
	}

	// If we reach here, all weak passwords were rejected (vulnerability is fixed)
	t.Log("SUCCESS: All weak passwords properly rejected")

	// Verify that a strong password still works
	strongPassword := "MyStr0ng!P@ssw0rd"
	strongEmail := "strong@example.com"

	err = authService.Register(ctx, strongEmail, strongPassword, "Strong User")
	if err != nil {
		t.Errorf("REGRESSION: Strong password rejected: %v", err)
	} else {
		t.Log("Strong password accepted correctly")
		// Clean up
		_, _ = pool.Exec(ctx, "DELETE FROM users WHERE email = $1", strongEmail)
	}
}

// TestCommonPasswordRejection verifies that common passwords from breach lists
// are rejected even if they meet complexity requirements.
//
// **Validates: Requirements 2.3**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (common passwords accepted)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (common passwords rejected)
func TestCommonPasswordRejection(t *testing.T) {
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

	// Common passwords that meet basic complexity but are in breach databases
	commonPasswords := []string{
		"Password123!",
		"Welcome123!",
		"Admin123!",
		"Qwerty123!",
	}

	vulnerabilityFound := false

	for _, password := range commonPasswords {
		email := "common-" + password + "@example.com"

		err := authService.Register(ctx, email, password, "Test User")

		if err == nil {
			t.Errorf("VULNERABILITY: Common password accepted: %s", password)
			vulnerabilityFound = true
			_, _ = pool.Exec(ctx, "DELETE FROM users WHERE email = $1", email)
		} else {
			t.Logf("Common password rejected (good): %s - %v", password, err)
		}
	}

	if vulnerabilityFound {
		t.Log("SECURITY ISSUE: System accepts common passwords from breach lists")
	} else {
		t.Log("SUCCESS: Common passwords properly rejected")
	}
}
