# Security Logic Audit Fixes - Bugfix Design

## Overview

This design addresses 18 security vulnerabilities and logic flaws across the OutfitStyle multi-service application. The fixes span critical SQL injection vulnerabilities, CORS misconfigurations, weak authentication mechanisms, insufficient authorization checks, and missing security controls. The approach implements defense-in-depth security practices including input validation, proper authorization, secure token management, rate limiting, audit logging, and cryptographic protections. Each fix is designed to eliminate the vulnerability while preserving existing functionality for legitimate use cases.

## Glossary

- **Bug_Condition (C)**: The conditions that trigger each of the 18 security vulnerabilities
- **Property (P)**: The desired secure behavior that prevents exploitation of each vulnerability
- **Preservation**: Existing legitimate functionality that must remain unchanged by security fixes
- **SQL Injection**: Attack technique where malicious SQL code is inserted through user input
- **CORS (Cross-Origin Resource Sharing)**: Browser security mechanism controlling cross-origin HTTP requests
- **CSRF (Cross-Site Request Forgery)**: Attack forcing users to execute unwanted actions on authenticated applications
- **Refresh Token Rotation**: Security practice of invalidating old tokens when issuing new ones
- **Rate Limiting**: Technique to control request frequency from clients to prevent abuse
- **HMAC (Hash-based Message Authentication Code)**: Cryptographic signature for message authenticity
- **HSTS (HTTP Strict Transport Security)**: Security header forcing HTTPS connections
- **Constant-Time Comparison**: Algorithm that takes the same time regardless of input to prevent timing attacks
- **Defense-in-Depth**: Security strategy using multiple layers of protection

## Bug Details

### Bug Condition

The bugs manifest across multiple security domains when the application processes untrusted input, configures security controls, or performs sensitive operations without proper validation and protection mechanisms.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type SecurityContext
  OUTPUT: boolean

  RETURN (
    // Critical: SQL Injection
    (input.type == "SQL_QUERY" AND input.hasUnsanitizedUserInput) OR

    // Critical: CORS Misconfiguration
    (input.type == "CORS_CONFIG" AND input.allowsWildcardWithCredentials) OR

    // High: Weak Password Policy
    (input.type == "PASSWORD_REGISTRATION" AND NOT input.meetsStrongRequirements) OR

    // High: Token Replay
    (input.type == "REFRESH_TOKEN_USE" AND NOT input.invalidatesOldToken) OR

    // High: Plaintext Secrets
    (input.type == "SECRET_STORAGE" AND input.isPlaintext) OR

    // High: Insufficient Input Validation
    (input.type == "ML_REQUEST" AND NOT input.hasStrictValidation) OR

    // High: Unsigned Messages
    (input.type == "KAFKA_EVENT" AND NOT input.isSigned) OR

    // High: No Rate Limiting
    (input.type == "AUTH_ENDPOINT" AND NOT input.hasRateLimit) OR

    // High: Missing Authorization
    (input.type == "RESOURCE_ACCESS" AND NOT input.verifiesOwnership) OR

    // High: Weak Session Management
    (input.type == "SESSION_CREATION" AND NOT input.hasTimeoutOrLimits) OR

    // Medium: Information Disclosure
    (input.type == "ERROR_RESPONSE" AND input.exposesInternalDetails) OR

    // Medium: Missing Security Headers
    (input.type == "HTTP_RESPONSE" AND NOT input.hasSecurityHeaders) OR

    // Medium: No HTTPS Enforcement
    (input.type == "SERVER_CONFIG" AND NOT input.enforcesHTTPS) OR

    // Medium: No Audit Logging
    (input.type == "SENSITIVE_OPERATION" AND NOT input.isAudited) OR

    // Medium: Timing Attack Vulnerability
    (input.type == "SECRET_COMPARISON" AND NOT input.usesConstantTime) OR

    // Low: No Vulnerability Scanning
    (input.type == "DEPENDENCY_MANAGEMENT" AND NOT input.hasVulnScanning) OR

    // Low: Insufficient Rate Limiting
    (input.type == "API_REQUEST" AND NOT input.hasPerUserRateLimit) OR

    // Low: Inconsistent Input Sani
oken indefinitely for new access tokens
- Plaintext Secrets: Admin API key stored as `ADMIN_KEY=secret123` → Exposed in logs/environment dumps
- ML DoS: Attacker sends `candidateCount=999999999` → System crashes or hangs
- Event Injection: Attacker publishes unsigned Kafka event → System processes malicious event
- Account Enumeration: Attacker tries 10000 registration attempts → System allows unlimited attempts
- Unauthorized Access: User A requests `/wardrobe/user-b-item-123` → System returns User B's data
- Session Hijacking: Attacker steals session token → Can use indefinitely without timeout

**Medium Severity Issues:**
- Information Disclosure: Database error occurs → System returns `"error: pq: duplicate key violates unique constraint users_email_key"`
- Missing Headers: Response lacks `X-Permitted-Cross-Domain-Policies` → Reduced defense against attacks
- No HTTPS: User accesses `http://api.outfitstyle.com` → Connection not upgraded to HTTPS
- No Audit Trail: Admin deletes user account → No log of who performed action
- Timing Attack: Attacker measures API key comparison time → Can guess key character by character

**Low Severity Issues:**
- Vulnerable Dependencies: Application uses library with known CVE → No automated detection
- IP-based Rate Limiting: Authenticated user can bypass limits by changing IP → Insufficient protection
- Inconsistent Sanitization: Some endpoints escape HTML, others don't → Potential XSS vulnerabilities

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Legitimate wardrobe operations with valid sort parameters must continue to return correctly sorted results
- Cross-origin requests from configured allowed origins must continue to work with proper CORS headers
- Users with strong passwords must continue to register and authenticate successfully
- Valid refresh tokens used for the first time must continue to issue new access tokens
- Admin operations with properly secured API keys must continue to authorize correctly
- ML service must continue to process valid requests with same accuracy and performance
- Legitimate Kafka events from authorized services must continue to process with same throughput
- Authentication requests within rate limits must continue without delays
- Users accessing their own resources must continue without additional friction
- Active sessions within timeout periods must continue without re-authentication
- User-facing validation errors must continue to provide helpful messages
- Application pages must continue to display correctly with security headers
- HTTPS content must continue to serve without mixed content warnings
- Normal operations must continue to log at appropriate levels without performance impact
- Correct authentication operations must continue with same response times
- Up-to-date dependencies must continue to function with all features working
- API requests within rate limits must continue without throttling
- Properly formatted input must continue to process correctly without data loss

**Scope:**
All inputs that do NOT trigger the 18 identified bug conditions should be completely unaffected by these fixes. This includes:
- Valid, properly formatted requests from legitimate users
- Authorized operations on owned resources
- Requests from allowed origins with proper authentication
- Operations within rate limits and security thresholds
- Well-formed data that passes validation checks

## Hypothesized Root Cause

Based on the comprehensive security audit, the root causes fall into several categories:

1. **Insufficient Input Validation**: The application trusts user input without proper sanitization
   - SQL queries constructed with string formatting instead of parameterized queries
   - ML service accepts unbounded numeric inputs
   - Inconsistent sanitization across different entry points

2. **Insecure Default Configurations**: Security controls use permissive defaults
   - CORS middleware allows wildcard origin with credentials
   - Password policy only checks minimum length
   - No HTTPS enforcement or HSTS headers by default

3. **Missing Security Controls**: Critical security mechanisms not implemented
   - No rate limiting on authentication endpoints
   - No authorization checks for resource ownership
   - No session timeouts or concurrent session limits
   - No audit logging for sensitive operations

4. **Weak Cryptographic Practices**: Improper handling of secrets and tokens
   - Secrets stored in plaintext environment variables
   - Refresh tokens not invalidated after use
   - Secret comparisons vulnerable to timing attacks

5. **Lack of Message Authentication**: Event-driven architecture without integrity verification
   - Kafka messages not signed or verified
   - Allows malicious event injection

6. **Information Leakage**: Excessive error details exposed to clients
   - Database errors and stack traces returned in responses
   - Missing security headers reduce defense-in-depth

7. **Inadequate Monitoring**: No automated security checks
   - No vulnerability scanning in CI/CD pipeline
   - No comprehensive audit trails for incident investigation

## Correctness Properties

Property 1: Bug Condition - Security Vulnerabilities Eliminated

_For any_ input where any of the 18 bug conditions hold (isBugCondition returns true), the fixed system SHALL reject, sanitize, or properly handle the input according to security best practices, preventing exploitation of SQL injection, CORS bypass, weak authentication, unauthorized access, information disclosure, and all other identified vulnerabilities.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11, 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18**

Property 2: Preservation - Legitimate Functionality Maintained

_For any_ input where none of the 18 bug conditions hold (isBugCondition returns false), the fixed system SHALL produce exactly the same behavior as the original system, preserving all legitimate functionality including wardrobe operations, authentication flows, ML recommendations, event processing, API responses, and user experience.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13, 3.14, 3.15, 3.16, 3.17, 3.18**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct, the following changes are required across multiple services:

#### Fix 1: SQL Injection Prevention

**File**: `internal/wardrobe/repository/postgres/wardrobe_repository.go`

**Function**: `List(ctx context.Context, userID string, filters WardrobeFilters) ([]Wardrobe, error)`

**Specific Changes**:
1. **Whitelist Validation**: Create a map of allowed sort fields and directions
   - Allowed fields: `["name", "created_at", "updated_at", "category"]`
   - Allowed directions: `["ASC", "DESC"]`
2. **Input Validation**: Check orderField and orderDir against whitelist before query construction
3. **Parameterized Queries**: Use PostgreSQL parameter placeholders for all user input
4. **Error Handling**: Return validation error if invalid sort parameters provided

#### Fix 2: CORS Configuration Hardening

**File**: `cmd/api/main.go` or `internal/middleware/cors.go`

**Function**: CORS middleware initialization

**Specific Changes**:
1. **Explicit Origins**: Load allowed origins from configuration (e.g., `["https://outfitstyle.com", "https://app.outfitstyle.com"]`)
2. **Remove Wildcard**: Never use `AllowOrigins: []string{"*"}` with `AllowCredentials: true`
3. **Origin Validation**: Implement strict origin header validation against whitelist
4. **Configuration**: Add environment variable `ALLOWED_ORIGINS` with comma-separated list

#### Fix 3: Strong Password Policy

**File**: `internal/auth/service/auth_service.go`

**Function**: `Register(ctx context.Context, email, password string) error`

**Specific Changes**:
1. **Length Check**: Enforce minimum 12 characters (increased from 8)
2. **Complexity Requirements**: Require at least one uppercase, lowercase, number, and special character
3. **Common Password Check**: Integrate check against top 10,000 common passwords list
4. **Entropy Calculation**: Optionally calculate password entropy and enforce minimum threshold
5. **Clear Error Messages**: Return specific validation failures to help users create strong passwords

#### Fix 4: Refresh Token Rotation

**File**: `internal/auth/service/token_service.go`

**Function**: `RefreshAccessToken(ctx context.Context, refreshToken string) (string, string, error)`

**Specific Changes**:
1. **Token Invalidation**: Mark old refresh token as used/invalid in database immediately after validation
2. **New Token Generation**: Generate new refresh token along with new access token
3. **Replay Detection**: Check if token has already been used; if yes, invalidate all tokens for that user (potential compromise)
4. **Atomic Operation**: Use database transaction to ensure token rotation is atomic
5. **Return Both Tokens**: Return both new access token and new refresh token to client

#### Fix 5: Secure Secret Management

**File**: `internal/config/config.go` and deployment configuration

**Function**: Configuration loading and secret management

**Specific Changes**:
1. **Secret Manager Integration**: Use cloud provider secret manager (AWS Secrets Manager, GCP Secret Manager, or HashiCorp Vault)
2. **Encrypted Storage**: Ensure secrets are encrypted at rest in secret manager
3. **Runtime Loading**: Load secrets at application startup from secure storage, not environment variables
4. **Access Control**: Implement IAM policies restricting secret access to authorized services only
5. **Rotation Support**: Design for secret rotation without application restart

#### Fix 6: ML Service Input Validation

**File**: `ml-service/app/api/routes.py` or `ml-service/app/services/recommendation_service.py`

**Function**: Request validation for ML recommendation endpoints

**Specific Changes**:
1. **Candidate Count Bounds**: Enforce maximum candidate count (e.g., 1-100)
2. **Weather Data Validation**: Validate temperature range (-50 to 50°C), humidity (0-100%), weather type enum
3. **Type Checking**: Ensure all numeric fields are valid numbers, not strings or special values
4. **Request Size Limits**: Enforce maximum request body size
5. **Schema Validation**: Use Pydantic models or similar for strict schema enforcement

#### Fix 7: Kafka Message Signing

**File**: `internal/events/publisher.go` and `internal/events/consumer.go`

**Function**: Event publishing and consumption

**Specific Changes**:
1. **HMAC Signing**: Generate HMAC-SHA256 signature for each message using shared secret
2. **Signature Header**: Add signature to Kafka message headers
3. **Signature Verification**: Verify signature on consumption before processing
4. **Key Management**: Store signing keys in secure secret manager
5. **Rejection Logic**: Reject and log unsigned or invalid signature messages

#### Fix 8: Authentication Rate Limiting

**File**: `internal/middleware/rate_limiter.go`

**Function**: Rate limiting middleware for authentication endpoints

**Specific Changes**:
1. **Per-IP Limits**: Implement rate limit per IP address (e.g., 5 attempts per 15 minutes)
2. **Per-Email Limits**: Implement rate limit per email address (e.g., 3 attempts per hour)
3. **Exponential Backoff**: Increase delay after each failed attempt
4. **CAPTCHA Integration**: Require CAPTCHA after threshold violations (e.g., 3 failed attempts)
5. **Redis Backend**: Use Redis for distributed rate limiting across multiple instances

#### Fix 9: Resource Ownership Authorization

**File**: `internal/wardrobe/service/wardrobe_service.go`

**Function**: All resource access methods (Get, Update, Delete)

**Specific Changes**:
1. **Ownership Check**: Query resource to verify `user_id` matches authenticated user before any operation
2. **Authorization Middleware**: Create reusable authorization middleware for resource ownership
3. **403 Forbidden**: Return HTTP 403 (not 404) when user attempts to access others' resources
4. **Audit Logging**: Log all authorization failures with user ID, resource ID, and attempted action
5. **Consistent Application**: Apply to all resource types (wardrobe items, outfits, preferences)

#### Fix 10: Session Management Enhancement

**File**: `internal/auth/service/session_service.go`

**Function**: Session creation and management

**Specific Changes**:
1. **Session Timeout**: Implement configurable idle timeout (e.g., 30 minutes) and absolute timeout (e.g., 24 hours)
2. **Device Fingerprinting**: Track user agent, IP address, and browser fingerprint for each session
3. **Concurrent Session Limits**: Allow configurable max concurrent sessions per user (e.g., 5 devices)
4. **Session Revocation**: Provide API for users to view and revoke active sessions
5. **Database Schema**: Add sessions table with columns: session_id, user_id, device_fingerprint, created_at, last_activity, expires_at

#### Fix 11: Error Message Sanitization

**File**: `internal/middleware/error_handler.go`

**Function**: Global error handling middleware

**Specific Changes**:
1. **Generic Client Messages**: Return generic messages like "Internal server error" or "Invalid request"
2. **Detailed Server Logging**: Log full error details including stack traces to server logs only
3. **Error Classification**: Categorize errors (validation, not found, unauthorized, internal) and return appropriate messages
4. **No Stack Traces**: Never include stack traces in client responses
5. **Structured Logging**: Use structured logging (JSON) for easy parsing and analysis

#### Fix 12: Security Headers Implementation

**File**: `internal/middleware/security_headers.go`

**Function**: Security headers middleware

**Specific Changes**:
1. **X-Permitted-Cross-Domain-Policies**: Set to `none` to prevent Flash/PDF cross-domain access
2. **Referrer-Policy**: Set to `strict-origin-when-cross-origin` to limit referrer information
3. **Permissions-Policy**: Restrict browser features (e.g., `geolocation=(), microphone=(), camera=()`)
4. **X-Content-Type-Options**: Set to `nosniff` to prevent MIME type sniffing
5. **X-Frame-Options**: Set to `DENY` or `SAMEORIGIN` to prevent clickjacking

#### Fix 13: HTTPS Enforcement

**File**: `cmd/api/main.go` and `internal/middleware/https_redirect.go`

**Function**: Server configuration and HTTPS redirection

**Specific Changes**:
1. **HTTP to HTTPS Redirect**: Implement middleware to redirect all HTTP requests to HTTPS
2. **HSTS Header**: Set `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
3. **TLS Configuration**: Enforce TLS 1.2+ with strong cipher suites
4. **Certificate Management**: Use automated certificate renewal (Let's Encrypt or cloud provider)
5. **Development Exception**: Allow HTTP only in local development environment

#### Fix 14: Comprehensive Audit Logging

**File**: `internal/audit/audit_logger.go`

**Function**: Audit logging service

**Specific Changes**:
1. **Audit Events**: Log authentication (login, logout, registration), authorization failures, data access, configuration changes
2. **Structured Format**: Include user_id, timestamp, action, resource_type, resource_id, ip_address, user_agent, outcome (success/failure)
3. **Separate Log Stream**: Write audit logs to dedicated log stream or database table
4. **Immutable Storage**: Ensure audit logs cannot be modified or deleted by application
5. **Retention Policy**: Implement appropriate retention (e.g., 90 days minimum for compliance)

#### Fix 15: Constant-Time Secret Comparison

**File**: Multiple files where secrets are compared (`internal/auth/service/auth_service.go`, `internal/middleware/api_key_auth.go`)

**Function**: Password verification, API key validation, token comparison

**Specific Changes**:
1. **Use subtle.ConstantTimeCompare**: Replace `==` or `strings.Compare` with `subtle.ConstantTimeCompare` from `crypto/subtle`
2. **Hash Comparison**: For password hashes, use `bcrypt.CompareHashAndPassword` which is already constant-time
3. **API Key Validation**: Apply constant-time comparison for API key checks
4. **Token Validation**: Apply constant-time comparison for token validation
5. **Consistent Application**: Audit all secret comparison code paths

#### Fix 16: Automated Vulnerability Scanning

**File**: `.github/workflows/security-scan.yml` or CI/CD pipeline configuration

**Function**: CI/CD security scanning integration

**Specific Changes**:
1. **Dependency Scanning**: Integrate `govulncheck` for Go dependencies, `pip-audit` or `safety` for Python
2. **Automated Alerts**: Configure alerts for high/critical vulnerabilities
3. **PR Checks**: Run vulnerability scans on every pull request
4. **Scheduled Scans**: Run daily scans on main branch
5. **Fail Build**: Optionally fail builds on high-severity vulnerabilities

#### Fix 17: Per-User API Rate Limiting

**File**: `internal/middleware/rate_limiter.go`

**Function**: API rate limiting middleware

**Specific Changes**:
1. **User-Based Limits**: Implement rate limits based on authenticated user ID (e.g., 1000 requests per hour)
2. **API Key Limits**: Implement separate limits for API key authentication
3. **Anonymous Limits**: Stricter limits for unauthenticated requests by IP (e.g., 100 requests per hour)
4. **Endpoint-Specific Limits**: Different limits for different endpoint categories (read vs write operations)
5. **Rate Limit Headers**: Return `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers

#### Fix 18: Consistent Input Sanitization

**File**: Multiple files across all services

**Function**: Input validation and sanitization at all entry points

**Specific Changes**:
1. **Centralized Validation**: Create shared validation library with context-aware sanitization functions
2. **HTML Escaping**: Use `html.EscapeString` for HTML contexts
3. **SQL Parameterization**: Use parameterized queries for all database operations
4. **JSON Encoding**: Use proper JSON encoding for JSON responses
5. **Validation Framework**: Apply validation consistently at API boundary using middleware or request validators

## Testing Strategy

### Validation Approach

The testing strategy follows a three-phase approach: first, demonstrate each vulnerability on unfixed code through exploratory testing; second, verify fixes prevent exploitation; third, ensure legitimate functionality is preserved. Given the breadth of 18 distinct security issues, testing will be organized by severity tier and security domain.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate each of the 18 vulnerabilities BEFORE implementing fixes. Confirm root cause analysis for each issue. If we refute any hypothesis, we will need to re-analyze that specific vulnerability.

**Test Plan**: Write security tests that attempt to exploit each vulnerability. Run these tests on the UNFIXED code to observe failures and confirm the security issues exist as described.

**Test Cases by Severity:**

**Critical Vulnerabilities:**
1. **SQL Injection Test**: Send `orderField="name; DROP TABLE users--"` to wardrobe list endpoint (will succeed on unfixed code, executing malicious SQL)
2. **CORS Bypass Test**: Make authenticated request from `http://evil.com` with credentials (will succeed on unfixed code due to wildcard origin)

**High Severity Vulnerabilities:**
3. **Weak Password Test**: Register with `password123` (will succeed on unfixed code)
4. **Token Replay Test**: Use same refresh token twice to get multiple access tokens (will succeed on unfixed code)
5. **Secret Exposure Test**: Check environment variables or logs for plaintext API keys (will find exposed secrets on unfixed code)
6. **ML DoS Test**: Send request with `candidateCount=999999999` (will cause resource exhaustion on unfixed code)
7. **Event Injection Test**: Publish unsigned Kafka event to topic (will be processed on unfixed code)
8. **Rate Limit Bypass Test**: Send 10000 registration requests rapidly (will succeed on unfixed code)
9. **Authorization Bypass Test**: User A requests User B's wardrobe item (will return data on unfixed code)
10. **Session Hijacking Test**: Use stolen session token after 24 hours (will still work on unfixed code)

**Medium Severity Vulnerabilities:**
11. **Information Disclosure Test**: Trigger database error and check response (will expose details on unfixed code)
12. **Missing Headers Test**: Check HTTP response for security headers (will be missing on unfixed code)
13. **HTTP Downgrade Test**: Access API via HTTP (will not redirect on unfixed code)
14. **Audit Gap Test**: Perform sensitive operation and check logs (will have no audit trail on unfixed code)
15. **Timing Attack Test**: Measure API key comparison time with correct vs incorrect keys (will show timing difference on unfixed code)

**Low Severity Vulnerabilities:**
16. **Vulnerable Dependency Test**: Run `govulncheck` on dependencies (will find vulnerabilities on unfixed code)
17. **Rate Limit Evasion Test**: Authenticated user makes excessive requests (will not be limited on unfixed code)
18. **Sanitization Gap Test**: Submit HTML in input fields and check for XSS (may succeed on unfixed code)

**Expected Counterexamples:**
- SQL injection allows arbitrary SQL execution
- CORS wildcard allows CSRF from any origin
- Weak passwords are accepted
- Refresh tokens can be reused indefinitely
- Secrets are visible in plaintext
- ML service accepts unbounded inputs causing DoS
- Unsigned Kafka events are processed
- No rate limiting allows unlimited authentication attempts
- Users can access others' resources
- Sessions never expire
- Error messages expose internal details
- Security headers are missing
- HTTP connections are not upgraded
- No audit logs for sensitive operations
- Secret comparisons are vulnerable to timing attacks
- Dependencies have known vulnerabilities
- Rate limits don't apply per user
- Input sanitization is inconsistent

### Fix Checking

**Goal**: Verify that for all inputs where any of the 18 bug conditions hold, the fixed system prevents exploitation and enforces security controls.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := securitySystem_fixed(input)
  ASSERT expectedSecureBehavior(result)
END FOR
```

**Verification by Fix:**

1. **SQL Injection**: Verify malicious SQL is rejected or sanitized, no SQL execution occurs
2. **CORS**: Verify wildcard origin is not allowed with credentials, only whitelisted origins accepted
3. **Weak Password**: Verify passwords not meeting strong requirements are rejected with clear error
4. **Token Replay**: Verify reused refresh tokens are rejected, new tokens issued on first use only
5. **Secret Exposure**: Verify secrets are loaded from secure storage, not visible in environment
6. **ML Validation**: Verify out-of-bounds inputs are rejected with 400 Bad Request
7. **Message Signing**: Verify unsigned or invalid signature messages are rejected
8. **Rate Limiting**: Verify excessive authentication attempts are blocked, CAPTCHA required
9. **Authorization**: Verify unauthorized resource access returns 403 Forbidden
10. **Session Management**: Verify sessions expire after timeout, concurrent sessions limited
11. **Error Sanitization**: Verify generic error messages returned, no internal details exposed
12. **Security Headers**: Verify all required security headers present in responses
13. **HTTPS Enforcement**: Verify HTTP requests redirected to HTTPS, HSTS header present
14. **Audit Logging**: Verify sensitive operations logged with all required fields
15. **Constant-Time**: Verify secret comparisons use constant-time functions
16. **Vulnerability Scanning**: Verify CI/CD pipeline runs security scans, alerts on vulnerabilities
17. **Per-User Rate Limiting**: Verify rate limits applied per authenticated user
18. **Input Sanitization**: Verify all inputs sanitized appropriately for context

### Preservation Checking

**Goal**: Verify that for all inputs where none of the 18 bug conditions hold, the fixed system produces the same result as the original system, preserving all legitimate functionality.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT originalSystem(input) = fixedSystem(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all legitimate inputs
- With 18 different fixes, manual testing of all combinations would be impractical

**Test Plan**: Observe behavior on UNFIXED code first for legitimate operations, then write property-based tests capturing that behavior to ensure it's preserved after fixes.

**Test Cases by Preservation Requirement:**

1. **Valid Sort Parameters**: Verify wardrobe list with valid sort fields returns same results
2. **Allowed Origins**: Verify CORS requests from whitelisted origins work identically
3. **Strong Passwords**: Verify registration with strong passwords succeeds as before
4. **First Token Use**: Verify first-time refresh token use issues new tokens successfully
5. **Admin Operations**: Verify admin API operations work with secured keys
6. **Valid ML Requests**: Verify ML recommendations with valid inputs return same results
7. **Signed Events**: Verify legitimate Kafka events process with same throughput
8. **Within Rate Limits**: Verify authentication requests within limits process without delay
9. **Own Resources**: Verify users accessing own resources experience no friction
10. **Active Sessions**: Verify sessions within timeout remain active
11. **User-Facing Errors**: Verify validation errors still provide helpful messages
12. **Page Rendering**: Verify application pages display correctly with security headers
13. **HTTPS Content**: Verify HTTPS content serves without mixed content warnings
14. **Normal Logging**: Verify operational logs continue at appropriate levels
15. **Correct Authentication**: Verify successful authentication has same response time
16. **Current Dependencies**: Verify application functions correctly with up-to-date dependencies
17. **Within API Limits**: Verify API requests within limits process without throttling
18. **Valid Input**: Verify properly formatted input processes without data loss

### Unit Tests

**Critical Security Tests:**
- Test SQL injection prevention with various malicious payloads (UNION, DROP, comment injection)
- Test CORS configuration with different origin combinations (allowed, disallowed, wildcard attempts)

**High Severity Tests:**
- Test password validation with weak passwords, strong passwords, edge cases (all numbers, all letters, special chars only)
- Test refresh token rotation with sequential uses, concurrent uses, replay attempts
- Test secret loading from secure storage, verify no plaintext in environment
- Test ML input validation with boundary values, negative numbers, extremely large numbers, non-numeric inputs
- Test Kafka message signing and verification with valid signatures, invalid signatures, missing signatures, tampered messages
- Test rate limiting with burst requests, sustained requests, distributed requests
- Test authorization checks for owned resources, others' resources, non-existent resources
- Test session timeout with idle sessions, active sessions, expired sessions, concurrent sessions

**Medium Severity Tests:**
- Test error handling with database errors, validation errors, internal errors, verify generic messages
- Test security headers presence and correct values in all response types
- Test HTTPS redirection from HTTP, HSTS header values, TLS configuration
- Test audit logging for authentication events, authorization failures, data access, configuration changes
- Test constant-time comparison with matching secrets, non-matching secrets, different lengths

**Low Severity Tests:**
- Test vulnerability scanning integration in CI/CD pipeline
- Test per-user rate limiting with authenticated requests, API key requests, anonymous requests
- Test input sanitization for HTML contexts, SQL contexts, JSON contexts, URL contexts

### Property-Based Tests

**Security Properties:**
- Generate random SQL injection payloads → verify all are rejected or sanitized
- Generate random origin headers → verify only whitelisted origins allowed with credentials
- Generate random passwords → verify only those meeting requirements are accepted
- Generate random token sequences → verify replay detection works for all patterns
- Generate random ML inputs → verify all out-of-bounds inputs rejected
- Generate random Kafka messages → verify all unsigned messages rejected
- Generate random request patterns → verify rate limits enforced consistently
- Generate random resource access attempts → verify authorization always checked
- Generate random session timings → verify timeouts enforced correctly

**Preservation Properties:**
- Generate random valid wardrobe operations → verify results identical to original
- Generate random valid authentication flows → verify behavior unchanged
- Generate random valid ML requests → verify recommendations identical
- Generate random valid API requests → verify responses identical
- Generate random valid inputs → verify processing identical

### Integration Tests

**End-to-End Security Flows:**
- Test complete authentication flow with strong password, token rotation, session management
- Test complete wardrobe operation flow with authorization checks, audit logging
- Test complete ML recommendation flow with input validation, rate limiting
- Test complete event flow with message signing, verification, processing
- Test complete API flow with HTTPS enforcement, security headers, rate limiting

**Cross-Service Security:**
- Test authentication service with rate limiting and audit logging
- Test wardrobe service with authorization and SQL injection prevention
- Test ML service with input validation and rate limiting
- Test event system with message signing across publishers and consumers

**Security Regression Tests:**
- Test that all 18 vulnerabilities remain fixed after code changes
- Test that legitimate functionality remains preserved after security updates
- Test that security controls don't interfere with each other (e.g., rate limiting doesn't break authorization)

**Performance Impact Tests:**
- Measure latency impact of security controls (should be minimal, <10ms per request)
- Measure throughput impact of message signing (should maintain >1000 events/sec)
- Measure memory impact of session management (should be bounded)
- Verify security controls don't cause resource exhaustion under normal load
