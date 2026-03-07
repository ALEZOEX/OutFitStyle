# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Cookie-Based Authentication Rejection
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing cases - requests with valid access_token cookies but no Authorization or X-API-Key headers
  - Test that requests with valid `access_token` cookie but no Authorization header are rejected with 401 Unauthorized
  - Test across multiple endpoints: `/api/v1/wardrobe`, `/api/v1/recommendations`, `/api/v1/notifications`, `/api/v1/achievements`
  - The test assertions should verify that authenticated requests with cookies return 200 OK with proper context (userID, sessionID)
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS with 401 Unauthorized (this is correct - it proves the bug exists)
  - Document counterexamples found (e.g., "GET /api/v1/wardrobe with valid access_token cookie returns 401 instead of 200")
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Header-Based Authentication Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs (requests with Bearer tokens or API keys)
  - Write property-based tests capturing observed behavior patterns:
    - For all requests with valid `Authorization: Bearer <token>` header, authentication succeeds
    - For all requests with valid `X-API-Key` header, authentication succeeds
    - For all requests with no credentials, authentication fails with 401
    - For all requests with invalid/expired credentials, authentication fails with 401
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. Fix for cookie-based authentication in AuthMiddleware

  - [x] 3.1 Implement cookie authentication path in AuthMiddleware
    - Add third authentication check after Bearer token and API key checks
    - Extract `access_token` cookie using `r.Cookie("access_token")`
    - If cookie exists with non-empty value, validate using `authService.ValidateAccessToken`
    - On successful validation, add userID and sessionID to request context (same as Bearer token path)
    - On validation failure, continue to 401 Unauthorized response
    - Maintain execution order: Bearer token → API key → Cookie → 401 if none succeed
    - Reuse existing validation logic for consistency
    - Use same error response pattern for consistency
    - _Bug_Condition: isBugCondition(request) where request.Header.Get("Authorization") == "" AND request.Header.Get("X-API-Key") == "" AND cookieExists(request, "access_token") AND isValidToken(getCookie(request, "access_token"))_
    - _Expected_Behavior: For requests matching bug condition, extract token from cookie, validate it, and authenticate successfully by adding userID and sessionID to context_
    - _Preservation: All header-based authentication (Bearer token, API key) must continue to work exactly as before; requests with no valid credentials must continue to return 401_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x] 3.2 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Cookie-Based Authentication Success
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify requests with valid access_token cookies authenticate successfully
    - Verify userID and sessionID are properly added to request context
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 3.3 Verify preservation tests still pass
    - **Property 2: Preservation** - Header-Based Authentication Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm Bearer token authentication still works exactly as before
    - Confirm API key authentication still works exactly as before
    - Confirm requests with no credentials still return 401
    - Confirm requests with invalid credentials still return 401
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
