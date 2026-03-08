6# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Invalid Code Allows UI Progression Without Server Validation
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing cases - any 6-digit code that allows UI progression without server-side validation
  - Test that entering any 6-digit code (valid or invalid) in the verification step allows progression to password entry step without making a server API call
  - The test assertions should verify: (1) No network request to `/api/v1/auth/verify-reset-code` is made, (2) UI state changes to password step, (3) No server-side validation occurs
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found: invalid codes like "000000", "123456" that allow progression without validation
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.1, 2.2_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Existing Password Reset Flow Behavior
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs (email submission, final password reset, code resend)
  - Write property-based tests capturing observed behavior patterns:
    - Email submission with valid email sends code and returns success
    - Final password reset with valid code updates password successfully
    - Code resend invalidates old code and sends new code
    - Rate limiting enforces 5 attempts per 15 minutes on final reset
    - UI step progression flow (email → code → password) displays correctly
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. Fix for password reset code validation vulnerability

  - [x] 3.1 Create backend verification endpoint
    - Add `verifyResetCodeRequest` struct in `auth_handler.go` with email and code fields
    - Implement `VerifyResetCode` handler method (replace deprecated method at line 523):
      - Validate email and code format (6 digits, numeric only)
      - Check code in Redis using key `password_reset:{email}`
      - Implement rate limiting using `password_reset_attempts:{email}` (5 attempts per 15 minutes)
      - Use constant-time comparison to prevent timing attacks
      - Return success/error without consuming the code (code remains valid for final reset)
      - Return appropriate errors: "invalid or expired code", "too many attempts"
    - Register route in `RegisterRoutes()` method (line 109): `/verify-reset-code` POST endpoint
    - Add route in `auth_routes.go` (after line 22): register `/verify-reset-code` endpoint
    - Add rate limit rule in `auth_rate_limit.go` (after line 70): 10 attempts per 15 minutes for verification
    - _Bug_Condition: isBugCondition(input) where input.code.length == 6 AND NOT serverSideValidationCalled(input.code, input.email)_
    - _Expected_Behavior: Server validates code, enforces rate limiting, returns success only for valid codes_
    - _Preservation: Email sending, final validation, existing rate limiting must remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 3.2 Add client-side verification method
    - Add `verifyResetCode` method in `session_manager.dart` (after line 563):
      - Call `/api/v1/auth/verify-reset-code` endpoint with email and code
      - Handle success and error responses
      - Log verification attempts with masked email
      - Rethrow errors for UI handling
    - _Bug_Condition: Client must call server validation before UI progression_
    - _Expected_Behavior: Client calls backend endpoint and only proceeds on success_
    - _Preservation: Existing session manager methods remain unchanged_
    - _Requirements: 2.1, 2.2_

  - [x] 3.3 Update UI verification flow
    - Replace `_verifyCode` method in `forgot_password_screen.dart` (lines 73-95):
      - Add server-side validation call to `sessionManager.verifyResetCode(email, code)`
      - Only update UI state to password step after successful server validation
      - Handle errors and display appropriate error messages
      - Maintain loading state during validation
    - _Bug_Condition: UI must not progress without server validation_
    - _Expected_Behavior: UI only progresses to password step after successful server validation_
    - _Preservation: UI step flow, error display, and navigation remain visually identical_
    - _Requirements: 2.1, 2.2, 2.4_

  - [x] 3.4 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Server-Side Code Verification Before Password Entry
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify: (1) Network request to `/api/v1/auth/verify-reset-code` is made, (2) Invalid codes prevent UI progression, (3) Valid codes allow progression, (4) Rate limiting is enforced
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 3.5 Verify preservation tests still pass
    - **Property 2: Preservation** - Existing Password Reset Flow Behavior
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm all tests still pass after fix: email submission, final password reset, code resend, rate limiting, UI flow
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 4. Checkpoint - Ensure all tests pass
  - Run all unit tests for backend verification endpoint
  - Run all integration tests for full password reset flow
  - Run property-based tests for code validation and rate limiting
  - Verify no regressions in existing password reset functionality
  - Ensure all tests pass, ask the user if questions arise
