//go:build integration

package integration_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/domain"
)

func TestAPIKeyPolicy_PermissionsOnly(t *testing.T) {
	router := mux.NewRouter()
	api := router.PathPrefix("/api/v1").Subrouter()

	protected := api.NewRoute().Subrouter()

	// inject API key meta into context
	protected.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := middleware.WithUserID(r.Context(), domain.NewID())
			ctx = middleware.WithAPIKeyID(ctx, domain.NewID())
			ctx = middleware.WithAPIKeyMeta(ctx, middleware.APIKeyMeta{
				APIKeyID:           domain.NewID(),
				RateLimitPerMinute: 60,
				RateLimitPerDay:    1000,
				Permissions:        []string{"wardrobe:read"}, // only read
			})
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	})

	protected.Use(middleware.APIKeyPolicyMiddleware())

	// route templates matter: permissions matrix uses templates
	protected.HandleFunc("/wardrobe", func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(204) }).Methods(http.MethodGet)
	protected.HandleFunc("/wardrobe", func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(204) }).Methods(http.MethodPost)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// GET with permission -> ok (origin check removed in server-to-server auth)
	req1, _ := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/wardrobe", nil)
	req1.Header.Set("Origin", "https://allowed.example")
	res1, _ := http.DefaultClient.Do(req1)
	res1.Body.Close()
	if res1.StatusCode != 204 {
		t.Fatalf("expected 204 for GET, got %d", res1.StatusCode)
	}

	// POST should be forbidden (needs wardrobe:write)
	req2, _ := http.NewRequest(http.MethodPost, srv.URL+"/api/v1/wardrobe", nil)
	req2.Header.Set("Origin", "https://allowed.example")
	res2, _ := http.DefaultClient.Do(req2)
	res2.Body.Close()
	if res2.StatusCode != 403 {
		t.Fatalf("expected 403 for POST, got %d", res2.StatusCode)
	}

	// GET with wrong origin should still be ok (origin check removed)
	req3, _ := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/wardrobe", nil)
	req3.Header.Set("Origin", "https://evil.example")
	res3, _ := http.DefaultClient.Do(req3)
	res3.Body.Close()
	if res3.StatusCode != 204 {
		t.Fatalf("expected 204 for wrong origin (origin check removed), got %d", res3.StatusCode)
	}
}
