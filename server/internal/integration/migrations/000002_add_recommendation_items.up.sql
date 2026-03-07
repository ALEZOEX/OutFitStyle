-- 000002_sessions_and_translation.up.sql

CREATE TABLE IF NOT EXISTS recommendation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  context_hash TEXT,
  model_version TEXT,

  weather_data JSONB,
  user_preferences JSONB
);

CREATE INDEX IF NOT EXISTS idx_rec_sessions_user_created_at
  ON recommendation_sessions(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_rec_sessions_context_hash
  ON recommendation_sessions(context_hash);

-- расширяем recommendation_items: session_id + score + rank
ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS session_id UUID REFERENCES recommendation_sessions(id) ON DELETE CASCADE;

ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS score NUMERIC(6,4);

ALTER TABLE recommendation_items
  ADD COLUMN IF NOT EXISTS rank INT;

CREATE INDEX IF NOT EXISTS idx_rec_items_session_id ON recommendation_items(session_id);
CREATE INDEX IF NOT EXISTS idx_rec_items_score ON recommendation_items(score);
CREATE INDEX IF NOT EXISTS idx_rec_items_rank ON recommendation_items(rank);

-- Кэш переводов
CREATE TABLE IF NOT EXISTS translation_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  source_text TEXT NOT NULL,
  source_language TEXT NOT NULL DEFAULT 'en',
  target_language TEXT NOT NULL,
  translated_text TEXT NOT NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,

  UNIQUE(source_text, source_language, target_language)
);

CREATE INDEX IF NOT EXISTS idx_translation_cache_lookup
  ON translation_cache(source_text, source_language, target_language);

CREATE INDEX IF NOT EXISTS idx_translation_cache_expires
  ON translation_cache(expires_at);
