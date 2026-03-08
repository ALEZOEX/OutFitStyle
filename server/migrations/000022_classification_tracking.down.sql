-- 000022_classification_tracking.down.sql
-- Removes classification tracking fields from clothing_items table

DROP INDEX IF EXISTS idx_clothing_items_classification_confidence;
DROP INDEX IF EXISTS idx_clothing_items_classification_source;

ALTER TABLE clothing_items
    DROP COLUMN IF EXISTS classification_source,
    DROP COLUMN IF EXISTS classification_confidence;
