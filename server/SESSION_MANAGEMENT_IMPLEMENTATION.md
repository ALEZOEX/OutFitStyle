# Session Management Enhancement Implementation

## Overview

This document describes the implementation of enhanced session management features for the OutfitStyle application, addressing security requirement 2.10 from the security audit.

## Features Implemented

### 1. Configurable Timeouts

#### Idle Timeout (30 minutes default)
- Sessions expire after 30 minutes of inactivity
- Tracked via `last_used_at` timestamp
- Automatically updated on each request via `Touch()` method
- Configurable via `SessionConfig.IdleTimeout`

#### Absolute Timeout (24 hours default)
- Sessions expire after 24 hours regardless of activity
- Tracked via `expires_at` timestamp
- Set during session creation
- Configurable via `SessionConfig.AbsoluteTimeout`

### 2. Device Tracking

The system now tracks comprehensive device information for each session:

- **device_id**: Unique device identifier
- **device_name**: User-friendly device name (e.g., "John's iPhone")
- **device_type**: Device category (mobile, desktop, tablet)
- **device_fingerprint**: Browser fingerprint for additional security
- **ip_address**: IP address of the device
- **user_agent**: Browser user agent string

### 3. Concurrent Session Limits

- Maximum 5 concurrent sessions per user (configurable)
- When limit is exceeded, the oldest session is automatically revoked
- Prevents session hijacking by limiting active sessions
- Configurable via `SessionConfig.MaxConcurrentSessions`

### 4. Session Management API

Users can now manage their active sessions through REST API endpoints:

#### GET /api/v1/sessions
- Lists all active sessions for the current user
- Shows device information, creation time, last activity
- Indicates which session is the current one
- Returns session configuration (timeouts, limits)

#### POST /api/v1/sessions/revoke
- Revokes a specific session by ID
- Requires authentication
- Only allows revoking own sessions (authorization check)

#### POST /api/v1/sessions/revoke-all
- Revokes all sessions except the current one
- Useful for "logout from all devices" functionality
- Requires authentication

## Database Schema Changes

### Migration 000021: Enhance Sessions Table

Added columns to the `sessions` table:
```sql
- device_id text
- device_name text
- device_type text
- device_fingerprint text
```

Added indexes for performance:
```sql
- idx_sessions_device_fingerprint
- idx_sessions_user_active (composite: user_id, is_active)
- idx_sessions_last_used_at
```

## Code Structure

### New Files Created

1. **server/internal/core/application/services/session_service.go**
   - `SessionService`: Core business logic for session management
   - `SessionConfig`: Configuration for timeouts and limits
   - Methods: CreateSession, ValidateSession, ListUserSessions, RevokeSession, RevokeAllSessions, CleanupExpiredSessions

2. **server/internal/api/handlers/session_handler.go**
   - `SessionHandler`: HTTP handlers for session management endpoints
   - Methods: ListSessions, RevokeSession, RevokeAllSessions

3. **server/internal/api/routes/session_routes.go**
   - `RegisterSessionRoutes`: Route registration for session endpoints

4. **server/internal/integration/migrations/000021_enhance_sessions.up.sql**
   - Database migration to add device tracking columns

5. **server/internal/integration/migrations/000021_enhance_sessions.down.sql**
   - Rollback migration

### Modified Files

1. **server/internal/infrastructure/persistence/postgres/pg/session_repository.go**
   - Updated `Create()` to include new device fields
   - Updated `GetByID()` to return new device fields
   - Updated `ListByUser()` to return new device fields
   - Updated `UpdateDeviceInfo()` to update new device fields

## Configuration

### Default Configuration

```go
SessionConfig{
    IdleTimeout:           30 * time.Minute,  // 30 minutes
    AbsoluteTimeout:       24 * time.Hour,    // 24 hours
    MaxConcurrentSessions: 5,                 // 5 devices
}
```

### Environment Variables

Session timeouts are derived from existing JWT token TTL configuration:
- `JWT_ACCESS_TOKEN_TTL`: Access token lifetime (default: 15 minutes)
- `JWT_REFRESH_TOKEN_TTL`: Refresh token lifetime (default: 30 days)

The session absolute timeout should align with the refresh token TTL.

## Security Features

### 1. Session Validation
- Checks if session is active
- Validates absolute timeout (expires_at)
- Validates idle timeout (last_used_at + idle_timeout)
- Automatically revokes expired sessions

### 2. Authorization
- Users can only view and revoke their own sessions
- Unauthorized revoke attempts are logged and rejected with 403 Forbidden

### 3. Automatic Cleanup
- `CleanupExpiredSessions()` method for periodic cleanup
- Should be called via cron job or scheduled task
- Removes sessions that have exceeded timeouts

### 4. Device Fingerprinting
- Supports browser fingerprinting for additional security
- Can detect session hijacking across different devices
- Indexed for fast lookups

## Integration Points

### Auth Service Integration

The `AuthService` already creates sessions during login/registration. To integrate the new session management:

1. **Initialize SessionService** in main.go:
```go
sessionConfig := services.DefaultSessionConfig()
sessionService := services.NewSessionService(sessionRepo, sessionConfig, logger)
```

2. **Register Session Routes** in main.go:
```go
sessionHandler := handlers.NewSessionHandler(sessionService, logger)
routes.RegisterSessionRoutes(apiV1, sessionHandler, authMiddleware)
```

3. **Add Periodic Cleanup** (optional):
```go
// Run cleanup every hour
ticker := time.NewTicker(1 * time.Hour)
go func() {
    for range ticker.C {
        if err := sessionService.CleanupExpiredSessions(context.Background()); err != nil {
            logger.Error("Failed to cleanup expired sessions", zap.Error(err))
        }
    }
}()
```

### Middleware Integration

The existing auth middleware already calls `sessionRepo.Touch()` to update last activity. The session validation logic can be enhanced by using `SessionService.ValidateSession()` instead of direct repository calls.

## Testing

### Manual Testing

1. **Create multiple sessions**:
   - Login from different devices/browsers
   - Verify sessions appear in GET /api/v1/sessions

2. **Test idle timeout**:
   - Create a session
   - Wait 30+ minutes without activity
   - Verify session is expired on next request

3. **Test absolute timeout**:
   - Create a session
   - Keep it active (make requests every 10 minutes)
   - After 24 hours, verify session is expired

4. **Test concurrent session limit**:
   - Login from 6 different devices
   - Verify oldest session is automatically revoked

5. **Test session revocation**:
   - Login from multiple devices
   - Revoke a specific session
   - Verify that session can no longer be used
   - Verify other sessions remain active

6. **Test revoke all sessions**:
   - Login from multiple devices
   - Call POST /api/v1/sessions/revoke-all
   - Verify all other sessions are revoked
   - Verify current session remains active

### Property-Based Testing

The implementation supports the following properties:

**Property 1: Bug Condition - Session Timeouts Enforced**
- For any session where `last_used_at + idle_timeout < now` OR `expires_at < now`, the session SHALL be expired and rejected

**Property 2: Preservation - Active Sessions Remain Active**
- For any session where `last_used_at + idle_timeout >= now` AND `expires_at >= now`, the session SHALL remain active and valid

## Deployment

### Migration Steps

1. **Apply database migration**:
```bash
cd server
make migrate-up
# or
migrate -path ./internal/integration/migrations -database "postgres://..." up
```

2. **Update application code**:
   - Deploy new version with session management code
   - Ensure SessionService is initialized
   - Ensure session routes are registered

3. **Configure timeouts** (optional):
   - Set environment variables for custom timeouts
   - Restart application

4. **Setup cleanup job** (optional):
   - Add cron job or scheduled task to call cleanup endpoint
   - Or implement in-process cleanup ticker

## Monitoring

### Metrics to Track

1. **Active sessions per user**: Monitor for unusual spikes
2. **Session creation rate**: Detect potential abuse
3. **Session expiration rate**: Understand user behavior
4. **Concurrent session limit hits**: Track how often users hit the limit
5. **Unauthorized revoke attempts**: Security monitoring

### Logging

The implementation logs the following events:
- Session creation (with user_id, session_id)
- Session validation failures (expired, inactive)
- Session revocation (with user_id, session_id)
- Concurrent session limit exceeded
- Unauthorized revoke attempts
- Cleanup operations (with deleted count)

## Future Enhancements

1. **Geolocation tracking**: Add country/city based on IP address
2. **Suspicious activity detection**: Alert on sessions from unusual locations
3. **Session transfer**: Allow users to transfer sessions between devices
4. **Push notifications**: Notify users of new session creation
5. **Session naming**: Allow users to name their devices
6. **Last activity details**: Track which endpoints were accessed

## References

- Security Audit Report: docs/SECURITY_AUDIT_REPORT.md
- Bugfix Spec: .kiro/specs/security-logic-audit-fixes/bugfix.md
- Design Document: .kiro/specs/security-logic-audit-fixes/design.md
- Task 12.1: Implement session management enhancements
