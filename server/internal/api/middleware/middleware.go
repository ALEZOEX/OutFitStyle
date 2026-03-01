package middleware

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	resp "outfitstyle/server/internal/pkg/http"
)

// CORSMiddleware handles Cross-Origin Resource Sharing
func CORSMiddleware(allowedOrigins []string) mux.MiddlewareFunc {
	allowAll := len(allowedOrigins) == 1 && allowedOrigins[0] == "*"

	allowed := map[string]struct{}{}
	for _, o := range allowedOrigins {
		o = strings.TrimSpace(o)
		if o == "" {
			continue
		}
		allowed[o] = struct{}{}
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			origin := r.Header.Get("Origin")
			w.Header().Add("Vary", "Origin")

			if allowAll {
				// Без credentials
				w.Header().Set("Access-Control-Allow-Origin", "*")
			} else if origin != "" {
				if _, ok := allowed[origin]; ok {
					w.Header().Set("Access-Control-Allow-Origin", origin)
					// Только при whitelist можно включать credentials
					w.Header().Set("Access-Control-Allow-Credentials", "true")
				}
			}

			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
			w.Header().Set("Access-Control-Max-Age", "600")

			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// SecurityHeadersMiddleware adds security headers to all responses
func SecurityHeadersMiddleware() mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Prevent clickjacking attacks
			w.Header().Set("X-Frame-Options", "DENY")
			
			// Prevent MIME type sniffing
			w.Header().Set("X-Content-Type-Options", "nosniff")
			
			// Enable XSS filter in browsers
			w.Header().Set("X-XSS-Protection", "1; mode=block")
			
			// Enforce HTTPS for future requests (1 year)
			w.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
			
			// Content Security Policy - restrict resource loading
			w.Header().Set("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https:; frame-ancestors 'none'; base-uri 'self'; form-action 'self'")
			
			// Referrer Policy - limit referrer information
			w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
			
			// Permissions Policy - disable unnecessary features
			w.Header().Set("Permissions-Policy", "geolocation=(), microphone=(), camera=(), payment=()")
			
			// Cache control for sensitive data
			w.Header().Set("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate")
			w.Header().Set("Pragma", "no-cache")
			w.Header().Set("Expires", "0")
			
			next.ServeHTTP(w, r)
		})
	}
}

// LoggerMiddleware logs request details with PII masking
func LoggerMiddleware(logger *zap.Logger) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()

			// Wrapper to capture status code
			rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

			next.ServeHTTP(rw, r)

			// Маскируем чувствительные данные
			remoteAddr := maskIP(r.RemoteAddr)

			logger.Info("HTTP Request",
				zap.String("method", r.Method),
				zap.String("path", r.URL.Path),
				zap.Int("status", rw.statusCode),
				zap.Duration("duration", time.Since(start)),
				zap.String("remote_addr", remoteAddr),
			)
		})
	}
}

// maskIP маскирует IP адрес для логирования
func maskIP(ip string) string {
	if ip == "" {
		return "***"
	}

	// Находим последнюю точку
	lastDot := -1
	for i := len(ip) - 1; i >= 0; i-- {
		if ip[i] == '.' {
			lastDot = i
			break
		}
	}

	if lastDot < 0 {
		return "***"
	}

	return "***.***.***" + ip[lastDot:]
}

// RateLimiter структура для ограничения частоты запросов
type RateLimiter struct {
	redis      *redis.Client
	violations repositories.RateLimitViolationRepository
}

// NewRedisRateLimiter создает новый RateLimiter с Redis
func NewRedisRateLimiter(rdb *redis.Client, violations repositories.RateLimitViolationRepository) *RateLimiter {
	return &RateLimiter{redis: rdb, violations: violations}
}

// AllowWithCurrent возвращает current значение (счётчик) — чтобы логировать превышение в БД.
func (l *RateLimiter) AllowWithCurrent(ctx context.Context, key string, limit int, window time.Duration) (allowed bool, current int, remaining int, resetUnix int64, err error) {
	if l == nil || l.redis == nil || limit <= 0 {
		return true, 0, limit, time.Now().Add(window).Unix(), nil
	}

	now := time.Now().Unix()
	win := int64(window.Seconds())
	if win <= 0 {
		win = 60
	}
	windowStart := (now / win) * win
	resetUnix = windowStart + win

	redisKey := fmt.Sprintf("rl:%s:%d:%d", key, win, windowStart)

	n, err := l.redis.Incr(ctx, redisKey).Result()
	if err != nil {
		// degrade gracefully
		return true, 0, limit, resetUnix, nil
	}
	if n == 1 {
		_ = l.redis.Expire(ctx, redisKey, window+5*time.Second).Err()
	}

	current = int(n)
	if current > limit {
		return false, current, 0, resetUnix, nil
	}
	return true, current, limit - current, resetUnix, nil
}

// Allow проверяет, разрешен ли запрос
func (l *RateLimiter) Allow(ctx context.Context, key string, limit int, window time.Duration) (allowed bool, remaining int, resetUnix int64, err error) {
	ok, _, remaining, resetUnix, err := l.AllowWithCurrent(ctx, key, limit, window)
	return ok, remaining, resetUnix, err
}

// RateLimitMiddleware ограничивает частоту запросов
func RateLimitMiddleware(limiter *RateLimiter, limit int, window time.Duration) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// ключ: user:{uuid} если есть, иначе ip:{remote}
			key, idType, idVal := rateIdentifier(r)

			ok, current, remaining, resetUnix, _ := limiter.AllowWithCurrent(r.Context(), key, limit, window)

			w.Header().Set("X-RateLimit-Limit", fmt.Sprintf("%d", limit))
			w.Header().Set("X-RateLimit-Remaining", fmt.Sprintf("%d", remaining))
			w.Header().Set("X-RateLimit-Reset", fmt.Sprintf("%d", resetUnix))

			if !ok {
				if limiter != nil && limiter.violations != nil {
					_ = limiter.violations.Record(r.Context(), repositories.RateLimitViolation{
						Identifier:     idVal,
						IdentifierType: idType,
						Endpoint:       routeTemplateOrPath(r),
						LimitType:      "global_per_minute",
						LimitValue:     limit,
						CurrentValue:   current,
					})
				}
				resp.Error(w, http.StatusTooManyRequests, fmt.Errorf("rate limit exceeded"))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// rateIdentifier возвращает ключ для rate limiting
func rateIdentifier(r *http.Request) (key string, identifierType string, identifierValue string) {
	if uid, ok := GetUserIDFromContext(r.Context()); ok {
		return "user:" + uid.String(), "user", uid.String()
	}

	ra := r.RemoteAddr
	if i := strings.LastIndex(ra, ":"); i > 0 {
		ra = ra[:i]
	}
	ra = strings.TrimSpace(ra)
	if ra == "" {
		ra = "unknown"
	}
	return "ip:" + ra, "ip", ra
}

// Helper struct to log status code
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}
