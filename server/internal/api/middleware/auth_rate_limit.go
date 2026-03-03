// Пакет middleware предоставляет HTTP middleware для защиты auth endpoints от abuse
package middleware

import (
	"context"
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
// Limits:
// - POST /auth/login: 5 запросов в минуту на IP/email
// - POST /auth/register: 3 запроса в час на IP
// - POST /auth/refresh: 10 запросов в минуту на IP
// - POST /auth/google: 5 запросов в минуту на IP
// - POST /auth/forgot-password: 3 запроса в 15 минут на email
func AuthRateLimitMiddleware(redisClient *redis.Client, logger *zap.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Определяем тип endpoint и применяем соответствующий лимит
			path := strings.TrimPrefix(r.URL.Path, "/api/v1/auth/")
			ip := extractIPForRateLimit(r.RemoteAddr)
			
			var key string
			var limit int
			var window time.Duration
			
			switch {
			// Login: 5 попыток в минуту на комбинацию IP+email
			case path == "login" && r.Method == http.MethodPost:
				email := extractEmailFromRequest(r)
				key = fmt.Sprintf("ratelimit:auth:login:%s:%s", ip, email)
				limit = 5
				window = time.Minute
				
			// Register: 3 регистрации в час на IP
			case path == "register" && r.Method == http.MethodPost:
				key = fmt.Sprintf("ratelimit:auth:register:%s", ip)
				limit = 3
				window = time.Hour
				
			// Refresh: 10 refresh в минуту на IP
			case path == "refresh" && r.Method == http.MethodPost:
				key = fmt.Sprintf("ratelimit:auth:refresh:%s", ip)
				limit = 10
				window = time.Minute
				
			// Google Sign-In: 5 попыток в минуту на IP
			case path == "google" && r.Method == http.MethodPost:
				key = fmt.Sprintf("ratelimit:auth:google:%s", ip)
				limit = 5
				window = time.Minute
				
			// Forgot Password: 3 запроса в 15 минут на email
			case path == "forgot-password" && r.Method == http.MethodPost:
				email := extractEmailFromRequest(r)
				key = fmt.Sprintf("ratelimit:auth:forgot:%s", email)
				limit = 3
				window = 15 * time.Minute
				
			// Reset Password: 5 попыток в 15 минут на email
			case path == "reset-password" && r.Method == http.MethodPost:
				email := extractEmailFromRequest(r)
				key = fmt.Sprintf("ratelimit:auth:reset:%s", email)
				limit = 5
				window = 15 * time.Minute
				
			default:
				// Для других endpoints используем общий rate limiter
				next.ServeHTTP(w, r)
				return
			}
			
			// Проверяем лимит
			allowed, remaining, resetUnix, err := checkRateLimit(r.Context(), redisClient, key, limit, window)
			
			// Добавляем заголовки rate limit
			w.Header().Set("X-RateLimit-Limit", fmt.Sprintf("%d", limit))
			w.Header().Set("X-RateLimit-Remaining", fmt.Sprintf("%d", remaining))
			w.Header().Set("X-RateLimit-Reset", fmt.Sprintf("%d", resetUnix))
			
			if err != nil {
				logger.Warn("rate limit check failed, allowing request",
					zap.String("key", key),
					zap.Error(err),
				)
				// Graceful degradation: разрешаем запрос при ошибке Redis
				next.ServeHTTP(w, r)
				return
			}
			
			if !allowed {
				retryAfter := resetUnix - time.Now().Unix()
				if retryAfter < 0 {
					retryAfter = int64(window.Seconds())
				}
				w.Header().Set("Retry-After", fmt.Sprintf("%d", retryAfter))
				resp.Error(w, http.StatusTooManyRequests, fmt.Errorf("too many requests. Please try again in %d seconds", retryAfter))
				return
			}
			
			next.ServeHTTP(w, r)
		})
	}
}

// checkRateLimit проверяет и обновляет счётчик запросов в Redis
func checkRateLimit(ctx context.Context, redisClient *redis.Client, key string, limit int, window time.Duration) (allowed bool, remaining int, resetUnix int64, err error) {
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
	return allowed, remaining, resetUnix, nil
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
