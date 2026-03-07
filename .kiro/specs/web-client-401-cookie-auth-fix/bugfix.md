# Bugfix Requirements Document

## Introduction

The web client is unable to authenticate with the API server, resulting in 401 Unauthorized errors for all authenticated endpoints. The root cause is an authentication method mismatch: the client sends httpOnly cookies (with `withCredentials: true`) while the server only validates `Authorization: Bearer <token>` headers or `X-API-Key` headers, never checking cookies. This prevents users from accessing any authenticated functionality including wardrobe, recommendations, notifications, and achievements.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the web client makes an authenticated API request with `withCredentials: true` and httpOnly cookies THEN the system returns 401 Unauthorized error

1.2 WHEN the web client attempts to access `/api/v1/wardrobe` endpoint with cookie-based authentication THEN the system returns 401 Unauthorized error

1.3 WHEN the web client attempts to access `/api/v1/recommendations` endpoint with cookie-based authentication THEN the system returns 401 Unauthorized error

1.4 WHEN the web client attempts to access `/api/v1/notifications` endpoint with cookie-based authentication THEN the system returns 401 Unauthorized error

1.5 WHEN the web client attempts to access `/api/v1/achievements` endpoint with cookie-based authentication THEN the system returns 401 Unauthorized error

1.6 WHEN the server authentication middleware processes a request with valid httpOnly cookies but no Authorization header THEN the system rejects the request with 401 Unauthorized

### Expected Behavior (Correct)

2.1 WHEN the web client makes an authenticated API request with `withCredentials: true` and valid httpOnly cookies THEN the system SHALL authenticate the request successfully and return the requested data

2.2 WHEN the web client attempts to access `/api/v1/wardrobe` endpoint with valid cookie-based authentication THEN the system SHALL authenticate successfully and return wardrobe data

2.3 WHEN the web client attempts to access `/api/v1/recommendations` endpoint with valid cookie-based authentication THEN the system SHALL authenticate successfully and return recommendations data

2.4 WHEN the web client attempts to access `/api/v1/notifications` endpoint with valid cookie-based authentication THEN the system SHALL authenticate successfully and return notifications data

2.5 WHEN the web client attempts to access `/api/v1/achievements` endpoint with valid cookie-based authentication THEN the system SHALL authenticate successfully and return achievements data

2.6 WHEN the server authentication middleware processes a request with valid httpOnly cookies but no Authorization header THEN the system SHALL extract and validate the authentication token from cookies and authenticate the request

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a request includes a valid `Authorization: Bearer <token>` header THEN the system SHALL CONTINUE TO authenticate using the Bearer token

3.2 WHEN a request includes a valid `X-API-Key` header THEN the system SHALL CONTINUE TO authenticate using the API key

3.3 WHEN a request has neither valid cookies nor valid headers THEN the system SHALL CONTINUE TO return 401 Unauthorized error

3.4 WHEN a request includes invalid or expired authentication credentials in any format THEN the system SHALL CONTINUE TO return 401 Unauthorized error

3.5 WHEN non-web clients (mobile, CLI) use header-based authentication THEN the system SHALL CONTINUE TO authenticate successfully using headers
