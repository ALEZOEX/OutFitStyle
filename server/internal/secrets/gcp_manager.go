package secrets

import (
	"context"
	"fmt"
	"sync"
	"time"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	"cloud.google.com/go/secretmanager/apiv1/secretmanagerpb"
)

// gcpManager implements Manager interface using GCP Secret Manager
type gcpManager struct {
	client    *secretmanager.Client
	projectID string
	cache     map[string]cachedSecret
	cacheTTL  time.Duration
	mu        sync.RWMutex
}

func newGCPManager(cfg Config) (Manager, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := secretmanager.NewClient(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to create GCP Secret Manager client: %w", err)
	}

	cacheTTL := cfg.CacheTTL
	if cacheTTL == 0 {
		cacheTTL = 5 * time.Minute // Default cache TTL
	}

	return &gcpManager{
		client:    client,
		projectID: cfg.GCPProjectID,
		cache:     make(map[string]cachedSecret),
		cacheTTL:  cacheTTL,
	}, nil
}

func (m *gcpManager) GetSecret(ctx context.Context, key string) (string, error) {
	// Check cache first
	m.mu.RLock()
	if cached, ok := m.cache[key]; ok && time.Now().Before(cached.expiresAt) {
		m.mu.RUnlock()
		return cached.value, nil
	}
	m.mu.RUnlock()

	// Build the secret name
	secretName := fmt.Sprintf("projects/%s/secrets/%s/versions/latest", m.projectID, key)

	// Access the secret
	req := &secretmanagerpb.AccessSecretVersionRequest{
		Name: secretName,
	}

	result, err := m.client.AccessSecretVersion(ctx, req)
	if err != nil {
		return "", fmt.Errorf("failed to access secret %s from GCP: %w", key, err)
	}

	value := string(result.Payload.Data)

	// Cache the secret
	m.mu.Lock()
	m.cache[key] = cachedSecret{
		value:     value,
		expiresAt: time.Now().Add(m.cacheTTL),
	}
	m.mu.Unlock()

	return value, nil
}

func (m *gcpManager) GetSecrets(ctx context.Context, keys []string) (map[string]string, error) {
	secrets := make(map[string]string, len(keys))

	for _, key := range keys {
		value, err := m.GetSecret(ctx, key)
		if err != nil {
			return nil, err
		}
		secrets[key] = value
	}

	return secrets, nil
}

func (m *gcpManager) Close() error {
	return m.client.Close()
}
