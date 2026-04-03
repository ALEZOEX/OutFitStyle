ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS source TEXT;

ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS is_from_wardrobe BOOLEAN DEFAULT false;

ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS alternatives_json JSONB;
