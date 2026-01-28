-- Создание таблицы sessions
CREATE TABLE IF NOT EXISTS public.sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  refresh_token_hash text NOT NULL,
  device_info text,
  ip_address inet,
  user_agent text,
  is_active boolean NOT NULL DEFAULT true,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  last_used_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON public.sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_is_active ON public.sessions(is_active);