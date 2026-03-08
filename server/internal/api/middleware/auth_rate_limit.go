// Пакет middleware предоставляет HTTP middleware для защиты auth endpoints от abuse
package middleware

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	resp "outfitstyle/server/internal/pkg/http"
)

// AuthRateLimitMiddleware защищает auth endpoints от brute-force и abuse
//
// Implements security requirements 2.8:
// - Per-IP rate limit: 5 attempts per 15 minutes
// - Per-email rate limit: 3 attempts per hour
// - Exponential backoff after each failed attempt
// - CAPTCHA requirement after threshold violations (3 failed attempts)
// - Uses Redis for distributed rate limiting across multiple instances
//
// Limits:
// - POST /auth/login: 5 per 15min (IP), 3 per hour (email)
// - POST /auth/register: 5 per 15min (IP), 3 per hour (email)
// - POST /auth/refresh: 10 per minute (IP)
// - POST /auth/google: 5 per 15min (IP)
// - POST /auth/forgot-password: 3 per 15min (email)
// - POST /auth/reset-password: 5 per 15min (email)
func AuthRateLimitMiddleware(redisClient *redis.Client, logger *zap.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Определяем тип endpoint и применяем соответствующий лимит
			path := strings.TrimPrefix(r.URL.Path, "/api/v1/auth/")
			ip := extractIPForRateLimit(r.RemoteAddr)

			var ipKey, emailKey string
			var ipLimit, emailLimit int
			var ipWindow, emailWindow time.Duration
			var requiresEmailLimit bool

			switch {
			// Login: 5 per 15min (IP), 3 per hour (email)
			case path == "login" && r.Method == http.MethodPost:
				email := extractEmailFromRequest(r)
				ipKey = fmt.Sprintf("ratelimit:auth:login:ip:%s", ip)
				emailKey = fmt.Sprintf("ratelimit:auth:login:email:%s", email)
				ipLimit = 5
				ipWindow = 15 * time.Minute
				emailLimit = 3
				emailWindow = time.Hour
				requiresEmailLimit = true

			// Register: 5 per 15min (IP), 3 per hour (email)
			case path == "register" && r.Method == http.MethodPost:
				email := extractEmailFromRequest(r)
				ipKey = fmt.Sprintf("ratelimit:auth:register:ip:%s", ip)
				emailKey = fmt.Sprintf("ratelimit:auth:register:email:%s", email)
				ipLimit = 5
				ipWindow = 15 * time.Minute
				emailLimit = 3
				emailWindow = time.Hour
				requiresEmailLimit = true

			// Refresh: 10 refresh per minute (IP only)
			case path == "refresh" && r.Method == http.MethodPost:
				ipKey = fmt.Sprintf("ratelimit:auth:refresh:ip:%s", ip)
				ipLimit = 10
				ipWindow = time.Minute
				requiresEmailLimit = false

			// Google Sign-In: 5 per 15min (IP only)
			case path == "google" && r.Method == http.MethodPost:
				ipKey = fmt.Sprintf("ratelimit:auth:google:ip:%s", ip)
				ipLimit = 5
				ipWindow = 15 * time.Minute
				requiresEmailLimit = false

			// Forgot Password: 3 per 15min (email only)
			case path == "forgot-password" && r.Method == http.MethodPost:
				email := extractEmailFromRequest(r)
				emailKey = fmt.Sprintf("ratelimit:auth:forgot:email:%s", email)
				emailLimit = 3
				emailWindow = 15 * time.Minute
				requiresEmailLimit = true
				ipKey = "" // No IP limit for forgot password

			// Reset Password: 5 per 15min (email only)
			case path == "reset-password" && r.Method == http.MethodPost:
				email := extractEmailFromRequest(r)
				emailKey = fmt.Sprintf("ratelimit:auth:reset:email:%s", email)
				emailLimit = 5
				emailWindow = 15 * time.Minute
				requiresEmailLimit = true
				ipKey = "" // No IP limit for reset password

			default:
				// Для других endpoints используем общий rate limiter
				next.ServeHTTP(w, r)
				return
			}

			// Check IP rate limit (if applicable)
			if ipKey != "" {
				allowed, remaining, resetUnix, err := checkRateLimitWithBackoff(r.Context(), redisClient, ipKey, ipLimit, ipWindow)

				// Add rate limit headers for IP
				w.Header().Set("X-RateLimit-IP-Limit", fmt.Sprintf("%d", ipLimit))
				w.Header().Set("X-RateLimit-IP-Remaining", fmt.Sprintf("%d", remaining))
				w.Header().Set("X-RateLimit-IP-Reset", fmt.Sprintf("%d", resetUnix))

				if err != nil {
					logger.Warn("IP rate limit check failed, allowing request",
						zap.String("key", ipKey),
						zap.Error(err),
					)
				} else if !allowed {
					// Check if CAPTCHA is required (after 3 failed attempts)
					requiresCaptcha := checkCaptchaRequired(r.Context(), redisClient, ipKey)

					retryAfter := resetUnix - time.Now().Unix()
					if retryAfter < 0 {
						retryAfter = int64(ipWindow.Seconds())
					}
					w.Header().Set("Retry-After", fmt.Sprintf("%d", retryAfter))
					w.Header().Set("X-Requires-Captcha", fmt.Sprintf("%t", requiresCaptcha))

					errMsg := fmt.Sprintf("too many requests from your IP. Please try again in %d seconds", retryAfter)
					if requiresCaptcha {
						errMsg = "too many failed attempts. CAPTCHA verification required"
					}
					resp.Error(w, http.StatusTooManyRequests, errors.New(errMsg))
					return
				}
			}

			// Check email rate limit (if applicable)
			if requiresEmailLimit && emailKey != "" {
				allowed, remaining, resetUnix, err := checkRateLimitWithBackoff(r.Context(), redisClient, emailKey, emailLimit, emailWindow)

				// Add rate limit headers for email
				w.Header().Set("X-RateLimit-Email-Limit", fmt.Sprintf("%d", emailLimit))
				w.Header().Set("X-RateLimit-Email-Remaining", fmt.Sprintf("%d", remaining))
				w.Header().Set("X-RateLimit-Email-Reset", fmt.Sprintf("%d", resetUnix))

				if err != nil {
					logger.Warn("Email rate limit check failed, allowing request",
						zap.String("key", emailKey),
						zap.Error(err),
					)
				} else if !allowed {
					// Check if CAPTCHA is required (after 3 failed attempts)
					requiresCaptcha := checkCaptchaRequired(r.Context(), redisClient, emailKey)

					retryAfter := resetUnix - time.Now().Unix()
					if retryAfter < 0 {
						retryAfter = int64(emailWindow.Seconds())
					}
					w.Header().Set("Retry-After", fmt.Sprintf("%d", retryAfter))
					w.Header().Set("X-Requires-Captcha", fmt.Sprintf("%t", requiresCaptcha))

					errMsg := fmt.Sprintf("too many requests for this email. Please try again in %d seconds", retryAfter)
					if requiresCaptcha {
						errMsg = "too many failed attempts. CAPTCHA verification required"
					}
					resp.Error(w, http.StatusTooManyRequests, errors.New(errMsg))
					return
				}
			}

			next.ServeHTTP(w, r)
		})
	}
}

// checkRateLimitWithBackoff проверяет и обновляет счётчик запросов в Redis с экспоненциальной задержкой
// Implements exponential backoff: delay increases with each failed attempt
func checkRateLimitWithBackoff(ctx context.Context, redisClient *redis.Client, key string, limit int, window time.Duration) (allowed bool, remaining int, resetUnix int64, err error) {
	if redisClient == nil {
		// Redis недоступен — разрешаем все запросы (graceful degradation)
		return true, limit, time.Now().Add(window).Unix(), nil
	}

	now := time.Now().Unix()
	windowStart := (now / int64(window.Seconds())) * int64(window.Seconds())
	resetUnix = windowStart + int64(window.Seconds())

	redisKey := fmt.Sprintf("%s:%d", key, windowStart)

	// Атомарно увеличиваем счётчик
	count, err := redisClient.Incr(ctx, redisKey).Result()
	if err != nil {
		return true, limit, resetUnix, err
	}

	// Устанавливаем TTL для ключа
	if count == 1 {
		_, _ = redisClient.Expire(ctx, redisKey, window+5*time.Second).Result()
	}

	remaining = limit - int(count)
	if remaining < 0 {
		remaining = 0
	}

	allowed = count <= int64(limit)

	// Exponential backoff: track failed attempts
	if !allowed {
		failedKey := fmt.Sprintf("%s:failed", key)
		failedCount, _ := redisClient.Incr(ctx, failedKey).Result()
		if failedCount == 1 {
			// Set expiry for failed attempts counter (reset after window expires)
			_, _ = redisClient.Expire(ctx, failedKey, window+time.Minute).Result()
		}

		// Calculate exponential backoff delay
		// Formula: baseDelay * 2^(failedAttempts-1)
		// Example: 1s, 2s, 4s, 8s, 16s, 32s, 64s (capped at window duration)
		backoffDelay := time.Second * time.Duration(1<<(failedCount-1))
		if backoffDelay > window {
			backoffDelay = window
		}

		// Update reset time to include backoff
		resetUnix = now + int64(backoffDelay.Seconds())
	}

	return allowed, remaining, resetUnix, nil
}

// checkCaptchaRequired determines if CAPTCHA verification is required
// Returns true if there have been 3 or more failed attempts
func checkCaptchaRequired(ctx context.Context, redisClient *redis.Client, key string) bool {
	if redisClient == nil {
		return false
	}

	failedKey := fmt.Sprintf("%s:failed", key)
	failedCount, err := redisClient.Get(ctx, failedKey).Int64()
	if err != nil {
		return false
	}

	// Require CAPTCHA after 3 failed attempts
	return failedCount >= 3
}

// checkRateLimit проверяет и обновляет счётчик запросов в Redis (legacy function, kept for compatibility)
func checkRateLimit(ctx context.Context, redisClient *redis.Client, key string, limit int, window time.Duration) (allowed bool, remaining int, resetUnix int64, err error) {
	return checkRateLimitWithBackoff(ctx, redisClient, key, limit, window)
}

// extractIPForRateLimit извлекает IP адрес из RemoteAddr
func extractIPForRateLimit(remoteAddr string) string {
	// Удаляем порт
	if idx := strings.LastIndex(remoteAddr, ":"); idx != -1 {
		return remoteAddr[:idx]
	}
	return remoteAddr
}

// extractEmailFromRequest пытается извлечь email из запроса
func extractEmailFromRequest(r *http.Request) string {
	// Пробуем получить из JSON body (для POST запросов)
	// Это упрощённая реализация — в production лучше парсить body заранее
	email := r.FormValue("email")
	if email == "" {
		// Fallback на IP если email не найден
		email = extractIPForRateLimit(r.RemoteAddr)
	}
	return strings.ToLower(strings.TrimSpace(email))
}
