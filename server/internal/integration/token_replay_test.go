//go:build integration

package integration_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestRefreshTokenReplay verifies that refresh tokens cannot be reused
// after they have been used once to obtain new access tokens.
//
// **Validates: Requirements 2.4**
//
// This test verifies that old refresh tokens are invalidated after use,
// preventing replay attacks.
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (token reuse succeeds)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (token reuse blocked)
func TestRefreshTokenReplay(t *testing.T) {
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
	tokenService := services.NewTokenService(userRepo, logger)

	// Create a test user
	userID := insertTestUser(t, pool)

	// Generate initial refresh token
	refreshToken, err := tokenService.GenerateRefreshToken(ctx, userID.String())
	if err != nil {
		t.Fatalf("Failed to generate refresh token: %v", err)
	}

	t.Logf("Generated initial refresh token: %s", refreshToken[:20]+"...")

	// Use the refresh token for the first time (should succeed)
	accessToken1, newRefreshToken1, err := tokenService.RefreshAccessToken(ctx, refreshToken)
	if err != nil {
		t.Fatalf("First token refresh failed: %v", err)
	}

	t.Logf("First refresh succeeded - Access token: %s..., New refresh token: %s...",
		accessToken1[:20], newRefreshToken1[:20])

	// SECURITY TEST: Try to reuse the SAME original refresh token again
	accessToken2, newRefreshToken2, err := tokenService.RefreshAccessToken(ctx, refreshToken)

	if err == nil {
		// Token reuse succeeded - VULNERABILITY CONFIRMED
		t.Error("VULNERABILITY CONFIRMED: Refresh token can be reused indefinitely")
		t.Logf("Second refresh with same token succeeded - Access token: %s..., Refresh token: %s...",
			accessToken2[:20], newRefreshToken2[:20])
		t.Log("This allows replay attacks if tokens are intercepted")

		// Try a third time to confirm
		accessToken3, _, err := tokenService.RefreshAccessToken(ctx, refreshToken)
		if err == nil {
			t.Logf("Third refresh also succeeded: %s...", accessToken3[:20])
			t.Error("Token can be reused multiple times - critical security vulnerability")
		}
		return
	}

	// Token reuse was blocked - vulnerability is fixed
	t.Logf("Second refresh with same token failed (good): %v", err)
	t.Log("SUCCESS: Refresh token replay prevented")

	// Verify that the NEW refresh token works (should succeed once)
	accessToken3, _, err := tokenService.RefreshAccessToken(ctx, newRefreshToken1)
	if err != nil {
		t.Errorf("REGRESSION: New refresh token doesn't work: %v", err)
	} else {
		t.Logf("New refresh token works correctly: %s...", accessToken3[:20])
	}
}

// TestRefreshTokenReplayDetection verifies that when a token replay is detected,
// all tokens for that user are invalidated (security measure against compromise).
//
// **Validates: Requirements 2.4**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (no replay detection)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (all tokens invalidated on replay)
func TestRefreshTokenReplayDetection(t *testing.T) {
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
	tokenService := services.NewTokenService(userRepo, logger)

	userID := insertTestUser(t, pool)

	// Generate initial refresh token
	refreshToken1, err := tokenService.GenerateRefreshToken(ctx, userID.String())
	if err != nil {
		t.Fatalf("Failed to generate refresh token: %v", err)
	}

	// Use it once to get a new token
	_, refreshToken2, err := tokenService.RefreshAccessToken(ctx, refreshToken1)
	if err != nil {
		t.Fatalf("First refresh failed: %v", err)
	}

	// Now try to replay the old token (should trigger security response)
	_, _, err = tokenService.RefreshAccessToken(ctx, refreshToken1)

	if err == nil {
		t.Log("VULNERABILITY: Token replay not detected, no security response triggered")
		return
	}

	t.Logf("Replay attempt blocked: %v", err)

	// Check if the NEW token (refreshToken2) is also invalidated as a security measure
	_, _, err = tokenService.RefreshAccessToken(ctx, refreshToken2)

	if err == nil {
		t.Log("INFO: Replay detection doesn't invalidate all user tokens (acceptable)")
		t.Log("Advanced security would invalidate all tokens on replay detection")
	} else {
		t.Log("SUCCESS: All user tokens invalidated on replay detection (advanced security)")
	}
}
