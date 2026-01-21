ALTER TABLE clothing_items
  ADD COLUMN IF NOT EXISTS external_id BIGINT;

CREATE UNIQUE INDEX IF NOT EXISTS uniq_clothing_items_external_id
  ON clothing_items(external_id)
  WHERE external_id IS NOT NULL;