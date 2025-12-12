-- Migration: Add recommendation_sessions and recommendation_items tables for storing ranked recommendations with context and scores

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

-- Create recommendation_items table
CREATE TABLE recommendation_items (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES recommendation_sessions(id) ON DELETE CASCADE,
    item_id BIGINT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    score DECIMAL(5, 4),                   -- ML score for this item in this recommendation
    rank INTEGER,                          -- Position in the recommendation (1 = highest ranked)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(session_id, item_id),           -- Ensure each item appears only once per session
    UNIQUE(session_id, rank)               -- Ensure unique ranks within a session
);

-- Create indexes (important for analytics/training queries)
CREATE INDEX idx_recommendation_sessions_user_id_created_at ON recommendation_sessions(user_id, created_at DESC);
CREATE INDEX idx_recommendation_sessions_created_at ON recommendation_sessions(created_at);
CREATE INDEX idx_recommendation_sessions_context_hash ON recommendation_sessions(context_hash);

CREATE INDEX idx_recommendation_items_session_id ON recommendation_items(session_id);
CREATE INDEX idx_recommendation_items_item_id ON recommendation_items(item_id);      -- For looking up item usage
CREATE INDEX idx_recommendation_items_score ON recommendation_items(score);
CREATE INDEX idx_recommendation_items_rank ON recommendation_items(rank);

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
CREATE INDEX idx_translation_cache_lookup ON translation_cache(source_text, source_language, target_language);
CREATE INDEX idx_translation_cache_expires ON translation_cache(expires_at);