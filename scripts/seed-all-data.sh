#!/bin/bash
# Script to seed database with all test data

set -e  # Exit on any error

echo "Starting data seeding process..."

# Check if DATABASE_URL is set
if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL is required"
  exit 1
fi

echo "Applying seed migration 004 (subcategory_specs and synthetic catalog)..."
psql "$DATABASE_URL" -f server/migrations/004_seed_catalog.up.sql
echo "Migration 004 applied successfully."

echo "Seeding test data for user wardrobe and catalog items..."
psql "$DATABASE_URL" -f scripts/seed_test_data.sql
echo "Test data seeded successfully."

echo "Data seeding process completed!"