# Web Client Bearer Token Authentication Bugfix Design

## Overview

The web client cannot authenticate with the API server because it does not send authentication credentials after login. When users log in via email/password or Google Sign-In, the backend returns an `access_token` in the response body, but the client neither stores this token nor includes it in subsequent API requests. The backend's AuthMiddleware already supports Bearer token authentication, but the client sends no `Authorization` header, causing all authenticated requests to fail with 401 Unauthorized.

The fix is minimal and surgical: modify the client to extract and store the `access_token` from login responses, then automatically add it to the `Authorization: Bearer <token>` header for all authenticated requests using a Dio interceptor.

## Glossary

- **Bug_Condition (C)**: Authenticated API requests from the web client that fail with 401 because no `Authorization` header is sent
- **Property (P)**: Successful authentication when valid `access_token` is included in `Authorization: Bearer <token>` header
- **Preservation**: Existing login flow, session storage, and non-authenticated requests that must remain unchanged
- **SessionManager**: The class in `client/lib/src/auth/session_manager.dart` that handles login and stores user session data
- **ApiClient**: The class in `client/lib/src/core/api/api_client.dart` that makes HTTP requests using Dio
- **access_token**: The JWT access token returned by the backend in the login/register response body
- **Bearer token**: The authentication scheme where the token is sent in the `Authorization: Bearer <token>` header
- **Dio interceptor**: A middleware mechanism in Dio that can modify requests before they are sent

## Bug Details

### Bug Condition

The bug manifests when the web client makes an authenticated API request after successful login. The backend returns an `access_token` in the login/register response body, but the client:
1. **Does not extract the access_token** from the response
2. **Does not store the access_token** in memory or SharedPreferences
3. **Does not add the access_token** to the `Authorization` header in subsequent requests

This causes all authenticated API requests to fail with 401 Unauthorized because the backend's AuthMiddleware receives no authentication credentials.

**Formal Specification:**
```
FUNCTION isBugCondition(request)
  INPUT: request of type HTTP Request
  OUTPUT: boolean

  RETURN request.path IN ['/api/v1/notifications', '/api/v1/wardrobe',
                          '/api/v1/recommendations', '/api/v1/achievements']
         AND request.Header.Get("Authorization") == ""
         AND userHasValidAccessToken(request.context)
         AND accessTokenNotSentByClient(request)
END FUNCTION
```

### Examples

- **Web client wardrobe request**: Client sends `GET /api/v1/wardrobe` after login, but no `Authorization` header is included → Server returns 401 Unauthorized (should include `Authorization: Bearer <token>`)
- **Web client recommendations request**: Client sends `GET /api/v1/recommendations` after login, no `Authorization` header → Server returns 401 Unauthorized (should include Bearer token)
- **Web client notifications request**: Client sends `GET /api/v1/notifications` after login, no `Authorization` header → Server returns 401 Unauthorized (should include Bearer token)
- **Email/password login**: User logs in, backend returns `{"user": {...}, "tokens": {"access_token": "eyJ..."}}`, but client doesn't extract or store the token → Subsequent requests fail with 401
- **Google Sign-In**: User signs in with Google, but client doesn't retrieve access_token from backend → Subsequent requests fail with 401
- **Edge case - expired token**: Client sends request with expired `access_token` in Authorization header → Server returns 401 Unauthorized (correct behavior, should remain unchanged)

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Login flow (email/password and Google Sign-In) must continue to work exactly as before
- Session data storage in SharedPreferences must remain unchanged
- User session state management must remain unchanged
- Non-authenticated requests (login, register, public endpoints) must continue to work without Authorization headers
- Error handling for invalid or expired tokens must continue to return 401 Unauthorized

**Scope:**
All inputs that do NOT involve authenticated API requests should be completely unaffected by this fix. This includes:
- Login and registration requests (these don't need Authorization headers)
- Public API endpoints that don't require authentication
- Session initialization and restoration from SharedPreferences
- Firebase authentication state management for Google Sign-In

## Hypothesized Root Cause

Based on code analysis of `SessionManager` and `ApiClient`, the root cause is now clear:

1. **Token Not Extracted from Login Response**: In `SessionManager.signIn()` (lines 189-245), the method receives the backend response containing `tokens.access_token`, but only extracts user data. The `access_token` is never read from `data['tokens']['access_token']`.

2. **Token Not Stored**: The client has no mechanism to store the `access_token` in memory or SharedPreferences. Only user session data (uid, email, displayName, etc.) is stored.

3. **No Authorization Header Added**: In `ApiClient` (lines 1-115), the Dio client has no interceptor to add the `Authorization: Bearer <token>` header to outgoing requests. The client only configures `withCredentials: true` for cookie support, but doesn't use Bearer tokens.

4. **Backend Already Supports Bearer Tokens**: The `AuthMiddleware` in `server/internal/api/middleware/auth.go` (lines 17-27) already validates Bearer tokens correctly. The server-side implementation is complete and working.

5. **Google Sign-In Has Same Issue**: In `SessionManager.signInWithGoogle()` (lines 268-307), the method uses Firebase authentication but never retrieves or stores an `access_token` from the backend for subsequent API requests.

**Why This Causes 401 Errors:**
- After login, the client makes authenticated requests to `/api/v1/wardrobe`, `/api/v1/notifications`, etc.
- These requests have no `Authorization` header, no `X-API-Key` header, and no cookies
- The backend's `AuthMiddleware` checks all three authentication methods and finds none
- The middleware returns 401 Unauthorized, causing the client to log the user out

## Correctness Properties

Property 1: Bug Condition - Bearer Token Authentication for Authenticated Requests

_For any_ HTTP request to an authenticated endpoint where the user has a valid access_token stored, the fixed client SHALL include the `Authorization: Bearer <token>` header, and the backend SHALL successfully authenticate the request by validating the token and adding userID and sessionID to the request context.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**

Property 2: Preservation - Login Flow and Non-Authenticated Requests

_For any_ login/register request OR non-authenticated public endpoint request, the fixed client SHALL produce exactly the same behavior as the original client, preserving the login flow, session storage, and public API access without requiring Authorization headers.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File 1**: `client/lib/src/auth/session_manager.dart`

**Function**: `signIn`

**Specific Changes**:
1. **Extract access_token from response**: After receiving the login response (line ~210), extract the access_token:
   ```dart
   final accessToken = tokens['access_token'] as String?;
   ```

2. **Store access_token in SharedPreferences**: Save the token for persistence:
   ```dart
   if (accessToken != null) {
     await _sharedPreferences.setString('access_token', accessToken);
   }
   ```

3. **Handle token in session restoration**: In `_initializeSession()`, also restore the access_token from SharedPreferences

**Function**: `signInWithGoogle`

**Specific Changes**:
1. **Call backend to get access_token**: After successful Firebase authentication, call the backend to exchange the Firebase token for an access_token
2. **Store the access_token**: Save it to SharedPreferences using the same mechanism as email/password login

**Function**: `signOut`

**Specific Changes**:
1. **Clear access_token**: Remove the access_token from SharedPreferences when user logs out:
   ```dart
   await _sharedPreferences.remove('access_token');
   ```

**File 2**: `client/lib/src/core/api/api_client.dart`

**Class**: `ApiClient`

**Specific Changes**:
1. **Add SharedPreferences dependency**: Inject SharedPreferences into ApiClient constructor to access the stored access_token

2. **Add Authorization header interceptor**: In the constructor (after line 23), add a new interceptor:
   ```dart
   _dio.interceptors.add(InterceptorsWrapper(
     onRequest: (options, handler) async {
       // Skip Authorization header for login/register endpoints
       if (!options.path.contains('/auth/login') &&
           !options.path.contains('/auth/register')) {
         final accessToken = _sharedPreferences.getString('access_token');
         if (accessToken != null && accessToken.isNotEmpty) {
           options.headers['Authorization'] = 'Bearer $accessToken';
         }
       }
       return handler.next(options);
     },
   ));
   ```

3. **Handle 401 errors**: The existing error interceptor already logs 401 errors; consider adding token refresh logic in the future

**File 3**: `client/lib/src/auth/session_manager.dart` (signUp method)

**Function**: `signUp`

**Specific Changes**:
1. **Extract and store access_token**: Same as signIn - extract `tokens['access_token']` and store in SharedPreferences

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm that authenticated requests fail with 401 Unauthorized because no Authorization header is sent.

**Test Plan**: Write integration tests that simulate the full login flow followed by authenticated API requests. Run these tests on the UNFIXED code to observe 401 failures and confirm the root cause.

**Test Cases**:
1. **Wardrobe Request After Login**: Login with email/password, then send `GET /api/v1/wardrobe` (will fail with 401 on unfixed code - no Authorization header)
2. **Recommendations Request After Login**: Login, then send `GET /api/v1/recommendations` (will fail with 401 on unfixed code)
3. **Notifications Request After Login**: Login, then send `GET /api/v1/notifications` (will fail with 401 on unfixed code)
4. **Google Sign-In Flow**: Sign in with Google, then make authenticated request (will fail with 401 on unfixed code)

**Expected Counterexamples**:
- All authenticated requests return 401 Unauthorized after successful login
- Network inspection shows no `Authorization` header in requests
- Root cause confirmed: client does not extract or send access_token

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL request WHERE isBugCondition(request) DO
  response := ApiClient_fixed.get(request.path)
  ASSERT response.statusCode == 200
  ASSERT request.headers['Authorization'] STARTS_WITH 'Bearer '
END FOR
```

**Test Plan**: After implementing the fix, run the same test cases and verify they succeed with proper authentication.

**Test Cases**:
1. **Wardrobe Request with Token**: Verify request includes `Authorization: Bearer <token>` header and returns 200 OK with wardrobe data
2. **Recommendations Request with Token**: Verify request includes Bearer token and returns 200 OK with recommendations
3. **Notifications Request with Token**: Verify request includes Bearer token and returns 200 OK with notifications
4. **Achievements Request with Token**: Verify request includes Bearer token and returns 200 OK with achievements
5. **Token Persistence**: Verify access_token is stored in SharedPreferences and survives app restart

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL request WHERE NOT isBugCondition(request) DO
  ASSERT ApiClient_original(request) = ApiClient_fixed(request)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-authenticated inputs

**Test Plan**: Run existing tests for login, registration, and session management to verify they continue to work exactly as before.

**Test Cases**:
1. **Login Flow Preservation**: Verify email/password login continues to work and stores session data correctly
2. **Registration Flow Preservation**: Verify user registration continues to work without changes
3. **Google Sign-In Preservation**: Verify Google authentication flow continues to work
4. **Session Restoration Preservation**: Verify session restoration from SharedPreferences continues to work
5. **Public Endpoints Preservation**: Verify public API endpoints (if any) continue to work without Authorization headers

### Unit Tests

- Test access_token extraction from login response with valid token
- Test access_token extraction with missing token (should handle gracefully)
- Test access_token storage in SharedPreferences
- Test access_token restoration from SharedPreferences
- Test Authorization header addition in Dio interceptor
- Test that login/register endpoints do NOT get Authorization header
- Test access_token removal on logout

### Property-Based Tests

- Generate random valid access tokens and verify they are correctly added to Authorization headers
- Generate random API endpoints and verify authenticated ones get Authorization header
- Generate random login responses and verify token extraction works correctly
- Test across many authenticated endpoints to ensure universal Bearer token support

### Integration Tests

- Test full authentication flow: login → store token → make authenticated request with Bearer token
- Test web client flow: register → login → access wardrobe/recommendations/notifications with tokens
- Test that Bearer token authentication works across all protected endpoints
- Test that session management works correctly with token-based auth
- Test that logout properly clears the access_token from storage
