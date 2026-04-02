package main

import (
	"database/sql"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

func main() {
	var (
		dir = flag.String("dir", "./migrations", "migrations directory")
		cmd = flag.String("cmd", "up", "up|down|goto|version|force")
		v   = flag.Int("v", -1, "version for goto/force")
	)
	flag.Parse()

	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("DATABASE_URL is required")
	}

	db, err := sql.Open("pgx", dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		log.Fatal(err)
	}

	m, err := migrate.NewWithDatabaseInstance("file://"+*dir, "postgres", driver)
	if err != nil {
		log.Fatal(err)
	}

	switch *cmd {
	case "up":
		err = m.Up()
	case "down":
		err = m.Down()
	case "goto":
		if *v < 0 {
			log.Fatal("use -v for goto")
		}
		err = m.Migrate(uint(*v))
	case "force":
		if *v < 0 {
			log.Fatal("use -v for force")
		}
		err = m.Force(*v)
	case "version":
		ver, dirty, e := m.Version()
		if e != nil && !errors.Is(e, migrate.ErrNilVersion) {
			log.Fatal(e)
		}
		fmt.Printf("version=%d dirty=%v\n", ver, dirty)
		return
	default:
		log.Fatalf("unknown cmd: %s", *cmd)
	}

	if err != nil && !errors.Is(err, migrate.ErrNoChange) {
		log.Fatal(err)
	}

	log.Println("migrations OK")
}
