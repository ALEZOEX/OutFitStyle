-- 000015_outfit_ratings.down.sql
-- Откат миграции системы рейтинга рекомендаций

-- Удаляем представления
DROP VIEW IF EXISTS low_quality_items CASCADE;
DROP VIEW IF EXISTS user_rating_stats CASCADE;
DROP VIEW IF EXISTS recommendation_quality_stats CASCADE;

-- Удаляем триггер
DROP TRIGGER IF EXISTS trg_calculate_quality_score ON outfit_ratings;
DROP FUNCTION IF EXISTS calculate_quality_score() CASCADE;

-- Удаляем таблицу
DROP TABLE IF EXISTS outfit_ratings CASCADE;
