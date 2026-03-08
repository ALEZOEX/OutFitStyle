-- Rollback migration 000021: Remove session enhancements

-- Drop indexes
DROP INDEX IF EXISTS idx_sessions_device_fingerprint;
DROP INDEX IF EXISTS idx_sessions_user_active;
DROP INDEX IF EXISTS idx_sessions_last_used_at;

-- Remove columns
ALTER TABLE public.sessions DROP COLUMN IF EXISTS device_id;
ALTER TABLE public.sessions DROP COLUMN IF EXISTS device_name;
ALTER TABLE public.sessions DROP COLUMN IF EXISTS device_type;
ALTER TABLE public.sessions DROP COLUMN IF EXISTS device_fingerprint;
