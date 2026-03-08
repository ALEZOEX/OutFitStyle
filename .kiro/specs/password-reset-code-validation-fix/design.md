# Password Reset Code Validation Bugfix Design

## Overview

The password reset flow contains a critical security vulnerability where the 6-digit verification code is not validated on the server until the final password reset step. This allows attackers to bypass code verification by entering arbitrary codes in the UI and proceeding to the password entry step without server-side validation. The vulnerability exists in the `_verifyCode()` method of `forgot_password_screen.dart`, which only updates local UI state without making a server-side validation call.

The fix requires creating a new backend endpoint `/api/v1/auth/verify-reset-code` that validates the code before allowing progression to the password entry step. The client's `_verifyCode()` method will be updated to call this endpoint and only proceed on successful validation. This ensures the code is validated twice: once before showing the password entry form (preventing brute-force attempts) and once during the final password reset (as a fallback security measure).

## Glossary

- **Bug_Condition (C)**: Password reset flow where any 6-digit code (valid or invalid) allows progression to password entry step without server-side validation
- **Property (P)**: Server-side code validation that rejects invalid codes and only allows progression with valid codes
- **Preservation**: Existing password reset flow behavior (email sending, final validation, rate limiting) that must remain unchanged
- **_verifyCode()**: The method in `forgot_password_screen.dart` (lines 73-95) that currently only updates UI state locally
- **ResetPassword**: The backend handler in `auth_handler.go` (line 642) that validates codes during final password reset
- **password_reset:{email}**: Redis key format storing the 6-digit verification code with 15-minute TTL
- **password_reset_attempts:{email}**: Redis key tracking validation attempts for rate limiting (5 attempts per 15 minutes)

## Bug Details

### Bug Condition

The bug manifests when a user enters any 6-digit code (valid or invalid) in the password reset verification step. The `_verifyCode()` method in `forgot_password_screen.dart`:
1. **D
*
```
FUNCTION isBugCondition(input)
  INPUT: input of type VerifyCodeRequest
  OUTPUT: boolean

  RETURN input.code.length == 6
         AND input.code.matches(/^\d{6}$/)
         AND NOT serverSideValidationCalled(input.code, input.email)
         AND uiStateUpdatedToPasswordStep()
END FUNCTION
```

### Examples

- **Invalid code progression**: User enters "000000" (invalid code) → UI allows progression to password entry step → No server validation occurs → User can enter new password → Only at final submit does server reject with "invalid code" (should reject at verification step)
- **Brute-force attempt**: Attacker enters "123456" → UI accepts → Enters "234567" → UI accepts → Can try multiple codes without server feedback → No rate limiting until final password reset (should rate limit at verification step)
- **Expired code**: User receives code "847291", waits 20 minutes → Enters expired code → UI allows progression → Only discovers expiration at final step (should reject immediately at verification step)
- **Valid code**: User enters correct code "847291" → UI allows progression → Server validates at final step → Password reset succeeds (correct behavior, but validation should occur earlier)
- **Edge case - non-numeric code**: User enters "abcdef" → Client-side validation rejects (correct behavior, should remain unchanged)

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Email sending with 6-digit code must continue to work exactly as before (`/api/v1/auth/forgot-password`)
- Final password reset validation must remain as fallback security measure (`/api/v1/auth/reset-password`)
- Rate limiting on password reset attempts must continue to enforce 5 attempts per 15 minutes
- Redis key format and TTL (15 minutes) for codes must remain unchanged
- UI step progression flow (email → code → password) must remain visually identical
- Client-side validation (6 digits, numeric only) must continue to work

**Scope:**
All inputs that do NOT involve the code verification step should be completely unaffected by this fix. This includes:
- Email submission step (requesting password reset code)
- Password entry step (entering new password)
- Final password reset submission with code validation
- Code resend functionality
- UI navigation and error display

## Hypothesized Root Cause

Based on code analysis of `forgot_password_screen.dart` and `auth_handler.go`, the root cause is clear:

1. **No Backend Endpoint for Code Verification**: The backend has a deprecated `VerifyCode` endpoint (line 523 in `auth_handler.go`) that returns 501 Not Implemented. There is no active endpoint to verify codes before the final password reset.

2. **Client Only Updates UI State**: In `_verifyCode()` (lines 73-95 of `forgot_password_screen.dart`), the method only calls `setState(() { _currentStep = _Step.password; })` without making any API call to validate the code.

3. **Validation Only at Final Step**: The `ResetPassword` handler (line 642 in `auth_handler.go`) validates the code, but this occurs too late in the flow after the user has already entered their new password.

4. **Rate Limiting Gap**: The rate limiting in `auth_rate_limit.go` (line 70) only applies to the `/auth/reset-password` endpoint, not to code verification attempts, allowing unlimited verification attempts.

5. **Security Design Flaw**: The original design assumed client-side validation was sufficient for the intermediate step, deferring all server-side validation to the final step. This violates the principle of defense in depth.

**Why This Creates a Security Vulnerability:**
- Attackers can enter unlimited invalid codes without server feedback
- No rate limiting prevents brute-force attempts at the verification step
- Users only discover code issues after entering their new password (poor UX)
- The 6-digit code space (1,000,000 combinations) becomes vulnerable to brute-force without early validation

## Correctness Properties

Property 1: Bug Condition - Server-Side Code Verification Before Password Entry

_For any_ code verification request where a user enters a 6-digit code, the fixed client SHALL call the backend `/api/v1/auth/verify-reset-code` endpoint to validate the code, and the backend SHALL verify the code against Redis storage, enforce rate limiting (5 attempts per 15 minutes), and only return success for valid non-expired codes, preventing progression to the password entry step for invalid codes.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

Property 2: Preservation - Existing Password Reset Flow Behavior

_For any_ password reset request that does NOT involve the code verification step (email submission, final password reset with code, code resend), the fixed system SHALL produce exactly the same behavior as the original system, preserving email sending, final validation, rate limiting, and UI flow.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File 1**: `server/internal/api/handlers/auth_handler.go`

**New Endpoint**: `VerifyResetCode`

**Specific Changes**:
1. **Create request DTO**: Add a new struct for the verification request:
   ```go
   type verifyResetCodeRequest struct {
       Email string `json:"email"`
       Code  string `json:"code"`
   }
   ```

2. **Implement VerifyResetCode handler**: Replace the deprecated `VerifyCode` method (line 523) with a working implementation:
   - Validate email and code format (6 digits)
   - Check code in Redis using key `password_reset:{email}`
   - Implement rate limiting using `password_reset_attempts:{email}` (5 attempts per 15 minutes)
   - Use constant-time comparison to prevent timing attacks
   - Return success/error without consuming the code (code remains valid for final reset)
   - Return appropriate errors: "invalid or expired code", "too many attempts"

3. **Register route**: Update the route registration in `RegisterRoutes()` method (line 109):
   ```go
   r.HandleFunc("/verify-reset-code", h.VerifyResetCode).Methods(http.MethodPost)
   ```

**File 2**: `server/internal/api/routes/auth_routes.go`

**Specific Changes**:
1. **Add route**: Register the new endpoint (after line 22):
   ```go
   auth.HandleFunc("/verify-reset-code", authHandler.VerifyResetCode).Methods("POST")
   ```

**File 3**: `server/internal/api/middleware/auth_rate_limit.go`

**Specific Changes**:
1. **Add rate limit rule**: Add rate limiting for the new endpoint (after line 70):
   ```go
   case path == "verify-reset-code" && r.Method == http.MethodPost:
       email := extractEmailFromRequest(r)
       key = fmt.Sprintf("ratelimit:auth:verify:%s", email)
       limit = 10  // Allow 10 verification attempts per window
       window = 15 * time.Minute
   ```

**File 4**: `client/lib/src/auth/session_manager.dart`

**New Method**: `verifyResetCode`

**Specific Changes**:
1. **Add verification method**: Insert after `resetPassword()` method (after line 563):
   ```dart
   /// Verify password reset code before allowing password entry
   ///
   /// Backend validates the code without consuming it
   Future<void> verifyResetCode(String email, String code) async {
     try {
       AppLogger.info('Verifying reset code for: ${_maskEmail(email)}');

       await _apiClient.post('/api/v1/auth/verify-reset-code', data: {
         'email': email,
         'code': code,
       });

       AppLogger.info('Reset code verified for: ${_maskEmail(email)}');
     } catch (e) {
       AppLogger.error('Error verifying reset code: $e', e);
       rethrow;
     }
   }
   ```

**File 5**: `client/lib/src/features/auth/presentation/screens/forgot_password_screen.dart`

**Function**: `_verifyCode`

**Specific Changes**:
1. **Add server-side validation**: Replace the current implementation (lines 73-95) with:
   ```dart
   Future<void> _verifyCode() async {
     final formState = _formKey.currentState;
     if (formState == null || !formState.validate()) return;

     setState(() {
       _isLoading = true;
       _error = null;
     });

     try {
       final sessionManager = ref.read(sessionManagerProvider);
       final email = _emailController.text.trim();
       final code = _codeController.text.trim();

       // Validate code on server before allowing progression
       await sessionManager.verifyResetCode(email, code);

       if (!mounted) return;

       // Only proceed to password step after successful validation
       setState(() {
         _currentStep = _Step.password;
         _isLoading = false;
       });
     } catch (e) {
       if (!mounted) return;
       setState(() {
         _error = e.toString();
         _isLoading = false;
       });
     }
   }
   ```

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm that invalid codes allow UI progression without server validation.

**Test Plan**: Write integration tests that simulate entering invalid codes in the verification step. Run these tests on the UNFIXED code to observe that the UI allows progression without server validation, confirming the security vulnerability.

**Test Cases**:
1. **Invalid Code Progression Test**: Enter "000000" (invalid code) in verification step (will succeed on unfixed code - UI allows progression without server call)
2. **Network Inspection Test**: Monitor network traffic during code verification (will show no API call on unfixed code)
3. **Brute-Force Simulation Test**: Enter 10 different invalid codes rapidly (will succeed on unfixed code - no rate limiting at verification step)
4. **Expired Code Test**: Enter expired code after 20 minutes (will allow progression on unfixed code - validation only at final step)

**Expected Counterexamples**:
- UI allows progression to password step with any 6-digit code
- No network request is made during code verification
- No rate limiting prevents multiple verification attempts
- Root cause confirmed: client does not validate codes on server before progression

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  response := verifyResetCode_fixed(input.email, input.code)
  ASSERT response.statusCode IN [200, 400, 429]
  ASSERT serverValidationCalled(input.code, input.email)
  IF input.code IS_INVALID THEN
    ASSERT response.statusCode == 400
    ASSERT uiStateRemainsAtCodeStep()
  END IF
  IF input.code IS_VALID THEN
    ASSERT response.statusCode == 200
    ASSERT uiStateProgressesToPasswordStep()
  END IF
END FOR
```

**Test Plan**: After implementing the fix, run tests to verify that code verification calls the backend, validates codes correctly, and enforces rate limiting.

**Test Cases**:
1. **Valid Code Verification**: Enter valid code → Backend validates successfully → UI progresses to password step → Returns 200 OK
2. **Invalid Code Rejection**: Enter invalid code → Backend returns 400 error → UI shows error message → Remains at code step
3. **Expired Code Rejection**: Enter expired code (after 15 minutes) → Backend returns 400 "invalid or expired code" → UI shows error
4. **Rate Limiting Enforcement**: Enter 6 invalid codes → Backend returns 429 "too many attempts" → UI shows rate limit error
5. **Code Preservation**: Verify code → Code remains in Redis → Can still use code for final password reset (code not consumed)

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL request WHERE NOT isBugCondition(request) DO
  ASSERT originalFlow(request) = fixedFlow(request)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-verification inputs

**Test Plan**: Run existing tests for email submission, final password reset, and code resend to verify they continue to work exactly as before.

**Test Cases**:
1. **Email Submission Preservation**: Request password reset code → Backend sends email with code → Returns success (unchanged behavior)
2. **Final Password Reset Preservation**: Submit final password reset with valid code → Backend validates code → Updates password → Returns success (unchanged behavior)
3. **Code Resend Preservation**: Click "Resend code" → Backend sends new code → Old code invalidated → Returns success (unchanged behavior)
4. **Rate Limiting Preservation**: Make 6 password reset requests → Backend enforces rate limit → Returns 429 (unchanged behavior)
5. **UI Flow Preservation**: Navigate through steps → UI displays same step indicators and forms (unchanged behavior)

### Unit Tests

- Test `verifyResetCode` handler with valid code (should return 200 OK)
- Test `verifyResetCode` handler with invalid code (should return 400 Bad Request)
- Test `verifyResetCode` handler with expired code (should return 400 with "expired" message)
- Test `verifyResetCode` handler with missing code in Redis (should return 400)
- Test rate limiting on verification endpoint (should return 429 after 10 attempts)
- Test constant-time comparison for code validation (security test)
- Test that verification does not consume the code (code remains in Redis)
- Test client-side `verifyResetCode` method calls correct endpoint with correct payload
- Test `_verifyCode` UI method calls session manager and handles errors correctly

### Property-Based Tests

- Generate random valid 6-digit codes and verify backend validates them correctly
- Generate random invalid codes (wrong length, non-numeric) and verify backend rejects them
- Generate random email addresses and verify rate limiting works per email
- Test across many verification attempts to ensure rate limiting is enforced consistently
- Generate random timing scenarios (code age) to verify expiration works correctly

### Integration Tests

- Test full password reset flow: request code → verify code → enter password → reset succeeds
- Test invalid code flow: request code → enter wrong code → verification fails → UI shows error → remains at code step
- Test rate limiting flow: request code → enter 10 wrong codes → rate limit triggered → cannot verify more codes
- Test code expiration flow: request code → wait 16 minutes → verify code → returns "expired" error
- Test that final password reset still validates code (defense in depth - two validation points)
- Test that verification does not consume code (can verify multiple times before final reset)
