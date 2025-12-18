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
	goerrors "errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

func TestAuditMiddleware_InsertsRow(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	uid := insertTestUser(t, pool)

	logger := zap.NewNop()
	db, err := dbpg.NewDB(os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	auditRepo := pg.NewAuditRepository(db)

	inject := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := middleware.WithUserID(r.Context(), uid)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}

	router := mux.NewRouter()
	router.Use(inject)
	router.Use(middleware.AuditMiddleware(auditRepo, logger))
	router.HandleFunc("/api/v1/wardrobe", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(204)
	}).Methods(http.MethodGet)

	srv := httptest.NewServer(router)
	defer srv.Close()

	res, err := http.Get(srv.URL + "/api/v1/wardrobe")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	res.Body.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var n int
	if err := db.Pool().QueryRow(ctx, `SELECT COUNT(*) FROM audit_logs WHERE user_id = $1`, uid).Scan(&n); err != nil {
		t.Fatalf("count audit: %v", err)
	}
	if n < 1 {
		t.Fatalf("expected audit row, got %d", n)
	}
}