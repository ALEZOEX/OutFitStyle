-- Migration Down: Remove additional attributes for retrieval and ML service

-- Remove columns from clothing_items table
ALTER TABLE clothing_items
    DROP COLUMN IF EXISTS min_temp,
    DROP COLUMN IF EXISTS max_temp,
    DROP COLUMN IF EXISTS warmth_level,
    DROP COLUMN IF EXISTS formality_level;