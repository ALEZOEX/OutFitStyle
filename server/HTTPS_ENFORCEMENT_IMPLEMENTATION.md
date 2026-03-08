# HTTPS Enforcement Implementation

## Overview

This document describes the implementation of HTTPS enforcement for the OutfitStyle API server, addressing security requirement 2.13 from the security audit.

## Implementation Details

### 1. HTTPS Redirect Middleware

**File**: `internal/api/middleware/https_redirect.go`

The HTTPS redirect middleware automatically redirects all HTTP requests to HTTPS in production environments.

**Key Features**:
- **301 Moved Permanently**: Uses HTTP 301 status code to tell clients to always use HTTPS
- **Development Exception**: Allows HTTP in `development` and `local` environments for easier local testing
- **Reverse Proxy Support**: Checks `X-Forwarded-Proto` header for proper detection behind load balancers
- **Port Handling**: Automatically removes default HTTP port (80) from redirect URL

**Usage**:
```go
router.Use(middleware.HTTPSRedirectMiddleware(cfg.Server.Environment))
```

### 2. HSTS Header

**File**: `internal/api/middleware/middleware.go`

The SecurityHeadersMiddleware sets the Strict-Transport-Security (HSTS) header on all responses.

**Configuration**:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

**Parameters**:
- `max-age=31536000`: 1 year (365 days) - browsers will enforce HTTPS for this duration
- `includeSubDomains`: Apply HSTS to all subdomains
- `preload`: Eligible for browser HSTS preload lists

### 3. TLS Configuration

**File**: `cmd/server/main.go`

The HTTP server is configured with strong TLS settings:

**Minimum TLS Version**: TLS 1.2
- Blocks older, insecure protocols (SSL 3.0, TLS 1.0, TLS 1.1)

**Cipher Suites** (in order of preference):
1. **TLS 1.3 Cipher Suites** (most secure):
   - `TLS_AES_128_GCM_SHA256`
   - `TLS_AES_256_GCM_SHA384`
   - `TLS_CHACHA20_POLY1305_SHA256`

2. **TLS 1.2 Cipher Suites** (strong):
   - `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
   - `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`
   - `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`
   - `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384`
   - `TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256`
   - `TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256`

**Additional Settings**:
- `PreferServerCipherSuites: true` - Server chooses cipher suite (prevents downgrade attacks)

### 4. Certificate Management

For production deployment, use one of the following approaches:

#### Option A: Let's Encrypt (Recommended for self-hosted)
```bash
# Install certbot
sudo apt-get install certbot

# Obtain certificate
sudo certbot certonly --standalone -d api.outfitstyle.com

# Certificates will be in:
# /etc/letsencrypt/live/api.outfitstyle.com/fullchain.pem
# /etc/letsencrypt/live/api.outfitstyle.com/privkey.pem

# Auto-renewal (certbot sets up cron job automatically)
sudo certbot renew --dry-run
```

Update server startup to use certificates:
```go
srv.ListenAndServeTLS(
    "/etc/letsencrypt/live/api.outfitstyle.com/fullchain.pem",
    "/etc/letsencrypt/live/api.outfitstyle.com/privkey.pem",
)
```

#### Option B: Cloud Provider Managed Certificates
- **AWS**: Use AWS Certificate Manager (ACM) with Application Load Balancer
- **GCP**: Use Google-managed SSL certificates with Cloud Load Balancing
- **Azure**: Use Azure App Service managed certificates

With cloud providers, TLS termination happens at the load balancer level, and the `X-Forwarded-Proto` header is used to detect HTTPS.

## Testing

### Unit Tests

**File**: `internal/api/middleware/https_redirect_test.go`

Tests cover:
- ✅ HTTP allowed in development environment
- ✅ HTTP redirected to HTTPS in production
- ✅ HTTPS passes through in production
- ✅ X-Forwarded-Proto header detection
- ✅ HTTP allowed in local environment

Run tests:
```bash
cd server
go test ./internal/api/middleware/https_redirect_test.go ./internal/api/middleware/https_redirect.go -v
```

### Manual Testing

#### Test HTTPS Redirect (Production)
```bash
# Set environment to production
export ENVIRONMENT=production

# Start server
go run cmd/server/main.go

# Test HTTP request (should redirect)
curl -v http://localhost:8080/health
# Expected: 301 Moved Permanently
# Location: https://localhost:8080/health
```

#### Test HTTP Allowed (Development)
```bash
# Set environment to development
export ENVIRONMENT=development

# Start server
go run cmd/server/main.go

# Test HTTP request (should work)
curl -v http://localhost:8080/health
# Expected: 200 OK
```

#### Test HSTS Header
```bash
# Make HTTPS request
curl -v https://api.outfitstyle.com/health

# Check response headers for:
# Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

## Security Benefits

1. **Man-in-the-Middle (MITM) Protection**: All traffic encrypted with TLS
2. **Protocol Downgrade Prevention**: HSTS prevents browsers from using HTTP
3. **Strong Encryption**: TLS 1.2+ with modern cipher suites
4. **Forward Secrecy**: ECDHE cipher suites provide forward secrecy
5. **Browser Preload**: Eligible for HSTS preload list (prevents first-request vulnerability)

## Deployment Checklist

- [ ] Set `ENVIRONMENT=production` in production
- [ ] Obtain valid SSL/TLS certificate (Let's Encrypt or cloud provider)
- [ ] Configure certificate paths in server startup
- [ ] Verify HTTPS redirect works (test with curl)
- [ ] Verify HSTS header is present in responses
- [ ] Test with SSL Labs (https://www.ssllabs.com/ssltest/) - should get A+ rating
- [ ] Consider submitting domain to HSTS preload list (https://hstspreload.org/)

## Compliance

This implementation satisfies:
- **Requirement 2.13**: HTTPS enforcement with HSTS headers
- **Requirement 3.13**: HTTPS content serves without mixed content warnings
- **Bug Condition**: `input.type == "SERVER_CONFIG" AND NOT input.enforcesHTTPS` - FIXED
- **Expected Behavior**: HTTP requests redirected to HTTPS, HSTS header present - ✅
- **Preservation**: HTTPS content serves without mixed content warnings - ✅

## References

- [OWASP Transport Layer Protection Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [HSTS Preload List](https://hstspreload.org/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
