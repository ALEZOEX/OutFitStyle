package middleware

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"

	"outfitstyle/server/internal/core/application/repositories"
	resp "outfitstyle/server/internal/pkg/http"
)

// PerUserRateLimitConfig holds configuration for per-user rate limiting
type PerUserRateLimitConfig struct {
	// Limits for authenticated users (per user ID)
	AuthenticatedLimit int
	AuthenticatedWindow time.Duration

	// Limits for anonymous requests (per IP)
	AnonymousLimit int
	AnonymousWindow time.Duration

	// Endpoint-specific limits
	ReadLimit int
	ReadWindow time.Duration
	WriteLimit int
	WriteWindow time.Duration
}

// DefaultPerUserRateLimitConfig returns the default configuration
func DefaultPerUserRateLimitConfig() PerUserRateLimitConfig {
	return PerUserRateLimitConfig{
		// Authenticated users: 1000 requests per hour
		AuthenticatedLimit: 1000,
		AuthenticatedWindow: time.Hour,

		// Anonymous users: 100 requests per hour
		AnonymousLimit: 100,
		AnonymousWindow: time.Hour,

		// Read operations: higher limit
		ReadLimit: 2000,
		ReadWindow: time.Hour,

		// Write operations: lower limit
		WriteLimit: 500,
		WriteWindow: time.Hour,
	}
}

// PerUserRateLimitMiddleware implements per-user rate limiting with different limits
// for authenticated users vs anonymous IPs, and endpoint-specific limits
func PerUserRateLimitMiddleware(limiter *RateLimiter, config PerUserRateLimitConfig) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Skip rate limiting for health checks, metrics, and swagger
			path := r.URL.Path
			if path == "/health" || path == "/metrics" || strings.HasPrefix(path, "/swagger") {
				next.ServeHTTP(w, r)
				return
			}

			// Determine identifier (user ID or IP)
			key, idType, idVal := rateIdentifier(r)

			// Determine appropriate limit based on authentication status
			var limit int
			var window time.Duration
			var limitType string

			if idType == "user" {
				// Authenticated user
				limit = config.AuthenticatedLimit
				window = config.AuthenticatedWindow
				limitType = "authenticated_per_hour"
			} else {
				// Anonymous IP
				limit = config.AnonymousLimit
				window = config.AnonymousWindow
				limitType = "anonymous_per_hour"
			}

			// Check endpoint-specific limits (read vs write)
			endpointLimit, endpointWindow, endpointLimitType := getEndpointLimit(r, config)

			// Apply both general and endpoint-specific limits
			// Check general limit first
			ok, current, remaining, resetUnix, _ := limiter.AllowWithCurrent(r.Context(), key, limit, window)

			// Set rate limit headers for general limit
			w.Header().Set("X-RateLimit-Limit", fmt.Sprintf("%d", limit))
			w.Header().Set("X-RateLimit-Remaining", fmt.Sprintf("%d", remaining))
			w.Header().Set("X-RateLimit-Reset", fmt.Sprintf("%d", resetUnix))

			if !ok {
				// Record violation
				if limiter != nil && limiter.violations != nil {
					_ = limiter.violations.Record(r.Context(), repositories.RateLimitViolation{
						Identifier:     idVal,
						IdentifierType: idType,
						Endpoint:       routeTemplateOrPath(r),
						LimitType:      limitType,
						LimitValue:     limit,
						CurrentValue:   current,
					})
				}
				resp.Error(w, http.StatusTooManyRequests, fmt.Errorf("rate limit exceeded"))
				return
			}

			// Check endpoint-specific limit if applicable
			if endpointLimit > 0 {
				endpointKey := key + ":endpoint:" + endpointLimitType
				okEndpoint, currentEndpoint, remainingEndpoint, resetEndpointUnix, _ := limiter.AllowWithCurrent(
					r.Context(), endpointKey, endpointLimit, endpointWindow)

				// Update headers with more restrictive limit
				if remainingEndpoint < remaining {
					w.Header().Set("X-RateLimit-Limit", fmt.Sprintf("%d", endpointLimit))
					w.Header().Set("X-RateLimit-Remaining", fmt.Sprintf("%d", remainingEndpoint))
					w.Header().Set("X-RateLimit-Reset", fmt.Sprintf("%d", resetEndpointUnix))
				}

				if !okEndpoint {
					// Record endpoint-specific violation
					if limiter != nil && limiter.violations != nil {
						_ = limiter.violations.Record(r.Context(), repositories.RateLimitViolation{
							Identifier:     idVal,
							IdentifierType: idType,
							Endpoint:       routeTemplateOrPath(r),
							LimitType:      endpointLimitType,
							LimitValue:     endpointLimit,
							CurrentValue:   currentEndpoint,
						})
					}
					resp.Error(w, http.StatusTooManyRequests, fmt.Errorf("rate limit exceeded"))
					return
				}
			}

			next.ServeHTTP(w, r)
		})
	}
}

// getEndpointLimit determines endpoint-specific limits based on HTTP method
func getEndpointLimit(r *http.Request, config PerUserRateLimitConfig) (limit int, window time.Duration, limitType string) {
	method := r.Method

	// Read operations: GET, HEAD, OPTIONS
	if method == http.MethodGet || method == http.MethodHead || method == http.MethodOptions {
		return config.ReadLimit, config.ReadWindow, "read_per_hour"
	}

	// Write operations: POST, PUT, PATCH, DELETE
	if method == http.MethodPost || method == http.MethodPut ||
	   method == http.MethodPatch || method == http.MethodDelete {
		return config.WriteLimit, config.WriteWindow, "write_per_hour"
	}

	// No specific limit for other methods
	return 0, 0, ""
}

// getIP extracts the real IP address from the request
func getIP(r *http.Request) string {
	// Check X-Forwarded-For header for proxied requests
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		return strings.Split(strings.TrimSpace(xff), ",")[0]
	}

	if xri := r.Header.Get("X-Real-IP"); xri != "" {
		return xri
	}

	ra := r.RemoteAddr
	if i := strings.LastIndex(ra, ":"); i > 0 {
		ra = ra[:i]
	}
	return strings.TrimSpace(ra)
}
