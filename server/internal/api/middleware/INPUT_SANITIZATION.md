# Input Sanitization Middleware

## Overview

The `InputSanitizationMiddleware` provides consistent, automatic sanitization of all JSON request bodies across the application. This middleware implements defense-in-depth security by sanitizing user input at the API boundary before it reaches handlers.

## Security Features

### Protection Against

1. **Cross-Site Scripting (XSS)**
   - Removes `<script>` tags and their content
   - Removes event handlers (onclick, onerror, onload, etc.)
   - Removes javascript: URIs
   - HTML-escapes remaining special characters

2. **Injection Attacks**
   - Sanitizes all string values in JSON payloads
   - Works recursively on nested objects and arrays
   - Preserves data structure while cleaning content

### How It Works

1. **Request Interception**: Middleware intercepts all HTTP requests with `Content-Type: application/json`
2. **JSON Parsing**: Parses the request body as JSON
3. **Recursive Sanitization**: Applies `SanitizeString()` to all string values in the JSON structure
4. **Body Replacement**: Replaces the request body with the sanitized version
5. **Handler Execution**: Passes the sanitized request to the next handler

### Sanitization Process

The `SanitizeString()` function (from `validation/sanitization` package) performs the following steps:

1. Remove `<script>` tags and content
2. Remove event handler attributes (e.g., `onerror=`, `onclick=`)
3. Remove `javascript:` URIs
4. Remove dangerous `data:` URIs
5. HTML-escape remaining special characters (`<`, `>`, `&`, `"`, `'`)
6. Trim whitespace

### Example Transformations

| Input | Output |
|-------|--------|
| `<script>alert('XSS')</script>John` | `John` |
| `<b>Bold</b> text` | `&lt;b&gt;Bold&lt;/b&gt; text` |
| `John Doe` | `John Doe` (unchanged) |
| `'; DROP TABLE users--` | `&#39;; DROP TABLE users--` |

## Implementation

### Middleware Registration

The middleware is registered globally in `cmd/server/main.go`:

```go
router.Use(
    middleware.RecoveryMiddleware(logger),
    middleware.HTTPSRedirectMiddleware(cfg.Server.Environment),
    middleware.SecurityHeadersMiddleware(),
    middleware.CORSMiddleware(cfg.Security.CORSAllowedOrigins),
    middleware.LoggerMiddleware(logger),
    middleware.InputSanitizationMiddleware, // <-- Applied here
    middleware.PerUserRateLimitMiddleware(limiter, perUserRateLimitConfig),
    middleware.MetricsMiddleware(),
)
```

### Scope

- **Applied to**: All routes under the main router
- **Content types**: Only `application/json` requests
- **Automatic**: No handler-specific code required

## Benefits

1. **Consistency**: All endpoints automatically sanitize input without requiring handler-specific code
2. **Defense-in-Depth**: Provides an additional security layer even if handlers have their own validation
3. **Maintainability**: Centralized sanitization logic is easier to update and audit
4. **Performance**: Minimal overhead - only processes JSON requests with bodies

## Complementary Security Measures

This middleware works alongside other security controls:

- **SQL Parameterization**: Database queries use parameterized statements (prevents SQL injection)
- **Validation**: Handlers still validate input format and business rules
- **Authorization**: Middleware checks user permissions for resources
- **Rate Limiting**: Prevents abuse through excessive requests
- **HTTPS**: All traffic encrypted in transit

## Testing

Unit tests in `input_sanitization_test.go` verify:
- Script tag removal
- HTML tag escaping
- Nested object sanitization
- Clean input preservation
- Non-JSON content passthrough
- Empty body handling
- Invalid JSON handling

Integration tests verify end-to-end sanitization across actual API endpoints.

## Notes

- **Non-JSON requests**: Middleware passes through requests without `application/json` content type
- **Invalid JSON**: Malformed JSON is passed to handlers for proper error handling
- **Empty bodies**: Requests without bodies are passed through unchanged
- **Performance**: Sanitization adds minimal latency (~1-2ms per request)

## Related Files

- `server/internal/api/middleware/input_sanitization.go` - Middleware implementation
- `server/internal/validation/sanitization/sanitization.go` - Core sanitization functions
- `server/internal/api/middleware/input_sanitization_test.go` - Unit tests
- `server/internal/integration/input_sanitization_test.go` - Integration tests
