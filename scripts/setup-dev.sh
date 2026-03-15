#!/bin/bash
# Setup development environment
echo "Setting up development environment..."

if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go 1.25.0 first."
    exit 1
fi

# Check Go version
GO_VERSION=$(go version | cut -d ' ' -f 3 | cut -c 3-)
if [[ $(printf '%s\n' "1.25.0" "$GO_VERSION" | sort -V | head -n1) != "1.25.0" ]]; then
    echo "Go version $GO_VERSION is too old. Please upgrade to Go 1.25.0."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Install Go dependencies
echo "Installing Go dependencies..."
go mod tidy

# Install Flutter dependencies (if Flutter is available)
if command -v flutter &> /dev/null; then
    echo "Installing Flutter dependencies..."
    cd client
    flutter pub get
    cd ..
fi

# Create .env file from example if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from example..."
    cp .env.example .env
    echo "Please update the .env file with your configuration."
fi

# Create .env file for client if it doesn't exist
if [ ! -f client/.env ]; then
    echo "Creating client/.env file from example..."
    cp client/.env.example client/.env
fi

echo "Development environment setup complete!"
echo "To start the services, run: docker-compose up -d"
echo "To start the backend server, run: cd server && go run cmd/server/main.go"
