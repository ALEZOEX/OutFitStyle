-- Rollback: Performance Optimization - Additional Indexes
-- Удаление индексов производительности

-- ============================================================================
-- SUBSCRIPTION TABLES INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_user_subscriptions_expires_at;
DROP INDEX IF EXISTS idx_user_subscriptions_active;

-- ============================================================================
-- RECOMMENDATIONS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_recommendations_algorithm;
DROP INDEX IF EXISTS idx_recommendations_ml_powered;

-- ============================================================================
-- USER_PROFILES TABLE INDEXES (wardrobe_items)
-- ============================================================================
DROP INDEX IF EXISTS idx_wardrobe_items_tags_gin;
DROP INDEX IF EXISTS idx_wardrobe_items_favorite;
DROP INDEX IF EXISTS idx_wardrobe_items_condition;
DROP INDEX IF EXISTS idx_wardrobe_items_user_archived;

-- ============================================================================
-- USERS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_users_active_last_login;
DROP INDEX IF EXISTS idx_users_created_at;
DROP INDEX IF EXISTS idx_users_oauth_provider_id;
DROP INDEX IF EXISTS idx_users_email_active;

-- ============================================================================
-- SESSIONS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_sessions_refresh_hash_active;
DROP INDEX IF EXISTS idx_sessions_user_active;
DROP INDEX IF EXISTS idx_sessions_expires_at;
