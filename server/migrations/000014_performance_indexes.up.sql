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

-- Составной индекс для истории рекомендаций пользователя
CREATE INDEX IF NOT EXISTS idx_recommendations_user_created
ON recommendations(user_id, created_at DESC);

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
-- USER_STATS TABLE INDEXES
-- ============================================================================

-- Индекс для топа пользователей по рекомендациям
CREATE INDEX IF NOT EXISTS idx_user_stats_recommendations 
ON user_stats(total_recommendations DESC);

-- Индекс для активных пользователей
CREATE INDEX IF NOT EXISTS idx_user_stats_last_active 
ON user_stats(last_active DESC) WHERE last_active IS NOT NULL;

-- ============================================================================
-- CLOTHING_ITEMS TABLE INDEXES
-- ============================================================================

-- Индекс для каталога одежды
CREATE INDEX IF NOT EXISTS idx_clothing_items_category_subcategory 
ON clothing_items(category, subcategory, is_archived) WHERE is_archived = false;

-- Индекс для популярных items
CREATE INDEX IF NOT EXISTS idx_clothing_items_usage_count 
ON clothing_items(usage_count DESC) WHERE is_archived = false;

-- ============================================================================
-- SUBSCRIPTION TABLES INDEXES (если есть)
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
-- ACHIEVEMENTS TABLES INDEXES
-- ============================================================================

-- Индекс для прогресса достижений пользователя
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_code 
ON user_achievements(user_id, achievement_code, unlocked_at DESC);

-- Индекс для разблокированных достижений
CREATE INDEX IF NOT EXISTS idx_user_achievements_unlocked 
ON user_achievements(user_id, unlocked_at DESC) 
WHERE unlocked_at IS NOT NULL;

-- ============================================================================
-- TRIPS TABLES INDEXES
-- ============================================================================

-- Индекс для поездок пользователя
CREATE INDEX IF NOT EXISTS idx_trips_user_dates 
ON trips(user_id, start_date DESC, end_date DESC);

-- Индекс для будущих поездок
CREATE INDEX IF NOT EXISTS idx_trips_future 
ON trips(user_id, start_date) 
WHERE start_date > NOW();

-- ============================================================================
-- NOTIFICATIONS TABLE INDEXES
-- ============================================================================

-- Индекс для уведомлений пользователя
CREATE INDEX IF NOT EXISTS idx_notifications_user_read 
ON notifications(user_id, is_read, created_at DESC);

-- Индекс для непрочитанных уведомлений
CREATE INDEX IF NOT EXISTS idx_notifications_unread 
ON notifications(user_id, created_at DESC) 
WHERE is_read = false;

-- ============================================================================
-- ANALYZE TABLES FOR QUERY OPTIMIZER
-- ============================================================================

-- Обновление статистики для оптимизатора запросов
ANALYZE users;
ANALYZE user_profiles;
ANALYZE wardrobe_items;
ANALYZE recommendations;
ANALYZE sessions;
ANALYZE user_stats;
ANALYZE clothing_items;
ANALYZE user_subscriptions;
ANALYZE user_achievements;
ANALYZE trips;
ANALYZE notifications;
