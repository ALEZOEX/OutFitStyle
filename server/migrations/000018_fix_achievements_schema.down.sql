-- 000018_fix_achievements_schema.down.sql
-- Откат миграции: удаление добавленных полей

DROP INDEX IF EXISTS idx_achievements_active;
DROP INDEX IF EXISTS idx_achievements_category;
DROP INDEX IF EXISTS idx_achievements_code;

ALTER TABLE achievements
DROP COLUMN IF EXISTS code,
DROP COLUMN IF EXISTS icon_emoji,
DROP COLUMN IF EXISTS points,
DROP COLUMN IF EXISTS is_active,
DROP COLUMN IF EXISTS condition_type,
DROP COLUMN IF EXISTS condition_value,
DROP COLUMN IF EXISTS condition_data,
DROP COLUMN IF EXISTS category,
DROP COLUMN IF EXISTS sort_order,
DROP COLUMN IF EXISTS is_secret;
