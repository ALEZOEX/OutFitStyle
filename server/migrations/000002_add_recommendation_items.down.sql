-- 000002_add_recommendation_items.down.sql
-- Удаление таблиц, добавленных в миграции 000002

-- Удаление таблицы recommendation_items
DROP TABLE IF EXISTS recommendation_items CASCADE;

-- Удаление таблицы recommendations
DROP TABLE IF EXISTS recommendations CASCADE;