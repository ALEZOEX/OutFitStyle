-- 0004_integration_clients_and_api_keys.down.sql

-- Удаляем индексы
DROP INDEX IF EXISTS idx_api_keys_last_used_at;
DROP INDEX IF EXISTS idx_api_keys_expires_at;
DROP INDEX IF EXISTS idx_api_keys_prefix_active;
DROP INDEX IF EXISTS idx_api_keys_client_id;

-- Удаляем таблицы
DROP TABLE IF EXISTS api_keys;
DROP TABLE IF EXISTS integration_clients; 
