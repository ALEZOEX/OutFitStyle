-- 0004_integration_clients_and_api_keys.up.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS integration_clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  -- Лимиты на уровне клиента
  rate_limit_per_minute INT NOT NULL DEFAULT 60,
  rate_limit_per_day INT NOT NULL DEFAULT 10000,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES integration_clients(id) ON DELETE CASCADE,

  key_prefix TEXT NOT NULL, -- уникальность теперь по client_id + key_prefix
  key_hash BYTEA NOT NULL, -- хэш секрета, НЕ токен

  name TEXT,
  description TEXT,

  permissions JSONB NOT NULL DEFAULT '[]'::jsonb,
  allowed_origins JSONB NOT NULL DEFAULT '[]'::jsonb,

  rate_limit_per_minute INT NOT NULL DEFAULT 60,
  rate_limit_per_day INT NOT NULL DEFAULT 10000,

  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(client_id, key_prefix) -- уникальность префикса внутри клиента
);

-- Индексы для эффективной работы
CREATE INDEX IF NOT EXISTS idx_api_keys_client_id ON api_keys(client_id);

-- Индекс для аутентификации (поиск по префиксу ключа)
CREATE INDEX IF NOT EXISTS idx_api_keys_prefix_active
  ON api_keys (key_prefix)
  WHERE is_active = true;

-- Индекс для проверки истечения срока действия
CREATE INDEX IF NOT EXISTS idx_api_keys_expires_at ON api_keys(expires_at);

-- Индекс для отслеживания последнего использования
CREATE INDEX IF NOT EXISTS idx_api_keys_last_used_at ON api_keys(last_used_at);