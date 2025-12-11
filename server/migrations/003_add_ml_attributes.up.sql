-- Migration: Add additional attributes for retrieval and ML service

-- Add new columns to clothing_items table for ML and retrieval
ALTER TABLE clothing_items
    ADD COLUMN IF NOT EXISTS min_temp           DECIMAL(4, 2),
    ADD COLUMN IF NOT EXISTS max_temp           DECIMAL(4, 2),
    ADD COLUMN IF NOT EXISTS warmth_level       INTEGER,
    ADD COLUMN IF NOT EXISTS formality_level    INTEGER;

-- Update category column to use the new category mapping (from our Python script)
-- Note: We'll need to update existing data to use the new category system
-- For now, we'll keep the old category column and add a new one or update in place
-- In the Python script, we'll map to the appropriate categories

-- Update any existing items to have a 'catalog' source if not already set
UPDATE clothing_items
SET source = 'catalog'
WHERE source IS NULL OR source = '';

-- The Python import script will handle setting 'kaggle_seed' source for imported items