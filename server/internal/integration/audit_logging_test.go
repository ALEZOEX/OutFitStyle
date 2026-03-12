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

// TestAuditLoggingGap verifies that sensitive operations are logged for audit trails.
//
// **Validates: Requirements 2.14**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (no audit logs)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (audit logs present)
func TestAuditLoggingGap(t *testing.T) {
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

	// Perform a sensitive operation (user registration)
	email := "audit-test@example.com"
	input := domain.UserRegistration{
		Email:       email,
		Password:    "TestPassword123!",
		DisplayName: "Audit Test User",
	}
	device := services.DeviceInfo{
		UserAgent: "test-agent",
		IPAddress: "127.0.0.1",
	}
	_, err = authService.Register(ctx, input, device)
	if err != nil {
		t.Fatalf("Registration failed: %v", err)
	}

	t.Log("Performed sensitive operation: user registration")

	// Check if audit log exists
	var auditCount int
	err = pool.QueryRow(ctx, `
		SELECT COUNT(*) FROM audit_logs
		WHERE action = 'user_registration'
		AND resource_type = 'user'
		AND created_at > NOW() - INTERVAL '1 minute'
	`).Scan(&auditCount)

	if err != nil {
		t.Log("INFO: No audit_logs table found")
		t.Error("VULNERABILITY CONFIRMED: No audit logging mechanism exists")
		t.Log("Sensitive operations are not logged for security monitoring")
		t.Log("Expected: audit_logs table with action, user_id, resource_type, ip_address, timestamp")
		return
	}

	if auditCount == 0 {
		t.Error("VULNERABILITY CONFIRMED: Sensitive operation not logged")
		t.Log("User registration was not recorded in audit logs")
	} else {
		t.Logf("SUCCESS: Found %d audit log entries for registration", auditCount)
	}
}
