# Preservation Property Tests for Cookie Authentication Bugfix

## Overview

The preservation property tests in `auth_preservation_property_test.go` verify that existing authentication methods continue to work exactly as before when implementing the cookie authentication fix.

## Test Coverage

### Property 2: Preservation - Header-Based Authentication Unchanged

The tests verify the following behaviors remain unchanged:

1. **Bearer Token Authentication** (Requirement 3.1)
   - Requests with valid `Authorization: Bearer <token>` header authenticate successfully
   - Uses property-based testing to generate 10 test cases with different users and tokens

2. **API Key Authentication** (Requirement 3.2)
   - Requests with valid `X-API-Key` header authenticate successfully
   - Uses property-based testing to verify consistent behavior across multiple requests

3. **No Credentials Rejection** (Requirement 3.3)
   - Requests with no authentication credentials return 401 Unauthorized
   - Verifies the middleware properly rejects unauthenticated requests

4. **Invalid Credentials Rejection** (Requirement 3.4)
   - Requests with invalid or expired Bearer tokens return 401 Unauthorized
   - Requests with invalid API keys return 401 Unauthorized
   - Uses property-based testing to verify rejection across multiple invalid inputs

## Running the Tests

### Prerequisites

1. Start the test database:
   ```bash
   docker-compose -f docker-compose.dev.yml up -d postgres
   ```

2. Set the DATABASE_URL environment variable:
   ```bash
   export DATABASE_URL="postgres://postgres@localhost:5433/outfitstyle?sslmode=disable"
   ```

### Execute Tests

Run all preservation tests:
```bash
cd server
go test -v -tags=integration ./internal/integration -run TestPreservation
```

Run a specific preservation test:
```bash
cd server
go test -v -tags=integration ./internal/integration -run TestPreservation_BearerTokenAuthentication
```

## Expected Outcome

**IMPORTANT**: These tests MUST PASS on UNFIXED code.

The preservation tests establish the baseline behavior that must be preserved when implementing the cookie authentication fix. They should pass both before and after the fix is implemented, confirming that no regressions were introduced.

## Test Implementation

The tests use Go's `testing/quick` package for property-based testing:

- **MaxCount: 10** - Each property is tested with 10 randomly generated test cases
- **Automatic test case generation** - The testing framework generates different users, sessions, and tokens
- **Strong guarantees** - Property-based testing provides stronger guarantees than manual unit tests by testing across many inputs

## Integration with Bugfix Workflow

These tests are part of Task 2 in the bugfix workflow:

1. **Task 1**: Write bug condition exploration test (MUST FAIL on unfixed code)
2. **Task 2**: Write preservation property tests (MUST PASS on unfixed code) ← These tests
3. **Task 3**: Implement the fix
   - 3.1: Add cookie authentication to AuthMiddleware
   - 3.2: Verify bug condition test now passes
   - 3.3: Verify preservation tests still pass ← Re-run these tests

## Test Status

✅ Tests compiled successfully
✅ Tests are ready to run with database
⏳ Awaiting database setup for execution
📋 Expected to PASS on unfixed code (baseline behavior)

## Notes

- The tests use integration testing with a real database and HTTP server
- Each test creates isolated test data (users, sessions, API keys)
- Tests clean up after themselves using deferred cleanup functions
- The tests are tagged with `//go:build integration` to separate them from unit tests
