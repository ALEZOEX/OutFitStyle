-- Migration: Add is_verified field to users table for OAuth integration

-- Add the is_verified column to the users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;

-- Optionally, add an index for efficient queries on verification status
CREATE INDEX IF NOT EXISTS idx_users_verified ON users(is_verified);