-- 001_initial.down.sql
-- Drop in rough reverse dependency order (CASCADE where OK)

DROP FUNCTION IF EXISTS cleanup_expired_data();
DROP FUNCTION IF EXISTS update_recommendation_stats();
DROP FUNCTION IF EXISTS update_user_wardrobe_stats();
DROP FUNCTION IF EXISTS update_updated_at_column();

DROP TABLE IF EXISTS uploaded_files CASCADE;
DROP TABLE IF EXISTS weather_cache CASCADE;
DROP TABLE IF EXISTS translation_cache CASCADE;

DROP TABLE IF EXISTS feature_flags CASCADE;

DROP TABLE IF EXISTS experiment_events CASCADE;
DROP TABLE IF EXISTS experiment_assignments CASCADE;
DROP TABLE IF EXISTS experiments CASCADE;

DROP TABLE IF EXISTS blocked_entities CASCADE;
DROP TABLE IF EXISTS rate_limit_violations CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;

DROP TABLE IF EXISTS affiliate_clicks CASCADE;
DROP TABLE IF EXISTS partners CASCADE;

DROP TABLE IF EXISTS push_tokens CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;

DROP TABLE IF EXISTS user_achievements CASCADE;
DROP TABLE IF EXISTS achievements CASCADE;

DROP TABLE IF EXISTS user_item_ratings CASCADE;
DROP TABLE IF EXISTS recommendation_items CASCADE;
DROP TABLE IF EXISTS recommendations CASCADE;

DROP TABLE IF EXISTS user_wardrobe CASCADE;
DROP TABLE IF EXISTS clothing_items CASCADE;
DROP TABLE IF EXISTS subcategory_specs CASCADE;

DROP TABLE IF EXISTS promo_code_uses CASCADE;
DROP TABLE IF EXISTS promo_codes CASCADE;

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS user_subscriptions CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;

DROP TABLE IF EXISTS user_consents CASCADE;
DROP TABLE IF EXISTS user_stats CASCADE;
DROP TABLE IF EXISTS user_2fa CASCADE;
DROP TABLE IF EXISTS user_onboarding CASCADE;
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP TYPE IF EXISTS notification_type;
DROP TYPE IF EXISTS clothing_source;
DROP TYPE IF EXISTS payment_status;
DROP TYPE IF EXISTS subscription_status;