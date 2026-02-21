-- 000006_update_gender_constraints.down.sql
-- Возврат к предыдущим CHECK ограничениям для gender в clothing_items и users

-- Восстанавливаем CHECK constraint для clothing_items.gender
ALTER TABLE clothing_items DROP CONSTRAINT IF EXISTS clothing_items_gender_check;
ALTER TABLE clothing_items ADD CONSTRAINT clothing_items_gender_check
  CHECK (gender IN ('unisex'));

-- Восстанавливаем CHECK constraint для users.gender (более строгий)
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_gender_check;
ALTER TABLE users ADD CONSTRAINT users_gender_check
  CHECK (gender IS NULL OR gender IN ('men','women','unisex'));