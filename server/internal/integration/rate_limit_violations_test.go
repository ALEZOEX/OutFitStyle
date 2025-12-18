//go:build integration

package integration_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/gorilla/mux"
	"github.com/redis/go-redis/v9"
	goerrors "errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/infrastructure/cache"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

func TestRateLimitViolations_Inserted(t *testing.T) {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		t.Skip("DATABASE_URL not set")
	}
	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		t.Skip("REDIS_URL not set")
	}

	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	logger := zap.NewNop()
	db, err := dbpg.NewDB(dsn, logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	// redis client
	var rdb *redis.Client
	rdb, err = cache.NewRedisClient(redisURL, "")
	if err != nil {
		t.Fatalf("redis: %v", err)
	}
	defer rdb.Close()

	violRepo := pg.NewRateLimitViolationRepository(db)
	limiter := middleware.NewRedisRateLimiter(rdb, violRepo)

	router := mux.NewRouter()
	router.Use(middleware.RateLimitMiddleware(limiter, 2, time.Minute))
	router.HandleFunc("/ping", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(204)
	}).Methods(http.MethodGet)

	srv := httptest.NewServer(router)
	defer srv.Close()

	// 1-2 ok, 3 -> 429
	for i := 1; i <= 3; i++ {
		res, err := http.Get(srv.URL + "/ping")
		if err != nil {
			t.Fatalf("get %d: %v", i, err)
		}
		res.Body.Close()

		if i <= 2 && res.StatusCode != 204 {
			t.Fatalf("expected 204 on %d got %d", i, res.StatusCode)
		}
		if i == 3 && res.StatusCode != 429 {
			t.Fatalf("expected 429 got %d", res.StatusCode)
		}
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var n int
	if err := db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM rate_limit_violations`).Scan(&n); err != nil {
		t.Fatalf("count violations: %v", err)
	}
	if n < 1 {
		t.Fatalf("expected violation row, got %d", n)
	}
}