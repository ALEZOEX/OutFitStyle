#!/bin/bash

# Database migration script for OutfitStyle server

set -e

echo "🚚 Running database migrations..."

# Check if migrate tool is installed
if ! command -v migrate &> /dev/null
then
    echo "❌ migrate tool is not installed."
    echo "Please install it from https://github.com/golang-migrate/migrate/tree/master/cmd/migrate"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Set default values if not in environment
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-password}
DB_NAME=${DB_NAME:-outfitstyle}

# Run migrations
echo "Running migrations on database: $DB_NAME"
migrate -path migrations -database "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose up

echo "✅ Database migrations completed!"