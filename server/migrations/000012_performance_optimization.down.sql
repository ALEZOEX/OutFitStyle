-- 000012_performance_optimization.down.sql
-- Удаление индексов для оптимизации производительности

-- Удаление индексов для clothing_items
DROP INDEX IF EXISTS idx_clothing_items_owner_active;
DROP INDEX IF EXISTS idx_clothing_items_source_active;
DROP INDEX IF EXISTS idx_clothing_items_category_active;
DROP INDEX IF EXISTS idx_clothing_items_warmth_temp;

-- Удаление индексов для wardrobe_items
DROP INDEX IF EXISTS idx_wardrobe_items_user_active;
DROP INDEX IF EXISTS idx_wardrobe_items_clothing_user;

-- Удаление индексов для recommendations
DROP INDEX IF EXISTS idx_recommendations_ml_powered;
DROP INDEX IF EXISTS idx_recommendations_algorithm;

-- Удаление индексов для recommendation_items
DROP INDEX IF EXISTS idx_recommendation_items_rec_cloth;
DROP INDEX IF EXISTS idx_recommendation_items_category;

-- Удаление индексов для recommendation_sessions
DROP INDEX IF EXISTS idx_recommendation_sessions_user_model;

-- Удаление индексов GIN
DROP INDEX IF EXISTS idx_clothing_items_materials_gin;
DROP INDEX IF EXISTS idx_wardrobe_items_tags_gin;