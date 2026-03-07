package secrets

import (
	"context"
	"os"
)

// envManager implements Manager interface using environment variables
// This is used for local development and as a fallback
type envManager struct{}

func newEnvManager() Manager {
	return &envManager{}
}

func (m *envManager) GetSecret(ctx context.Context, key string) (string, error) {
	value := os.Getenv(key)
	if value == "" {
		return "", nil
	}
	return value, nil
}

func (m *envManager) GetSecrets(ctx context.Context, keys []string) (map[string]string, error) {
	secrets := make(map[string]string, len(keys))
	for _, key := range keys {
		value := os.Getenv(key)
		if value != "" {
			secrets[key] = value
		}
	}
	return secrets, nil
}

func (m *envManager) Close() error {
	return nil
}
