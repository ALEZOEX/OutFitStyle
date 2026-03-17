-- 000024_add_device_fields_to_sessions.up.sql
-- Добавляем поля устройства в таблицу sessions

ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS device_id TEXT,
ADD COLUMN IF NOT EXISTS device_name TEXT,
ADD COLUMN IF NOT EXISTS device_type TEXT;

-- Индексы для поиска по device_id
CREATE INDEX IF NOT EXISTS idx_sessions_device_id ON sessions(device_id) WHERE is_active = true;
