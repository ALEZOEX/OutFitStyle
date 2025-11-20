package middleware

import (
	"context"
	"net/http"
	"strings"

	"outfitstyle/server/internal/api"
	"outfitstyle/server/internal/core/application/services"
)

// AuthMiddleware creates a middleware that validates JWT tokens
func AuthMiddleware(authService *services.AuthService) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				api.JSONError(w, http.StatusUnauthorized, "Authorization header required")
				return
			}

			if !strings.HasPrefix(authHeader, "Bearer ") {
				api.JSONError(w, http.StatusUnauthorized, "Invalid authorization header format")
				return
			}

			token := authHeader[7:] // Remove "Bearer " prefix

			user, err := authService.ValidateToken(token)
			if err != nil {
				api.JSONError(w, http.StatusUnauthorized, "Invalid or expired token")
				return
			}

			// Add user to request context
			ctx := context.WithValue(r.Context(), "user", user)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
