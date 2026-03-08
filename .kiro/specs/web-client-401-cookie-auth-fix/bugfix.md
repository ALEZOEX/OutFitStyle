# Bugfix Requirements Document

## Introduction

The Flutter web client is unable to authenticate with the API server, resulting in 401 Unauthorized errors for all authenticated endpoints (`/api/v1/notifications`, `/api/v1/wardrobe`, `/api/v1/recommendations`, `/api/v1/achievements`). The root cause is that the web client does not send authentication credentials with API requests after login. When users log in via email/password or Google Sign-In, the backend returns an `access_token` in the response body, but the client neither stores it in a cookie nor adds it to the `Authorization` header. The backend's AuthMiddleware supports three authentication methods (Bearer token header, X-API-Key header, and access_token cookie), but the client sends none of these, causing all authenticated requests to fail.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a user successfully logs in via email/password or Google Sign-In THEN the system receives an access_token in the response body but does not store it in a cookie or send it with subsequent requests

1.2 WHEN the web client makes an authenticated API request to `/api/v1/notifications` after login THEN the system sends no Authorization header, no X-API-Key header, and no access_token cookie, resulting in 401 Unauthorized error

1.3 WHEN the web client makes an authenticated API request to `/api/v1/wardrobe` after login THEN the system sends no authentication credentials, resulting in 401 Unauthorized error

1.4 WHEN the web client makes an authenticated API request to `/api/v1/recommendations` after login THEN the system sends no authentication credentials, resulting in 401 Unauthorized error

1.5 WHEN the web client makes an authenticated API request to `/api/v1/achievements` after login THEN the system sends no authentication credentials, resulting in 401 Unauthorized error

1.6 WHEN the web client receives a 401 Unauthorized error on authenticated endpoints THEN the system displays "Требуется повторная авторизация — выход из системы" and logs the user out

### Expected Behavior (Correct)

2.1 WHEN a user successfully logs in via email/password or Google Sign-In THEN the system SHALL store the access_token from the response body and send it with all subsequent authenticated requests

2.2 WHEN the web client makes an authenticated API request to `/api/v1/notifications` after login THEN the system SHALL send the access_token (either as Authorization: Bearer header or as access_token cookie) and receive 200 OK with notification data

2.3 WHEN the web client makes an authenticated API request to `/api/v1/wardrobe` after login THEN the system SHALL send the access_token and receive 200 OK with wardrobe data

2.4 WHEN the web client makes an authenticated API request to `/api/v1/recommendations` after login THEN the system SHALL send the access_token and receive 200 OK with recommendations data

2.5 WHEN the web client makes an authenticated API request to `/api/v1/achievements` after login THEN the system SHALL send the access_token and receive 200 OK with achievements data

2.6 WHEN the web client's Dio HTTP client is configured THEN the system SHALL either enable cookie storage with withCredentials: true or add an Authorization header interceptor to include the access_token

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a user logs in successfully THEN the system SHALL CONTINUE TO store session information in SharedPreferences

3.2 WHEN the backend returns an access_token in the login response body THEN the system SHALL CONTINUE TO receive the token in the response

3.3 WHEN a user has not logged in THEN the system SHALL CONTINUE TO not send authentication credentials

3.4 WHEN the access_token is invalid or expired THEN the system SHALL CONTINUE TO receive 401 Unauthorized and handle re-authentication appropriately

3.5 WHEN non-web Flutter clients (mobile) use the same SessionManager and ApiClient THEN the system SHALL CONTINUE TO function correctly with their authentication mechanisms
