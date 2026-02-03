#!/bin/bash
# Database migration script
echo "Running database migrations..."

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "DATABASE_URL environment variable is not set."
    echo "Please set DATABASE_URL to your PostgreSQL connection string."
    exit 1
fi

# Navigate to server directory and run migrations
cd server && go run cmd/migrate/main.go up && cd ..

echo "Database migrations completed successfully!"