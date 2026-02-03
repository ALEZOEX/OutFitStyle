//go:build integration

package integration_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

func TestLimits_FreeRecommendationsPerDay(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	uid := insertTestUser(t, pool)

	// DB wrapper used by repos
	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("new db wrapper: %v", err)
	}
	defer db.Close()

	subRepo := pg.NewSubscriptionRepository(db.Pool(), logger)
	subSvc := services.NewSubscriptionService(subRepo)
	limiter := middleware.NewSubscriptionLimiter(subSvc)

	// fake auth: inject user into context
	inject := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := middleware.WithUserID(r.Context(), uid)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}

	// handler inserts recommendation row
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
		defer cancel()

		_, err := db.Pool().Exec(ctx, `
INSERT INTO recommendations (user_id, weather_data, outfit_data)
VALUES ($1, '{}'::jsonb, '{}'::jsonb)
`, uid)
		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": true})
	})

	router := mux.NewRouter()
	api := router.PathPrefix("/api/v1").Subrouter()
	protected := api.NewRoute().Subrouter()
	protected.Use(inject)
	protected.Use(limiter.EnforceRecommendationsLimit())
	protected.Handle("/recommendations", handler).Methods(http.MethodPost)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// 3 ok, 4th -> 402
	for i := 1; i <= 4; i++ {
		res, err := http.Post(srv.URL+"/api/v1/recommendations", "application/json", bytes.NewReader([]byte(`{}`)))
		if err != nil {
			t.Fatalf("post %d: %v", i, err)
		}
		res.Body.Close()

		if i <= 3 && res.StatusCode != 200 {
			t.Fatalf("expected 200 on %d, got %d", i, res.StatusCode)
		}
		if i == 4 && res.StatusCode != 402 {
			t.Fatalf("expected 402 on 4th, got %d", res.StatusCode)
		}
	}
}

func TestLimits_FreeWardrobeLimit(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	uid := insertTestUser(t, pool)

	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("new db wrapper: %v", err)
	}
	defer db.Close()

	subRepo := pg.NewSubscriptionRepository(db.Pool(), logger)
	subSvc := services.NewSubscriptionService(subRepo)
	limiter := middleware.NewSubscriptionLimiter(subSvc)

	inject := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := middleware.WithUserID(r.Context(), uid)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}

	// handler adds wardrobe item: create clothing_items row then user_wardrobe row
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
		defer cancel()

		var itemID string
		err := db.Pool().QueryRow(ctx, `
INSERT INTO clothing_items (name, category, subcategory, style, source, is_owned, is_active)
VALUES ('X','upper','tshirt','casual','user',TRUE,TRUE)
RETURNING id::text
`).Scan(&itemID)
		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}

		_, err = db.Pool().Exec(ctx, `
INSERT INTO user_wardrobe (user_id, clothing_item_id)
VALUES ($1, $2)
`, uid, itemID)
		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}

		w.WriteHeader(200)
	})

	router := mux.NewRouter()
	api := router.PathPrefix("/api/v1").Subrouter()
	protected := api.NewRoute().Subrouter()
	protected.Use(inject)
	protected.Use(limiter.EnforceWardrobeLimit())
	protected.Handle("/wardrobe", handler).Methods(http.MethodPost)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// free limit 30: 30 ok, 31 -> 402
	for i := 1; i <= 31; i++ {
		res, err := http.Post(srv.URL+"/api/v1/wardrobe", "application/json", bytes.NewReader([]byte(`{}`)))
		if err != nil {
			t.Fatalf("post %d: %v", i, err)
		}
		res.Body.Close()

		if i <= 30 && res.StatusCode != 200 {
			t.Fatalf("expected 200 on %d, got %d", i, res.StatusCode)
		}
		if i == 31 && res.StatusCode != 402 {
			t.Fatalf("expected 402 on 31st, got %d", res.StatusCode)
		}
	}
}
