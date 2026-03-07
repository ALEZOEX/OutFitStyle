-- 000006_update_gender_constraints.up.sql
-- Обновление CHECK ограничений для gender в clothing_items и users

-- Обновляем CHECK constraint для clothing_items.gender
-- (значения для одежды: men, women, unisex)
ALTER TABLE clothing_items DROP CONSTRAINT IF EXISTS clothing_items_gender_check;
ALTER TABLE clothing_items ADD CONSTRAINT clothing_items_gender_check
  CHECK (gender IN ('men','women','unisex'));

-- Добавляем CHECK constraint для users.gender
-- (значения для пользователей: male, female, other, prefer_not_to_say)
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_gender_check;
ALTER TABLE users ADD CONSTRAINT users_gender_check
  CHECK (gender IS NULL OR gender IN ('male','female','other','prefer_not_to_say'));