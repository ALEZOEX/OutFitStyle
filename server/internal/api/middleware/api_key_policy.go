package middleware

import (
	"net/http"
	"strings"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	resp "outfitstyle/server/internal/pkg/http"
)

func APIKeyPolicyMiddleware() mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			meta, ok := GetAPIKeyMetaFromContext(r.Context())
			if !ok {
				// JWT auth → не применяем бизнес-политику
				next.ServeHTTP(w, r)
				return
			}

			// Проверяем запрещённые зоны для API ключей
			if APIKeyForbiddenPath(r) {
				resp.Error(w, http.StatusForbidden, errors.New("api key cannot be used for this endpoint"))
				return
			}

			// 1) Allowed origins (только если Origin присутствует и allowed_origins задан)
			if len(meta.AllowedOrigins) > 0 {
				origin := r.Header.Get("Origin")
				if origin != "" && !originAllowed(origin, meta.AllowedOrigins) {
					resp.Error(w, http.StatusForbidden, errors.New("origin is not allowed for this api key"))
					return
				}
			}

			// 2) Permissions (если список пуст — считаем "all allowed")
			if len(meta.Permissions) > 0 {
				required := RequiredPermission(r)
				if required == "" {
					// fallback к старой эвристике, если хочешь:
					// required = requiredPermission(r)
				}
				if required != "" && !hasPermission(meta.Permissions, required) {
					resp.Error(w, http.StatusForbidden, errors.New("api key does not have required permission: "+required))
					return
				}
			}

			next.ServeHTTP(w, r)
		})
	}
}

func originAllowed(origin string, allowed []string) bool {
	for _, a := range allowed {
		a = strings.TrimSpace(a)
		if a == "" {
			continue
		}
		if a == origin {
			return true
		}
	}
	return false
}

func hasPermission(perms []string, need string) bool {
	need = strings.TrimSpace(need)
	for _, p := range perms {
		if strings.TrimSpace(p) == need {
			return true
		}
	}
	return false
}

// минимальная матрица прав (можно расширять):
// recommendations:read|write, wardrobe:read|write, user:read|write, notifications:read|write, admin:* (не для api keys)
func requiredPermission(r *http.Request) string {
	method := r.Method

	// используем шаблон mux, чтобы не зависеть от uuid/id
	tpl := ""
	if rt := mux.CurrentRoute(r); rt != nil {
		if p, err := rt.GetPathTemplate(); err == nil {
			tpl = p
		}
	}
	path := tpl
	if path == "" {
		path = r.URL.Path
	}

	switch {
	// Recommendations
	case strings.HasPrefix(path, "/api/v1/recommendations"):
		if method == http.MethodGet {
			return "recommendations:read"
		}
		if method == http.MethodPost || method == http.MethodPut || method == http.MethodDelete {
			return "recommendations:write"
		}

	// Wardrobe
	case strings.HasPrefix(path, "/api/v1/wardrobe"):
		if method == http.MethodGet {
			return "wardrobe:read"
		}
		if method == http.MethodPost || method == http.MethodPut || method == http.MethodDelete {
			return "wardrobe:write"
		}

	// User endpoints
	case strings.HasPrefix(path, "/api/v1/user"):
		if method == http.MethodGet {
			return "user:read"
		}
		if method == http.MethodPost || method == http.MethodPut || method == http.MethodDelete {
			return "user:write"
		}

	// Notifications
	case strings.HasPrefix(path, "/api/v1/notifications"):
		if method == http.MethodGet {
			return "notifications:read"
		}
		if method == http.MethodPost || method == http.MethodPut || method == http.MethodDelete {
			return "notifications:write"
		}
	}

	// неизвестное — не требуем permission (чтобы не заблокировать новые ручки)
	return ""
}
