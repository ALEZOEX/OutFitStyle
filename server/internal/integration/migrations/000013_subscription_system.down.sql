-- 000013_subscription_system.down.sql
-- Откат миграции системы подписок

-- Удаляем представление
DROP VIEW IF EXISTS active_user_subscriptions;

-- Удаляем функцию
DROP FUNCTION IF EXISTS reset_daily_subscription_usage();

-- Удаляем триггеры
DROP TRIGGER IF EXISTS trg_family_members_updated_at ON family_members;
DROP TRIGGER IF EXISTS trg_promo_codes_updated_at ON promo_codes;
DROP TRIGGER IF EXISTS trg_subscription_transactions_updated_at ON subscription_transactions;
DROP TRIGGER IF EXISTS trg_subscription_usage_updated_at ON subscription_usage;
DROP TRIGGER IF EXISTS trg_user_subscriptions_updated_at ON user_subscriptions;
DROP TRIGGER IF EXISTS trg_subscription_plans_updated_at ON subscription_plans;

-- Удаляем таблицы (в порядке, обратном созданию)
DROP TABLE IF EXISTS family_members CASCADE;
DROP TABLE IF EXISTS promo_redemptions CASCADE;
DROP TABLE IF EXISTS promo_codes CASCADE;
DROP TABLE IF EXISTS subscription_transactions CASCADE;
DROP TABLE IF EXISTS subscription_usage CASCADE;
DROP TABLE IF EXISTS user_subscriptions CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;

-- Удаляем функцию set_updated_at если она больше не используется (опционально)
-- DROP FUNCTION IF EXISTS set_updated_at();
