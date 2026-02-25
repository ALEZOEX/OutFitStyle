-- 000020_fix_user_achievements.down.sql
-- Откат: удаление добавленных полей

DROP INDEX IF EXISTS idx_user_achievements_user_status;
DROP INDEX IF EXISTS idx_user_achievements_status;

ALTER TABLE user_achievements
DROP CONSTRAINT IF EXISTS check_achievement_status;

ALTER TABLE user_achievements
DROP COLUMN IF EXISTS status,
DROP COLUMN IF EXISTS code;
