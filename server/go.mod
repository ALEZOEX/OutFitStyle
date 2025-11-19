module outfitstyle/server

go 1.22.0

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

	// Testing
	github.com/stretchr/testify v1.8.4 // indirect

	// Logging and monitoring
	go.uber.org/zap v1.27.0
	golang.org/x/crypto v0.14.0 // indirect
)

require golang.org/x/text v0.13.0 // indirect

require (
	github.com/jackc/pgpassfile v1.0.0 // indirect
	github.com/jackc/pgservicefile v0.0.0-20221227161230-091c0ba34f0a // indirect
	github.com/jackc/puddle/v2 v2.2.0 // indirect
	go.uber.org/multierr v1.10.0 // indirect
	golang.org/x/sync v0.3.0 // indirect
)
