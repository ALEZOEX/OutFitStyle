package middleware

import (
	"net/http"
	"runtime/debug"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/observability"
)

func RecoveryMiddleware(logger *zap.Logger) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if v := recover(); v != nil {
					observability.CapturePanic(v)

					if logger != nil {
						logger.Error("panic recovered",
							zap.Any("panic", v),
							zap.ByteString("stack", debug.Stack()),
							zap.String("method", r.Method),
							zap.String("path", r.URL.Path),
							zap.String("remote_addr", r.RemoteAddr),
						)
					}

					// Return generic error message to client (no stack trace)
					w.Header().Set("Content-Type", "application/json")
					w.WriteHeader(http.StatusInternalServerError)
					w.Write([]byte(`{"error":"Internal server error"}`))
				}
			}()

			next.ServeHTTP(w, r)
		})
	}
}
