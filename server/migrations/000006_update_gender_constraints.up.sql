-- 0006_update_gender_constraints.up.sql
-- Обновление CHECK ограничений для gender в clothing_items и users

-- Обновляем CHECK constraint для clothing_items.gender
ALTER TABLE clothing_items DROP CONSTRAINT IF EXISTS clothing_items_gender_check;
ALTER TABLE clothing_items ADD CONSTRAINT clothing_items_gender_check
  CHECK (gender IN ('men','women','unisex'));

-- Добавляем CHECK constraint для users.gender (идемпотентно)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'users_gender_check' AND conrelid = 'users'::regclass
  ) THEN
    ALTER TABLE users ADD CONSTRAINT users_gender_check
      CHECK (gender IS NULL OR gender IN ('men','women','unisex'));
  END IF;
END $$;