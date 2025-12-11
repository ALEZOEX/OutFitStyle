-- Migration Down: Rollback changes from 002_expand_clothing_schema

-- Drop trigger and function for wardrobe_items
DROP TRIGGER IF EXISTS trg_wardrobe_items_updated_at ON wardrobe_items;
DROP FUNCTION IF EXISTS update_wardrobe_items_updated_at();

-- Drop indexes
DROP INDEX IF EXISTS idx_clothing_items_owner;
DROP INDEX IF EXISTS idx_wardrobe_items_user;
DROP INDEX IF EXISTS idx_clothing_items_source;
DROP INDEX IF EXISTS idx_clothing_items_season;
DROP INDEX IF EXISTS idx_clothing_items_gender;
DROP INDEX IF EXISTS idx_clothing_items_source_cat;
DROP INDEX IF EXISTS idx_clothing_items_cat_temp;

-- Drop wardrobe_items table
DROP TABLE IF EXISTS wardrobe_items;

-- Remove new columns from clothing_items (only if supported by your PostgreSQL version)
-- For older PostgreSQL versions, we'll keep the columns since removing them is complex
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS gender;
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS master_category;
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS season;
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS base_colour;
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS usage;
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS source;
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS is_owned;
-- ALTER TABLE clothing_items DROP COLUMN IF EXISTS owner_user_id;