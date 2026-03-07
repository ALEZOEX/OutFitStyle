-- 000001_init_schema.down.sql
-- Откат базовой схемы OutfitStyle

-- Удаление таблиц в обратном порядке (из-за внешних ключей)

-- Удаление таблиц, связанных с рекомендациями
DROP TABLE IF EXISTS recommendation_items CASCADE;
DROP TABLE IF EXISTS recommendations CASCADE;

-- Удаление таблиц, связанных с достижениями
DROP TABLE IF EXISTS user_achievements CASCADE;
DROP TABLE IF EXISTS achievements CASCADE;

-- Удаление таблиц, связанных с рейтингами
DROP TABLE IF EXISTS user_ratings CASCADE;

-- Удаление таблиц, связанных с избранным
DROP TABLE IF EXISTS user_favorites CASCADE;

-- Удаление таблиц, связанных с одеждой
DROP TABLE IF EXISTS wardrobe_items CASCADE;
DROP TABLE IF EXISTS clothing_items CASCADE;

-- Удаление таблиц, связанных с пользователями
DROP TABLE IF EXISTS users CASCADE;

-- Удаление таблиц, связанных с погодой
DROP TABLE IF EXISTS weather_data CASCADE;

-- Удаление справочной таблицы
DROP TABLE IF EXISTS subcategory_specs CASCADE;

-- Удаление триггеров
DROP FUNCTION IF EXISTS set_updated_at() CASCADE;

-- Удаление расширения (если не используется в других местах)
-- DROP EXTENSION IF EXISTS "pgcrypto";