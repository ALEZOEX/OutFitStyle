# Makefile for OutfitStyle project

.PHONY: help build run stop logs test clean

help:
	@echo "OutfitStyle Project Commands:"
	@echo "  build    - Build all services"
	@echo "  run      - Run all services"
	@echo "  stop     - Stop all services"
	@echo "  logs     - View service logs"
	@echo "  test     - Run tests"
	@echo "  clean    - Clean build artifacts"

build:
	@echo "Building all services..."
	cd infrastructure/docker-compose && docker-compose build

run:
	@echo "Starting all services..."
	cd infrastructure/docker-compose && docker-compose up -d

stop:
	@echo "Stopping all services..."
	cd infrastructure/docker-compose && docker-compose down

logs:
	@echo "Viewing service logs..."
	cd infrastructure/docker-compose && docker-compose logs -f

test:
	@echo "Running tests..."
	cd server/api && go test -v ./...
	cd server/ml-service && python -m pytest tests/
	cd server/marketplace-service && python -m pytest tests/

clean:
	@echo "Cleaning build artifacts..."
	cd server/api && rm -f server
	cd infrastructure/docker-compose && docker-compose down -v