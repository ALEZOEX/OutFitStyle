#!/bin/bash
# Seed database with test data
echo "Seeding database with test data..."

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "DATABASE_URL environment variable is not set."
    echo "Please set DATABASE_URL to your PostgreSQL connection string."
    exit 1
fi

# Run the migrate command to ensure tables exist
echo "Ensuring database schema is up to date..."
cd server && go run cmd/migrate/main.go up && cd ..

# Import basic catalog data
if [ -f "basic_catalog.ndjson" ]; then
    echo "Importing basic catalog data..."
    cd server && go run cmd/import_catalog/main.go ../basic_catalog.ndjson && cd ..
else
    echo "basic_catalog.ndjson file not found, skipping catalog import."
fi

# Seed with basic user data if needed
echo "Database seeding complete!"