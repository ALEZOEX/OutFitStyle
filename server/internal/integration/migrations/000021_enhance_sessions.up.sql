-- Migration 000021: Enhance sessions table for session management
-- Adds device tracking columns and fingerprinting support

-- Add device_id column for unique device identification
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS device_id text;

-- Add device_name column for user-friendly device names
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS device_name text;

-- Add device_type column for device categorization (mobile, desktop, tablet, etc.)
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS device_type text;

-- Add device_fingerprint column for browser fingerprinting
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS device_fingerprint text;

-- Create index on device_fingerprint for faster lookups
CREATE INDEX IF NOT EXISTS idx_sessions_device_fingerprint ON public.sessions(device_fingerprint);

-- Create composite index for user_id and is_active for faster active session queries
CREATE INDEX IF NOT EXISTS idx_sessions_user_active ON public.sessions(user_id, is_active) WHERE is_active = true;

-- Create index on last_used_at for idle timeout checks
CREATE INDEX IF NOT EXISTS idx_sessions_last_used_at ON public.sessions(last_used_at);

-- Add comment to table
COMMENT ON TABLE public.sessions IS 'User sessions with device tracking and timeout management';
COMMENT ON COLUMN public.sessions.device_id IS 'Unique device identifier';
COMMENT ON COLUMN public.sessions.device_name IS 'User-friendly device name';
COMMENT ON COLUMN public.sessions.device_type IS 'Device type (mobile, desktop, tablet)';
COMMENT ON COLUMN public.sessions.device_fingerprint IS 'Browser fingerprint for device identification';
COMMENT ON COLUMN public.sessions.last_used_at IS 'Last activity timestamp for idle timeout';
COMMENT ON COLUMN public.sessions.expires_at IS 'Absolute expiration timestamp';
