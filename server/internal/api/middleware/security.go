package middleware

import (
	"net/http"

	"github.com/gorilla/mux"
)

// SecurityHeadersMiddleware добавляет заголовки безопасности
func SecurityHeadersMiddleware() mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Заголовки безопасности
			w.Header().Set("X-Content-Type-Options", "nosniff")
			w.Header().Set("X-Frame-Options", "DENY")
			w.Header().Set("X-XSS-Protection", "1; mode=block")
			w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
			w.Header().Set("Permissions-Policy", "geolocation=(), microphone=(), camera=()")
			w.Header().Set("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'none';")

			// Добавляем Vary заголовок для правильной работы кэширования
			w.Header().Add("Vary", "Origin")

			next.ServeHTTP(w, r)
		})
	}
}