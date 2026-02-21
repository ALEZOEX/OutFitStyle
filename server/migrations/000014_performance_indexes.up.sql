-- Performance Optimization - Additional Indexes
-- Добавление индексов для ускорения частых запросов

-- ============================================================================
-- USERS TABLE INDEXES
-- ============================================================================

-- Индекс для быстрого поиска по email (аутентификация)
-- Уже есть уникальный индекс, но добавим для covering
CREATE INDEX IF NOT EXISTS idx_users_email_active 
ON users(email) WHERE is_active = true;

-- Индекс для поиска по OAuth (Google sign-in)
CREATE INDEX IF NOT EXISTS idx_users_oauth_provider_id 
ON users(oauth_provider, oauth_id) WHERE oauth_provider IS NOT NULL;

-- Индекс для получения пользователей по created_at (аналитика)
CREATE INDEX IF NOT EXISTS idx_users_created_at 
ON users(created_at DESC);

-- Индекс для активных пользователей с last_login (engagement метрики)
CREATE INDEX IF NOT EXISTS idx_users_active_last_login 
ON users(is_active, last_login_at DESC) WHERE is_active = true;

-- ============================================================================
-- USER_PROFILES TABLE INDEXES (wardrobe_items)
-- ============================================================================

-- Составной индекс для гардероба пользователя
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_user_archived
ON wardrobe_items(user_id, is_archived, created_at DESC);

-- Индекс для фильтрации по condition (состояние одежды)
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_condition
ON wardrobe_items(user_id, condition, is_archived) WHERE is_archived = false;

-- Индекс для избранных вещей
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_favorite
ON wardrobe_items(user_id, is_favorite) WHERE is_favorite = true;

-- Индекс для GIN поиска по тегам
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_tags_gin
ON wardrobe_items USING gin(tags);

-- ============================================================================
-- RECOMMENDATIONS TABLE INDEXES
-- ============================================================================

-- Индекс для ML рекомендаций
CREATE INDEX IF NOT EXISTS idx_recommendations_ml_powered
ON recommendations(ml_powered, created_at DESC) WHERE ml_powered = true;

-- Индекс для алгоритма рекомендаций
CREATE INDEX IF NOT EXISTS idx_recommendations_algorithm
ON recommendations(algorithm_used);

-- ============================================================================
-- SESSIONS TABLE INDEXES
-- ============================================================================

-- Индекс для поиска сессий по refresh_hash (аутентификация)
CREATE INDEX IF NOT EXISTS idx_sessions_refresh_hash_active 
ON sessions(refresh_token_hash) WHERE is_active = true;

-- Индекс для получения сессий пользователя
CREATE INDEX IF NOT EXISTS idx_sessions_user_active 
ON sessions(user_id, is_active, expires_at DESC) WHERE is_active = true;

-- Индекс для очистки просроченных сессий
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at 
ON sessions(expires_at) WHERE is_active = true;

-- ============================================================================
-- SUBSCRIPTION TABLES INDEXES
-- ============================================================================

-- Индекс для активных подписок
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_active
ON user_subscriptions(user_id, status, expires_at)
WHERE status IN ('active', 'trialing');

-- Индекс для подписок по дате окончания
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_expires_at
ON user_subscriptions(expires_at)
WHERE status = 'active' AND expires_at IS NOT NULL;

-- ============================================================================
-- ANALYZE TABLES FOR QUERY OPTIMIZER
-- ============================================================================

-- Обновление статистики для оптимизатора запросов
ANALYZE users;
ANALYZE wardrobe_items;
ANALYZE recommendations;
ANALYZE sessions;
ANALYZE clothing_items;
ANALYZE user_subscriptions;
