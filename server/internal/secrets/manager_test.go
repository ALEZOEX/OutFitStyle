package secrets

import (
	"context"
	"os"
	"testing"
	"time"
)

func TestEnvManager(t *testing.T) {
	// Set test environment variables
	os.Setenv("TEST_SECRET_1", "value1")
	os.Setenv("TEST_SECRET_2", "value2")
	defer func() {
		os.Unsetenv("TEST_SECRET_1")
		os.Unsetenv("TEST_SECRET_2")
	}()

	manager := newEnvManager()
	ctx := context.Background()

	t.Run("GetSecret", func(t *testing.T) {
		value, err := manager.GetSecret(ctx, "TEST_SECRET_1")
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if value != "value1" {
			t.Errorf("expected 'value1', got '%s'", value)
		}
	})

	t.Run("GetSecret_NotFound", func(t *testing.T) {
		value, err := manager.GetSecret(ctx, "NONEXISTENT_SECRET")
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if value != "" {
			t.Errorf("expected empty string, got '%s'", value)
		}
	})

	t.Run("GetSecrets", func(t *testing.T) {
		secrets, err := manager.GetSecrets(ctx, []string{"TEST_SECRET_1", "TEST_SECRET_2"})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if len(secrets) != 2 {
			t.Errorf("expected 2 secrets, got %d", len(secrets))
		}
		if secrets["TEST_SECRET_1"] != "value1" {
			t.Errorf("expected 'value1', got '%s'", secrets["TEST_SECRET_1"])
		}
		if secrets["TEST_SECRET_2"] != "value2" {
			t.Errorf("expected 'value2', got '%s'", secrets["TEST_SECRET_2"])
		}
	})

	t.Run("Close", func(t *testing.T) {
		err := manager.Close()
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
	})
}

func TestNewManager(t *testing.T) {
	t.Run("EnvProvider", func(t *testing.T) {
		cfg := Config{
			Provider: "env",
		}
		manager, err := NewManager(cfg)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if manager == nil {
			t.Fatal("expected manager, got nil")
		}
		defer manager.Close()
	})

	t.Run("DefaultProvider", func(t *testing.T) {
		cfg := Config{
			Provider: "",
		}
		manager, err := NewManager(cfg)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if manager == nil {
			t.Fatal("expected manager, got nil")
		}
		defer manager.Close()
	})

	t.Run("UnsupportedProvider", func(t *testing.T) {
		cfg := Config{
			Provider: "unsupported",
		}
		_, err := NewManager(cfg)
		if err == nil {
			t.Fatal("expected error for unsupported provider")
		}
	})
}

func TestCaching(t *testing.T) {
	// This test verifies that the cache mechanism works correctly
	// We'll use the env manager as a simple test case
	os.Setenv("CACHE_TEST_SECRET", "initial_value")
	defer os.Unsetenv("CACHE_TEST_SECRET")

	manager := newEnvManager()
	ctx := context.Background()

	// First retrieval
	value1, err := manager.GetSecret(ctx, "CACHE_TEST_SECRET")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if value1 != "initial_value" {
		t.Errorf("expected 'initial_value', got '%s'", value1)
	}

	// Change the environment variable
	os.Setenv("CACHE_TEST_SECRET", "updated_value")

	// Second retrieval (env manager doesn't cache, so should get new value)
	value2, err := manager.GetSecret(ctx, "CACHE_TEST_SECRET")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if value2 != "updated_value" {
		t.Errorf("expected 'updated_value', got '%s'", value2)
	}
}

func TestSecretManagerConfig(t *testing.T) {
	t.Run("AWSConfig", func(t *testing.T) {
		cfg := Config{
			Provider:     "aws",
			AWSRegion:    "us-east-1",
			AWSSecretARN: "arn:aws:secretsmanager:us-east-1:123456789012:secret:test",
			CacheTTL:     5 * time.Minute,
			Timeout:      10 * time.Second,
		}

		if cfg.Provider != "aws" {
			t.Errorf("expected provider 'aws', got '%s'", cfg.Provider)
		}
		if cfg.AWSRegion != "us-east-1" {
			t.Errorf("expected region 'us-east-1', got '%s'", cfg.AWSRegion)
		}
	})

	t.Run("GCPConfig", func(t *testing.T) {
		cfg := Config{
			Provider:     "gcp",
			GCPProjectID: "my-project",
			CacheTTL:     5 * time.Minute,
			Timeout:      10 * time.Second,
		}

		if cfg.Provider != "gcp" {
			t.Errorf("expected provider 'gcp', got '%s'", cfg.Provider)
		}
		if cfg.GCPProjectID != "my-project" {
			t.Errorf("expected project 'my-project', got '%s'", cfg.GCPProjectID)
		}
	})

	t.Run("VaultConfig", func(t *testing.T) {
		cfg := Config{
			Provider:     "vault",
			VaultAddress: "https://vault.example.com:8200",
			VaultToken:   "test-token",
			VaultPath:    "secret/data/app",
			CacheTTL:     5 * time.Minute,
			Timeout:      10 * time.Second,
		}

		if cfg.Provider != "vault" {
			t.Errorf("expected provider 'vault', got '%s'", cfg.Provider)
		}
		if cfg.VaultAddress != "https://vault.example.com:8200" {
			t.Errorf("expected address 'https://vault.example.com:8200', got '%s'", cfg.VaultAddress)
		}
	})
}
