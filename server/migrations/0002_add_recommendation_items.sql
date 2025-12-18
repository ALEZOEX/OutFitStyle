-- Migration: Add recommendation_sessions and translation_cache tables, and update recommendation_items table for storing ranked recommendations with context and scores

-- Create recommendation_sessions table for tracking recommendation contexts
CREATE TABLE recommendation_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    context_hash VARCHAR(64),              -- Hash of the recommendation context for deduplication
    model_version VARCHAR(50),             -- Version of the model that generated this recommendation
    weather_data JSONB,                    -- Weather information at recommendation time
    user_preferences JSONB                 -- User preferences at recommendation time
);

-- Update existing recommendation_items table to support sessions instead of direct recommendations

-- Create indexes (important for analytics/training queries)
CREATE INDEX IF NOT EXISTS idx_recommendation_sessions_user_id_created_at ON recommendation_sessions(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_recommendation_sessions_created_at ON recommendation_sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_recommendation_sessions_context_hash ON recommendation_sessions(context_hash);

-- Add columns if they don't exist
ALTER TABLE recommendation_items ADD COLUMN IF NOT EXISTS session_id INTEGER REFERENCES recommendation_sessions(id) ON DELETE CASCADE;
ALTER TABLE recommendation_items ADD COLUMN IF NOT EXISTS score DECIMAL(5, 4); -- ML score for this item in this recommendation
ALTER TABLE recommendation_items ADD COLUMN IF NOT EXISTS rank INTEGER; -- Position in the recommendation (1 = highest ranked)

-- Update the session_id for existing records based on recommendation_id
-- (Only run update if session_id is NULL to avoid conflicts)
UPDATE recommendation_items SET session_id = recommendation_id WHERE session_id IS NULL;

-- Update score based on ml_score if score is NULL
UPDATE recommendation_items SET score = ml_score WHERE score IS NULL;

-- Update rank based on position if rank is NULL
UPDATE recommendation_items SET rank = position WHERE rank IS NULL;

-- Make session_id not null after updating
ALTER TABLE recommendation_items ALTER COLUMN session_id DROP NOT NULL; -- temporarily allow NULL
ALTER TABLE recommendation_items ALTER COLUMN session_id SET NOT NULL; -- then enforce NOT NULL

-- Remove the old recommendation_id column and its foreign key constraint after populating session_id
ALTER TABLE recommendation_items DROP CONSTRAINT IF EXISTS recommendation_items_recommendation_id_fkey;
ALTER TABLE recommendation_items DROP COLUMN IF EXISTS recommendation_id;

-- Rename columns to match new schema
ALTER TABLE recommendation_items RENAME COLUMN clothing_item_id TO item_id;

-- Add unique constraints
ALTER TABLE recommendation_items ADD CONSTRAINT recommendation_items_session_item_key UNIQUE(session_id, item_id);
ALTER TABLE recommendation_items ADD CONSTRAINT recommendation_items_session_rank_key UNIQUE(session_id, rank);

-- Create indexes for the new columns
CREATE INDEX IF NOT EXISTS idx_recommendation_items_session_id ON recommendation_items(session_id);
CREATE INDEX IF NOT EXISTS idx_recommendation_items_item_id ON recommendation_items(item_id);      -- For looking up item usage
CREATE INDEX IF NOT EXISTS idx_recommendation_items_score ON recommendation_items(score);
CREATE INDEX IF NOT EXISTS idx_recommendation_items_rank ON recommendation_items(rank);

-- Create translation cache table for caching translations
CREATE TABLE translation_cache (
    id SERIAL PRIMARY KEY,
    source_text TEXT NOT NULL,
    source_language VARCHAR(10) NOT NULL DEFAULT 'en',
    target_language VARCHAR(10) NOT NULL,
    translated_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    UNIQUE(source_text, source_language, target_language)
);

-- Create indexes for efficient translation cache lookups
CREATE INDEX IF NOT EXISTS idx_translation_cache_lookup ON translation_cache(source_text, source_language, target_language);
CREATE INDEX IF NOT EXISTS idx_translation_cache_expires ON translation_cache(expires_at);