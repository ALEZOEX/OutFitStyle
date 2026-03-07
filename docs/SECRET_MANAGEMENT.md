# Secure Secret Management

This document describes how to configure and use secure secret management in the OutfitStyle application.

## Overview

The application supports multiple secret management providers:
- **AWS Secrets Manager** - For AWS deployments
- **GCP Secret Manager** - For Google Cloud deployments
- **HashiCorp Vault** - For on-premise or multi-cloud deployments
- **Environment Variables** - For local development (fallback)

Secrets are loaded at application startup and cached in memory with configurable TTL. The system is designed to support secret rotation without application restart.

## Configuration

### Environment Variables

Configure the secret manager using these environment variables:

```bash
# Secret Manager Provider (aws, gcp, vault, env)
SECRET_MANAGER_PROVIDER=aws

# Cache TTL for secrets (default: 5m)
SECRET_CACHE_TTL=5m

# Timeout for secret retrieval (default: 10s)
SECRET_MANAGER_TIMEOUT=10s
```

### AWS Secrets Manager

For AWS deployments, configure:

```bash
SECRET_MANAGER_PROVIDER=aws
AWS_REGION=us-east-1
AWS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:outfitstyle-secrets-AbCdEf
```

**IAM Policy Requirements:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:123456789012:secret:outfitstyle-secrets-*"
    }
  ]
}
```

**Secret Format in AWS:**

Store secrets as a JSON object:

```json
{
  "JWT_SECRET": "your-jwt-secret-here",
  "ADMIN_API_KEY": "your-admin-key-here",
  "API_KEY_PEPPER": "your-pepper-here",
  "OPENWEATHER_API_KEY": "your-weather-key-here",
  "REDIS_PASSWORD": "your-redis-password",
  "SMTP_PASSWORD": "your-smtp-password",
  "S3_SECRET_KEY": "your-s3-secret",
  "YOOKASSA_SECRET_KEY": "your-yookassa-secret",
  "STRIPE_SECRET_KEY": "your-stripe-secret",
  "STRIPE_WEBHOOK_SECRET": "your-stripe-webhook-secret"
}
```

### GCP Secret Manager

For Google Cloud deployments, configure:

```bash
SECRET_MANAGER_PROVIDER=gcp
GCP_PROJECT_ID=your-project-id
```

**IAM Permissions Required:**

Grant the service account the `roles/secretmanager.secretAccessor` role:

```bash
gcloud projects add-iam-policy-binding your-project-id \
  --member="serviceAccount:your-service-account@your-project-id.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

**Secret Format in GCP:**

Create individual secrets for each key:

```bash
# Create secrets
echo -n "your-jwt-secret" | gcloud secrets create JWT_SECRET --data-file=-
echo -n "your-admin-key" | gcloud secrets create ADMIN_API_KEY --data-file=-
echo -n "your-pepper" | gcloud secrets create API_KEY_PEPPER --data-file=-
# ... repeat for other secrets
```

### HashiCorp Vault

For Vault deployments, configure:

```bash
SECRET_MANAGER_PROVIDER=vault
VAULT_ADDR=https://vault.example.com:8200
VAULT_TOKEN=your-vault-token
VAULT_SECRET_PATH=secret/data/outfitstyle
```

**Vault Policy Requirements:**

```hcl
path "secret/data/outfitstyle" {
  capabilities = ["read"]
}
```

**Secret Format in Va
For local development, use environment variables:

```bash
SECRET_MANAGER_PROVIDER=env
# Or omit SECRET_MANAGER_PROVIDER entirely (defaults to env)
```

Secrets will be loaded from `.env` file or environment variables as before.

## Secrets Loaded

The following secrets are loaded from the secret manager:

1. **JWT_SECRET** - JWT signing secret
2. **ADMIN_API_KEY** - Admin API authentication key
3. **API_KEY_PEPPER** - Pepper for API key hashing
4. **OPENWEATHER_API_KEY** - OpenWeather API key
5. **REDIS_PASSWORD** - Redis password
6. **SMTP_PASSWORD** - SMTP password for email
7. **S3_SECRET_KEY** - S3 secret key
8. **YOOKASSA_SECRET_KEY** - YooKassa payment secret
9. **STRIPE_SECRET_KEY** - Stripe payment secret
10. **STRIPE_WEBHOOK_SECRET** - Stripe webhook secret

## Secret Rotation

### Without Application Restart

The secret manager caches secrets with a configurable TTL (default: 5 minutes). After the TTL expires, secrets are automatically reloaded from the secret manager on the next access.

To rotate a secret:

1. Update the secret in your secret manager (AWS/GCP/Vault)
2. Wait for the cache TTL to expire (or restart the application for immediate effect)
3. The application will automatically load the new secret value

### With Application Restart

For immediate secret rotation:

1. Update the secret in your secret manager
2. Perform a rolling restart of the application instances
3. Each instance will load the new secrets on startup

## Security Best Practices

1. **Never commit secrets to version control** - Use `.gitignore` to exclude `.env` files
2. **Use different secrets for each environment** - Development, staging, and production should have separate secrets
3. **Rotate secrets regularly** - Implement a secret rotation policy (e.g., every 90 days)
4. **Restrict access to secret managers** - Use IAM policies to limit who can read/write secrets
5. **Enable audit logging** - Track all secret access in your secret manager
6. **Use encryption at rest** - All supported secret managers encrypt secrets at rest by default
7. **Use encryption in transit** - All secret manager APIs use HTTPS/TLS

## Monitoring

Monitor secret manager operations:

- Check application logs for secret loading errors
- Monitor secret manager API calls and latency
- Set up alerts for failed secret retrievals
- Track cache hit/miss rates

## Troubleshooting

### Secrets not loading

1. Check `SECRET_MANAGER_PROVIDER` is set correctly
2. Verify IAM permissions for the service account
3. Check network connectivity to the secret manager
4. Review application logs for error messages
5. Verify secret names match exactly (case-sensitive)

### Fallback to environment variables

If secret manager fails to load secrets, the application falls back to environment variables with a warning log message. This ensures the application can still start in degraded mode.

### Cache issues

If secrets are not updating after rotation:
1. Check `SECRET_CACHE_TTL` setting
2. Wait for cache to expire or restart the application
3. Verify the secret was updated in the secret manager

## Migration from Environment Variables

To migrate from environment variables to a secret manager:

1. Choose your secret manager provider (AWS/GCP/Vault)
2. Create secrets in the secret manager with the same keys as your environment variables
3. Configure the secret manager environment variables
4. Test in a non-production environment first
5. Deploy to production with the new configuration
6. Remove secrets from environment variables (keep non-sensitive config)

## Example Deployment Configurations

### Kubernetes with AWS Secrets Manager

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: outfitstyle-api
spec:
  template:
    spec:
      serviceAccountName: outfitstyle-api
      containers:
      - name: api
        image: outfitstyle/api:latest
        env:
        - name: SECRET_MANAGER_PROVIDER
          value: "aws"
        - name: AWS_REGION
          value: "us-east-1"
        - name: AWS_SECRET_ARN
          value: "arn:aws:secretsmanager:us-east-1:123456789012:secret:outfitstyle-secrets-AbCdEf"
```

### Docker Compose with Vault

```yaml
version: '3.8'
services:
  api:
    image: outfitstyle/api:latest
    environment:
      SECRET_MANAGER_PROVIDER: vault
      VAULT_ADDR: https://vault.example.com:8200
      VAULT_TOKEN: ${VAULT_TOKEN}
      VAULT_SECRET_PATH: secret/data/outfitstyle
```

### GCP Cloud Run

```bash
gcloud run deploy outfitstyle-api \
  --image gcr.io/your-project/outfitstyle-api \
  --set-env-vars SECRET_MANAGER_PROVIDER=gcp,GCP_PROJECT_ID=your-project-id \
  --service-account outfitstyle-api@your-project-id.iam.gserviceaccount.com
```
