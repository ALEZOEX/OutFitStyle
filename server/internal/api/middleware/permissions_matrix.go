package middleware

import (
	"net/http"
	"strings"

	"github.com/gorilla/mux"
)

// key = "METHOD {template}"
var permissionMatrix = map[string]string{
	// User
	"GET /api/v1/user/profile":                  "user:read",
	"PUT /api/v1/user/profile":                  "user:write",
	"POST /api/v1/user/avatar":                  "user:write",
	"GET /api/v1/user/export":                   "user:read",
	"GET /api/v1/user/sessions":                 "user:read",
	"DELETE /api/v1/user/sessions/{session_id}": "user:write",
	"DELETE /api/v1/user/account":               "user:write",

	// Wardrobe
	"GET /api/v1/wardrobe":                "wardrobe:read",
	"POST /api/v1/wardrobe":               "wardrobe:write",
	"GET /api/v1/wardrobe/{id}":           "wardrobe:read",
	"PUT /api/v1/wardrobe/{id}":           "wardrobe:write",
	"DELETE /api/v1/wardrobe/{id}":        "wardrobe:write",
	"POST /api/v1/wardrobe/{id}/favorite": "wardrobe:write",
	"POST /api/v1/wardrobe/{id}/archive":  "wardrobe:write",
	"POST /api/v1/wardrobe/{id}/worn":     "wardrobe:write",

	// Recommendations
	"POST /api/v1/recommendations":               "recommendations:write",
	"GET /api/v1/recommendations":                "recommendations:read",
	"GET /api/v1/recommendations/favorites":      "recommendations:read",
	"GET /api/v1/recommendations/{id}":           "recommendations:read",
	"POST /api/v1/recommendations/{id}/rate":     "recommendations:write",
	"POST /api/v1/recommendations/{id}/favorite": "recommendations:write",

	// Notifications
	"GET /api/v1/notifications":           "notifications:read",
	"PUT /api/v1/notifications/{id}/read": "notifications:write",
	"PUT /api/v1/notifications/read-all":  "notifications:write",
	"POST /api/v1/notifications/token":    "notifications:write",
	"DELETE /api/v1/notifications/token":  "notifications:write",

	// Catalog (public usually, but if protected)
	"POST /api/v1/catalog/items/{id}/click": "catalog:write",
}

func RequiredPermission(r *http.Request) string {
	tpl := ""
	if rt := mux.CurrentRoute(r); rt != nil {
		if p, err := rt.GetPathTemplate(); err == nil {
			tpl = p
		}
	}
	if tpl == "" {
		return "" // неизвестно → не требуем
	}
	k := r.Method + " " + tpl
	return permissionMatrix[k]
}

// Запрещённые зоны для API key (даже если permission совпадёт)
func APIKeyForbiddenPath(r *http.Request) bool {
	path := r.URL.Path

	if strings.HasPrefix(path, "/api/v1/auth") {
		return true
	}
	if strings.HasPrefix(path, "/api/v1/admin") {
		return true
	}
	// webhooks лучше не давать через api key
	if strings.Contains(path, "/webhook/") {
		return true
	}
	return false
}
