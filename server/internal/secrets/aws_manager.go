package secrets

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
)

// awsManager implements Manager interface using AWS Secrets Manager
type awsManager struct {
	client    *secretsmanager.Client
	secretARN string
	cache     map[string]cachedSecret
	cacheTTL  time.Duration
	mu        sync.RWMutex
}

type cachedSecret struct {
	value     string
	expiresAt time.Time
}

func newAWSManager(cfg Config) (Manager, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Load AWS configuration
	awsCfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(cfg.AWSRegion))
	if err != nil {
		return nil, fmt.Errorf("failed to load AWS config: %w", err)
	}

	client := secretsmanager.NewFromConfig(awsCfg)

	cacheTTL := cfg.CacheTTL
	if cacheTTL == 0 {
		cacheTTL = 5 * time.Minute // Default cache TTL
	}

	return &awsManager{
		client:    client,
		secretARN: cfg.AWSSecretARN,
		cache:     make(map[string]cachedSecret),
		cacheTTL:  cacheTTL,
	}, nil
}

func (m *awsManager) GetSecret(ctx context.Context, key string) (string, error) {
	// Check cache first
	m.mu.RLock()
	if cached, ok := m.cache[key]; ok && time.Now().Before(cached.expiresAt) {
		m.mu.RUnlock()
		return cached.value, nil
	}
	m.mu.RUnlock()

	// Retrieve from AWS Secrets Manager
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(m.secretARN),
	}

	result, err := m.client.GetSecretValue(ctx, input)
	if err != nil {
		return "", fmt.Errorf("failed to retrieve secret from AWS: %w", err)
	}

	// Parse the secret string as JSON
	var secrets map[string]string
	if err := json.Unmarshal([]byte(*result.SecretString), &secrets); err != nil {
		return "", fmt.Errorf("failed to parse secret JSON: %w", err)
	}

	value, ok := secrets[key]
	if !ok {
		return "", fmt.Errorf("secret key %s not found in AWS Secrets Manager", key)
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

func (m *awsManager) GetSecrets(ctx context.Context, keys []string) (map[string]string, error) {
	// Retrieve all secrets at once
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(m.secretARN),
	}

	result, err := m.client.GetSecretValue(ctx, input)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve secrets from AWS: %w", err)
	}

	// Parse the secret string as JSON
	var allSecrets map[string]string
	if err := json.Unmarshal([]byte(*result.SecretString), &allSecrets); err != nil {
		return nil, fmt.Errorf("failed to parse secret JSON: %w", err)
	}

	// Filter requested keys and cache them
	secrets := make(map[string]string, len(keys))
	m.mu.Lock()
	for _, key := range keys {
		if value, ok := allSecrets[key]; ok {
			secrets[key] = value
			m.cache[key] = cachedSecret{
				value:     value,
				expiresAt: time.Now().Add(m.cacheTTL),
			}
		}
	}
	m.mu.Unlock()

	return secrets, nil
}

func (m *awsManager) Close() error {
	return nil
}
