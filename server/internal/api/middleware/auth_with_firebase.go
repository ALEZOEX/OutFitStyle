package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/google/uuid"

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
}

// NewAuthMiddlewareWithFirebase создаёт middleware с поддержкой Firebase
func NewAuthMiddlewareWithFirebase(authService *services.AuthService, apiKeyService *services.APIKeyService, firebaseAuth FirebaseAuthClient) *AuthMiddlewareWithFirebase {
	return &AuthMiddlewareWithFirebase{
		authService:   authService,
		apiKeyService: apiKeyService,
		firebaseAuth:  firebaseAuth,
	}
}

// Handler проверяет токен и добавляет user_id в контекст
func (m *AuthMiddlewareWithFirebase) Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if strings.HasPrefix(authHeader, "Bearer ") {
			tokenString := strings.TrimSpace(strings.TrimPrefix(authHeader, "Bearer "))
			if tokenString == "" {
				resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
				return
			}

			if m.firebaseAuth != nil {
				token, err := m.firebaseAuth.VerifyIDToken(r.Context(), tokenString)
				if err == nil {
					userID, err := uuid.Parse(token.UID)
					if err != nil {
						resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
						return
					}
					ctx := context.WithValue(r.Context(), ctxUserID, userID)
					next.ServeHTTP(w, r.WithContext(ctx))
					return
				}
			}

			if m.authService != nil {
				userID, sessionID, err := m.authService.ValidateAccessToken(r.Context(), tokenString)
				if err == nil {
					ctx := WithUserID(r.Context(), userID)
					ctx = WithSessionID(ctx, sessionID)
					next.ServeHTTP(w, r.WithContext(ctx))
					return
				}
			}

			resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
			return
		}

		apiKey := strings.TrimSpace(r.Header.Get("X-API-Key"))
		if apiKey != "" && m.apiKeyService != nil {
			res, err := m.apiKeyService.Authenticate(r.Context(), apiKey)
			if err != nil {
				resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
				return
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

		resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
	})
}
