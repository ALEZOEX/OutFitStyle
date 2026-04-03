ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS source TEXT;
