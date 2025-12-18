-- 005_indexes_perf.up.sql
-- Performance indexes for wardrobe/recommendations/catalog search

-- Recommendations filtering
CREATE INDEX IF NOT EXISTS idx_recs_user_created_at
  ON recommendations(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_recs_user_favorite
  ON recommendations(user_id, is_favorite, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_recs_user_occasion
  ON recommendations(user_id, occasion);

CREATE INDEX IF NOT EXISTS idx_recs_user_rating
  ON recommendations(user_id, user_rating);

-- Wardrobe filtering
CREATE INDEX IF NOT EXISTS idx_wardrobe_user_updated_at
  ON user_wardrobe(user_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_wardrobe_user_flags
  ON user_wardrobe(user_id, is_favorite, is_archived);

-- Trigram search (needs pg_trgm extension; already in 001)
CREATE INDEX IF NOT EXISTS idx_clothing_name_trgm
  ON clothing_items USING gin (name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_clothing_subcategory_trgm
  ON clothing_items USING gin (subcategory gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_wardrobe_custom_name_trgm
  ON user_wardrobe USING gin (custom_name gin_trgm_ops);

-- Catalog filters
CREATE INDEX IF NOT EXISTS idx_clothing_catalog_filters
  ON clothing_items (category, style, base_colour);

CREATE INDEX IF NOT EXISTS idx_clothing_partner_price
  ON clothing_items (partner_id, partner_price)
  WHERE partner_id IS NOT NULL;