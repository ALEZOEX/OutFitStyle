-- 000020_fix_user_achievements.up.sql
-- Исправление структуры таблицы user_achievements для соответствия коду
-- Добавление поля status для отслеживания статуса достижения

-- Добавляем поле status
DO $$ BEGIN
  ALTER TABLE user_achievements ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'locked';
EXCEPTION
  WHEN duplicate_column THEN NULL;
END $$;

-- Добавляем поле code для денормализации (чтобы не делать JOIN с achievements)
DO $$ BEGIN
  ALTER TABLE user_achievements ADD COLUMN code VARCHAR(50);
EXCEPTION
  WHEN duplicate_column THEN NULL;
END $$;

-- Заполняем code из связанной таблицы achievements
UPDATE user_achievements ua
SET code = a.code
FROM achievements a
WHERE ua.achievement_id = a.id AND ua.code IS NULL;

-- Обновляем status для разблокированных достижений
UPDATE user_achievements
SET status = 'unlocked'
WHERE unlocked_at IS NOT NULL;

-- Обновляем status для достижений в процессе (если есть колонка progress)
-- UPDATE user_achievements
-- SET status = 'in_progress'
-- WHERE unlocked_at IS NULL AND progress > 0;

-- Индекс для статуса
CREATE INDEX IF NOT EXISTS idx_user_achievements_status ON user_achievements(status);

-- Индекс для пользователя и статуса
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_status ON user_achievements(user_id, status);

-- Комментарии
COMMENT ON COLUMN user_achievements.status IS 'Статус достижения: locked, in_progress, unlocked';
COMMENT ON COLUMN user_achievements.code IS 'Денормализованный код достижения для быстрого доступа';

-- Проверочный constraint
DO $$ BEGIN
  ALTER TABLE user_achievements ADD CONSTRAINT check_achievement_status
    CHECK (status IN ('locked', 'in_progress', 'unlocked'));
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
