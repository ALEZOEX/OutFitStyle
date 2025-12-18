-- 001_initial.up.sql (TZ-aligned foundation)
-- PostgreSQL 15+

-- =========================
-- EXTENSIONS
-- =========================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =========================
-- ENUMS (idempotent)
-- =========================
DO $$ BEGIN
    CREATE TYPE subscription_status AS ENUM ('active', 'cancelled', 'expired', 'past_due', 'trialing');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE clothing_source AS ENUM ('user', 'partner', 'manual', 'synthetic');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE notification_type AS ENUM ('recommendation', 'weather_alert', 'subscription', 'achievement', 'promo');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- =========================
-- USERS & AUTH
-- =========================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    display_name VARCHAR(100),
    avatar_url TEXT,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    birth_date DATE,

    body_measurements JSONB DEFAULT '{
        "height": null,
        "weight": null,
        "sizes": {
            "top": null,
            "bottom": null,
            "shoes": null,
            "size_system": "EU"
        }
    }'::jsonb,

    default_location VARCHAR(255),
    default_latitude DECIMAL(10, 8),
    default_longitude DECIMAL(11, 8),
    timezone VARCHAR(50) DEFAULT 'Europe/Moscow',
    locale VARCHAR(10) DEFAULT 'ru',

    preferences JSONB DEFAULT '{
        "preferred_styles": [],
        "avoid_styles": [],
        "color_preferences": [],
        "avoid_colors": [],
        "formality_default": 2,
        "temperature_sensitivity": 0,
        "notifications_enabled": true,
        "morning_reminder_time": "08:00",
        "weekly_digest": true
    }'::jsonb,

    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,

    oauth_provider VARCHAR(50),
    oauth_id VARCHAR(255),

    last_login_at TIMESTAMP,
    login_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_oauth ON users(oauth_provider, oauth_id) WHERE oauth_provider IS NOT NULL;

CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    refresh_token_hash VARCHAR(255) NOT NULL,
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    device_type VARCHAR(50),
    ip_address INET,
    user_agent TEXT,

    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,
    last_used_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON user_sessions(refresh_token_hash);

CREATE TABLE IF NOT EXISTS user_onboarding (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_step INTEGER DEFAULT 1,
    completed_steps JSONB DEFAULT '[]'::jsonb,
    skipped_steps JSONB DEFAULT '[]'::jsonb,
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    ab_variant VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS user_2fa (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    totp_secret_encrypted TEXT,
    totp_enabled BOOLEAN DEFAULT false,
    backup_codes_hash TEXT[],
    backup_codes_used INTEGER DEFAULT 0,
    recovery_email VARCHAR(255),
    recovery_phone VARCHAR(20),
    enabled_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    recommendations_count INTEGER DEFAULT 0,
    wardrobe_size INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    max_streak INTEGER DEFAULT 0,
    last_active_date DATE,
    perfect_ratings_count INTEGER DEFAULT 0,
    weather_types_seen TEXT[] DEFAULT '{}',
    styles_used TEXT[] DEFAULT '{}',
    total_points INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    consent_type VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL,
    granted BOOLEAN NOT NULL,
    granted_at TIMESTAMP DEFAULT NOW(),
    ip_address INET,
    UNIQUE(user_id, consent_type)
);

-- =========================
-- SUBSCRIPTIONS & PAYMENTS
-- =========================
CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    price_monthly DECIMAL(10,2) NOT NULL DEFAULT 0,
    price_yearly DECIMAL(10,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'RUB',

    recommendations_per_day INTEGER,
    wardrobe_items_limit INTEGER,
    history_days INTEGER,
    styles_limit INTEGER,
    family_accounts INTEGER DEFAULT 1,

    features JSONB NOT NULL DEFAULT '{}'::jsonb,

    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert default plans (idempotent by code)
INSERT INTO subscription_plans (code, name, price_monthly, price_yearly,
    recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, features)
VALUES
('free', 'Free', 0, 0, 3, 30, 7, 2,
    '{"ads": true, "api_access": false, "ai_stylist": false, "export": false, "analytics": false}'::jsonb),
('style_plus', 'Style+', 299, 2990, NULL, 200, 30, 5,
    '{"ads": false, "api_access": false, "ai_stylist": false, "export": true, "analytics": false}'::jsonb),
('pro', 'Pro', 599, 5990, NULL, NULL, 365, NULL,
    '{"ads": false, "api_access": false, "ai_stylist": true, "export": true, "analytics": true}'::jsonb),
('business', 'Business', 1499, 14990, NULL, NULL, NULL, NULL,
    '{"ads": false, "api_access": true, "ai_stylist": true, "export": true, "analytics": true, "priority_support": true}'::jsonb)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),

    billing_cycle VARCHAR(10) NOT NULL CHECK (billing_cycle IN ('monthly', 'yearly')),
    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
    current_period_start TIMESTAMP NOT NULL DEFAULT NOW(),
    current_period_end TIMESTAMP NOT NULL,
    cancelled_at TIMESTAMP,

    status subscription_status NOT NULL DEFAULT 'active',
    auto_renew BOOLEAN DEFAULT true,

    payment_provider VARCHAR(50),
    external_subscription_id VARCHAR(255),

    trial_end TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_active_subscription ON user_subscriptions(user_id)
    WHERE status IN ('active', 'trialing');

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    subscription_id UUID REFERENCES user_subscriptions(id),

    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RUB',

    status payment_status NOT NULL DEFAULT 'pending',
    payment_provider VARCHAR(50) NOT NULL,
    external_payment_id VARCHAR(255),
    payment_method VARCHAR(50),

    description TEXT,
    metadata JSONB,
    error_message TEXT,
    receipt_url TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);

CREATE TABLE IF NOT EXISTS promo_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,

    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percent', 'fixed', 'trial_days')),
    discount_value DECIMAL(10,2) NOT NULL,

    applicable_plans UUID[],
    min_billing_cycle VARCHAR(10),

    max_uses INTEGER,
    uses_count INTEGER DEFAULT 0,
    max_uses_per_user INTEGER DEFAULT 1,

    valid_from TIMESTAMP DEFAULT NOW(),
    valid_until TIMESTAMP,

    campaign_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS promo_code_uses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    promo_code_id UUID NOT NULL REFERENCES promo_codes(id),
    user_id UUID NOT NULL REFERENCES users(id),
    subscription_id UUID REFERENCES user_subscriptions(id),
    discount_applied DECIMAL(10,2),
    used_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(promo_code_id, user_id)
);

-- =========================
-- CLOTHING + WARDROBE
-- =========================
CREATE TABLE IF NOT EXISTS clothing_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(255) NOT NULL,
    description TEXT,

    category VARCHAR(50) NOT NULL CHECK (category IN ('outerwear', 'upper', 'lower', 'footwear', 'accessory')),
    subcategory VARCHAR(100) NOT NULL,

    min_temp INTEGER,
    max_temp INTEGER,
    warmth_level INTEGER CHECK (warmth_level BETWEEN 1 AND 10),
    rain_ok BOOLEAN DEFAULT false,
    snow_ok BOOLEAN DEFAULT false,
    wind_ok BOOLEAN DEFAULT false,

    style VARCHAR(50) NOT NULL CHECK (style IN ('casual', 'sport', 'street', 'classic', 'business', 'smart_casual', 'outdoor')),
    formality_level INTEGER CHECK (formality_level BETWEEN 1 AND 5),
    base_colour VARCHAR(50),
    secondary_colours TEXT[],
    pattern VARCHAR(50) DEFAULT 'solid',
    fit VARCHAR(50) DEFAULT 'regular',

    gender VARCHAR(20) DEFAULT 'unisex',
    season VARCHAR(20) DEFAULT 'all' CHECK (season IN ('winter', 'spring', 'summer', 'autumn', 'all')),
    usage TEXT[],
    materials TEXT[],
    brand VARCHAR(100),

    available_sizes TEXT[],
    size_chart JSONB,

    image_url TEXT,
    thumbnail_url TEXT,
    icon_emoji VARCHAR(10),

    source clothing_source NOT NULL DEFAULT 'synthetic',
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    is_owned BOOLEAN DEFAULT false,

    partner_id UUID,
    partner_sku VARCHAR(100),
    partner_url TEXT,
    partner_price DECIMAL(10,2),
    partner_currency VARCHAR(3),

    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_clothing_category ON clothing_items(category);
CREATE INDEX IF NOT EXISTS idx_clothing_subcategory ON clothing_items(subcategory);
CREATE INDEX IF NOT EXISTS idx_clothing_owner ON clothing_items(owner_id) WHERE owner_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_clothing_source ON clothing_items(source);
CREATE INDEX IF NOT EXISTS idx_clothing_temp ON clothing_items(min_temp, max_temp);
CREATE INDEX IF NOT EXISTS idx_clothing_style ON clothing_items(style);

CREATE TABLE IF NOT EXISTS user_wardrobe (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clothing_item_id UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,

    custom_name VARCHAR(255),
    notes TEXT,
    tags TEXT[],

    purchase_date DATE,
    purchase_price DECIMAL(10,2),
    purchase_currency VARCHAR(3),

    wear_count INTEGER DEFAULT 0,
    last_worn_at TIMESTAMP,

    is_favorite BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    condition VARCHAR(20) DEFAULT 'good' CHECK (condition IN ('new', 'good', 'worn', 'damaged')),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(user_id, clothing_item_id)
);

CREATE INDEX IF NOT EXISTS idx_wardrobe_user ON user_wardrobe(user_id);

CREATE TABLE IF NOT EXISTS subcategory_specs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcategory VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,

    typical_min_temp INTEGER,
    typical_max_temp INTEGER,
    typical_warmth_level INTEGER,

    typical_formality INTEGER,
    typical_styles TEXT[],
    compatible_occasions TEXT[],

    default_rain_ok BOOLEAN DEFAULT false,
    default_snow_ok BOOLEAN DEFAULT false,
    default_wind_ok BOOLEAN DEFAULT false,

    layer_position INTEGER,
    can_be_standalone BOOLEAN DEFAULT true,

    description TEXT,
    icon_emoji VARCHAR(10),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- RECOMMENDATIONS
-- =========================
CREATE TABLE IF NOT EXISTS recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    location VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    occasion VARCHAR(50),
    requested_style VARCHAR(50),
    requested_formality INTEGER,

    weather_data JSONB NOT NULL,

    outfit_data JSONB NOT NULL,
    total_score DECIMAL(5,4),
    style_coherence DECIMAL(5,4),
    color_harmony DECIMAL(5,4),
    weather_match DECIMAL(5,4),

    model_version VARCHAR(50),
    processing_time_ms INTEGER,
    ab_test_variant VARCHAR(50),

    user_rating INTEGER CHECK (user_rating BETWEEN 1 AND 5),
    user_feedback TEXT,
    thermal_feedback VARCHAR(20) CHECK (thermal_feedback IN ('too_cold', 'cold', 'perfect', 'warm', 'too_warm')),
    rated_at TIMESTAMP,

    is_favorite BOOLEAN DEFAULT false,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recommendations_user ON recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_created ON recommendations(created_at);

CREATE TABLE IF NOT EXISTS recommendation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recommendation_id UUID NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
    clothing_item_id UUID NOT NULL REFERENCES clothing_items(id),

    category VARCHAR(50) NOT NULL,
    layer_position INTEGER,
    score DECIMAL(5,4),

    source clothing_source NOT NULL,
    is_from_wardrobe BOOLEAN DEFAULT false,

    alternatives JSONB,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rec_items_recommendation ON recommendation_items(recommendation_id);

CREATE TABLE IF NOT EXISTS user_item_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clothing_item_id UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    recommendation_id UUID REFERENCES recommendations(id),

    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    context JSONB,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(user_id, clothing_item_id)
);

-- =========================
-- ACHIEVEMENTS
-- =========================
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_emoji VARCHAR(10),

    condition_type VARCHAR(50) NOT NULL,
    condition_value INTEGER NOT NULL,
    condition_data JSONB,

    reward_type VARCHAR(50),
    reward_value VARCHAR(255),

    category VARCHAR(50),
    points INTEGER DEFAULT 0,
    is_secret BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO achievements (code, name, description, icon_emoji, condition_type, condition_value, category, points)
VALUES
('first_outfit', 'Первый образ', 'Получите первую рекомендацию', '👔', 'recommendations_count', 1, 'beginner', 10),
('wardrobe_10', 'Коллекционер', 'Добавьте 10 вещей в гардероб', '👕', 'wardrobe_size', 10, 'wardrobe', 20),
('wardrobe_50', 'Модник', 'Добавьте 50 вещей в гардероб', '👗', 'wardrobe_size', 50, 'wardrobe', 50),
('streak_7', 'Неделя стиля', 'Используйте приложение 7 дней подряд', '🔥', 'streak_days', 7, 'engagement', 30),
('streak_30', 'Месяц стиля', 'Используйте приложение 30 дней подряд', '💪', 'streak_days', 30, 'engagement', 100),
('perfect_10', 'Перфекционист', 'Получите 10 оценок 5 звёзд', '⭐', 'perfect_ratings', 10, 'quality', 40),
('all_weather', 'Всепогодный', 'Получите рекомендации для всех типов погоды', '🌤️', 'weather_types', 5, 'explorer', 60),
('style_master', 'Мастер стиля', 'Попробуйте все стили', '🎨', 'styles_used', 7, 'explorer', 50)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id),

    progress INTEGER DEFAULT 0,
    unlocked_at TIMESTAMP,
    notified BOOLEAN DEFAULT false,

    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(user_id, achievement_id)
);

-- =========================
-- NOTIFICATIONS
-- =========================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    image_url TEXT,
    data JSONB,

    action_type VARCHAR(50),
    action_data JSONB,

    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,

    push_sent BOOLEAN DEFAULT false,
    push_sent_at TIMESTAMP,
    push_error TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

CREATE TABLE IF NOT EXISTS push_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    token TEXT NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    device_id VARCHAR(255),

    is_active BOOLEAN DEFAULT true,
    last_used_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(token)
);

-- =========================
-- PARTNERS & AFFILIATE
-- =========================
CREATE TABLE IF NOT EXISTS partners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,

    api_base_url TEXT,
    api_key_encrypted TEXT,
    webhook_secret_encrypted TEXT,

    commission_percent DECIMAL(5,2),
    cookie_days INTEGER DEFAULT 30,
    affiliate_url_template TEXT,

    logo_url TEXT,
    display_name VARCHAR(100),

    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS affiliate_clicks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    partner_id UUID NOT NULL REFERENCES partners(id),
    clothing_item_id UUID REFERENCES clothing_items(id),
    recommendation_id UUID REFERENCES recommendations(id),

    click_id VARCHAR(100),
    session_id VARCHAR(100),

    clicked_at TIMESTAMP DEFAULT NOW(),

    converted BOOLEAN DEFAULT false,
    converted_at TIMESTAMP,
    conversion_value DECIMAL(10,2),
    commission_earned DECIMAL(10,2)
);

-- =========================
-- AUDIT & SECURITY
-- =========================
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),

    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,

    old_value JSONB,
    new_value JSONB,

    ip_address INET,
    user_agent TEXT,

    success BOOLEAN DEFAULT true,
    error_message TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs(created_at);

CREATE TABLE IF NOT EXISTS rate_limit_violations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    identifier VARCHAR(255) NOT NULL,
    identifier_type VARCHAR(20) NOT NULL,
    endpoint VARCHAR(255),
    limit_type VARCHAR(50),
    limit_value INTEGER,
    current_value INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS blocked_entities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(20) NOT NULL,
    entity_value VARCHAR(255) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    blocked_by UUID REFERENCES users(id),
    blocked_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- A/B TESTING
-- =========================
CREATE TABLE IF NOT EXISTS experiments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,

    variants JSONB NOT NULL,

    user_percentage INTEGER DEFAULT 100,
    targeting_rules JSONB,

    status VARCHAR(20) DEFAULT 'draft',
    started_at TIMESTAMP,
    ended_at TIMESTAMP,

    primary_metric VARCHAR(100),
    secondary_metrics TEXT[],

    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS experiment_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID NOT NULL REFERENCES experiments(id),
    user_id UUID NOT NULL REFERENCES users(id),
    variant VARCHAR(50) NOT NULL,
    assigned_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(experiment_id, user_id)
);

CREATE TABLE IF NOT EXISTS experiment_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID NOT NULL REFERENCES experiments(id),
    user_id UUID NOT NULL REFERENCES users(id),
    variant VARCHAR(50) NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    event_value DECIMAL(10,4),
    event_data JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- FEATURE FLAGS
-- =========================
CREATE TABLE IF NOT EXISTS feature_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    key VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    enabled BOOLEAN DEFAULT false,

    rules JSONB DEFAULT '[]'::jsonb,

    default_value JSONB DEFAULT 'false'::jsonb,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- CACHE TABLES
-- =========================
CREATE TABLE IF NOT EXISTS translation_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    source_text TEXT NOT NULL,
    source_lang VARCHAR(10) NOT NULL,
    target_lang VARCHAR(10) NOT NULL,
    translated_text TEXT NOT NULL,

    provider VARCHAR(50) DEFAULT 'yandex',

    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,

    UNIQUE(source_text, source_lang, target_lang)
);

CREATE TABLE IF NOT EXISTS weather_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    location_key VARCHAR(100) NOT NULL,

    weather_data JSONB NOT NULL,
    forecast_data JSONB,

    fetched_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,

    UNIQUE(location_key)
);

-- =========================
-- UPLOADED FILES
-- =========================
CREATE TABLE IF NOT EXISTS uploaded_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),

    bucket VARCHAR(100) NOT NULL,
    path VARCHAR(500) NOT NULL,
    filename VARCHAR(255) NOT NULL,

    mime_type VARCHAR(100),
    size_bytes BIGINT,

    thumbnails JSONB,

    status VARCHAR(20) DEFAULT 'active',

    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- TRIGGERS
-- =========================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DO $$ BEGIN
    CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER update_clothing_items_updated_at
    BEFORE UPDATE ON clothing_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER update_user_subscriptions_updated_at
    BEFORE UPDATE ON user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER update_user_wardrobe_updated_at
    BEFORE UPDATE ON user_wardrobe
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION update_user_wardrobe_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO user_stats (user_id, wardrobe_size)
        VALUES (NEW.user_id, 1)
        ON CONFLICT (user_id) DO UPDATE
        SET wardrobe_size = user_stats.wardrobe_size + 1,
            updated_at = NOW();
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE user_stats
        SET wardrobe_size = GREATEST(0, wardrobe_size - 1),
            updated_at = NOW()
        WHERE user_id = OLD.user_id;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

DO $$ BEGIN
    CREATE TRIGGER update_wardrobe_stats
    AFTER INSERT OR DELETE ON user_wardrobe
    FOR EACH ROW EXECUTE FUNCTION update_user_wardrobe_stats();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION update_recommendation_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_stats (user_id, recommendations_count, last_active_date)
    VALUES (NEW.user_id, 1, CURRENT_DATE)
    ON CONFLICT (user_id) DO UPDATE
    SET recommendations_count = user_stats.recommendations_count + 1,
        current_streak = CASE
            WHEN user_stats.last_active_date = CURRENT_DATE - 1 THEN user_stats.current_streak + 1
            WHEN user_stats.last_active_date = CURRENT_DATE THEN user_stats.current_streak
            ELSE 1
        END,
        max_streak = GREATEST(user_stats.max_streak,
            CASE
                WHEN user_stats.last_active_date = CURRENT_DATE - 1 THEN user_stats.current_streak + 1
                WHEN user_stats.last_active_date = CURRENT_DATE THEN user_stats.current_streak
                ELSE 1
            END),
        last_active_date = CURRENT_DATE,
        updated_at = NOW();
    RETURN NULL;
END;
$$ language 'plpgsql';

DO $$ BEGIN
    CREATE TRIGGER update_rec_stats
    AFTER INSERT ON recommendations
    FOR EACH ROW EXECUTE FUNCTION update_recommendation_stats();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION cleanup_expired_data()
RETURNS void AS $$
BEGIN
    DELETE FROM user_sessions WHERE expires_at < NOW();
    DELETE FROM translation_cache WHERE expires_at < NOW();
    DELETE FROM weather_cache WHERE expires_at < NOW();
    DELETE FROM audit_logs WHERE created_at < NOW() - INTERVAL '90 days';
    DELETE FROM rate_limit_violations WHERE created_at < NOW() - INTERVAL '7 days';
    DELETE FROM notifications WHERE expires_at IS NOT NULL AND expires_at < NOW();
END;
$$ language 'plpgsql';