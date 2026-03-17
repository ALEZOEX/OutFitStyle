-- 000024_add_device_fields_to_sessions.down.sql
-- Удаляем поля устройства из таблицы sessions

DROP INDEX IF EXISTS idx_sessions_device_id;

ALTER TABLE sessions 
DROP COLUMN IF EXISTS device_id,
DROP COLUMN IF NOT EXISTS device_name,
DROP COLUMN IF NOT EXISTS device_type;
