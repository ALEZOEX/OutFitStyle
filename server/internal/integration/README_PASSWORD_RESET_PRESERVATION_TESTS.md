# Preservation Property Tests for Password Reset Code Validation Bugfix

## Overview

The preservation property tests in `password_reset_preservation_property_test.go` verify that existing password reset flow behaviors continue to work exactly as before when implementing the code verification fix.

## Test Coverage

### Property 2: Preservation - Existing Password Reset Flow Behavior

The tests verify the following behaviors remain unchanged:

1. **Email Submission** (Requirement 3.1)
   - Requests to `/api/v1/auth/forgot-password` with valid email send a 6-digit code to Redis
   - Returns 200 OK success response
   - Uses property-based testing to generate 5 test cases with different users

2. **Final Password Reset** (Requirement 3.2)
   - Requests to `/api/v1/auth/reset-password` with valid code update the password successfully
   - Code is deleted from Redis after successful password reset (one-time use)
   - Uses property-based testing to verify consistent behavior across multiple requests

3. **Reset Password Rate Limiting** (Requirement 3.4)
   - Final password reset endpoint enforces 5 attempts per 15 minutes
   - After 5 failed attempts with wrong code, 6th attempt returns 429 Too Many Requests
   - Verifies rate limiting prevents brute-force attacks on the final reset endpoint

4. **Forgot Password Rate Limiting** (Requirement 3.1)
   - Forgot password endpoint enforces 3 requests per 15 minutes
   - After 3 requests, 4th request returns 200 OK but silently rate limits (security best practice)
   - Verifies no new code is generated when rate limited

## Running the Tests

### Prerequisites

1. Start the test database and Redis:
   ```bash
   docker-compose -f docker-compose.dev.yml up -d postgres redis
   ```

2. Set the environment variables:
   ```bash
   export DATABASE_URL="postgres://postgres@localhost:5433/outfitstyle?sslmode=disable"
   export REDIS_URL="redis://localhost:6380"
   ```

### Execute Tests

Run all preservation tests:
```bash
cd server
go test -v -tags=integration ./internal/integration -run TestPasswordResetPreservation
```

Run a specific preservation test:
```bash
cd server
go test -v -tags=integration ./internal/integration -run TestPasswordResetPreservation_EmailSubmission
```

## Expected Outcome

**IMPORTANT**: These tests MUST PASS on both UNFIXED and FIXED code.

The preservation tests establish the baseline behavior that must be preserved when implementing the code verification fix. They should pass both before and after the fix is implemented, confirming that no regressions were introduced.

## Test Implementation

The tests use Go's `testing/quick` package for property-based testing:

- **MaxCount: 5** - Each property is tested with 5 randomly generated test cases
- **Automatic test case generation** - The testing framework generates different users and scenarios
- **Strong guarantees** - Property-based testing provides stronger guarantees than manual unit tests by testing across many inputs

## Integration with Bugfix Workflow

These tests are part of Task 2 in the bugfix workflow:

1. **Task 1**: Write bug condition exploration test (MUST FAIL on unfixed code)
2. **Task 2**: Write preservation property tests (MUST PASS on unfixed code) ← These tests
3. **Task 3**: Implement the fix
   - 3.1: Create backend verification endpoint
   - 3.2: Add client-side verification method
   - 3.3: Update UI verification flow
   - 3.4: Verify bug condition test now passes
   - 3.5: Verify preservation tests still pass ← Re-run these tests

## Test Status

✅ Tests compiled successfully
✅ Tests are ready to run with database and Redis
⏳ Awaiting database and Redis setup for execution
📋 Expected to PASS on both unfixed and fixed code (baseline behavior)

## Notes

- The tests use integration testing with a real database, Redis, and HTTP server
- Each test creates isolated test data (users, codes)
- Tests gracefully skip if Redis is not available
- The tests are tagged with `//go:build integration` to separate them from unit tests
- Tests verify that password reset flow behaviors (email submission, final reset, rate limiting) remain unchanged after implementing the code verification fix

## Test Scenarios

### Email Submission Test
- Creates a test user
- Sends forgot password request with user's email
- Verifies 200 OK response
- Verifies 6-digit code is stored in Redis with correct key format
- Cleans up Redis keys after test

### Final Password Reset Test
- Creates a test user
- Stores a valid code in Redis
- Sends reset password request with code and new password
- Verifies 200 OK response
- Verifies code is deleted from Redis (one-time use)
- Cleans up Redis keys after test

### Reset Password Rate Limiting Test
- Creates a test user
- Stores a valid code in Redis
- Makes 5 failed attempts with wrong code (all return 400 Bad Request)
- Makes 6th attempt (returns 429 Too Many Requests - rate limited)
- Verifies rate limiting is enforced correctly

### Forgot Password Rate Limiting Test
- Creates a test user
- Makes 3 forgot password requests (all return 200 OK)
- Makes 4th request (returns 200 OK but silently rate limited)
- Verifies no new code is generated on 4th request (TTL check)
- Cleans up Redis keys after test
