package middleware

import (
	"net/http"
	"strings"

	"github.com/gorilla/mux"

	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

func AuthMiddleware(authService *services.AuthService, apiKeyService *services.APIKeyService) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// 1) Bearer JWT
			h := r.Header.Get("Authorization")
			if strings.HasPrefix(h, "Bearer ") {
				token := strings.TrimSpace(strings.TrimPrefix(h, "Bearer "))
				userID, sessionID, err := authService.ValidateAccessToken(r.Context(), token)
				if err != nil {
					resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
					return
				}
				ctx := WithUserID(r.Context(), userID)
				ctx = WithSessionID(ctx, sessionID)
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			// 2) API key (Business): X-API-Key
			apiKey := strings.TrimSpace(r.Header.Get("X-API-Key"))
			if apiKey != "" && apiKeyService != nil {
				res, err := apiKeyService.Authenticate(r.Context(), apiKey)
				if err != nil {
					resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
					return
				}
				ctx := WithUserID(r.Context(), res.UserID)
				// session_id нет, но кладём api_key_id
				ctx = WithAPIKeyID(ctx, res.APIKeyID)

				ctx = WithAPIKeyMeta(ctx, APIKeyMeta{
					APIKeyID: res.APIKeyID,
					RateLimitPerMinute: res.RateLimitPerMinute,
					RateLimitPerDay:    res.RateLimitPerDay,
					Permissions:        res.Permissions,
					AllowedOrigins:     res.AllowedOrigins,
				})

				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			resp.Error(w, http.StatusUnauthorized, services.ErrUnauthorized)
		})
	}
}