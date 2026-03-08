# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Bearer Token Authentication Missing
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing cases - authenticated requests after login that have no Authorization header
  - Write integration test that performs login (email/password) and then makes authenticated requests
  - Test that requests to `/api/v1/wardrobe`, `/api/v1/recommendations`, `/api/v1/notifications`, `/api/v1/achievements` fail with 401 Unauthorized
  - Verify that no `Authorization` header is present in the requests (inspect network traffic or Dio request logs)
  - The test assertions should verify that authenticated requests with Bearer tokens return 200 OK with proper data
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS with 401 Unauthorized (this is correct - it proves the bug exists)
  - Document counterexamples found (e.g., "GET /api/v1/wardrobe after login returns 401 instead of 200 because no Authorization header is sent")
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Login Flow and Session Management Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs (login, registration, session management)
  - Write property-based tests capturing observed behavior patterns:
    - For all login requests (email/password), authentication succeeds and session data is stored
    - For all registration requests, user creation succeeds and session is initialized
    - For all Google Sign-In flows, Firebase authentication succeeds
    - For all session restoration flows, user data is correctly loaded from SharedPreferences
    - For all logout flows, session data is cleared from SharedPreferences
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. Fix for Bearer token authentication in web client

  - [x] 3.1 Modify SessionManager.signIn() to extract and store access_token
    - In `client/lib/src/auth/session_manager.dart`, after receiving login response (around line 210)
    - Extract access_token from response: `final accessToken = tokens['access_token'] as String?;`
    - Store access_token in SharedPreferences: `await _sharedPreferences.setString('access_token', accessToken);`
    - Handle null/missing token gracefully
    - _Bug_Condition: isBugCondition(request) where request.path IN ['/api/v1/notifications', '/api/v1/wardrobe', '/api/v1/recommendations', '/api/v1/achievements'] AND request.Header.Get("Authorization") == "" AND userHasValidAccessToken(request.context)_
    - _Expected_Behavior: For requests matching bug condition, include Authorization: Bearer <token> header and authenticate successfully_
    - _Preservation: Login flow must continue to work exactly as before; session data storage must remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x] 3.2 Modify SessionManager.signUp() to extract and store access_token
    - In `client/lib/src/auth/session_manager.dart`, in the signUp method
    - Extract access_token from registration response: `final accessToken = tokens['access_token'] as String?;`
    - Store access_token in SharedPreferences: `await _sharedPreferences.setString('access_token', accessToken);`
    - Handle null/missing token gracefully
    - _Requirements: 2.1, 2.2, 3.1_

  - [x] 3.3 Modify SessionManager.signInWithGoogle() to get access_token from backend
    - In `client/lib/src/auth/session_manager.dart`, after successful Firebase authentication
    - Call backend endpoint to exchange Firebase token for access_token
    - Store access_token in SharedPreferences using same mechanism as email/password login
    - Handle errors gracefully
    - _Requirements: 2.1, 2.2, 3.2_

  - [x] 3.4 Modify SessionManager.signOut() to clear access_token
    - In `client/lib/src/auth/session_manager.dart`, in the signOut method
    - Remove access_token from SharedPreferences: `await _sharedPreferences.remove('access_token');`
    - Ensure token is cleared before user logs out
    - _Requirements: 3.5_

  - [x] 3.5 Modify SessionManager._initializeSession() to restore access_token
    - In `client/lib/src/auth/session_manager.dart`, in the _initializeSession method
    - Restore access_token from SharedPreferences when app starts
    - Verify token is available for ApiClient to use
    - _Requirements: 2.3, 3.4_

  - [x] 3.6 Add SharedPreferences dependency to ApiClient constructor
    - In `client/lib/src/core/api/api_client.dart`, modify constructor
    - Inject SharedPreferences instance to access stored access_token
    - Update all ApiClient instantiation sites to pass SharedPreferences
    - _Requirements: 2.4_

  - [x] 3.7 Add Dio interceptor to inject Authorization header
    - In `client/lib/src/core/api/api_client.dart`, in the constructor (after line 23)
    - Add InterceptorsWrapper to Dio client
    - In onRequest callback, check if path is NOT login/register endpoint
    - If authenticated endpoint, get access_token from SharedPreferences
    - Add `Authorization: Bearer <token>` header to request
    - Skip Authorization header for `/auth/login` and `/auth/register` endpoints
    - Handle missing token gracefully (don't add header if token is null/empty)
    - _Requirements: 2.5, 2.6_

  - [x] 3.8 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Bearer Token Authentication Success
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify requests to `/api/v1/wardrobe`, `/api/v1/recommendations`, `/api/v1/notifications`, `/api/v1/achievements` now return 200 OK
    - Verify `Authorization: Bearer <token>` header is present in requests
    - Verify authenticated data is returned correctly
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 3.9 Verify preservation tests still pass
    - **Property 2: Preservation** - Login Flow and Session Management Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm login flow continues to work exactly as before
    - Confirm registration flow continues to work exactly as before
    - Confirm Google Sign-In flow continues to work
    - Confirm session restoration continues to work
    - Confirm logout continues to work and clears all session data
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
