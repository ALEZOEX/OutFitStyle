# Security Guidelines for OutfitStyle

## Authentication & Authorization

### JWT Token Management
- Use RS256 algorithm for asymmetric signing
- Short-lived access tokens (15-60 minutes)
- Refresh tokens with rotation
- Blacklist revoked tokens in Redis
- Validate issuer and audience claims

### OAuth 2.0 with Google
- Validate ID tokens on backend
- Verify `email_verified: true`
- Store minimal user data (email, name only)
- Don't store Google refresh tokens unless needed

## API Protection

### Rate Limiting
- Global: 10,000 req/min for entire service
- Per IP: 100 req/min (anonymous), 300 req/min (authenticated)
- Per User: 200 req/min
- Per Endpoint:
  - `/auth/*`: 10 req/min (brute force protection)
  - `/recommendations`: 30 req/min (heavy endpoint)
  - `/wardrobe/*`: 100 req/min

### Input Validation
- Validate at HTTP handler level
- Sanitize strings (trim, HTML escape)
- Limit payload size (max 1MB)
- Limit image uploads (max 5MB)
- Validate Content-Type headers

### SQL Injection Prevention
- Use parameterized queries only
- Never concatenate user input
- Use ORM or query builder instead of raw SQL

### CORS Configuration
- Allow only your domain in production
- Allow GET, POST, PUT, DELETE methods
- Allow Authorization and Content-Type headers
- Use credentials: true for cookies

## Data Protection

### In Transit
- TLS 1.3 everywhere
- HSTS header (Strict-Transport-Security)
- Certificate pinning in mobile app (optional)

### At Rest
- Disk encryption on servers
- Encrypted backups
- Password hashing with bcrypt/argon2

### Personal Identifiable Information (PII)
- Minimize collection: gather only necessary data
- Logs: mask emails, never log tokens
- Audit: who accessed what data when

## Security Headers

### Recommended Headers
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(self)
```

## Secrets Management

### Best Practices
- Never commit secrets to git
- Use environment variables in production
- Use SOPS for encrypting config files
- Rotate secrets regularly
- Use least privilege principle

### Secret Storage
- GitHub Secrets for CI/CD
- HashiCorp Vault for production (recommended)
- AWS/GCP KMS for cloud environments
- Kubernetes Secrets for containerized deployments

## Monitoring & Incident Response

### Security Monitoring
- Monitor for unusual API usage patterns
- Track failed authentication attempts
- Alert on schema changes to sensitive tables
- Log all access to PII data

### Incident Response
- Immediate notification for security events
- Predefined escalation procedures
- Regular security drills
- Post-incident analysis and improvements