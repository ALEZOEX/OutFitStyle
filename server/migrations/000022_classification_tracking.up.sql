-- 000022_classification_tracking.up.sql
-- Adds classification tracking fields to clothing_items table

ALTER TABLE clothing_items
    ADD COLUMN classification_confidence NUMERIC(4,3),
    ADD COLUMN classification_source TEXT DEFAULT 'mapping'
        CHECK (classification_source IN ('mapping', 'ml_auto', 'ml_flagged', 'manual'));

-- Create index for filtering by classification source
CREATE INDEX idx_clothing_items_classification_source ON clothing_items(classification_source);

-- Create index for filtering by confidence score
CREATE INDEX idx_clothing_items_classification_confidence ON clothing_items(classification_confidence)
    WHERE classification_confidence IS NOT NULL;
