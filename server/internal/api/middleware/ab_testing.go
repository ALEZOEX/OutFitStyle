package middleware

import (
	"net/http"

	"github.com/gorilla/mux"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
)

func ABTestingMiddleware(experiments *services.ExperimentService, experimentName string, enabled bool) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if !enabled || experiments == nil {
				next.ServeHTTP(w, r)
				return
			}
			userID, ok := domain.GetUserIDFromContext(r.Context())
			if !ok {
				next.ServeHTTP(w, r)
				return
			}
			variant, _, _ := experiments.Assign(r.Context(), experimentName, userID)
			if variant != "" {
				ctx := domain.WithABVariant(r.Context(), variant)
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
