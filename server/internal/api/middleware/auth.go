package middleware

import (
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

// Logger интерфейс для логгирования
type Logger interface {
	Debug(msg string, fields ...zap.Field)
	Info(msg string, fields ...zap.Field)
	Error(msg string, fields ...zap.Field)
}

func AuthMiddleware(authService *services.AuthService, apiKeyService *services.APIKeyService, logger ...Logger) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			startTime := time.Now()
			var log Logger
			if len(logger) > 0 && logger[0] != nil {
				log = logger[0]
			}

			// 1) Bearer JWT
			h := r.Header.Get("Authorization")
			if strings.HasPrefix(h, "Bearer ") {
				token := strings.TrimSpace(strings.TrimPrefix(h, "Bearer "))
				
				if log != nil {
					log.Debug("[AuthMiddleware] [JWT] Обнаружен Bearer токен",
						zap.String("path", r.URL.Path),
						zap.String("method", r.Method),
						zap.Int("token_length", len(token)),
					)
				}

				userID, sessionID, err := authService.ValidateAccessToken(r.Context(), token)
				if err != nil {
					if log != nil {
						log.Error("[AuthMiddleware] [JWT] Ошибка валидации токена",
							zap.String("path", r.URL.Path),
							zap.String("method", r.Method),
							zap.String("error", err.Error()),
							zap.Duration("latency_ms", time.Since(startTime)),
						)
					}
					resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
					return
				}

				if log != nil {
					log.Debug("[AuthMiddleware] [JWT] Токен валиден",
						zap.String("path", r.URL.Path),
						zap.String("method", r.Method),
						zap.String("user_id", userID.String()),
						zap.String("session_id", sessionID.String()),
						zap.Duration("latency_ms", time.Since(startTime)),
					)
				}

				ctx := WithUserID(r.Context(), userID)
				ctx = WithSessionID(ctx, sessionID)
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			// 2) API key (Business): X-API-Key
			apiKey := strings.TrimSpace(r.Header.Get("X-API-Key"))
			if apiKey != "" && apiKeyService != nil {
				if log != nil {
					log.Debug("[AuthMiddleware] [APIKey] Обнаружен API ключ",
						zap.String("path", r.URL.Path),
						zap.String("method", r.Method),
						zap.Int("api_key_length", len(apiKey)),
					)
				}

				res, err := apiKeyService.Authenticate(r.Context(), apiKey)
				if err != nil {
					if log != nil {
						log.Error("[AuthMiddleware] [APIKey] Ошибка аутентификации API ключа",
							zap.String("path", r.URL.Path),
							zap.String("method", r.Method),
							zap.String("error", err.Error()),
							zap.Duration("latency_ms", time.Since(startTime)),
						)
					}
					resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
					return
				}

				if log != nil {
					log.Debug("[AuthMiddleware] [APIKey] API ключ валиден",
						zap.String("path", r.URL.Path),
						zap.String("method", r.Method),
						zap.String("client_id", res.ClientID.String()),
						zap.Duration("latency_ms", time.Since(startTime)),
					)
				}

				// ВАЖНО: это партнёр/клиент интеграции, НЕ user
				ctx := WithClientID(r.Context(), res.ClientID)

				// session_id нет, но кладём api_key_id
				ctx = WithAPIKeyID(ctx, res.APIKeyID)

				ctx = WithAPIKeyMeta(ctx, APIKeyMeta{
					APIKeyID:           res.APIKeyID,
					RateLimitPerMinute: res.RateLimitPerMinute,
					RateLimitPerDay:    res.RateLimitPerDay,
					Permissions:        res.Permissions,
				})

				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			// 3) Cookie-based authentication: access_token cookie
			cookie, err := r.Cookie("access_token")
			if err == nil && cookie.Value != "" {
				token := strings.TrimSpace(cookie.Value)
				
				if log != nil {
					log.Debug("[AuthMiddleware] [Cookie] Обнаружен access_token cookie",
						zap.String("path", r.URL.Path),
						zap.String("method", r.Method),
						zap.Int("token_length", len(token)),
					)
				}

				userID, sessionID, err := authService.ValidateAccessToken(r.Context(), token)
				if err != nil {
					if log != nil {
						log.Error("[AuthMiddleware] [Cookie] Ошибка валидации cookie токена",
							zap.String("path", r.URL.Path),
							zap.String("method", r.Method),
							zap.String("error", err.Error()),
							zap.Duration("latency_ms", time.Since(startTime)),
						)
					}
					resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
					return
				}

				if log != nil {
					log.Debug("[AuthMiddleware] [Cookie] Cookie токен валиден",
						zap.String("path", r.URL.Path),
						zap.String("method", r.Method),
						zap.String("user_id", userID.String()),
						zap.String("session_id", sessionID.String()),
						zap.Duration("latency_ms", time.Since(startTime)),
					)
				}

				ctx := WithUserID(r.Context(), userID)
				ctx = WithSessionID(ctx, sessionID)
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			// Нет токена
			if log != nil {
				log.Debug("[AuthMiddleware] Токен не найден",
					zap.String("path", r.URL.Path),
					zap.String("method", r.Method),
					zap.Bool("has_auth_header", h != ""),
					zap.Bool("has_api_key", apiKey != ""),
					zap.Bool("has_cookie", err == nil && cookie != nil),
					zap.Duration("latency_ms", time.Since(startTime)),
				)
			}

			resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		})
	}
}
