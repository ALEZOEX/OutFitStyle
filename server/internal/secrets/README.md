# Secrets Package

This package provides a unified interface for secure secret management across multiple providers.

## Features

- **Multiple Providers**: Support for AWS Secrets Manager, GCP Secret Manager, HashiCorp Vault, and environment variables
- **Caching**: In-memory caching with configurable TTL to reduce API calls
- **Fallback**: Graceful fallback to environment variables if secret manager fails
- **Thread-Safe**: Concurrent access to secrets is safe
- **Easy Integration**: Simple interface for loading secrets at application startup

## Supported Providers

### Environment Variables (Default)
- **Use Case**: Local development
- **Configuration**: No additional setup required
- **Security**: Secrets stored in `.env` file or environment

### AWS Secrets Manager
- **Use Case**: AWS deployments (ECS, EKS, EC2)
- **Configuration**: Requires AWS credentials and secret ARN
- **Security**: Encrypted at rest, IAM-based access control

### GCP Secret Manager
- **Use Case**: Google Cloud deployments (GKE, Cloud Run, GCE)
- **Configuration**: Requires GCP project ID and service account
- **Security**: Encrypted at rest, IAM-based access control

### HashiCorp Vault
- **Use Case**: On-premise or multi-cloud deployments
- **Configuration**: Requires Vault address, token, and secret path
- **Security**: Encrypted at rest and in transit, policy-based access control

## Usage

### Basic Usage

```go
import (
    "context"
    "outfitstyle/server/internal/secrets"
)

// Create a secret manager
cfg := secrets.Config{
    Provider: "aws",
    AWSRegion: "us-east-1",
    AWSSecretARN: "arn:aws:secretsmanager:us-east-1:123456789012:secret:app-secrets",
    CacheTTL: 5 * time.Minute,
}

manager, err := secre
manager:

```go
import "outfitstyle/server/internal/config"

// Load configuration (automatically initializes secret manager)
cfg, err := config.Load()
if err != nil {
    log.Fatal(err)
}
defer cfg.Close()

// Secrets are automatically loaded from the secret manager
// and available in the config struct
fmt.Println("JWT Secret loaded:", cfg.Security.JWTSecret != "")
```

## Configuration

### Environment Variables

Configure the secret manager using these environment variables:

```bash
# Provider selection
SECRET_MANAGER_PROVIDER=aws  # Options: aws, gcp, vault, env

# AWS Secrets Manager
AWS_REGION=us-east-1
AWS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:app-secrets

# GCP Secret Manager
GCP_PROJECT_ID=my-project-id

# HashiCorp Vault
VAULT_ADDR=https://vault.example.com:8200
VAULT_TOKEN=your-vault-token
VAULT_SECRET_PATH=secret/data/app

# Cache configuration
SECRET_CACHE_TTL=5m
SECRET_MANAGER_TIMEOUT=10s
```

## Architecture

### Interface

```go
type Manager interface {
    GetSecret(ctx context.Context, key string) (string, error)
    GetSecrets(ctx context.Context, keys []string) (map[string]string, error)
    Close() error
}
```

### Caching

All providers (except env) implement in-memory caching:
- Reduces API calls to secret managers
- Configurable TTL (default: 5 minutes)
- Thread-safe with read-write locks
- Automatic cache invalidation on TTL expiry

### Error Handling

- If secret manager fails to initialize, falls back to environment variables
- If secret retrieval fails, returns error (no fallback for individual secrets)
- Logs warnings when falling back to environment variables

## Security Considerations

1. **Encryption at Rest**: All cloud providers encrypt secrets at rest
2. **Encryption in Transit**: All API calls use HTTPS/TLS
3. **Access Control**: Use IAM policies to restrict secret access
4. **Audit Logging**: Enable audit logs in your secret manager
5. **Secret Rotation**: Implement regular secret rotation policies
6. **Cache Security**: Secrets cached in memory are cleared on application restart
7. **No Disk Storage**: Secrets are never written to disk

## Testing

Run tests:

```bash
go test ./internal/secrets/... -v
```

Run tests with coverage:

```bash
go test ./internal/secrets/... -cover
```

## Performance

- **First Access**: Retrieves from secret manager (network call)
- **Cached Access**: Retrieves from memory (microseconds)
- **Cache Miss**: Retrieves from secret manager and updates cache
- **Batch Retrieval**: More efficient than individual calls

### Benchmarks

Typical performance (approximate):
- Environment variables: < 1μs
- Cached secrets: < 1μs
- AWS Secrets Manager (uncached): 50-200ms
- GCP Secret Manager (uncached): 50-200ms
- HashiCorp Vault (uncached): 10-100ms

## Troubleshooting

### Secret Manager Initialization Fails

**Symptom**: Application logs "Warning: failed to load secrets from secret manager"

**Solutions**:
1. Verify provider configuration is correct
2. Check IAM permissions for service account
3. Ensure network connectivity to secret manager
4. Verify secret ARN/name/path is correct

### Secret Not Found

**Symptom**: Error "secret key X not found"

**Solutions**:
1. Verify secret exists in the secret manager
2. Check secret name matches exactly (case-sensitive)
3. Ensure secret is in the correct region/project
4. Verify IAM permissions include read access

### High Latency

**Symptom**: Slow application startup or secret retrieval

**Solutions**:
1. Increase cache TTL to reduce API calls
2. Use batch retrieval (GetSecrets) instead of individual calls
3. Check network latency to secret manager
4. Consider using a secret manager in the same region

## Migration Guide

### From Environment Variables to Secret Manager

1. **Backup Current Secrets**: Save current `.env` file
2. **Create Secrets**: Add secrets to your chosen secret manager
3. **Update Configuration**: Set `SECRET_MANAGER_PROVIDER` environment variable
4. **Test**: Verify application starts and secrets are loaded
5. **Deploy**: Roll out to production with monitoring
6. **Cleanup**: Remove secrets from environment variables (keep non-sensitive config)

### Example Migration Script

```bash
#!/bin/bash
# migrate-to-aws-secrets.sh

# Load current secrets from .env
source .env

# Create AWS secret
aws secretsmanager create-secret \
  --name app-secrets \
  --secret-string "{
    \"JWT_SECRET\": \"$JWT_SECRET\",
    \"ADMIN_API_KEY\": \"$ADMIN_API_KEY\",
    \"API_KEY_PEPPER\": \"$API_KEY_PEPPER\"
  }"

echo "Secrets migrated to AWS Secrets Manager"
```

## Future Enhancements

- [ ] Support for Azure Key Vault
- [ ] Automatic secret rotation
- [ ] Secret versioning support
- [ ] Metrics and monitoring integration
- [ ] Secret validation on load
- [ ] Support for binary secrets
- [ ] Kubernetes Secrets integration
