-- Rollback: Performance Optimization - Additional Indexes
-- Удаление индексов производительности

-- ============================================================================
-- NOTIFICATIONS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_notifications_unread;
DROP INDEX IF EXISTS idx_notifications_user_read;

-- ============================================================================
-- TRIPS TABLES INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_trips_future;
DROP INDEX IF EXISTS idx_trips_user_dates;

-- ============================================================================
-- ACHIEVEMENTS TABLES INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_user_achievements_unlocked;
DROP INDEX IF EXISTS idx_user_achievements_user_code;

-- ============================================================================
-- SUBSCRIPTION TABLES INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_user_subscriptions_expires_at;
DROP INDEX IF EXISTS idx_user_subscriptions_active;

-- ============================================================================
-- CLOTHING_ITEMS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_clothing_items_usage_count;
DROP INDEX IF EXISTS idx_clothing_items_category_subcategory;

-- ============================================================================
-- USER_STATS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_user_stats_last_active;
DROP INDEX IF EXISTS idx_user_stats_recommendations;

-- ============================================================================
-- SESSIONS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_sessions_expires_at;
DROP INDEX IF EXISTS idx_sessions_user_active;
DROP INDEX IF EXISTS idx_sessions_refresh_hash_active;

-- ============================================================================
-- RECOMMENDATIONS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_recommendations_ml_powered;
DROP INDEX IF EXISTS idx_recommendations_temperature;
DROP INDEX IF EXISTS idx_recommendations_user_created;

-- ============================================================================
-- USER_PROFILES TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_wardrobe_items_season;
DROP INDEX IF EXISTS idx_wardrobe_items_color;
DROP INDEX IF EXISTS idx_wardrobe_items_category;
DROP INDEX IF EXISTS idx_wardrobe_items_user_archived;

-- ============================================================================
-- USERS TABLE INDEXES
-- ============================================================================
DROP INDEX IF EXISTS idx_users_active_last_login;
DROP INDEX IF EXISTS idx_users_created_at;
DROP INDEX IF EXISTS idx_users_oauth_provider_id;
DROP INDEX IF EXISTS idx_users_email_active;
