# OutfitStyle Server Makefile

# Variables
BINARY=server
MAIN_FILE=cmd/server/main.go

# Default target
.PHONY: all
all: build

# Build the application
.PHONY: build
build:
	@echo "Building server..."
	go build -o ${BINARY} ${MAIN_FILE}

# Run the application
.PHONY: run
run:
	@echo "Running server..."
	go run ${MAIN_FILE}

# Install dependencies
.PHONY: deps
deps:
	@echo "Installing dependencies..."
	go mod tidy

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	go test -v ./...

# Run tests with coverage
.PHONY: test-cover
test-cover:
	@echo "Running tests with coverage..."
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Clean build files
.PHONY: clean
clean:
	@echo "Cleaning..."
	rm -f ${BINARY}

# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Vet code
.PHONY: vet
vet:
	@echo "Vetting code..."
	go vet ./...

# Lint code
.PHONY: lint
lint:
	@echo "Linting code..."
	golangci-lint run

# Generate documentation
.PHONY: docs
docs:
	@echo "Generating documentation..."
	swag init -g ${MAIN_FILE} -o internal/api/docs

# Docker build
.PHONY: docker-build
docker-build:
	@echo "Building Docker image..."
	docker build -t outfitstyle-server -f deployments/docker/Dockerfile .

# Docker run
.PHONY: docker-run
docker-run:
	@echo "Running Docker container..."
	docker run -p 8080:8080 outfitstyle-server

# Database migration up
.PHONY: migrate-up
migrate-up:
	@echo "Running database migrations..."
	migrate -path migrations -database "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose up

# Database migration down
.PHONY: migrate-down
migrate-down:
	@echo "Rolling back database migrations..."
	migrate -path migrations -database "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose down

# Database migration create
.PHONY: migrate-create
migrate-create:
	@echo "Creating new migration..."
	migrate create -ext sql -dir migrations -seq ${name}

# Help
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make              - Build the application (default)"
	@echo "  make build        - Build the application"
	@echo "  make run          - Run the application"
	@echo "  make deps         - Install dependencies"
	@echo "  make test         - Run tests"
	@echo "  make test-cover   - Run tests with coverage"
	@echo "  make clean        - Clean build files"
	@echo "  make fmt          - Format code"
	@echo "  make vet          - Vet code"
	@echo "  make lint         - Lint code"
	@echo "  make docs         - Generate documentation"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-run   - Run Docker container"
	@echo "  make migrate-up   - Run database migrations"
	@echo "  make migrate-down - Rollback database migrations"
	@echo "  make migrate-create name=migration_name - Create new migration"
	@echo "  make help         - Show this help message"