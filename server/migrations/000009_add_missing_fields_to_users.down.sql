ALTER TABLE public.users
  DROP COLUMN IF EXISTS display_name,
  DROP COLUMN IF EXISTS avatar_url,
  DROP COLUMN IF EXISTS oauth_provider,
  DROP COLUMN IF EXISTS oauth_id,
  DROP COLUMN IF EXISTS verified_at,
  DROP COLUMN IF EXISTS last_login_at,
  DROP COLUMN IF EXISTS login_count;

ALTER TABLE public.users
  DROP CONSTRAINT IF EXISTS users_gender_check;
