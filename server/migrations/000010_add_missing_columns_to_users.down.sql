-- Удаляем добавленные столбцы из таблицы users
ALTER TABLE public.users
DROP COLUMN IF EXISTS birth_date,
DROP COLUMN IF EXISTS default_location,
DROP COLUMN IF EXISTS default_latitude,
DROP COLUMN IF EXISTS default_longitude,
DROP COLUMN IF EXISTS timezone,
DROP COLUMN IF EXISTS locale,
DROP COLUMN IF EXISTS body_measurements,
DROP COLUMN IF EXISTS is_active,
DROP COLUMN IF EXISTS last_login_at,
DROP COLUMN IF EXISTS login_count;