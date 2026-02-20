# OutfitStyle Project Makefile
# Основные команды для разработки и тестирования

.PHONY: help test test-go test-flutter test-python lint lint-go lint-flutter lint-python coverage clean build

# Показ доступных команд
help:
	@echo "OutfitStyle - Available Commands:"
	@echo ""
	@echo "=== Testing ==="
	@echo "  make test              - Run all tests (Go + Flutter + Python)"
	@echo "  make test-go           - Run Go backend tests"
	@echo "  make test-flutter      - Run Flutter client tests"
	@echo "  make test-python       - Run Python ML service tests"
	@echo ""
	@echo "=== Linting ==="
	@echo "  make lint              - Run all linters"
	@echo "  make lint-go           - Run Go linter (golangci-lint)"
	@echo "  make lint-flutter      - Run Flutter analyzer"
	@echo "  make lint-python       - Run Python linters (ruff, mypy)"
	@echo ""
	@echo "=== Coverage ==="
	@echo "  make coverage          - Generate coverage reports for all"
	@echo "  make coverage-go       - Generate Go coverage report"
	@echo "  make coverage-flutter  - Generate Flutter coverage report"
	@echo "  make coverage-python   - Generate Python coverage report"
	@echo ""
	@echo "=== Build ==="
	@echo "  make build             - Build all services"
	@echo "  make build-go          - Build Go backend"
	@echo "  make build-flutter     - Build Flutter client (APK)"
	@echo "  make build-ml          - Build ML service Docker image"
	@echo ""
	@echo "=== Clean ==="
	@echo "  make clean             - Clean all build artifacts"
	@echo "  make clean-go          - Clean Go build cache"
	@echo "  make clean-flutter     - Clean Flutter build"
	@echo "  make clean-python      - Clean Python cache"
	@echo ""
	@echo "=== Docker ==="
	@echo "  make docker-up         - Start all services (docker-compose)"
	@echo "  make docker-down       - Stop all services"
	@echo "  make docker-logs       - Show logs"
	@echo ""
	@echo "=== Database ==="
	@echo "  make migrate-up        - Run database migrations"
	@echo "  make migrate-down      - Rollback migrations"
	@echo ""

# ============================================
# Testing
# ============================================

# Run all tests
test: test-go test-flutter test-python
	@echo "✅ All tests completed!"

# Go backend tests
test-go:
	@echo "🧪 Running Go tests..."
	cd server && go test -v -race -coverprofile=coverage.out -covermode=atomic ./internal/core/... ./internal/api/... ./internal/infrastructure/adapters/... ./internal/validation/... ./internal/integration/...
	@echo "📊 Go coverage report:"
	cd server && go tool cover -func=coverage.out | tail -1

# Flutter client tests
test-flutter:
	@echo "🧪 Running Flutter tests..."
	cd client && flutter test --coverage --test-randomize-ordering-seed=random
	@echo "✅ Flutter tests completed!"

# Python ML service tests
test-python:
	@echo "🧪 Running Python tests..."
	cd ml-service && python -m pytest -v tests/ --tb=short
	@echo "✅ Python tests completed!"

# ============================================
# Linting
# ============================================

# Run all linters
lint: lint-go lint-flutter lint-python
	@echo "✅ All linters completed!"

# Go linter
lint-go:
	@echo "🔍 Running Go linter..."
	cd server && golangci-lint run --timeout=5m

# Flutter analyzer
lint-flutter:
	@echo "🔍 Running Flutter analyzer..."
	cd client && flutter analyze --fatal-infos

# Python linters
lint-python:
	@echo "🔍 Running Python linters..."
	cd ml-service && ruff check . --output-format=github
	cd ml-service && mypy . --ignore-missing-imports --no-error-summary || true

# ============================================
# Coverage
# ============================================

# Generate all coverage reports
coverage: coverage-go coverage-flutter coverage-python
	@echo "✅ All coverage reports generated!"

# Go coverage
coverage-go:
	@echo "📊 Generating Go coverage report..."
	cd server && go test -coverprofile=coverage.out ./...
	cd server && go tool cover -html=coverage.out -o coverage.html
	cd server && go tool cover -func=coverage.out
	@echo "📄 Go coverage report: server/coverage.html"

# Flutter coverage
coverage-flutter:
	@echo "📊 Generating Flutter coverage report..."
	cd client && flutter test --coverage
	cd client && genhtml coverage/lcov.info -o coverage/html
	@echo "📄 Flutter coverage report: client/coverage/html/index.html"

# Python coverage
coverage-python:
	@echo "📊 Generating Python coverage report..."
	cd ml-service && pytest -v --cov=api --cov=model --cov=services --cov=contracts --cov-report=html --cov-report=xml tests/
	@echo "📄 Python coverage report: ml-service/htmlcov/index.html"

# ============================================
# Build
# ============================================

# Build all
build: build-go build-flutter
	@echo "✅ All builds completed!"

# Build Go backend
build-go:
	@echo "🔨 Building Go backend..."
	cd server && go build -o bin/server cmd/server/main.go
	@echo "📄 Binary: server/bin/server"

# Build Flutter APK
build-flutter:
	@echo "🔨 Building Flutter APK..."
	cd client && flutter build apk --release
	@echo "📄 APK: client/build/app/outputs/flutter-apk/app-release.apk"

# Build ML service Docker image
build-ml:
	@echo "🔨 Building ML service Docker image..."
	docker build -t outfitstyle/ml-service -f Dockerfile.ml-service .

# ============================================
# Clean
# ============================================

# Clean all
clean: clean-go clean-flutter clean-python
	@echo "✅ Clean completed!"

# Clean Go
clean-go:
	@echo "🧹 Cleaning Go build cache..."
	cd server && go clean -cache -testcache -modcache
	cd server && rm -rf bin/ coverage.out coverage.html

# Clean Flutter
clean-flutter:
	@echo "🧹 Cleaning Flutter build..."
	cd client && flutter clean
	cd client && rm -rf coverage/

# Clean Python
clean-python:
	@echo "🧹 Cleaning Python cache..."
	find ml-service -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find ml-service -type f -name "*.pyc" -delete 2>/dev/null || true
	find ml-service -type f -name "*.pyo" -delete 2>/dev/null || true
	find ml-service -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find ml-service -type d -name .coverage -exec rm -rf {} + 2>/dev/null || true
	find ml-service -type d -name htmlcov -exec rm -rf {} + 2>/dev/null || true
	rm -f ml-service/coverage.xml 2>/dev/null || true

# ============================================
# Docker
# ============================================

# Start all services
docker-up:
	@echo "🚀 Starting Docker services..."
	docker-compose -f docker-compose.dev.yml up -d

# Stop all services
docker-down:
	@echo "🛑 Stopping Docker services..."
	docker-compose -f docker-compose.dev.yml down

# Show logs
docker-logs:
	@echo "📋 Showing Docker logs..."
	docker-compose -f docker-compose.dev.yml logs -f

# ============================================
# Database Migrations
# ============================================

# Run migrations
migrate-up:
	@echo "📈 Running database migrations..."
	cd server && go run cmd/migrate/main.go up

# Rollback migrations
migrate-down:
	@echo "📉 Rolling back database migrations..."
	cd server && go run cmd/migrate/main.go down

# ============================================
# Import Catalog
# ============================================

# Импорт каталога из NDJSON файла
import-catalog:
	go run server/scripts/import_catalog/main.go -file $(FILE) -dsn $(DSN) -batch $(or $(BATCH),300)
