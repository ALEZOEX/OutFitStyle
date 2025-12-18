#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL is required"
  exit 1
fi

echo "Applying seed migration 004..."
psql "$DATABASE_URL" -f server/migrations/004_seed_catalog.up.sql
echo "Seed done."