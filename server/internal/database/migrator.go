package database

import (
	"fmt"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

type Migrator struct {
	m *migrate.Migrate
}

func NewMigrator(databaseURL string) (*Migrator, error) {
	driver, err := postgres.WithInstance(nil, &postgres.Config{})
	if err != nil {
		return nil, fmt.Errorf("failed to create postgres driver: %w", err)
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://migrations",
		"postgres", driver)
	if err != nil {
		return nil, fmt.Errorf("failed to create migrator: %w", err)
	}

	return &Migrator{m: m}, nil
}

func (m *Migrator) Up() error {
	if err := m.m.Up(); err != nil {
		if err == migrate.ErrNoChange {
			return nil
		}
		return fmt.Errorf("migration up failed: %w", err)
	}
	return nil
}

func (m *Migrator) Down() error {
	if err := m.m.Down(); err != nil {
		if err == migrate.ErrNoChange {
			return nil
		}
		return fmt.Errorf("migration down failed: %w", err)
	}
	return nil
}

func (m *Migrator) Drop() error {
	return m.m.Drop()
}

func (m *Migrator) Close() error {
	return m.m.Close()
}

func (m *Migrator) Version() (uint, bool, error) {
	return m.m.Version()
}