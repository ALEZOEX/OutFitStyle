package middleware

import (
	"net/http"
	"runtime/debug"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/observability"
	resp "outfitstyle/server/internal/pkg/http"
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
						)
					}

					resp.Error(w, http.StatusInternalServerError, http.ErrAbortHandler)
				}
			}()

			next.ServeHTTP(w, r)
		})
	}
}
