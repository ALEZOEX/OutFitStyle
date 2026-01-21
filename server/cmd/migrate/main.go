package main

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
	"regexp"
	"strconv"

	"github.com/jackc/pgx/v5/pgxpool"
)

type mig struct {
	ID   string
	Seq  int
	Path string
	SQL  []byte
}

var reSeq = regexp.MustCompile(`^(\d+)`)

func main() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		fmt.Fprintln(os.Stderr, "DATABASE_URL is required")
		os.Exit(1)
	}

	migrationsDir := os.Getenv("MIGRATIONS_DIR")
	if migrationsDir == "" {
		migrationsDir = "./migrations"
	}

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		fmt.Fprintln(os.Stderr, "pg connect:", err)
		os.Exit(1)
	}
	defer pool.Close()

	if err := ensureSchemaMigrations(ctx, pool); err != nil {
		fmt.Fprintln(os.Stderr, "ensure schema_migrations:", err)
		os.Exit(1)
	}

	// advisory lock
	_, err = pool.Exec(ctx, `SELECT pg_advisory_lock(123456789)`)
	if err != nil {
		fmt.Fprintln(os.Stderr, "acquire advisory lock:", err)
		os.Exit(1)
	}
	defer func() {
		pool.Exec(context.Background(), `SELECT pg_advisory_unlock(123456789)`)
	}()

	migs, err := loadMigrations(migrationsDir)
	if err != nil {
		fmt.Fprintln(os.Stderr, "load migrations:", err)
		os.Exit(1)
	}

	applied, err := loadApplied(ctx, pool)
	if err != nil {
		fmt.Fprintln(os.Stderr, "load applied:", err)
		os.Exit(1)
	}

	for _, m := range migs {
		if applied[m.ID] {
			continue
		}
		if err := applyOne(ctx, pool, m); err != nil {
			fmt.Fprintln(os.Stderr, "apply migration", m.ID, ":", err)
			os.Exit(1)
		}
		fmt.Println("applied", m.ID)
	}

	fmt.Println("migrations ok")
}

func ensureSchemaMigrations(ctx context.Context, pool *pgxpool.Pool) error {
	_, err := pool.Exec(ctx, `
CREATE TABLE IF NOT EXISTS schema_migrations (
version VARCHAR(64) PRIMARY KEY,
applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
`)
	return err
}

func loadApplied(ctx context.Context, pool *pgxpool.Pool) (map[string]bool, error) {
	rows, err := pool.Query(ctx, `SELECT version FROM schema_migrations`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := map[string]bool{}
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		out[id] = true
	}
	return out, rows.Err()
}

func loadMigrations(dir string) ([]mig, error) {
	var files []mig

	err := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return err
		}
		name := d.Name()
		if !strings.HasSuffix(name, ".up.sql") {
			return nil
		}

		b, err := os.ReadFile(p)
		if err != nil {
			return err
		}

		base := strings.TrimSuffix(name, ".up.sql") // например "000001_init"
		seq := 0
		if m := reSeq.FindStringSubmatch(base); len(m) == 2 {
			seq, _ = strconv.Atoi(m[1])
		}

		files = append(files, mig{
			ID:   base,
			Seq:  seq,
			Path: p,
			SQL:  b,
		})
		return nil
	})
	if err != nil {
		return nil, err
	}

	// проверка на дубликаты ID (важно)
	seen := map[string]bool{}
	for _, m := range files {
		if seen[m.ID] {
			return nil, fmt.Errorf("duplicate migration id: %s", m.ID)
		}
		seen[m.ID] = true
	}

	sort.Slice(files, func(i, j int) bool {
		if files[i].Seq != files[j].Seq {
			return files[i].Seq < files[j].Seq
		}
		return files[i].ID < files[j].ID
	})
	return files, nil
}

func applyOne(ctx context.Context, pool *pgxpool.Pool, m mig) error {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	if _, err := tx.Exec(ctx, string(m.SQL)); err != nil {
		return fmt.Errorf("sql exec: %w", err)
	}

	if _, err := tx.Exec(ctx, `INSERT INTO schema_migrations(version) VALUES ($1)`, m.ID); err != nil {
		return fmt.Errorf("insert schema_migrations: %w", err)
	}

	return tx.Commit(ctx)
}