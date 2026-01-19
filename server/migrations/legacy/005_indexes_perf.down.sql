-- 005_indexes_perf.down.sql

DROP INDEX IF EXISTS idx_clothing_partner_price;
DROP INDEX IF EXISTS idx_clothing_catalog_filters;

DROP INDEX IF EXISTS idx_wardrobe_custom_name_trgm;
DROP INDEX IF EXISTS idx_clothing_subcategory_trgm;
DROP INDEX IF EXISTS idx_clothing_name_trgm;

DROP INDEX IF EXISTS idx_wardrobe_user_flags;
DROP INDEX IF EXISTS idx_wardrobe_user_updated_at;

DROP INDEX IF EXISTS idx_recs_user_rating;
DROP INDEX IF EXISTS idx_recs_user_occasion;
DROP INDEX IF EXISTS idx_recs_user_favorite;
DROP INDEX IF EXISTS idx_recs_user_created_at;