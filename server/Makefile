# Makefile for OutfitStyle Server

.PHONY: build run test clean docs lint coverage help test-unit test-integration

# Build the application
build:
	go build -o bin/server cmd/server/main.go

# Run the application
run:
	go run cmd/server/main.go

# Run all tests
test:
	go test -v -race ./...

# Run unit tests only (no database required)
test-unit:
	go test -v -race \
		./internal/core/... \
		./internal/api/... \
		./internal/infrastructure/adapters/... \
		./internal/infrastructure/external/... \
		./internal/validation/...

# Run integration tests (requires database)
test-integration:
	go test -v -race -tags=integration ./tests/integration/...

# Run tests with coverage
coverage:
	go test -v -race -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html
	go tool cover -func=coverage.out
	@echo "Coverage report generated: coverage.html"

# Run linter
lint:
	golangci-lint run --timeout=5m

# Clean build artifacts
clean:
	rm -rf bin/
	rm -f coverage.out coverage.html

# Generate Swagger documentation
docs:
	swag init -g cmd/server/main.go -o internal/docs

# Install swag tool
install-swag:
	go install github.com/swaggo/swag/cmd/swag@latest

# Install golangci-lint
install-lint:
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Install all dev dependencies
install-dev: install-swag install-lint
	@echo "✅ Dev dependencies installed"

# Show help
help:
	@echo "OutfitStyle Server - Available Commands:"
	@echo ""
	@echo "  make build            - Build the application"
	@echo "  make run              - Run the application"
	@echo "  make test             - Run all tests"
	@echo "  make test-unit        - Run unit tests only"
	@echo "  make test-integration - Run integration tests"
	@echo "  make coverage         - Run tests with coverage report"
	@echo "  make lint             - Run linter"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make docs             - Generate Swagger documentation"
	@echo "  make install-swag     - Install swag tool"
	@echo "  make install-lint     - Install golangci-lint"
	@echo "  make install-dev      - Install all dev dependencies"
	@echo "  make help             - Show this help message"
