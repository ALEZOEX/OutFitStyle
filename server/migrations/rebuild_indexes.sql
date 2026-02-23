-- Скрипт пересоздания индексов для оптимизации производительности
-- Запускать раз в месяц или при деградации производительности

-- REINDEX с опцией CONCURRENTLY (не блокирует таблицы)
-- Доступно в PostgreSQL 12+

-- Основные индексы пользователей
REINDEX INDEX CONCURRENTLY IF EXISTS idx_users_email;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_users_external_id;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_users_created_at;

-- Индексы гардероба
REINDEX INDEX CONCURRENTLY IF EXISTS idx_wardrobe_items_user_id;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_wardrobe_items_category;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_wardrobe_items_season;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_wardrobe_items_color;

-- Индексы рекомендаций
REINDEX INDEX CONCURRENTLY IF EXISTS idx_recommendations_user_id;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_recommendations_created_at;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_recommendation_items_recommendation_id;

-- Индексы интеграций
REINDEX INDEX CONCURRENTLY IF EXISTS idx_integration_clients_user_id;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_api_keys_user_id;

-- Индексы сессий
REINDEX INDEX CONCURRENTLY IF EXISTS idx_sessions_user_id;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_sessions_expires_at;

-- Индексы подписок
REINDEX INDEX CONCURRENTLY IF EXISTS idx_subscriptions_user_id;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_subscriptions_status;

-- Индексы outfit ratings
REINDEX INDEX CONCURRENTLY IF EXISTS idx_outfit_ratings_user_id;
REINDEX INDEX CONCURRENTLY IF EXISTS idx_outfit_ratings_outfit_id;

-- Анализ таблиц для обновления статистики
ANALYZE users;
ANALYZE wardrobe_items;
ANALYZE recommendations;
ANALYZE recommendation_items;
ANALYZE integration_clients;
ANALYZE api_keys;
ANALYZE sessions;
ANALYZE subscriptions;
ANALYZE outfit_ratings;

-- Вывод информации о размере индексов
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexrelid) DESC;
