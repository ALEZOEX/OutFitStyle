ALTER TABLE recommendation_items
  DROP COLUMN IF EXISTS source;

ALTER TABLE recommendation_items
  DROP COLUMN IF EXISTS is_from_wardrobe;

ALTER TABLE recommendation_items
  DROP COLUMN IF EXISTS alternatives_json;
