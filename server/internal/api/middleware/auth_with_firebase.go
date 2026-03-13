package middleware

import (
	"context"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

// Token представляет Firebase ID Token
type Token struct {
	UID string
}

// FirebaseAuthClient интерфейс для Firebase Auth клиента
type FirebaseAuthClient interface {
	VerifyIDToken(ctx context.Context, idToken string) (*Token, error)
}

// AuthMiddlewareWithFirebase проверяет JWT и Firebase ID Token
type AuthMiddlewareWithFirebase struct {
	authService   *services.AuthService
	apiKeyService *services.APIKeyService
	firebaseAuth  FirebaseAuthClient
	logger        *zap.Logger
}

// NewAuthMiddlewareWithFirebase создаёт middleware с поддержкой Firebase
func NewAuthMiddlewareWithFirebase(authService *services.AuthService, apiKeyService *services.APIKeyService, firebaseAuth FirebaseAuthClient, logger ...*zap.Logger) *AuthMiddlewareWithFirebase {
	var log *zap.Logger
	if len(logger) > 0 && logger[0] != nil {
		log = logger[0]
	}
	return &AuthMiddlewareWithFirebase{
		authService:   authService,
		apiKeyService: apiKeyService,
		firebaseAuth:  firebaseAuth,
		logger:        log,
	}
}

// Handler проверяет токен и добавляет user_id в контекст
func (m *AuthMiddlewareWithFirebase) Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		startTime := time.Now()
		authHeader := r.Header.Get("Authorization")
		
		if m.logger != nil {
			m.logger.Debug("[AuthMiddlewareWithFirebase] Проверка авторизации",
				zap.String("path", r.URL.Path),
				zap.String("method", r.Method),
				zap.Bool("has_auth_header", authHeader != ""),
			)
		}

		if strings.HasPrefix(authHeader, "Bearer ") {
			tokenString := strings.TrimSpace(strings.TrimPrefix(authHeader, "Bearer "))
			if tokenString == "" {
				if m.logger != nil {
					m.logger.Debug("[AuthMiddlewareWithFirebase] Пустой Bearer токен",
						zap.String("path", r.URL.Path),
					)
				}
				resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
				return
			}

			if m.logger != nil {
				m.logger.Debug("[AuthMiddlewareWithFirebase] Обнаружен Bearer токен",
					zap.String("path", r.URL.Path),
					zap.Int("token_length", len(tokenString)),
				)
			}

			// Сначала пробуем Firebase ID Token
			if m.firebaseAuth != nil {
				if m.logger != nil {
					m.logger.Debug("[AuthMiddlewareWithFirebase] Верификация Firebase ID Token",
						zap.String("path", r.URL.Path),
						zap.Int("token_length", len(tokenString)),
					)
				}

				token, err := m.firebaseAuth.VerifyIDToken(r.Context(), tokenString)
				if err == nil {
					userID, err := uuid.Parse(token.UID)
					if err != nil {
						if m.logger != nil {
							m.logger.Error("[AuthMiddlewareWithFirebase] Ошибка парсинга Firebase UID",
								zap.String("path", r.URL.Path),
								zap.String("error", err.Error()),
							)
						}
						resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
						return
					}

					if m.logger != nil {
						m.logger.Debug("[AuthMiddlewareWithFirebase] Firebase токен валиден",
							zap.String("path", r.URL.Path),
							zap.String("user_id", userID.String()),
							zap.Duration("latency_ms", time.Since(startTime)),
						)
					}

					ctx := context.WithValue(r.Context(), ctxUserID, userID)
					next.ServeHTTP(w, r.WithContext(ctx))
					return
				}

				if m.logger != nil {
					m.logger.Debug("[AuthMiddlewareWithFirebase] Firebase токен не валиден, пробуем JWT",
						zap.String("path", r.URL.Path),
						zap.String("error", err.Error()),
					)
				}
			}

			// Пробуем JWT токен
			if m.authService != nil {
				if m.logger != nil {
					m.logger.Debug("[AuthMiddlewareWithFirebase] Верификация JWT токена",
						zap.String("path", r.URL.Path),
						zap.Int("token_length", len(tokenString)),
					)
				}

				userID, sessionID, err := m.authService.ValidateAccessToken(r.Context(), tokenString)
				if err == nil {
					if m.logger != nil {
						m.logger.Debug("[AuthMiddlewareWithFirebase] JWT токен валиден",
							zap.String("path", r.URL.Path),
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

				if m.logger != nil {
					m.logger.Error("[AuthMiddlewareWithFirebase] Ошибка валидации JWT токена",
						zap.String("path", r.URL.Path),
						zap.String("error", err.Error()),
						zap.Duration("latency_ms", time.Since(startTime)),
					)
				}
			}

			resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
			return
		}

		// Проверка API ключа
		apiKey := strings.TrimSpace(r.Header.Get("X-API-Key"))
		if apiKey != "" && m.apiKeyService != nil {
			if m.logger != nil {
				m.logger.Debug("[AuthMiddlewareWithFirebase] Обнаружен API ключ",
					zap.String("path", r.URL.Path),
					zap.Int("api_key_length", len(apiKey)),
				)
			}

			res, err := m.apiKeyService.Authenticate(r.Context(), apiKey)
			if err != nil {
				if m.logger != nil {
					m.logger.Error("[AuthMiddlewareWithFirebase] Ошибка аутентификации API ключа",
						zap.String("path", r.URL.Path),
						zap.String("error", err.Error()),
					)
				}
				resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
				return
			}

			if m.logger != nil {
				m.logger.Debug("[AuthMiddlewareWithFirebase] API ключ валиден",
					zap.String("path", r.URL.Path),
					zap.String("client_id", res.ClientID.String()),
				)
			}

			ctx := WithClientID(r.Context(), res.ClientID)
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

		if m.logger != nil {
			m.logger.Debug("[AuthMiddlewareWithFirebase] Токен не найден",
				zap.String("path", r.URL.Path),
				zap.String("method", r.Method),
				zap.Bool("has_auth_header", authHeader != ""),
				zap.Bool("has_api_key", apiKey != ""),
				zap.Duration("latency_ms", time.Since(startTime)),
			)
		}

		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
	})
}
