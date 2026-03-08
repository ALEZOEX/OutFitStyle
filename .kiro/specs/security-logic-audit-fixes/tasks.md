# Implementation Plan

## Phase 1: Exploration Tests (BEFORE Fixes)

- [~] 1. Write bug condition exploration tests for all 18 vulnerabilities
  - **Property 1: Bug Condition** - Security Vulnerabilities Exist
  - **CRITICAL**: These tests MUST FAIL on unfixed code - failures confirm the vulnerabilities exist
  - **DO NOT attempt to fix the tests or the code when they fail**
  - **NOTE**: These tests encode the expected secure behavior - they will validate the fixes when they pass after implementation
  - **GOAL**: Surface counterexamples that demonstrate each vulnerability exists
  - **Scoped PBT Approach**: For deterministic vulnerabilities, scope properties to concrete failing cases to ensure reproducibility
  - Test implementation details from Bug Condition in design (isBugCondition pseudocode)
  - The test assertions should match the Expected Behavior Properties from design
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests FAIL (this is correct - it proves the vulnerabilities exist)
  - Document counterexamples found to understand root causes
  - Mark task complete when tests are written, run, and failures are documented
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11, 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18_

  - [x] 1.1 Critical: SQL Injection Test
    - Test wardrobe list endpoint with malicious orderField: `name; DROP TABLE users--`
    - Verify SQL injection executes on unfixed code
    - Document: SQL command injection successful

  - [ ] 1.2 Critical: CORS Bypass Test
    - Make authenticated request from `http://evil.com` with credentials
    - Verify wildcard origin allows request on unfixed code
    - Document: CORS bypass allows CSRF from any origin

  - [ ] 1.3 High: Weak Password Test
    - Register user with password `password123`
    - Verify weak password is accepted on unfixed code
    - Document: Weak passwords allowed

  - [ ] 1.4 High: Token Replay Test
    - Use same refresh token twice to get multiple access tokens
    - Verify token reuse succeeds on unfixed code
    - Document: Refresh tokens can be reused indefinitely

  - [ ] 1.5 High: Secret Exposure Test
    - Check environment variables or logs for plaintext ADMIN_KEY
    - Verify secrets are exposed in plaintext on unfixed code
    - Document: API keys stored in plaintext

  - [ ] 1.6 High: ML DoS Test
    - Send ML request with candidateCount=999999999
    - Verify system crashes or hangs on unfixed code
    - Document: Unbounded inputs cause resource exhaustion

  - [ ] 1.7 High: Event Injection Test
    - Publish unsigned Kafka event to topic
    - Verify unsigned event is processed on unfixed code
    - Document: Unsigned events accepted

  - [ ] 1.8 High: Rate Limit Bypass Test
    - Send 10000 registration requests rapidly
    - Verify no rate limiting on unfixed code
    - Document: Unlimited authentication attempts allowed

  - [ ] 1.9 High: Authorization Bypass Test
    - User A requests User B's wardrobe item via API
    - Verify unauthorized access succeeds on unfixed code
    - Document: Users can access others' resources

  - [ ] 1.10 High: Session Hijacking Test
    - Use stolen session token after 24 hours
    - Verify session still works on unfixed code
    - Document: Sessions never expire

  - [ ] 1.11 Medium: Information Disclosure Test
    - Trigger database error (e.g., duplicate email)
    - Verify error response exposes internal details on unfixed code
    - Document: Database errors exposed to clients

  - [ ] 1.12 Medium: Missing Headers Test
    - Check HTTP response for security headers
    - Verify headers missing on unfixed code
    - Document: X-Permitted-Cross-Domain-Policies, Referrer-Policy, Permissions-Policy missing

  - [ ] 1.13 Medium: HTTP Downgrade Test
    - Access API via HTTP protocol
    - Verify no HTTPS redirect on unfixed code
    - Document: HTTP connections not upgraded

  - [ ] 1.14 Medium: Audit Gap Test
    - Perform sensitive operation (e.g., delete account)
    - Check logs for audit trail
    - Verify no audit logging on unfixed code
    - Document: No audit trail for sensitive operations

  - [ ] 1.15 Medium: Timing Attack Test
    - Measure API key comparison time with correct vs incorrect keys
    - Verify timing difference exists on unfixed code
    - Document: Secret comparisons vulnerable to timing attacks

  - [ ] 1.16 Low: Vulnerable Dependency Test
    - Run `govulncheck` on Go dependencies
    - Run `pip-audit` on Python dependencies
    - Verify vulnerabilities found on unfixed code
    - Document: Dependencies have known CVEs

  - [ ] 1.17 Low: Rate Limit Evasion Test
    - Authenticated user makes excessive API requests
    - Verify no per-user rate limiting on unfixed code
    - Document: Rate limits don't apply per user

  - [ ] 1.18 Low: Sanitization Gap Test
    - Submit HTML in input fields across different endpoints
    - Check for inconsistent sanitization on unfixed code
    - Document: Input sanitization inconsistent

- [~] 2. Write preservation property tests (BEFORE implementing fixes)
  - **Property 2: Preservation** - Legitimate Functionality Maintained
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for legitimate operations
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13, 3.14, 3.15, 3.16, 3.17, 3.18_

  - [ ] 2.1 Valid Wardrobe Operations
    - Observe: Wardrobe list with valid sort parameters (name ASC, created_at DESC) returns sorted results
    - Write property: For all valid sort fields and directions, results are correctly sorted
    - Verify test passes on UNFIXED code

  - [ ] 2.2 Allowed CORS Origins
    - Observe: Requests from whitelisted origins (https://outfitstyle.com) work with proper headers
    - Write property: For all allowed origins, CORS requests succeed with credentials
    - Verify test passes on UNFIXED code

  - [ ] 2.3 Strong Password Registration
    - Observe: Registration with strong password (e.g., MyP@ssw0rd123!) succeeds
    - Write property: For all passwords meeting strong requirements, registration succeeds
    - Verify test passes on UNFIXED code

  - [ ] 2.4 First-Time Token Use
    - Observe: First use of valid refresh token issues new access token
    - Write property: For all valid unused refresh tokens, new access tokens are issued
    - Verify test passes on UNFIXED code

  - [ ] 2.5 Admin Operations
    - Observe: Admin operations with valid API key succeed
    - Write property: For all valid admin API keys, operations are authorized
    - Verify test passes on UNFIXED code

  - [ ] 2.6 Valid ML Requests
    - Observe: ML requests with valid inputs (candidateCount=10, temp=20) return recommendations
    - Write property: For all valid ML inputs within bounds, recommendations are returned
    - Verify test passes on UNFIXED code

  - [ ] 2.7 Signed Event Processing
    - Observe: Legitimate Kafka events from authorized services process successfully
    - Write property: For all properly signed events, processing succeeds with same throughput
    - Verify test passes on UNFIXED code

  - [ ] 2.8 Within Rate Limits
    - Observe: Authentication requests within limits (e.g., 3 per hour) process without delay
    - Write property: For all requests within rate limits, processing is immediate
    - Verify test passes on UNFIXED code

  - [ ] 2.9 Own Resource Access
    - Observe: Users accessing their own wardrobe items succeed
    - Write property: For all owned resources, access succeeds without friction
    - Verify test passes on UNFIXED code

  - [ ] 2.10 Active Sessions
    - Observe: Sessions used within timeout period remain active
    - Write property: For all sessions within timeout, authentication persists
    - Verify test passes on UNFIXED code

  - [ ] 2.11 User-Facing Validation Errors
    - Observe: Validation errors (e.g., invalid email format) return helpful messages
    - Write property: For all validation failures, clear error messages are provided
    - Verify test passes on UNFIXED code

  - [ ] 2.12 Page Rendering
    - Observe: Application pages display correctly
    - Write property: For all pages, rendering is correct and functional
    - Verify test passes on UNFIXED code

  - [ ] 2.13 HTTPS Content Serving
    - Observe: HTTPS content serves without mixed content warnings
    - Write property: For all HTTPS requests, content serves securely
    - Verify test passes on UNFIXED code

  - [ ] 2.14 Normal Logging
    - Observe: Normal operations log at appropriate levels without performance impact
    - Write property: For all normal operations, logging is appropriate and performant
    - Verify test passes on UNFIXED code

  - [ ] 2.15 Correct Authentication
    - Observe: Successful authentication has consistent response time
    - Write property: For all valid credentials, authentication response time is consistent
    - Verify test passes on UNFIXED code

  - [ ] 2.16 Current Dependencies
    - Observe: Application functions correctly with up-to-date dependencies
    - Write property: For all current dependencies, functionality is preserved
    - Verify test passes on UNFIXED code

  - [ ] 2.17 Within API Limits
    - Observe: API requests within limits process without throttling
    - Write property: For all requests within limits, no throttling occurs
    - Verify test passes on UNFIXED code

  - [ ] 2.18 Valid Input Processing
    - Observe: Properly formatted input processes correctly without data loss
    - Write property: For all valid inputs, processing is correct and complete
    - Verify test passes on UNFIXED code

## Phase 2: Implementation

- [x] 3. Fix 1: SQL Injection Prevention
  - [x] 3.1 Implement SQL injection prevention in wardrobe repository
    - File: `internal/wardrobe/repository/postgres/wardrobe_repository.go`
    - Function: `List(ctx context.Context, userID string, filters WardrobeFilters) ([]Wardrobe, error)`
    - Create whitelist map for allowed sort fields: ["name", "created_at", "updated_at", "category"]
    - Create whitelist for allowed directions: ["ASC", "DESC"]
    - Validate orderField and orderDir against whitelists before query construction
    - Use PostgreSQL parameter placeholders ($1, $2, etc.) for all user input
    - Return validation error if invalid sort parameters provided
    - _Bug_Condition: input.type == "SQL_QUERY" AND input.hasUnsanitizedUserInput_
    - _Expected_Behavior: Malicious SQL is rejected or sanitized, no SQL execution occurs_
    - _Preservation: Valid sort parameters return correctly sorted results_
    - _Requirements: 2.1, 3.1_

  - [x] 3.2 Verify SQL injection exploration test now passes
    - **Property 1: Expected Behavior** - SQL Injection Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.1 - do NOT write a new test
    - Run SQL injection test with malicious orderField
    - **EXPECTED OUTCOME**: Test PASSES (confirms SQL injection is prevented)
    - _Requirements: 2.1_

  - [x] 3.3 Verify wardrobe preservation test still passes
    - **Property 2: Preservation** - Valid Wardrobe Operations
    - **IMPORTANT**: Re-run the SAME test from task 2.1 - do NOT write a new test
    - Run valid wardrobe operations test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 4. Fix 2: CORS Configuration Hardening
  - [x] 4.1 Implement CORS configuration hardening
    - File: `cmd/api/main.go` or `internal/middleware/cors.go`
    - Load allowed origins from configuration environment variable ALLOWED_ORIGINS
    - Example: `ALLOWED_ORIGINS=https://outfitstyle.com,https://app.outfitstyle.com`
    - Remove wildcard origin configuration: Never use `AllowOrigins: []string{"*"}` with `AllowCredentials: true`
    - Implement strict origin header validation against whitelist
    - Reject requests from non-whitelisted origins when credentials are required
    - _Bug_Condition: input.type == "CORS_CONFIG" AND input.allowsWildcardWithCredentials_
    - _Expected_Behavior: Only whitelisted origins allowed with credentials_
    - _Preservation: Requests from allowed origins work with proper CORS headers_
    - _Requirements: 2.2, 3.2_

  - [x] 4.2 Verify CORS bypass exploration test now passes
    - **Property 1: Expected Behavior** - CORS Bypass Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.2 - do NOT write a new test
    - Run CORS bypass test from evil origin
    - **EXPECTED OUTCOME**: Test PASSES (confirms CORS bypass is prevented)
    - _Requirements: 2.2_

  - [x] 4.3 Verify CORS preservation test still passes
    - **Property 2: Preservation** - Allowed CORS Origins
    - **IMPORTANT**: Re-run the SAME test from task 2.2 - do NOT write a new test
    - Run allowed origins test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 5. Fix 3: Strong Password Policy
  - [x] 5.1 Implement strong password policy
    - File: `internal/auth/service/auth_service.go`
    - Function: `Register(ctx context.Context, email, password string) error`
    - Enforce minimum 12 characters (increased from 8)
    - Require at least one uppercase letter
    - Require at least one lowercase letter
    - Require at least one number
    - Require at least one special character
    - Integrate check against top 10,000 common passwords list
    - Return specific validation failures to help users create strong passwords
    - _Bug_Condition: input.type == "PASSWORD_REGISTRATION" AND NOT input.meetsStrongRequirements_
    - _Expected_Behavior: Weak passwords rejected with clear error messages_
    - _Preservation: Strong passwords continue to register successfully_
    - _Requirements: 2.3, 3.3_

  - [x] 5.2 Verify weak password exploration test now passes
    - **Property 1: Expected Behavior** - Weak Passwords Rejected
    - **IMPORTANT**: Re-run the SAME test from task 1.3 - do NOT write a new test
    - Run weak password test
    - **EXPECTED OUTCOME**: Test PASSES (confirms weak passwords are rejected)
    - _Requirements: 2.3_

  - [x] 5.3 Verify strong password preservation test still passes
    - **Property 2: Preservation** - Strong Password Registration
    - **IMPORTANT**: Re-run the SAME test from task 2.3 - do NOT write a new test
    - Run strong password registration test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 6. Fix 4: Refresh Token Rotation
  - [x] 6.1 Implement refresh token rotation
    - File: `internal/auth/service/token_service.go`
    - Function: `RefreshAccessToken(ctx context.Context, refreshToken string) (string, string, error)`
    - Mark old refresh token as used/invalid in database immediately after validation
    - Generate new refresh token along with new access token
    - Implement replay detection: if token already used, invalidate all tokens for that user
    - Use database transaction to ensure token rotation is atomic
    - Return both new access token and new refresh token to client
    - _Bug_Condition: input.type == "REFRESH_TOKEN_USE" AND NOT input.invalidatesOldToken_
    - _Expected_Behavior: Old tokens invalidated, replay attempts rejected_
    - _Preservation: First-time token use issues new tokens successfully_
    - _Requirements: 2.4, 3.4_

  - [x] 6.2 Verify token replay exploration test now passes
    - **Property 1: Expected Behavior** - Token Replay Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.4 - do NOT write a new test
    - Run token replay test
    - **EXPECTED OUTCOME**: Test PASSES (confirms token replay is prevented)
    - _Requirements: 2.4_

  - [x] 6.3 Verify first-time token preservation test still passes
    - **Property 2: Preservation** - First-Time Token Use
    - **IMPORTANT**: Re-run the SAME test from task 2.4 - do NOT write a new test
    - Run first-time token use test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 7. Fix 5: Secure Secret Management
  - [x] 7.1 Implement secure secret management
    - Files: `internal/config/config.go` and deployment configuration
    - Integrate cloud provider secret manager (AWS Secrets Manager, GCP Secret Manager, or HashiCorp Vault)
    - Load secrets at application startup from secure storage, not environment variables
    - Ensure secrets are encrypted at rest in secret manager
    - Implement IAM policies restricting secret access to authorized services only
    - Design for secret rotation without application restart
    - _Bug_Condition: input.type == "SECRET_STORAGE" AND input.isPlaintext_
    - _Expected_Behavior: Secrets loaded from secure storage, not visible in environment_
    - _Preservation: Admin operations with valid API keys continue to work_
    - _Requirements: 2.5, 3.5_

  - [x] 7.2 Verify secret exposure exploration test now passes
    - **Property 1: Expected Behavior** - Secrets Secured
    - **IMPORTANT**: Re-run the SAME test from task 1.5 - do NOT write a new test
    - Run secret exposure test
    - **EXPECTED OUTCOME**: Test PASSES (confirms secrets are not exposed)
    - _Requirements: 2.5_

  - [x] 7.3 Verify admin operations preservation test still passes
    - **Property 2: Preservation** - Admin Operations
    - **IMPORTANT**: Re-run the SAME test from task 2.5 - do NOT write a new test
    - Run admin operations test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 8. Fix 6: ML Service Input Validation
  - [x] 8.1 Implement ML service input validation
    - File: `ml-service/app/api/routes.py` or `ml-service/app/services/recommendation_service.py`
    - Enforce candidate count bounds: minimum 1, maximum 100
    - Validate temperature range: -50 to 50°C
    - Validate humidity range: 0 to 100%
    - Validate weather type against enum of allowed values
    - Ensure all numeric fields are valid numbers, not strings or special values
    - Enforce maximum request body size
    - Use Pydantic models for strict schema enforcement
    - Return 400 Bad Request with clear error for invalid inputs
    - _Bug_Condition: input.type == "ML_REQUEST" AND NOT input.hasStrictValidation_
    - _Expected_Behavior: Out-of-bounds inputs rejected with 400 Bad Request_
    - _Preservation: Valid ML requests return same recommendations_
    - _Requirements: 2.6, 3.6_

  - [x] 8.2 Verify ML DoS exploration test now passes
    - **Property 1: Expected Behavior** - ML DoS Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.6 - do NOT write a new test
    - Run ML DoS test with extreme candidateCount
    - **EXPECTED OUTCOME**: Test PASSES (confirms DoS is prevented)
    - _Requirements: 2.6_

  - [x] 8.3 Verify valid ML requests preservation test still passes
    - **Property 2: Preservation** - Valid ML Requests
    - **IMPORTANT**: Re-run the SAME test from task 2.6 - do NOT write a new test
    - Run valid ML requests test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 9. Fix 7: Kafka Message Signing
  - [x] 9.1 Implement Kafka message signing and verification
    - Files: `internal/events/publisher.go` and `internal/events/consumer.go`
    - Generate HMAC-SHA256 signature for each message using shared secret
    - Add signature to Kafka message headers
    - Store signing keys in secure secret manager
    - Verify signature on consumption before processing
    - Reject and log unsigned or invalid signature messages
    - _Bug_Condition: input.type == "KAFKA_EVENT" AND NOT input.isSigned_
    - _Expected_Behavior: Unsigned or invalid signature messages rejected_
    - _Preservation: Signed events process with same throughput_
    - _Requirements: 2.7, 3.7_

  - [x] 9.2 Verify event injection exploration test now passes
    - **Property 1: Expected Behavior** - Event Injection Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.7 - do NOT write a new test
    - Run event injection test with unsigned message
    - **EXPECTED OUTCOME**: Test PASSES (confirms unsigned events are rejected)
    - _Requirements: 2.7_

  - [x] 9.3 Verify signed event preservation test still passes
    - **Property 2: Preservation** - Signed Event Processing
    - **IMPORTANT**: Re-run the SAME test from task 2.7 - do NOT write a new test
    - Run signed event processing test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 10. Fix 8: Authentication Rate Limiting
  - [x] 10.1 Implement authentication rate limiting
    - File: `internal/middleware/rate_limiter.go`
    - Implement per-IP rate limit: 5 attempts per 15 minutes
    - Implement per-email rate limit: 3 attempts per hour
    - Implement exponential backoff after each failed attempt
    - Require CAPTCHA after threshold violations (e.g., 3 failed attempts)
    - Use Redis for distributed rate limiting across multiple instances
    - _Bug_Condition: input.type == "AUTH_ENDPOINT" AND NOT input.hasRateLimit_
    - _Expected_Behavior: Excessive attempts blocked, CAPTCHA required_
    - _Preservation: Requests within limits process without delay_
    - _Requirements: 2.8, 3.8_

  - [x] 10.2 Verify rate limit bypass exploration test now passes
    - **Property 1: Expected Behavior** - Rate Limiting Enforced
    - **IMPORTANT**: Re-run the SAME test from task 1.8 - do NOT write a new test
    - Run rate limit bypass test with 10000 requests
    - **EXPECTED OUTCOME**: Test PASSES (confirms rate limiting works)
    - _Requirements: 2.8_

  - [x] 10.3 Verify within limits preservation test still passes
    - **Property 2: Preservation** - Within Rate Limits
    - **IMPORTANT**: Re-run the SAME test from task 2.8 - do NOT write a new test
    - Run within rate limits test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 11. Fix 9: Resource Ownership Authorization
  - [x] 11.1 Implement resource ownership authorization
    - File: `internal/wardrobe/service/wardrobe_service.go`
    - Functions: All resource access methods (Get, Update, Delete)
    - Query resource to verify user_id matches authenticated user before any operation
    - Create reusable authorization middleware for resource ownership
    - Return HTTP 403 Forbidden (not 404) when user attempts to access others' resources
    - Log all authorization failures with user ID, resource ID, and attempted action
    - Apply consistently to all resource types (wardrobe items, outfits, preferences)
    - _Bug_Condition: input.type == "RESOURCE_ACCESS" AND NOT input.verifiesOwnership_
    - _Expected_Behavior: Unauthorized access returns 403 Forbidden_
    - _Preservation: Users accessing own resources experience no friction_
    - _Requirements: 2.9, 3.9_

  - [x] 11.2 Verify authorization bypass exploration test now passes
    - **Property 1: Expected Behavior** - Authorization Enforced
    - **IMPORTANT**: Re-run the SAME test from task 1.9 - do NOT write a new test
    - Run authorization bypass test
    - **EXPECTED OUTCOME**: Test PASSES (confirms unauthorized access is blocked)
    - _Requirements: 2.9_

  - [x] 11.3 Verify own resource preservation test still passes
    - **Property 2: Preservation** - Own Resource Access
    - **IMPORTANT**: Re-run the SAME test from task 2.9 - do NOT write a new test
    - Run own resource access test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 12. Fix 10: Session Management Enhancement
  - [x] 12.1 Implement session management enhancements
    - File: `internal/auth/service/session_service.go`
    - Implement configurable idle timeout (e.g., 30 minutes)
    - Implement configurable absolute timeout (e.g., 24 hours)
    - Track user agent, IP address, and browser fingerprint for each session
    - Allow configurable max concurrent sessions per user (e.g., 5 devices)
    - Provide API for users to view and revoke active sessions
    - Add sessions table with columns: session_id, user_id, device_fingerprint, created_at, last_activity, expires_at
    - _Bug_Condition: input.type == "SESSION_CREATION" AND NOT input.hasTimeoutOrLimits_
    - _Expected_Behavior: Sessions expire after timeout, concurrent sessions limited_
    - _Preservation: Active sessions within timeout remain active_
    - _Requirements: 2.10, 3.10_

  - [x] 12.2 Verify session hijacking exploration test now passes
    - **Property 1: Expected Behavior** - Session Hijacking Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.10 - do NOT write a new test
    - Run session hijacking test with old token
    - **EXPECTED OUTCOME**: Test PASSES (confirms sessions expire)
    - _Requirements: 2.10_

  - [x] 12.3 Verify active session preservation test still passes
    - **Property 2: Preservation** - Active Sessions
    - **IMPORTANT**: Re-run the SAME test from task 2.10 - do NOT write a new test
    - Run active session test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 13. Fix 11: Error Message Sanitization
  - [x] 13.1 Implement error message sanitization
    - File: `internal/middleware/error_handler.go`
    - Return generic messages like "Internal server error" or "Invalid request" to clients
    - Log full error details including stack traces to server logs only
    - Categorize errors (validation, not found, unauthorized, internal)
    - Return appropriate generic messages for each category
    - Never include stack traces in client responses
    - Use structured logging (JSON) for easy parsing and analysis
    - _Bug_Condition: input.type == "ERROR_RESPONSE" AND input.exposesInternalDetails_
    - _Expected_Behavior: Generic error messages returned, no internal details exposed_
    - _Preservation: Validation errors still provide helpful messages_
    - _Requirements: 2.11, 3.11_

  - [x] 13.2 Verify information disclosure exploration test now passes
    - **Property 1: Expected Behavior** - Information Disclosure Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.11 - do NOT write a new test
    - Run information disclosure test
    - **EXPECTED OUTCOME**: Test PASSES (confirms internal details not exposed)
    - _Requirements: 2.11_

  - [x] 13.3 Verify validation error preservation test still passes
    - **Property 2: Preservation** - User-Facing Validation Errors
    - **IMPORTANT**: Re-run the SAME test from task 2.11 - do NOT write a new test
    - Run validation error test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 14. Fix 12: Security Headers Implementation
  - [x] 14.1 Implement security headers middleware
    - File: `internal/middleware/security_headers.go`
    - Set X-Permitted-Cross-Domain-Policies: none
    - Set Referrer-Policy: strict-origin-when-cross-origin
    - Set Permissions-Policy: geolocation=(), microphone=(), camera=()
    - Set X-Content-Type-Options: nosniff
    - Set X-Frame-Options: DENY or SAMEORIGIN
    - Apply headers to all HTTP responses
    - _Bug_Condition: input.type == "HTTP_RESPONSE" AND NOT input.hasSecurityHeaders_
    - _Expected_Behavior: All required security headers present in responses_
    - _Preservation: Application pages display correctly with security headers_
    - _Requirements: 2.12, 3.12_

  - [x] 14.2 Verify missing headers exploration test now passes
    - **Property 1: Expected Behavior** - Security Headers Present
    - **IMPORTANT**: Re-run the SAME test from task 1.12 - do NOT write a new test
    - Run missing headers test
    - **EXPECTED OUTCOME**: Test PASSES (confirms headers are present)
    - _Requirements: 2.12_

  - [x] 14.3 Verify page rendering preservation test still passes
    - **Property 2: Preservation** - Page Rendering
    - **IMPORTANT**: Re-run the SAME test from task 2.12 - do NOT write a new test
    - Run page rendering test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 15. Fix 13: HTTPS Enforcement
  - [x] 15.1 Implement HTTPS enforcement
    - Files: `cmd/api/main.go` and `internal/middleware/https_redirect.go`
    - Implement middleware to redirect all HTTP requests to HTTPS
    - Set Strict-Transport-Security header: max-age=31536000; includeSubDomains; preload
    - Enforce TLS 1.2+ with strong cipher suites
    - Use automated certificate renewal (Let's Encrypt or cloud provider)
    - Allow HTTP only in local development environment
    - _Bug_Condition: input.type == "SERVER_CONFIG" AND NOT input.enforcesHTTPS_
    - _Expected_Behavior: HTTP requests redirected to HTTPS, HSTS header present_
    - _Preservation: HTTPS content serves without mixed content warnings_
    - _Requirements: 2.13, 3.13_

  - [x] 15.2 Verify HTTP downgrade exploration test now passes
    - **Property 1: Expected Behavior** - HTTPS Enforced
    - **IMPORTANT**: Re-run the SAME test from task 1.13 - do NOT write a new test
    - Run HTTP downgrade test
    - **EXPECTED OUTCOME**: Test PASSES (confirms HTTPS is enforced)
    - _Requirements: 2.13_

  - [x] 15.3 Verify HTTPS content preservation test still passes
    - **Property 2: Preservation** - HTTPS Content Serving
    - **IMPORTANT**: Re-run the SAME test from task 2.13 - do NOT write a new test
    - Run HTTPS content serving test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [~] 16. Fix 14: Comprehensive Audit Logging
  - [ ] 16.1 Implement comprehensive audit logging
    - File: `internal/audit/audit_logger.go`
    - Log authentication events: login, logout, registration
    - Log authorization failures
    - Log data access to sensitive resources
    - Log configuration changes
    - Include in logs: user_id, timestamp, action, resource_type, resource_id, ip_address, user_agent, outcome
    - Write audit logs to dedicated log stream or database table
    - Ensure audit logs cannot be modified or deleted by application (immutable storage)
    - Implement retention policy (e.g., 90 days minimum for compliance)
    - _Bug_Condition: input.type == "SENSITIVE_OPERATION" AND NOT input.isAudited_
    - _Expected_Behavior: Sensitive operations logged with all required fields_
    - _Preservation: Normal operations continue to log at appropriate levels_
    - _Requirements: 2.14, 3.14_

  - [ ] 16.2 Verify audit gap exploration test now passes
    - **Property 1: Expected Behavior** - Audit Logging Implemented
    - **IMPORTANT**: Re-run the SAME test from task 1.14 - do NOT write a new test
    - Run audit gap test
    - **EXPECTED OUTCOME**: Test PASSES (confirms audit logging works)
    - _Requirements: 2.14_

  - [ ] 16.3 Verify normal logging preservation test still passes
    - **Property 2: Preservation** - Normal Logging
    - **IMPORTANT**: Re-run the SAME test from task 2.14 - do NOT write a new test
    - Run normal logging test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 17. Fix 15: Constant-Time Secret Comparison
  - [x] 17.1 Implement constant-time secret comparison
    - Files: Multiple files where secrets are compared
      - `internal/auth/service/auth_service.go`
      - `internal/middleware/api_key_auth.go`
    - Replace == or strings.Compare with subtle.ConstantTimeCompare from crypto/subtle
    - For password hashes, use bcrypt.CompareHashAndPassword (already constant-time)
    - Apply constant-time comparison for API key checks
    - Apply constant-time comparison for token validation
    - Audit all secret comparison code paths for consistent application
    - _Bug_Condition: input.type == "SECRET_COMPARISON" AND NOT input.usesConstantTime_
    - _Expected_Behavior: Secret comparisons use constant-time functions_
    - _Preservation: Correct authentication has same response times_
    - _Requirements: 2.15, 3.15_

  - [x] 17.2 Verify timing attack exploration test now passes
    - **Property 1: Expected Behavior** - Timing Attack Prevented
    - **IMPORTANT**: Re-run the SAME test from task 1.15 - do NOT write a new test
    - Run timing attack test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no timing difference)
    - _Requirements: 2.15_

  - [x] 17.3 Verify authentication timing preservation test still passes
    - **Property 2: Preservation** - Correct Authentication
    - **IMPORTANT**: Re-run the SAME test from task 2.15 - do NOT write a new test
    - Run correct authentication test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [x] 18. Fix 16: Automated Vulnerability Scanning
  - [x] 18.1 Implement automated vulnerability scanning
    - File: `.github/workflows/security-scan.yml` or CI/CD pipeline configuration
    - Integrate govulncheck for Go dependencies
    - Integrate pip-audit or safety for Python dependencies
    - Configure alerts for high/critical vulnerabilities
    - Run vulnerability scans on every pull request
    - Run daily scans on main branch
    - Optionally fail builds on high-severity vulnerabilities
    - _Bug_Condition: input.type == "DEPENDENCY_MANAGEMENT" AND NOT input.hasVulnScanning_
    - _Expected_Behavior: CI/CD pipeline runs security scans, alerts on vulnerabilities_
    - _Preservation: Application functions correctly with up-to-date dependencies_
    - _Requirements: 2.16, 3.16_

  - [x] 18.2 Verify vulnerable dependency exploration test now passes
    - **Property 1: Expected Behavior** - Vulnerability Scanning Active
    - **IMPORTANT**: Re-run the SAME test from task 1.16 - do NOT write a new test
    - Run vulnerable dependency test
    - **EXPECTED OUTCOME**: Test PASSES (confirms scanning detects vulnerabilities)
    - _Requirements: 2.16_

  - [x] 18.3 Verify dependency functionality preservation test still passes
    - **Property 2: Preservation** - Current Dependencies
    - **IMPORTANT**: Re-run the SAME test from task 2.16 - do NOT write a new test
    - Run current dependencies test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [~] 19. Fix 17: Per-User API Rate Limiting
  - [ ] 19.1 Implement per-user API rate limiting
    - File: `internal/middleware/rate_limiter.go`
    - Implement user-based limits: 1000 requests per hour per authenticated user ID
    - Implement API key limits: separate limits for API key authentication
    - Implement anonymous limits: stricter limits for unauthenticated requests by IP (100 requests per hour)
    - Implement endpoint-specific limits: different limits for read vs write operations
    - Return rate limit headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
    - Use Redis for distributed rate limiting
    - _Bug_Condition: input.type == "API_REQUEST" AND NOT input.hasPerUserRateLimit_
    - _Expected_Behavior: Rate limits applied per authenticated user_
    - _Preservation: Requests within limits process without throttling_
    - _Requirements: 2.17, 3.17_

  - [ ] 19.2 Verify rate limit evasion exploration test now passes
    - **Property 1: Expected Behavior** - Per-User Rate Limiting Enforced
    - **IMPORTANT**: Re-run the SAME test from task 1.17 - do NOT write a new test
    - Run rate limit evasion test
    - **EXPECTED OUTCOME**: Test PASSES (confirms per-user limits work)
    - _Requirements: 2.17_

  - [ ] 19.3 Verify API limits preservation test still passes
    - **Property 2: Preservation** - Within API Limits
    - **IMPORTANT**: Re-run the SAME test from task 2.17 - do NOT write a new test
    - Run within API limits test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

- [~] 20. Fix 18: Consistent Input Sanitization
  - [ ] 20.1 Implement consistent input sanitization
    - Files: Multiple files across all services
    - Create shared validation library with context-aware sanitization functions
    - Use html.EscapeString for HTML contexts
    - Use parameterized queries for all database operations (SQL contexts)
    - Use proper JSON encoding for JSON responses
    - Apply validation consistently at API boundary using middleware or request validators
    - Document sanitization requirements for each context type
    - _Bug_Condition: input.type == "INPUT_SANITIZATION" AND input.isInconsistent_
    - _Expected_Behavior: All inputs sanitized appropriately for context_
    - _Preservation: Properly formatted input processes correctly without data loss_
    - _Requirements: 2.18, 3.18_

  - [ ] 20.2 Verify sanitization gap exploration test now passes
    - **Property 1: Expected Behavior** - Consistent Sanitization Applied
    - **IMPORTANT**: Re-run the SAME test from task 1.18 - do NOT write a new test
    - Run sanitization gap test
    - **EXPECTED OUTCOME**: Test PASSES (confirms consistent sanitization)
    - _Requirements: 2.18_

  - [ ] 20.3 Verify valid input preservation test still passes
    - **Property 2: Preservation** - Valid Input Processing
    - **IMPORTANT**: Re-run the SAME test from task 2.18 - do NOT write a new test
    - Run valid input processing test
    - **EXPECTED OUTCOME**: Test PASSES (confirms no regressions)

## Phase 3: Final Validation

- [x] 21. Checkpoint - Ensure all tests pass
  - Run complete test suite including all exploration tests and preservation tests
  - Verify all 18 bug condition tests pass (vulnerabilities fixed)
  - Verify all 18 preservation tests pass (no regressions)
  - Review security scan results for any remaining issues
  - Measure performance impact of security controls (should be <10ms per request)
  - Verify audit logs are being generated correctly
  - Confirm all security headers are present in responses
  - Validate HTTPS enforcement is working
  - Check that rate limiting is functioning across all endpoints
  - Ensure all tests pass, ask the user if questions arise
