-- 000013_subscription_system.up.sql
-- Полная система подписок с интеграцией YooKassa
-- Планы: Free, Premium, Pro, Business

-- ============================================
-- 1. subscription_plans - планы подписок
-- ============================================
CREATE TABLE IF NOT EXISTS subscription_plans (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    -- Цены
    price_monthly NUMERIC(12, 2) NOT NULL DEFAULT 0,
    price_yearly NUMERIC(12, 2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',

    -- Лимиты
    recommendations_per_day INTEGER,
    wardrobe_items_limit INTEGER,
    history_days INTEGER,
    styles_limit INTEGER,
    family_accounts INTEGER NOT NULL DEFAULT 1,

    -- Фичи (JSON массив строк)
    features JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Метаданные
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    trial_period_days INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT subscription_plans_code_check CHECK (code IN ('free', 'premium', 'pro', 'business')),
    CONSTRAINT subscription_plans_currency_check CHECK (currency IN ('RUB', 'USD', 'EUR'))
);

CREATE INDEX IF NOT EXISTS idx_subscription_plans_code ON subscription_plans(code);
CREATE INDEX IF NOT EXISTS idx_subscription_plans_active ON subscription_plans(is_active);

-- ============================================
-- 2. user_subscriptions - активные подписки пользователей
-- ============================================
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id BIGINT NOT NULL REFERENCES subscription_plans(id),

    -- Цикл оплаты
    billing_cycle VARCHAR(20) NOT NULL CHECK (billing_cycle IN ('monthly', 'yearly')),

    -- Периоды
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_period_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_period_end TIMESTAMPTZ NOT NULL,
    trial_end TIMESTAMPTZ,

    -- Статусы
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'trialing', 'cancelled', 'expired', 'past_due')),
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    cancelled_at TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN NOT NULL DEFAULT FALSE,

    -- Платежный провайдер
    payment_provider VARCHAR(50) NOT NULL DEFAULT 'yookassa',
    external_subscription_id VARCHAR(255),

    -- Отмена
    cancellation_reason TEXT,
    cancellation_feedback TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT user_subscriptions_user_plan_unique UNIQUE (user_id, plan_id, status)
);

CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_period_end ON user_subscriptions(current_period_end);

-- ============================================
-- 3. subscription_usage - использование лимитов подписки
-- ============================================
CREATE TABLE IF NOT EXISTS subscription_usage (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id BIGINT REFERENCES user_subscriptions(id) ON DELETE SET NULL,

    -- Счётчики
    recommendations_today INTEGER NOT NULL DEFAULT 0,
    recommendations_reset_at DATE NOT NULL DEFAULT CURRENT_DATE,

    wardrobe_count INTEGER NOT NULL DEFAULT 0,

    -- История (дата последнего сброса)
    last_reset_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT subscription_usage_user_unique UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_subscription_usage_user_id ON subscription_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_usage_reset ON subscription_usage(recommendations_reset_at);

-- ============================================
-- 4. subscription_transactions - история транзакций
-- ============================================
CREATE TABLE IF NOT EXISTS subscription_transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id BIGINT REFERENCES user_subscriptions(id) ON DELETE SET NULL,

    -- Сумма
    amount NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',

    -- Статус
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled')),

    -- Платежный провайдер
    payment_provider VARCHAR(50) NOT NULL,
    external_payment_id VARCHAR(255) NOT NULL,
    payment_method VARCHAR(50),

    -- Метаданные
    description TEXT,
    receipt_url TEXT,
    error_message TEXT,

    -- Временные метки
    paid_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT subscription_transactions_external_unique UNIQUE (payment_provider, external_payment_id)
);

CREATE INDEX IF NOT EXISTS idx_subscription_transactions_user_id ON subscription_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_transactions_status ON subscription_transactions(status);
CREATE INDEX IF NOT EXISTS idx_subscription_transactions_external ON subscription_transactions(payment_provider, external_payment_id);
CREATE INDEX IF NOT EXISTS idx_subscription_transactions_created ON subscription_transactions(created_at);

-- ============================================
-- 5. promo_codes - промокоды
-- ============================================
CREATE TABLE IF NOT EXISTS promo_codes (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100),

    -- Тип скидки
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount', 'free_trial', 'free_month')),
    discount_value NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(3),

    -- Ограничения
    min_order_amount NUMERIC(12, 2),
    max_discount NUMERIC(12, 2),
    usage_limit INTEGER,
    usage_limit_per_user INTEGER NOT NULL DEFAULT 1,

    -- Применимость к планам
    applicable_plans JSONB NOT NULL DEFAULT '["premium", "pro", "business"]'::jsonb,
    min_billing_cycle VARCHAR(20),

    -- Период действия
    valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    valid_until TIMESTAMPTZ,

    -- Статус
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Статистика
    uses_count INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT promo_codes_currency_check CHECK (currency IS NULL OR currency IN ('RUB', 'USD', 'EUR'))
);

CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promo_codes(is_active);
CREATE INDEX IF NOT EXISTS idx_promo_codes_valid ON promo_codes(valid_from, valid_until);

-- ============================================
-- 6. promo_redemptions - использования промокодов
-- ============================================
CREATE TABLE IF NOT EXISTS promo_redemptions (
    id BIGSERIAL PRIMARY KEY,
    promo_code_id BIGINT NOT NULL REFERENCES promo_codes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id BIGINT REFERENCES user_subscriptions(id) ON DELETE SET NULL,

    discount_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT promo_redemptions_unique UNIQUE (promo_code_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_promo_redemptions_user ON promo_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_promo_redemptions_promo ON promo_redemptions(promo_code_id);

-- ============================================
-- 7. family_members - семейные аккаунты (для Pro плана)
-- ============================================
CREATE TABLE IF NOT EXISTS family_members (
    id BIGSERIAL PRIMARY KEY,
    owner_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    member_user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,

    -- Статус приглашения
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'removed', 'expired')),
    invited_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,

    -- Кто добавил
    added_by UUID REFERENCES users(id) ON DELETE SET NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT family_members_owner_member_unique UNIQUE (owner_user_id, member_user_id)
);

CREATE INDEX IF NOT EXISTS idx_family_members_owner ON family_members(owner_user_id);
CREATE INDEX IF NOT EXISTS idx_family_members_member ON family_members(member_user_id);
CREATE INDEX IF NOT EXISTS idx_family_members_status ON family_members(status);

-- ============================================
-- 8. Триггеры для updated_at
-- ============================================
DROP TRIGGER IF EXISTS trg_subscription_plans_updated_at ON subscription_plans;
CREATE TRIGGER trg_subscription_plans_updated_at
    BEFORE UPDATE ON subscription_plans
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_user_subscriptions_updated_at ON user_subscriptions;
CREATE TRIGGER trg_user_subscriptions_updated_at
    BEFORE UPDATE ON user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_subscription_usage_updated_at ON subscription_usage;
CREATE TRIGGER trg_subscription_usage_updated_at
    BEFORE UPDATE ON subscription_usage
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_subscription_transactions_updated_at ON subscription_transactions;
CREATE TRIGGER trg_subscription_transactions_updated_at
    BEFORE UPDATE ON subscription_transactions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_promo_codes_updated_at ON promo_codes;
CREATE TRIGGER trg_promo_codes_updated_at
    BEFORE UPDATE ON promo_codes
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_family_members_updated_at ON family_members;
CREATE TRIGGER trg_family_members_updated_at
    BEFORE UPDATE ON family_members
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================
-- 9. Начальные данные - планы подписок
-- ============================================
INSERT INTO subscription_plans (code, name, description, price_monthly, price_yearly, currency,
                                 recommendations_per_day, wardrobe_items_limit, history_days, styles_limit, family_accounts,
                                 features, trial_period_days, is_active, sort_order)
VALUES
    ('free', 'Free', 'Базовый бесплатный план',
     0, 0, 'RUB',
     3, 50, 7, 2, 1,
     '["basic_recommendations", "weather_alerts", "style_tracking"]'::jsonb,
     0, TRUE, 0),

    ('premium', 'Premium', 'Расширенный план с ML-персонализацией',
     299, 2990, 'RUB',
     20, 500, 90, 10, 1,
     '["ml_personalization", "priority_support", "advanced_analytics", "weather_alerts", "style_tracking", "outfit_calendar"]'::jsonb,
     14, TRUE, 1),

    ('pro', 'Pro', 'Профессиональный план с семейным доступом',
     599, 5990, 'RUB',
     NULL, 5000, 365, NULL, 4,
     '["unlimited_recommendations", "family_access", "priority_support", "advanced_analytics", "export_data", "api_access"]'::jsonb,
     14, TRUE, 2),

    ('business', 'Business', 'Бизнес план с API и white-label',
     1990, 19900, 'RUB',
     NULL, 50000, 730, NULL, 1,
     '["unlimited_recommendations", "api_access", "white_label", "advanced_analytics", "dedicated_support", "custom_integrations", "sla"]'::jsonb,
     14, TRUE, 3)
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- 10. Функция для сброса дневных лимитов
-- ============================================
CREATE OR REPLACE FUNCTION reset_daily_subscription_usage()
RETURNS VOID AS $$
BEGIN
    UPDATE subscription_usage
    SET recommendations_today = 0,
        recommendations_reset_at = CURRENT_DATE,
        last_reset_at = NOW(),
        updated_at = NOW()
    WHERE recommendations_reset_at < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 11. Представление для текущей активной подписки
-- ============================================
CREATE OR REPLACE VIEW active_user_subscriptions AS
SELECT
    us.id,
    us.user_id,
    us.plan_id,
    sp.code AS plan_code,
    sp.name AS plan_name,
    us.billing_cycle,
    us.started_at,
    us.current_period_start,
    us.current_period_end,
    us.trial_end,
    us.status,
    us.auto_renew,
    us.payment_provider,
    us.external_subscription_id,
    sp.recommendations_per_day,
    sp.wardrobe_items_limit,
    sp.history_days,
    sp.family_accounts
FROM user_subscriptions us
JOIN subscription_plans sp ON us.plan_id = sp.id
WHERE us.status IN ('active', 'trialing')
  AND us.current_period_end > NOW();

COMMENT ON TABLE subscription_plans IS 'Планы подписок OutfitStyle (Free, Premium, Pro, Business)';
COMMENT ON TABLE user_subscriptions IS 'Активные подписки пользователей';
COMMENT ON TABLE subscription_usage IS 'Использование лимитов подписки (счётчики)';
COMMENT ON TABLE subscription_transactions IS 'История транзакций и платежей';
COMMENT ON TABLE promo_codes IS 'Промокоды для скидок на подписки';
COMMENT ON TABLE promo_redemptions IS 'Использованные промокоды';
COMMENT ON TABLE family_members IS 'Семейные аккаунты для Pro плана';
