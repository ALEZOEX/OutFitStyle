module outfitstyle/server

go 1.23.0

toolchain go1.24.6

require (
	// Utilities
	github.com/cenkalti/backoff/v4 v4.2.1

	// Security
	github.com/golang-jwt/jwt/v5 v5.0.0
	// Core web framework
	github.com/gorilla/mux v1.8.1

	// Database
	github.com/jackc/pgx/v5 v5.4.1

	// Configuration
	github.com/joho/godotenv v1.5.1
	github.com/pkg/errors v0.9.1
	github.com/sony/gobreaker v0.5.0


	// Logging and monitoring
	go.uber.org/zap v1.27.0
	golang.org/x/crypto v0.14.0
)

require golang.org/x/text v0.28.0 // indirect

require (
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/jackc/pgpassfile v1.0.0 // indirect
	github.com/jackc/pgservicefile v0.0.0-20221227161230-091c0ba34f0a // indirect
	github.com/jackc/puddle/v2 v2.2.0 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/prometheus/client_golang v1.23.2 
	github.com/prometheus/client_model v0.6.2 // indirect
	github.com/prometheus/common v0.66.1 // indirect
	github.com/prometheus/procfs v0.16.1 // indirect
	go.uber.org/multierr v1.10.0 // indirect
	go.yaml.in/yaml/v2 v2.4.2 // indirect
	golang.org/x/sync v0.16.0 // indirect
	golang.org/x/sys v0.35.0 // indirect
	google.golang.org/protobuf v1.36.8 // indirect
)
