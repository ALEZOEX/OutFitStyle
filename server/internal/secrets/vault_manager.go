package secrets

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/hashicorp/vault/api"
)

// vaultManager implements Manager interface using HashiCorp Vault
type vaultManager struct {
	client   *api.Client
	path     string
	cache    map[string]cachedSecret
	cacheTTL time.Duration
	mu       sync.RWMutex
}

func newVaultManager(cfg Config) (Manager, error) {
	config := api.DefaultConfig()
	config.Address = cfg.VaultAddress

	client, err := api.NewClient(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create Vault client: %w", err)
	}

	// Set the token
	client.SetToken(cfg.VaultToken)

	cacheTTL := cfg.CacheTTL
	if cacheTTL == 0 {
		cacheTTL = 5 * time.Minute // Default cache TTL
	}

	return &vaultManager{
		client:   client,
		path:     cfg.VaultPath,
		cache:    make(map[string]cachedSecret),
		cacheTTL: cacheTTL,
	}, nil
}

func (m *vaultManager) GetSecret(ctx context.Context, key string) (string, error) {
	// Check cache first
	m.mu.RLock()
	if cached, ok := m.cache[key]; ok && time.Now().Before(cached.expiresAt) {
		m.mu.RUnlock()
		return cached.value, nil
	}
	m.mu.RUnlock()

	// Read from Vault
	secret, err := m.client.Logical().ReadWithContext(ctx, m.path)
	if err != nil {
		return "", fmt.Errorf("failed to read secret from Vault: %w", err)
	}

	if secret == nil || secret.Data == nil {
		return "", fmt.Errorf("secret not found at path %s", m.path)
	}

	// Handle KV v2 format (data wrapper)
	data := secret.Data
	if dataWrapper, ok := secret.Data["data"].(map[string]interface{}); ok {
		data = dataWrapper
	}

	valueInterface, ok := data[key]
	if !ok {
		return "", fmt.Errorf("secret key %s not found in Vault", key)
	}

	value, ok := valueInterface.(string)
	if !ok {
		return "", fmt.Errorf("secret value for key %s is not a string", key)
	}

	// Cache the secret
	m.mu.Lock()
	m.cache[key] = cachedSecret{
		value:     value,
		expiresAt: time.Now().Add(m.cacheTTL),
	}
	m.mu.Unlock()

	return value, nil
}

func (m *vaultManager) GetSecrets(ctx context.Context, keys []string) (map[string]string, error) {
	// Read all secrets at once from Vault
	secret, err := m.client.Logical().ReadWithContext(ctx, m.path)
	if err != nil {
		return nil, fmt.Errorf("failed to read secrets from Vault: %w", err)
	}

	if secret == nil || secret.Data == nil {
		return nil, fmt.Errorf("secrets not found at path %s", m.path)
	}

	// Handle KV v2 format (data wrapper)
	data := secret.Data
	if dataWrapper, ok := secret.Data["data"].(map[string]interface{}); ok {
		data = dataWrapper
	}

	secrets := make(map[string]string, len(keys))
	m.mu.Lock()
	for _, key := range keys {
		if valueInterface, ok := data[key]; ok {
			if value, ok := valueInterface.(string); ok {
				secrets[key] = value
				m.cache[key] = cachedSecret{
					value:     value,
					expiresAt: time.Now().Add(m.cacheTTL),
				}
			}
		}
	}
	m.mu.Unlock()

	return secrets, nil
}

func (m *vaultManager) Close() error {
	return nil
}
