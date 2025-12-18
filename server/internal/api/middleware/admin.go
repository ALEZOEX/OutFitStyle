package middleware

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/config"
	resp "outfitstyle/server/internal/pkg/http"
)

func AdminMiddleware(cfg *config.AppConfig) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if cfg.Admin.APIKey == "" {
				resp.Error(w, http.StatusForbidden, errors.New("admin api key is not configured"))
				return
			}
			key := r.Header.Get("X-Admin-Key")
			if key == "" || key != cfg.Admin.APIKey {
				resp.Error(w, http.StatusForbidden, errors.New("forbidden"))
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}