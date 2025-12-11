-- Migration: Add advanced attributes to clothing_items and create wardrobe_items table

-- Add new columns to clothing_items table
ALTER TABLE clothing_items
    ADD COLUMN IF NOT EXISTS gender           TEXT,
    ADD COLUMN IF NOT EXISTS master_category  TEXT,
    ADD COLUMN IF NOT EXISTS subcategory      TEXT,  -- We already have this column but will keep for completeness
    ADD COLUMN IF NOT EXISTS season           TEXT,
    ADD COLUMN IF NOT EXISTS base_colour      TEXT,  -- We already have color but this will be for standardized color
    ADD COLUMN IF NOT EXISTS usage            TEXT,
    ADD COLUMN IF NOT EXISTS source           TEXT DEFAULT 'catalog',  -- 'wardrobe', 'catalog', 'kaggle_seed', ...
    ADD COLUMN IF NOT EXISTS is_owned         BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS owner_user_id    BIGINT;

-- Create wardrobe_items table for personal wardrobe items
CREATE TABLE IF NOT EXISTS wardrobe_items (
    user_id          BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clothing_item_id BIGINT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, clothing_item_id)
);

-- Add indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_clothing_items_cat_temp
    ON clothing_items (category_id, COALESCE(gender, 'unknown'), COALESCE(season, 'all'));

CREATE INDEX IF NOT EXISTS idx_clothing_items_source_cat
    ON clothing_items (source, category_id);

CREATE INDEX IF NOT EXISTS idx_clothing_items_gender
    ON clothing_items (gender);

CREATE INDEX IF NOT EXISTS idx_clothing_items_season
    ON clothing_items (season);

CREATE INDEX IF NOT EXISTS idx_clothing_items_source
    ON clothing_items (source);

CREATE INDEX IF NOT EXISTS idx_wardrobe_items_user
    ON wardrobe_items (user_id);

CREATE INDEX IF NOT EXISTS idx_clothing_items_owner
    ON clothing_items (owner_user_id);

-- Update existing clothing_items to have 'wardrobe' source for user-owned items
UPDATE clothing_items 
SET source = 'wardrobe', 
    is_owned = TRUE, 
    owner_user_id = user_id 
WHERE user_id IS NOT NULL;

-- Add updated_at trigger for wardrobe_items table
CREATE OR REPLACE FUNCTION update_wardrobe_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trg_wardrobe_items_updated_at
    BEFORE UPDATE ON wardrobe_items
    FOR EACH ROW
    EXECUTE FUNCTION update_wardrobe_items_updated_at();