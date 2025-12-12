package main

import (
	"context"
	"database/sql"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"

	_ "github.com/lib/pq" // PostgreSQL driver
)

// Migration represents a single migration file
type Migration struct {
	Version    int
	FileName   string
	FilePath   string
	IsUp       bool // true for .up.sql, false for .down.sql
}

// MigrationRunner handles applying database migrations
type MigrationRunner struct {
	db     *sql.DB
	logger *log.Logger
}

// NewMigrationRunner creates a new migration runner
func NewMigrationRunner(db *sql.DB, logger *log.Logger) *MigrationRunner {
	return &MigrationRunner{
		db:     db,
		logger: logger,
	}
}

// LoadMigrations loads all migration files from the specified directory
func (mr *MigrationRunner) LoadMigrations(migrationsDir string) ([]Migration, error) {
	var migrations []Migration

	err := filepath.WalkDir(migrationsDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() {
			return nil
		}

		filename := d.Name()
		if strings.HasSuffix(filename, ".sql") {
			versionStr := getMigrationVersion(filename)
			if versionStr == "" {
				return nil // Skip non-migration files
			}

			version, err := strconv.Atoi(versionStr)
			if err != nil {
				mr.logger.Printf("Warning: invalid migration version in filename %s: %v", filename, err)
				return nil
			}

			isUp := strings.HasSuffix(filename, ".up.sql")
			if strings.HasSuffix(filename, ".down.sql") {
				isUp = false
			} else if !isUp {
				// If it's neither up nor down, treat as up by default
				isUp = true
			}

			migration := Migration{
				Version:  version,
				FileName: filename,
				FilePath: path,
				IsUp:     isUp,
			}

			migrations = append(migrations, migration)
		}

		return nil
	})

	if err != nil {
		return nil, fmt.Errorf("failed to walk migrations directory: %w", err)
	}

	// Sort migrations by version number
	sort.Slice(migrations, func(i, j int) bool {
		if migrations[i].Version == migrations[j].Version {
			// If same version, .up.sql should come after .down.sql
			if !migrations[i].IsUp && migrations[j].IsUp {
				return true
			}
			return false
		}
		return migrations[i].Version < migrations[j].Version
	})

	return migrations, nil
}

// getMigrationVersion extracts version number from migration filename
// e.g., "0001_init_schema.up.sql" -> "0001"
func getMigrationVersion(filename string) string {
	re := regexp.MustCompile(`^(\d+)_.*\.sql$`)
	matches := re.FindStringSubmatch(filename)
	if len(matches) >= 2 {
		return matches[1]
	}
	return ""
}

// EnsureSchemaMigrationsTable creates the schema_migrations table if it doesn't exist
func (mr *MigrationRunner) EnsureSchemaMigrationsTable() error {
	query := `
		CREATE TABLE IF NOT EXISTS schema_migrations (
			version VARCHAR(20) PRIMARY KEY,
			applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);
	`

	_, err := mr.db.Exec(query)
	if err != nil {
		return fmt.Errorf("failed to create schema_migrations table: %w", err)
	}

	return nil
}

// GetAppliedMigrations returns all previously applied migrations
func (mr *MigrationRunner) GetAppliedMigrations() ([]string, error) {
	rows, err := mr.db.Query("SELECT version FROM schema_migrations ORDER BY version")
	if err != nil {
		return nil, fmt.Errorf("failed to get applied migrations: %w", err)
	}
	defer rows.Close()

	var versions []string
	for rows.Next() {
		var version string
		if err := rows.Scan(&version); err != nil {
			return nil, fmt.Errorf("failed to scan migration version: %w", err)
		}
		versions = append(versions, version)
	}

	return versions, rows.Err()
}

// IsMigrationApplied checks if a migration version has already been applied
func (mr *MigrationRunner) IsMigrationApplied(version string) (bool, error) {
	var exists bool
	err := mr.db.QueryRow("SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE version = $1)", version).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("failed to check if migration is applied: %w", err)
	}
	return exists, nil
}

// ApplyMigration applies a single migration file
func (mr *MigrationRunner) ApplyMigration(migration Migration) error {
	sqlBytes, err := os.ReadFile(migration.FilePath)
	if err != nil {
		return fmt.Errorf("failed to read migration file %s: %w", migration.FileName, err)
	}

	sqlContent := string(sqlBytes)

	// Start transaction
	tx, err := mr.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback() // Will be ignored if tx.Commit() succeeds

	// Execute migration
	_, err = tx.Exec(sqlContent)
	if err != nil {
		return fmt.Errorf("failed to execute migration %s: %w", migration.FileName, err)
	}

	// Record migration in schema_migrations
	_, err = tx.Exec("INSERT INTO schema_migrations (version, applied_at) VALUES ($1, NOW())", fmt.Sprintf("%04d", migration.Version))
	if err != nil {
		return fmt.Errorf("failed to record migration in schema_migrations: %w", err)
	}

	// Commit transaction
	err = tx.Commit()
	if err != nil {
		return fmt.Errorf("failed to commit migration transaction: %w", err)
	}

	mr.logger.Printf("Applied migration: %s", migration.FileName)
	return nil
}

// RunMigrations applies all unapplied migrations
func (mr *MigrationRunner) RunMigrations(migrationsDir string) error {
	migrations, err := mr.LoadMigrations(migrationsDir)
	if err != nil {
		return fmt.Errorf("failed to load migrations: %w", err)
	}

	if len(migrations) == 0 {
		mr.logger.Println("No migration files found")
		return nil
	}

	err = mr.EnsureSchemaMigrationsTable()
	if err != nil {
		return fmt.Errorf("failed to ensure schema_migrations table: %w", err)
	}

	appliedVersions, err := mr.GetAppliedMigrations()
	if err != nil {
		return fmt.Errorf("failed to get applied migrations: %w", err)
	}

	// Convert applied versions to a map for quick lookup
	appliedMap := make(map[string]bool)
	for _, version := range appliedVersions {
		appliedMap[version] = true
	}

	// Apply unapplied migrations
	for _, migration := range migrations {
		if !migration.IsUp {
			continue // Only apply up migrations in normal mode
		}

		versionStr := fmt.Sprintf("%04d", migration.Version)
		if appliedMap[versionStr] {
			continue // Already applied
		}

		mr.logger.Printf("Applying migration: %s", migration.FileName)
		err := mr.ApplyMigration(migration)
		if err != nil {
			return fmt.Errorf("failed to apply migration %s: %w", migration.FileName, err)
		}
	}

	mr.logger.Println("All migrations applied successfully")
	return nil
}

func main() {
	// Get connection parameters from environment
	host := getEnv("DB_HOST", "localhost")
	port := getEnvAsInt("DB_PORT", 5432)
	user := getEnv("DB_USER", "Admin")
	password := getEnv("DB_PASSWORD", "password")
	dbname := getEnv("DB_NAME", "outfitstyle")
	sslmode := getEnv("DB_SSL_MODE", "disable")

	// Construct connection string
	connStr := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		host, port, user, password, dbname, sslmode)

	// Connect to database
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Set connection pool settings
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)

	// Test connection
	if err := db.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	logger := log.New(os.Stdout, "[MIGRATE] ", log.LstdFlags)

	// Create migration runner
	mr := NewMigrationRunner(db, logger)

	migrationsDir := getEnv("MIGRATIONS_DIR", "./migrations")
	logger.Printf("Starting migrations from directory: %s", migrationsDir)

	// Run migrations
	if err := mr.RunMigrations(migrationsDir); err != nil {
		log.Fatalf("Migration failed: %v", err)
	}
}

// Helper functions to get environment variables
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

func getEnvAsInt(key string, defaultValue int) int {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	intValue, err := strconv.Atoi(value)
	if err != nil {
		return defaultValue
	}
	return intValue
}