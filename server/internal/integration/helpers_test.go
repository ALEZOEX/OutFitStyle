//go:build integration

package integration_test

import (
	"context"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

func mustDB(t *testing.T) *pgxpool.Pool {
	t.Helper()
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		t.Skip("DATABASE_URL is not set")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("pg connect: %v", err)
	}
	return pool
}

func applyMigrations(t *testing.T, pool *pgxpool.Pool) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	_, err := pool.Exec(ctx, `
CREATE TABLE IF NOT EXISTS schema_migrations (
version VARCHAR(64) PRIMARY KEY,
applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)`)
	if err != nil {
		t.Fatalf("ensure schema_migrations: %v", err)
	}

	applied := map[string]bool{}
	rows, err := pool.Query(ctx, `SELECT version FROM schema_migrations`)
	if err != nil {
		t.Fatalf("read schema_migrations: %v", err)
	}
	for rows.Next() {
		var v string
		_ = rows.Scan(&v)
		applied[v] = true
	}
	rows.Close()

	dir := filepath.Join(".", "migrations")
	entries, err := os.ReadDir(dir)
	if err != nil {
		t.Fatalf("readdir migrations: %v", err)
	}

	type mig struct {
		version string
		name    string
		sql     []byte
	}
	var migs []mig
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if !strings.HasSuffix(name, ".up.sql") {
			continue
		}
		b, err := os.ReadFile(filepath.Join(dir, name))
		if err != nil {
			t.Fatalf("read migration %s: %v", name, err)
		}
		v := strings.SplitN(name, "_", 2)[0]
		migs = append(migs, mig{version: v, name: name, sql: b})
	}

	sort.Slice(migs, func(i, j int) bool { return migs[i].name < migs[j].name })

	for _, m := range migs {
		if applied[m.version] {
			continue
		}
		tx, err := pool.Begin(ctx)
		if err != nil {
			t.Fatalf("begin: %v", err)
		}
		if _, err := tx.Exec(ctx, string(m.sql)); err != nil {
			_ = tx.Rollback(ctx)
			t.Fatalf("exec migration %s: %v", m.name, err)
		}
		if _, err := tx.Exec(ctx, `INSERT INTO schema_migrations(version) VALUES ($1)`, m.version); err != nil {
			_ = tx.Rollback(ctx)
			t.Fatalf("insert schema_migrations %s: %v", m.version, err)
		}
		if err := tx.Commit(ctx); err != nil {
			t.Fatalf("commit migration %s: %v", m.name, err)
		}
	}
}

func insertTestUser(t *testing.T, pool *pgxpool.Pool) uuid.UUID {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	id := uuid.New()
	email := "it_" + uuid.NewString() + "@example.com"

	_, err := pool.Exec(ctx, `
INSERT INTO users (id, email, password_hash, is_active, is_verified, timezone, locale)
VALUES ($1,$2,'x',TRUE,TRUE,'Europe/Moscow','ru')
`, id, email)
	if err != nil {
		t.Fatalf("insert user: %v", err)
	}
	return id
}
