DROP INDEX IF EXISTS uniq_clothing_items_external_id;

ALTER TABLE clothing_items
  DROP COLUMN IF EXISTS external_id;