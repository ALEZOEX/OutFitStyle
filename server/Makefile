#Makefile for OutfitStyle server

.PHONY: build run test clean docs

# Build the application
build:
	go build -o bin/server cmd/server/main.go

# Run the application
run:
	go run cmd/server/main.go

# Run tests
test:
	go test ./...

# Clean build artifacts
clean:
	rm -rf bin/

# Generate Swagger documentation
docs:
	swag init -g cmd/server/main.go -o internal/docs

# Install swag tool
install-swag:
	go install github.com/swaggo/swag/cmd/swag@latest

# Help.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build- Build the application"
	@echo "  make run          - Run the application"
	@echo "  make test- Run tests"
	@echo "  make clean- Clean build artifacts"
@echo "  make docs- Generate Swaggerdocumentation"
@echo "  make install-swag -Installswag tool"
@echo "  make help- Show this help message"
