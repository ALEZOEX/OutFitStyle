# Deployment Secrets Setup Guide

This guide provides step-by-step instructions for setting up secure secret management in different cloud environments.

## Table of Contents

1. [AWS Secrets Manager Setup](#aws-secrets-manager-setup)
2. [GCP Secret Manager Setup](#gcp-secret-manager-setup)
3. [HashiCorp Vault Setup](#hashicorp-vault-setup)
4. [Kubernetes Integration](#kubernetes-integration)
5. [Docker Compose Integration](#docker-compose-integration)

---

## AWS Secrets Manager Setup

### Step 1: Create the Secret

```bash
# Create a secret with all required keys
aws secretsmanager create-secret \
  --name outfitstyle-secrets \
  --description "OutfitStyle application secrets" \
  --secret-string '{
    "JWT_SECRET": "REPLACE_WITH_SECURE_RANDOM_STRING_MIN_256_BITS",
    "ADMIN_API_KEY": "REPLACE_WITH_SECURE_ADMIN_KEY",
    "API_KEY_PEPPER": "REPLACE_WITH_SECURE_RANDOM_PEPPER",
    "OPENWEATHER_API_KEY": "your-openweather-api-key",
    "REDIS_PASSWORD": "your-redis-password",
    "SMTP_PASSWORD": "your-smtp-password",
    "S3_SECRET_KEY": "your-s3-secret-key",
    "YOOKASSA_SECRET_KEY": "your-yookassa-secret",
    "STRIPE_SECRET_KEY": "your-stripe-secret",
    "STRIPE_WEBHOOK_SECRET": "your-stripe-webhook-secret"
  }' \
  --region us-east-1
```

### Step 2: Note the Secret ARN

The command will return a JSON response with the ARN:

```json
{
  "ARN": "arn:aws:secretsmanager:us-east-1:123456789012:secret:outfitstyle-secrets-AbCdEf",
  "Name": "outfitstyle-secrets",
  "VersionId": "..."
}
```

### Step 3: Create IAM Policy

Create a policy file `outfitstyle-secrets-policy.json`:

```json

```bash
aws iam attach-role-policy \
  --role-name OutfitStyleServiceRole \
  --policy-arn arn:aws:iam::123456789012:policy/OutfitStyleSecretsReadPolicy
```

For EC2 instance profile:

```bash
aws iam attach-role-policy \
  --role-name OutfitStyleEC2Role \
  --policy-arn arn:aws:iam::123456789012:policy/OutfitStyleSecretsReadPolicy
```

### Step 5: Configure Application

Set environment variables:

```bash
export SECRET_MANAGER_PROVIDER=aws
export AWS_REGION=us-east-1
export AWS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:outfitstyle-secrets-AbCdEf
```

### Step 6: Enable Secret Rotation (Optional)

```bash
aws secretsmanager rotate-secret \
  --secret-id outfitstyle-secrets \
  --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation \
  --rotation-rules AutomaticallyAfterDays=90
```

---

## GCP Secret Manager Setup

### Step 1: Enable Secret Manager API

```bash
gcloud services enable secretmanager.googleapis.com
```

### Step 2: Create Secrets

Create each secret individually:

```bash
# JWT Secret
echo -n "REPLACE_WITH_SECURE_RANDOM_STRING_MIN_256_BITS" | \
  gcloud secrets create JWT_SECRET \
  --data-file=- \
  --replication-policy="automatic"

# Admin API Key
echo -n "REPLACE_WITH_SECURE_ADMIN_KEY" | \
  gcloud secrets create ADMIN_API_KEY \
  --data-file=- \
  --replication-policy="automatic"

# API Key Pepper
echo -n "REPLACE_WITH_SECURE_RANDOM_PEPPER" | \
  gcloud secrets create API_KEY_PEPPER \
  --data-file=- \
  --replication-policy="automatic"

# OpenWeather API Key
echo -n "your-openweather-api-key" | \
  gcloud secrets create OPENWEATHER_API_KEY \
  --data-file=- \
  --replication-policy="automatic"

# Redis Password
echo -n "your-redis-password" | \
  gcloud secrets create REDIS_PASSWORD \
  --data-file=- \
  --replication-policy="automatic"

# SMTP Password
echo -n "your-smtp-password" | \
  gcloud secrets create SMTP_PASSWORD \
  --data-file=- \
  --replication-policy="automatic"

# S3 Secret Key
echo -n "your-s3-secret-key" | \
  gcloud secrets create S3_SECRET_KEY \
  --data-file=- \
  --replication-policy="automatic"

# YooKassa Secret
echo -n "your-yookassa-secret" | \
  gcloud secrets create YOOKASSA_SECRET_KEY \
  --data-file=- \
  --replication-policy="automatic"

# Stripe Secret
echo -n "your-stripe-secret" | \
  gcloud secrets create STRIPE_SECRET_KEY \
  --data-file=- \
  --replication-policy="automatic"

# Stripe Webhook Secret
echo -n "your-stripe-webhook-secret" | \
  gcloud secrets create STRIPE_WEBHOOK_SECRET \
  --data-file=- \
  --replication-policy="automatic"
```

### Step 3: Create Service Account

```bash
gcloud iam service-accounts create outfitstyle-api \
  --display-name="OutfitStyle API Service Account"
```

### Step 4: Grant Secret Access

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:outfitstyle-api@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### Step 5: Configure Application

For GKE:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: outfitstyle-api
  annotations:
    iam.gke.io/gcp-service-account: outfitstyle-api@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

For Cloud Run:

```bash
gcloud run deploy outfitstyle-api \
  --image gcr.io/YOUR_PROJECT_ID/outfitstyle-api \
  --service-account outfitstyle-api@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars SECRET_MANAGER_PROVIDER=gcp,GCP_PROJECT_ID=YOUR_PROJECT_ID
```

---

## HashiCorp Vault Setup

### Step 1: Install Vault

Follow the [official Vault installation guide](https://www.vaultproject.io/docs/install).

### Step 2: Initialize and Unseal Vault

```bash
# Initialize Vault
vault operator init

# Unseal Vault (use 3 of 5 unseal keys)
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>

# Login with root token
vault login <root-token>
```

### Step 3: Enable KV Secrets Engine

```bash
vault secrets enable -path=secret kv-v2
```

### Step 4: Create Secrets

```bash
vault kv put secret/outfitstyle \
  JWT_SECRET="REPLACE_WITH_SECURE_RANDOM_STRING_MIN_256_BITS" \
  ADMIN_API_KEY="REPLACE_WITH_SECURE_ADMIN_KEY" \
  API_KEY_PEPPER="REPLACE_WITH_SECURE_RANDOM_PEPPER" \
  OPENWEATHER_API_KEY="your-openweather-api-key" \
  REDIS_PASSWORD="your-redis-password" \
  SMTP_PASSWORD="your-smtp-password" \
  S3_SECRET_KEY="your-s3-secret-key" \
  YOOKASSA_SECRET_KEY="your-yookassa-secret" \
  STRIPE_SECRET_KEY="your-stripe-secret" \
  STRIPE_WEBHOOK_SECRET="your-stripe-webhook-secret"
```

### Step 5: Create Policy

Create a policy file `outfitstyle-policy.hcl`:

```hcl
path "secret/data/outfitstyle" {
  capabilities = ["read"]
}
```

Apply the policy:

```bash
vault policy write outfitstyle outfitstyle-policy.hcl
```

### Step 6: Create Token or AppRole

**Option A: Token-based authentication**

```bash
vault token create -policy=outfitstyle -ttl=720h
```

**Option B: AppRole authentication (recommended for production)**

```bash
# Enable AppRole
vault auth enable approle

# Create role
vault write auth/approle/role/outfitstyle \
  token_policies="outfitstyle" \
  token_ttl=1h \
  token_max_ttl=4h

# Get role ID
vault read auth/approle/role/outfitstyle/role-id

# Generate secret ID
vault write -f auth/approle/role/outfitstyle/secret-id
```

### Step 7: Configure Application

```bash
export SECRET_MANAGER_PROVIDER=vault
export VAULT_ADDR=https://vault.example.com:8200
export VAULT_TOKEN=<your-token>
export VAULT_SECRET_PATH=secret/data/outfitstyle
```

---

## Kubernetes Integration

### AWS Secrets Manager with IRSA

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: outfitstyle-api
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/OutfitStyleServiceRole
---
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

### GCP Secret Manager with Workload Identity

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: outfitstyle-api
  annotations:
    iam.gke.io/gcp-service-account: outfitstyle-api@YOUR_PROJECT_ID.iam.gserviceaccount.com
---
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
        image: gcr.io/YOUR_PROJECT_ID/outfitstyle-api:latest
        env:
        - name: SECRET_MANAGER_PROVIDER
          value: "gcp"
        - name: GCP_PROJECT_ID
          value: "YOUR_PROJECT_ID"
```

### Vault with Kubernetes Auth

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: outfitstyle-api
spec:
  template:
    spec:
      containers:
      - name: api
        image: outfitstyle/api:latest
        env:
        - name: SECRET_MANAGER_PROVIDER
          value: "vault"
        - name: VAULT_ADDR
          value: "https://vault.example.com:8200"
        - name: VAULT_TOKEN
          valueFrom:
            secretKeyRef:
              name: vault-token
              key: token
        - name: VAULT_SECRET_PATH
          value: "secret/data/outfitstyle"
```

---

## Docker Compose Integration

### With AWS Secrets Manager

```yaml
version: '3.8'
services:
  api:
    image: outfitstyle/api:latest
    environment:
      SECRET_MANAGER_PROVIDER: aws
      AWS_REGION: us-east-1
      AWS_SECRET_ARN: arn:aws:secretsmanager:us-east-1:123456789012:secret:outfitstyle-secrets-AbCdEf
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
```

### With Vault

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

---

## Testing Secret Manager Integration

### Test AWS Secrets Manager

```bash
# Set environment variables
export SECRET_MANAGER_PROVIDER=aws
export AWS_REGION=us-east-1
export AWS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:outfitstyle-secrets-AbCdEf

# Run the application
./bin/server.exe
```

### Test GCP Secret Manager

```bash
# Set environment variables
export SECRET_MANAGER_PROVIDER=gcp
export GCP_PROJECT_ID=your-project-id

# Authenticate
gcloud auth application-default login

# Run the application
./bin/server.exe
```

### Test Vault

```bash
# Set environment variables
export SECRET_MANAGER_PROVIDER=vault
export VAULT_ADDR=https://vault.example.com:8200
export VAULT_TOKEN=your-token
export VAULT_SECRET_PATH=secret/data/outfitstyle

# Run the application
./bin/server.exe
```

---

## Monitoring and Alerts

### CloudWatch Alarms (AWS)

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name outfitstyle-secrets-access-errors \
  --alarm-description "Alert on Secrets Manager access errors" \
  --metric-name UserErrorCount \
  --namespace AWS/SecretsManager \
  --statistic Sum \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold
```

### GCP Monitoring

```bash
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Secret Manager Access Errors" \
  --condition-display-name="High error rate" \
  --condition-threshold-value=5 \
  --condition-threshold-duration=300s
```

---

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Verify IAM roles/policies are correctly attached
   - Check service account has necessary permissions
   - Ensure secret ARN/name is correct

2. **Secret Not Found**
   - Verify secret exists in the correct region/project
   - Check secret name matches exactly (case-sensitive)
   - Ensure secret path is correct for Vault

3. **Network Connectivity**
   - Verify network access to secret manager endpoint
   - Check firewall rules allow outbound HTTPS
   - Ensure VPC endpoints are configured (AWS)

4. **Authentication Failures**
   - Verify credentials are valid and not expired
   - Check token has necessary permissions
   - Ensure service account key is valid (GCP)

### Debug Mode

Enable debug logging:

```bash
export LOG_LEVEL=debug
./bin/server.exe
```

Check logs for secret manager operations and errors.
