-- 000003_add_users_verification_field.down.sql
-- Удаление поля verified из таблицы users

-- Удаление столбца verified из таблицы users
ALTER TABLE users DROP COLUMN IF EXISTS verified;