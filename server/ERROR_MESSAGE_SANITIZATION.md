# Error Message Sanitization Implementation

## Overview

This document describes the implementation of error message sanitization to prevent information disclosure vulnerabilities (Security Fix #11 from the security audit).

## Security Requirement

**Bug Condition**: `input.type == "ERROR_RESPONSE" AND input.exposesInternalDetails`

**Expected Behavior**: Generic error messages returned to clients, no internal details exposed

**Preservation**: Validation errors still provide helpful messages

## Implementation

### 1. Error Handler Middleware (`server/internal/middleware/error_handler.go`)

The error handler middleware provides:

#### Error Categorization

Errors are categorized into four types:
- **Validation** (400): User input errors - returns helpful messages
- **Not Found** (404): Resource not found - returns generic "Resource not found"
- **Unauthorized** (401/403): Authentication/authorization failures - returns generic "Unauthorized"
- **Internal** (500): Server errors - returns generic "Internal server error"

#### Error Types

```go
type AppError struct {
    Category ErrorCategory
    Message  string
    Err      error
}
```

Helper functions:
- `NewValidationError(message string)` - For validation errors (message shown to user)
- `NewNotFoundError(message string)` - For not found errors (generic message shown)
- `NewUnauthorizedError(message string)` - For auth errors (generic message shown)
- `NewInternalError(err error)` - For internal errors (generic message shown)

#### Automatic Categorization

The `categorizeError()` function automatically categorizes errors based on:
1. Explicit `AppError` type
2. Error message patterns (e.g., "not found", "invalid", "unauthorized")

#### Logging

- **Server-side**: Full error details including stack traces are logged using structured JSON logging
- **Client-side**: Only generic sanitized messages are returned

```go
// Server logs (internal only)
logger.Error("Internal server error",
    zap.String("category", "internal"),
    zap.Int("status_code", 500),
    zap.String("method", "GET"),
    zap.String("path", "/api/v1/resource"),
    zap.String("remote_addr", "192.168.1.100"),
    zap.Error(err),
    zap.ByteString("stack_trace", debug.Stack()),
)

// Client response (sanitized)
{
    "error": "Internal server error"
}
```

### 2. Response Package Updates (`server/internal/pkg/http/response.go`)

Updated `Error()` and `JSONError()` functions to automatically sanitize error messages based on HTTP status codes:

- **5xx errors**: Always return "Internal server error"
- **404 errors**: Always return "Resource not found"
- **401/403 errors**: Always return "Unauthorized"
- **4xx validation errors**: Return the actual error message (assumed to be user-friendly)

### 3. Recovery Middleware Updates (`server/internal/api/middleware/recovery.go`)

Updated panic recovery to:
- Log full panic details including stack trace server-side
- Return only generic "Internal server error" message to clients
- Never expose stack traces in HTTP responses

## Usage Examples

### Using Typed Errors

```go
// In a handler
func (h *Handler) GetUser(w http.ResponseWriter, r *http.Request) {
    user, err := h.service.GetUser(userID)
    if err != nil {
        if errors.Is(err, ErrUserNotFound) {
            middleware.HandleError(w, r,
                middleware.NewNotFoundError("user not found"),
                h.logger)
            return
        }
        middleware.HandleError(w, r,
            middleware.NewInternalError(err),
            h.logger)
        return
    }
    // ... success response
}
```

### Using Existing Error Functions

```go
// Validation error - message is shown to user
if !isValidEmail(email) {
    http.Error(w, http.StatusBadRequest, errors.New("Invalid email format"))
    return
}

// Internal error - generic message shown to user
if err := db.Query(...); err != nil {
    http.Error(w, http.StatusInternalServerError, err)
    return
}
```

## Security Properties

### ✅ No Information Disclosure

- Database errors are never exposed to clients
- Stack traces are never included in responses
- Internal implementation details are hidden
- File paths and system information are not leaked

### ✅ Helpful Validation Messages

- Validation errors (400) still provide helpful feedback
- Users can understand what went wrong with their input
- Error messages guide users to correct their requests

### ✅ Comprehensive Server Logging

- All errors are logged with full details server-side
- Structured JSON logging for easy parsing
- Stack traces included for internal errors
- Request context (method, path, IP) logged for debugging

## Testing

Tests verify:
1. Error categorization works correctly
2. Generic messages are returned for internal errors
3. Helpful messages are returned for validation errors
4. No stack traces appear in client responses
5. Full details are logged server-side

Run tests:
```bash
cd server
go test ./internal/middleware/error_handler_test.go ./internal/middleware/error_handler.go -v
```

## Integration

The error sanitization is automatically applied through:

1. **Recovery Middleware**: Catches panics and sanitizes responses
2. **Response Package**: Sanitizes all error responses
3. **Handler Functions**: Can use `middleware.HandleError()` for explicit error handling

No changes required to existing handlers - error sanitization is applied automatically.

## Compliance

This implementation satisfies:
- **Requirement 2.11**: Generic error messages returned, no internal details exposed
- **Requirement 3.11**: Validation errors still provide helpful messages
- **OWASP**: Prevents information disclosure through error messages
- **CWE-209**: Mitigation of Information Exposure Through an Error Message

## Future Enhancements

Potential improvements:
1. Error codes for client-side error handling
2. Localized error messages
3. Rate limiting on error responses to prevent enumeration
4. Correlation IDs for tracking errors across services
