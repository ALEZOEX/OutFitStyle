//go:build integration

package integration_test

import (
	"context"
	"testing"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestAuditLoggingSimple verifies that user registration creates an audit log entry.
//
// **Validates: Requirements 2.14**
//
// This is a simplified test that focuses on the core audit logging functionality.
func TestAuditLoggingSimple(t *testing.T) {
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

	userRepo := pg.NewUserRepository(db.Pool(), logger)
	sessionRepo := pg.NewSessionRepository(db.Pool(), logger)
	auditRepo := pg.NewAuditRepository(db.Pool())

	// Create a simple token service mock
	tokenSvc := &mockTokenService{}

	authService := services.NewAuthService(userRepo, sessionRepo, tokenSvc, nil, nil, auditRepo, logger)

	// Perform a sensitive operation (user registration)
	email := "audit-test-simple@example.com"
	displayName := "Audit Test User"
	input := domain.UserRegistration{
		Email:       email,
		Password:    "TestPassword123!",
		DisplayName: &displayName,
	}
	device := services.DeviceInfo{
		UserAgent: strPtr("test-agent"),
		IPAddress: strPtr("127.0.0.1"),
	}

	result, err := authService.Register(ctx, input, device)
	if err != nil {
		t.Fatalf("Registration failed: %v", err)
	}

	t.Log("Performed sensitive operation: user registration")
	t.Logf("User ID: %s", result.User.ID.String())

	// Check if audit log exists
	var auditCount int
	err = pool.QueryRow(ctx, `
		SELECT COUNT(*) FROM audit_logs
		WHERE action = 'user_registration'
		AND resource_type = 'user'
		AND user_id = $1
		AND created_at > NOW() - INTERVAL '1 minute'
	`, result.User.ID).Scan(&auditCount)

	if err != nil {
		t.Fatalf("Failed to query audit logs: %v", err)
	}

	if auditCount == 0 {
		t.Error("FAIL: Sensitive operation not logged")
		t.Log("User registration was not recorded in audit logs")
	} else {
		t.Logf("SUCCESS: Found %d audit log entries for registration", auditCount)
	}
}

// mockTokenService is a minimal mock for testing
type mockTokenService struct{}

func (m *mockTokenService) GenerateAccessToken(userID, sessionID domain.ID) (string, time.Time, error) {
	return "mock-access-token", time.Now().Add(15 * time.Minute), nil
}

func (m *mockTokenService) GenerateRefreshToken() (string, error) {
	return "mock-refresh-token", nil
}

func (m *mockTokenService) ValidateAccessToken(token string) (domain.ID, domain.ID, string, error) {
	return domain.NewID(), domain.NewID(), "mock-jti", nil
}

func (m *mockTokenService) HashRefreshToken(token string) string {
	return "mock-hash"
}

func (m *mockTokenService) AccessTTL() time.Duration {
	return 15 * time.Minute
}

func (m *mockTokenService) RefreshTTL() time.Duration {
	return 30 * 24 * time.Hour
}

func strPtr(s string) *string {
	return &s
}
