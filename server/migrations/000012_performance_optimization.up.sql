-- 000012_performance_optimization.up.sql
-- Добавление индексов для оптимизации производительности

-- Индексы для clothing_items
CREATE INDEX IF NOT EXISTS idx_clothing_items_owner_active ON clothing_items(owner_id, is_active) WHERE owner_id IS NOT NULL AND is_active = true;
CREATE INDEX IF NOT EXISTS idx_clothing_items_source_active ON clothing_items(source, is_active);
CREATE INDEX IF NOT EXISTS idx_clothing_items_category_active ON clothing_items(category, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_clothing_items_warmth_temp ON clothing_items(warmth_level, min_temp, max_temp) WHERE is_active = true;

-- Индексы для wardrobe_items
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_user_active ON wardrobe_items(user_id, is_archived) WHERE is_archived = false;
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_clothing_user ON wardrobe_items(clothing_item_id, user_id);

-- Индексы для recommendations
CREATE INDEX IF NOT EXISTS idx_recommendations_ml_powered ON recommendations(ml_powered);
CREATE INDEX IF NOT EXISTS idx_recommendations_algorithm ON recommendations(algorithm_used);

-- Индексы для recommendation_items
CREATE INDEX IF NOT EXISTS idx_recommendation_items_rec_cloth ON recommendation_items(recommendation_id, clothing_item_id);
CREATE INDEX IF NOT EXISTS idx_recommendation_items_category ON recommendation_items(category);

-- Индексы для recommendation_sessions
CREATE INDEX IF NOT EXISTS idx_recommendation_sessions_user_model ON recommendation_sessions(user_id, model_version);

-- Индекс для ускорения поиска по массивам материалов в clothing_items
CREATE INDEX IF NOT EXISTS idx_clothing_items_materials_gin ON clothing_items USING gin(materials);

-- Индекс для ускорения поиска по тегам в wardrobe_items
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_tags_gin ON wardrobe_items USING gin(tags);