-- Добавляем недостающие столбцы в таблицу users
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS default_location TEXT,
ADD COLUMN IF NOT EXISTS default_latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS default_longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS timezone TEXT,
ADD COLUMN IF NOT EXISTS locale TEXT,
ADD COLUMN IF NOT EXISTS body_measurements JSONB,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS login_count INTEGER DEFAULT 0;

-- Копируем значения из date_of_birth в birth_date, если birth_date пустой
UPDATE public.users
SET birth_date = date_of_birth
WHERE birth_date IS NULL AND date_of_birth IS NOT NULL;