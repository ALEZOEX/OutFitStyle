-- FIX_DIRTY_000012.sql
-- Скрипт для исправления грязного состояния миграции 000012
-- Запускать ТОЛЬКО если есть ошибка "Dirty database version 12"

-- ============================================================================
-- ШАГ 1: Проверка текущего состояния
-- ============================================================================

-- Показать текущую версию и dirty статус
SELECT version, dirty FROM schema_migrations ORDER BY version DESC LIMIT 1;

-- ============================================================================
-- ШАГ 2: Исправление грязного состояния
-- ============================================================================

-- Если dirty = true для версии 12, нужно очистить флаг
-- golang-migrate устанавливает dirty=true перед выполнением UP и не успевает
-- поставить false если процесс прервался

-- Сбросить dirty флаг для версии 12
UPDATE schema_migrations SET dirty = false WHERE version = 12 AND dirty = true;

-- ============================================================================
-- ШАГ 3: Проверка дублирующихся индексов
-- ============================================================================

-- Проверить какие индексы из миграции 000012 уже существуют
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE indexname IN (
    'idx_clothing_items_owner_active',
    'idx_clothing_items_source_active', 
    'idx_clothing_items_category_active',
    'idx_clothing_items_warmth_temp',
    'idx_wardrobe_items_user_active',
    'idx_wardrobe_items_clothing_user',
    'idx_recommendations_ml_powered',
    'idx_recommendations_algorithm',
    'idx_recommendation_items_rec_cloth',
    'idx_recommendation_items_category',
    'idx_recommendation_sessions_user_model',
    'idx_clothing_items_materials_gin',
    'idx_wardrobe_items_tags_gin'
)
ORDER BY tablename, indexname;

-- ============================================================================
-- ШАГ 4: Удаление проблемных дублирующихся индексов
-- ============================================================================

-- Индексы которые дублируются в 000012 и 000014 (будут созданы в 000014):
-- - idx_recommendations_ml_powered (другое определение в 000014)
-- - idx_recommendations_algorithm (одинаковый в обеих)
-- - idx_wardrobe_items_tags_gin (одинаковый в обеих)

-- Если миграция 000012 частично применилась, удалим эти индексы
-- чтобы 000014 мог создать их корректно

-- Удалить дублирующиеся индексы рекомендаций (будут пересозданы в 000014)
DROP INDEX IF EXISTS idx_recommendations_ml_powered;
DROP INDEX IF EXISTS idx_recommendations_algorithm;

-- Удалить дублирующийся GIN индекс тегов (будет пересоздан в 000014)
DROP INDEX IF EXISTS idx_wardrobe_items_tags_gin;

-- ============================================================================
-- ШАГ 5: Создание отсутствующих индексов из миграции 000012
-- ============================================================================

-- Индексы для clothing_items (уникальные для 000012)
CREATE INDEX IF NOT EXISTS idx_clothing_items_owner_active 
    ON clothing_items(owner_id, is_active) 
    WHERE owner_id IS NOT NULL AND is_active = true;

CREATE INDEX IF NOT EXISTS idx_clothing_items_source_active 
    ON clothing_items(source, is_active);

CREATE INDEX IF NOT EXISTS idx_clothing_items_category_active 
    ON clothing_items(category, is_active) 
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_clothing_items_warmth_temp 
    ON clothing_items(warmth_level, min_temp, max_temp) 
    WHERE is_active = true;

-- Индексы для wardrobe_items (уникальные для 000012)
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_user_active 
    ON wardrobe_items(user_id, is_archived) 
    WHERE is_archived = false;

CREATE INDEX IF NOT EXISTS idx_wardrobe_items_clothing_user 
    ON wardrobe_items(clothing_item_id, user_id);

-- Индексы для recommendation_items (уникальные для 000012)
CREATE INDEX IF NOT EXISTS idx_recommendation_items_rec_cloth 
    ON recommendation_items(recommendation_id, clothing_item_id);

CREATE INDEX IF NOT EXISTS idx_recommendation_items_category 
    ON recommendation_items(category);

-- Индекс для recommendation_sessions (уникальный для 000012)
CREATE INDEX IF NOT EXISTS idx_recommendation_sessions_user_model 
    ON recommendation_sessions(user_id, model_version);

-- GIN индекс для материалов (уникальный для 000012)
CREATE INDEX IF NOT EXISTS idx_clothing_items_materials_gin 
    ON clothing_items USING gin(materials);

-- ============================================================================
-- ШАГ 6: Финальная проверка
-- ============================================================================

-- Убедиться что версия 12 отмечена как применённая
INSERT INTO schema_migrations (version, dirty) 
VALUES (12, false) 
ON CONFLICT (version) DO UPDATE SET dirty = false;

-- Показать итоговое состояние
SELECT version, dirty FROM schema_migrations ORDER BY version DESC LIMIT 5;

-- Показать все созданные индексы
SELECT 
    tablename,
    indexname
FROM pg_indexes 
WHERE indexname LIKE 'idx_%'
  AND tablename IN ('clothing_items', 'wardrobe_items', 'recommendations', 
                    'recommendation_items', 'recommendation_sessions')
ORDER BY tablename, indexname;
