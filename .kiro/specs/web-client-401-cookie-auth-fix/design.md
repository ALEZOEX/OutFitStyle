# Web Client Cookie Authentication Bugfix Design

## Overview

The web client cannot authenticate with the API server because of an authentication method mismatch. The client sends httpOnly cookies with `withCredentials: true`, but the server's `AuthMiddleware` only validates `Authorization: Bearer <token>` headers and `X-API-Key` headers, never checking cookies. This fix adds cookie-based authentication checking to the middleware while preserving all existing header-based authentication methods.

The fix is minimal and surgical: add a third authentication path in `AuthMiddleware` that extracts the access to
earer token and API key authentication that must remain unchanged by the fix
- **AuthMiddleware**: The function in `server/internal/api/middleware/auth.go` that validates authentication credentials
- **access_token cookie**: The httpOnly cookie containing the JWT access token sent by the web client
- **withCredentials**: The Dio client configuration that enables automatic cookie sending from the web client

## Bug Details

### Bug Condition

The bug manifests when the web client makes an authenticated API request with `withCredentials: true` and valid httpOnly cookies, but the server's `AuthMiddleware` does not check cookies for authentication tokens. The middleware only validates `Authorization: Bearer <token>` headers or `X-API-Key` headers, causing all cookie-based requests to fail with 401 Unauthorized.

**Formal Specification:**
```
FUNCTION isBugCondition(request)
  INPUT: request of type *http.Request
  OUTPUT: boolean

  RETURN request.Header.Get("Authorization") == ""
         AND request.Header.Get("X-API-Key") == ""
         AND cookieExists(request, "access_token")
         AND isValidToken(getCookie(request, "access_token"))
         AND NOT requestAuthenticated(request)
END FUNCTION
```

### Examples

- **Web client wardrobe request**: Client sends `GET /api/v1/wardrobe` with `access_token` cookie → Server returns 401 Unauthorized (should return wardrobe data)
- **Web client recommendations request**: Client sends `GET /api/v1/recommendations` with `access_token` cookie → Server returns 401 Unauthorized (should return recommendations)
- **Web client notifications request**: Client sends `GET /api/v1/notifications` with `access_token` cookie → Server returns 401 Unauthorized (should return notifications)
- **Edge case - expired cookie**: Client sends request with expired `access_token` cookie → Server returns 401 Unauthorized (correct behavior, should remain unchanged)

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Bearer token authentication (`Authorization: Bearer <token>`) must continue to work exactly as before
- API key authentication (`X-API-Key` header) must continue to work exactly as before
- Requests with neither valid cookies nor valid headers must continue to return 401 Unauthorized
- Invalid or expired credentials in any format must continue to return 401 Unauthorized
- Non-web clients (mobile, CLI) using header-based authentication must continue to work

**Scope:**
All inputs that do NOT involve cookie-based authentication should be completely unaffected by this fix. This includes:
- Bearer token requests from mobile clients
- API key requests from integration partners
- Requests with no authentication credentials
- Requests with invalid authentication credentials

## Hypothesized Root Cause

Based on the bug description and code analysis, the root cause is clear:

1. **Missing Cookie Check**: The `AuthMiddleware` function in `server/internal/api/middleware/auth.go` only checks two authentication methods:
   - Bearer token in `Authorization` header (lines 17-29)
   - API key in `X-API-Key` header (lines 32-56)
   - No cookie checking logic exists

2. **Web Client Configuration**: The web client is correctly configured with `withCredentials: true` in `client/lib/src/core/api/api_client.dart`, which automatically sends httpOnly cookies with every request

3. **Cookie Infrastructure Exists**: The codebase already has cookie handling infrastructure in `server/internal/api/middleware/cookie_middleware.go` with functions like `GetRefreshTokenFromCookie`, but this is only used for refresh tokens, not access tokens

4. **Access Token Storage**: The authentication handlers (`server/internal/api/handlers/auth_handler.go`) set refresh tokens in cookies but return access tokens in the response body, expecting clients to send them in headers. The web client appears to be storing access tokens in cookies as well, but the middleware doesn't check for them.

## Correctness Properties

Property 1: Bug Condition - Cookie-Based Authentication

_For any_ HTTP request where the bug condition holds (no Authorization or X-API-Key header, but valid access_token cookie present), the fixed AuthMiddleware SHALL extract the access token from the cookie, validate it using the existing ValidateAccessToken method, and authenticate the request successfully by adding userID and sessionID to the request context.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**

Property 2: Preservation - Header-Based Authentication

_For any_ HTTP request that uses Bearer token or API key authentication in headers, the fixed AuthMiddleware SHALL produce exactly the same behavior as the original middleware, preserving all existing authentication flows for non-web clients.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File**: `server/internal/api/middleware/auth.go`

**Function**: `AuthMiddleware`

**Specific Changes**:
1. **Add Cookie Authentication Path**: After checking Bearer token and API key, add a third check for `access_token` cookie
   - Use `r.Cookie("access_token")` to extract the cookie
   - If cookie exists and has a non-empty value, validate it using `authService.ValidateAccessToken`
   - On successful validation, add userID and sessionID to context (same as Bearer token path)
   - On validation failure, return 401 Unauthorized

2. **Maintain Execution Order**: The authentication checks should remain in priority order:
   - First: Bearer token (existing)
   - Second: API key (existing)
   - Third: Cookie (new)
   - If none succeed: 401 Unauthorized (existing)

3. **Reuse Existing Validation**: Use the same `authService.ValidateAccessToken` method that Bearer tokens use, ensuring consistent validation logic

4. **Preserve Error Handling**: Use the same error response pattern (`resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)`) for consistency

5. **No Changes to Cookie Setting**: The fix only adds cookie reading in the middleware; cookie setting logic in auth handlers remains unchanged

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm that requests with valid access_token cookies are rejected with 401 Unauthorized.

**Test Plan**: Write integration tests that simulate authenticated requests with cookies but no headers. Run these tests on the UNFIXED code to observe 401 failures and confirm the root cause.

**Test Cases**:
1. **Wardrobe Request with Cookie**: Send `GET /api/v1/wardrobe` with valid `access_token` cookie, no Authorization header (will fail with 401 on unfixed code)
2. **Recommendations Request with Cookie**: Send `GET /api/v1/recommendations` with valid `access_token` cookie, no Authorization header (will fail with 401 on unfixed code)
3. **Notifications Request with Cookie**: Send `GET /api/v1/notifications` with valid `access_token` cookie, no Authorization header (will fail with 401 on unfixed code)
4. **Invalid Cookie Test**: Send request with expired or malformed `access_token` cookie (should fail with 401 on both unfixed and fixed code)

**Expected Counterexamples**:
- All requests with valid cookies but no headers return 401 Unauthorized
- Root cause confirmed: middleware does not check cookies for authentication

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL request WHERE isBugCondition(request) DO
  response := AuthMiddleware_fixed(request)
  ASSERT response.statusCode == 200
  ASSERT request.context.userID != nil
  ASSERT request.context.sessionID != nil
END FOR
```

**Test Plan**: After implementing the fix, run the same test cases and verify they succeed with proper authentication.

**Test Cases**:
1. **Wardrobe Request with Cookie**: Verify request succeeds and returns wardrobe data
2. **Recommendations Request with Cookie**: Verify request succeeds and returns recommendations
3. **Notifications Request with Cookie**: Verify request succeeds and returns notifications
4. **Achievements Request with Cookie**: Verify request succeeds and returns achievements
5. **Multiple Endpoints**: Test various authenticated endpoints to ensure cookie auth works universally

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL request WHERE NOT isBugCondition(request) DO
  ASSERT AuthMiddleware_original(request) = AuthMiddleware_fixed(request)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-cookie inputs

**Test Plan**: Run existing integration tests for Bearer token and API key authentication to verify they continue to work exactly as before.

**Test Cases**:
1. **Bearer Token Preservation**: Verify all requests with `Authorization: Bearer <token>` header continue to authenticate successfully
2. **API Key Preservation**: Verify all requests with `X-API-Key` header continue to authenticate successfully
3. **No Credentials Preservation**: Verify requests with no authentication credentials continue to return 401 Unauthorized
4. **Invalid Credentials Preservation**: Verify requests with invalid or expired credentials continue to return 401 Unauthorized
5. **Mobile Client Preservation**: Verify mobile clients using header-based auth continue to work without any changes

### Unit Tests

- Test cookie extraction from request with valid `access_token` cookie
- Test cookie authentication with valid token (should succeed)
- Test cookie authentication with expired token (should fail with 401)
- Test cookie authentication with malformed token (should fail with 401)
- Test cookie authentication with missing cookie (should fall through to 401)
- Test that Bearer token takes precedence over cookie if both are present

### Property-Based Tests

- Generate random valid access tokens in cookies and verify authentication succeeds
- Generate random invalid tokens in cookies and verify authentication fails with 401
- Generate random requests with Bearer tokens and verify behavior is unchanged
- Generate random requests with API keys and verify behavior is unchanged
- Test across many authenticated endpoints to ensure universal cookie support

### Integration Tests

- Test full authentication flow: login → receive tokens → make authenticated request with cookie
- Test web client flow: register → login → access wardrobe/recommendations/notifications with cookies
- Test that cookie authentication works across all protected endpoints
- Test that session management works correctly with cookie-based auth
- Test that logout properly invalidates cookie-based sessions
