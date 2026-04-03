ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS source TEXT;

ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS is_from_wardrobe BOOLEAN DEFAULT false;

ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS alternatives_json JSONB;

CREATE TABLE IF NOT EXISTS user_stats (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  recommendations_generated INT DEFAULT 0,
  outfits_saved INT DEFAULT 0,
  total_recommendations INT DEFAULT 0,
  last_active TIMESTAMPTZ DEFAULT now()
);
