#!/bin/bash

# Setup script for OutfitStyle server

set -e

echo "🚀 Setting up OutfitStyle server environment..."

# Check if Go is installed
if ! command -v go &> /dev/null
then
    echo "❌ Go is not installed. Please install Go 1.25.0 or higher."
    exit 1
fi

echo "✅ Go is installed"

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "⚠️ Docker is not installed. Some features may not work."
else
    echo "✅ Docker is installed"
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null
then
    echo "⚠️ docker-compose is not installed. Some features may not work."
else
    echo "✅ docker-compose is installed"
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from example..."
    cp .env.example .env
    echo "✅ .env file created. Please update it with your configuration."
else
    echo "✅ .env file already exists"
fi

# Install Go dependencies
echo "📦 Installing Go dependencies..."
go mod tidy
echo "✅ Go dependencies installed"

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p logs
mkdir -p tmp
echo "✅ Directories created"

echo "🎉 Setup complete!"
echo "Next steps:"
echo "1. Update the .env file with your configuration"
echo "2. Run 'make build' to build the server"
echo "3. Run 'make run' to start the server"
