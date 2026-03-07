package secrets

import (
	"context"
	"fmt"
	"time"
)

// Manager defines the interface for secret management
type Manager interface {
	// GetSecret retrieves a secret by key
	GetSecret(ctx context.Context, key string) (string, error)

	// GetSecrets retrieves multiple secrets at once
	GetSecrets(ctx context.Context, keys []string) (map[string]string, error)

	// Close cleans up any resources
	Close() error
}

// Config holds configuration for secret manager
type Config struct {
	// Provider specifies which secret manager to use: "aws", "gcp", "vault", "env"
	Provider string

	// AWS Secrets Manager configuration
	AWSRegion    string
	AWSSecretARN string

	// GCP Secret Manager configuration
	GCPProjectID string

	// HashiCorp Vault configuration
	VaultAddress string
	VaultToken   string
	VaultPath    string

	// Cache configuration
	CacheTTL time.Duration

	// Timeout for secret retrieval
	Timeout time.Duration
}

// NewManager creates a new secret manager based on the provider
func NewManager(cfg Config) (Manager, error) {
	switch cfg.Provider {
	case "aws":
		return newAWSManager(cfg)
	case "gcp":
		return newGCPManager(cfg)
	case "vault":
		return newVaultManager(cfg)
	case "env", "":
		// Fallback to environment variables for local development
		return newEnvManager(), nil
	default:
		return nil, fmt.Errorf("unsupported secret provider: %s", cfg.Provider)
	}
}
