ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS display_name text;

-- опционально: заполнить существующих пользователей
UPDATE public.users
SET display_name = NULLIF(TRIM(CONCAT_WS(' ', first_name, last_name)), '')
WHERE display_name IS NULL;

UPDATE public.users
SET display_name = username
WHERE (display_name IS NULL OR display_name = '') AND username IS NOT NULL;

UPDATE public.users
SET display_name = email
WHERE (display_name IS NULL OR display_name = '');