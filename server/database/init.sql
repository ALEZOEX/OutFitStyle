

SET TIME ZONE 'UTC';

BEGIN;

-- --------------------------------------------
-- DEV‑сброс (для локалки / CI)
-- --------------------------------------------
DROP TABLE IF EXISTS user_ratings          CASCADE;
DROP TABLE IF EXISTS user_achievements     CASCADE;
DROP TABLE IF EXISTS achievements          CASCADE;
DROP TABLE IF EXISTS favorite_outfits      CASCADE;
DROP TABLE IF EXISTS recommendation_items  CASCADE;
DROP TABLE IF EXISTS recommendations       CASCADE;
DROP TABLE IF EXISTS outfit_plans          CASCADE;
DROP TABLE IF EXISTS clothing_items        CASCADE;
DROP TABLE IF EXISTS clothing_categories   CASCADE;
DROP TABLE IF EXISTS user_profiles         CASCADE;
DROP TABLE IF EXISTS user_stats            CASCADE;
DROP TABLE IF EXISTS users                 CASCADE;

DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- ============================================
-- USERS
-- ============================================

CREATE TABLE users (
                       id          SERIAL PRIMARY KEY,
                       email       VARCHAR(255) UNIQUE NOT NULL,
                       username    VARCHAR(50)  UNIQUE NOT NULL,
                       password    VARCHAR(255) NOT NULL,
                       avatar_url  TEXT,
                       is_verified BOOLEAN      NOT NULL DEFAULT FALSE,
                       created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
                       updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
                       CHECK (email <> ''),
                       CHECK (username <> '')
);

-- Профиль пользователя (данные для ML + доменные поля)
CREATE TABLE user_profiles (
                               id                       SERIAL PRIMARY KEY,
                               user_id                  INTEGER NOT NULL
                                   REFERENCES users(id) ON DELETE CASCADE,

    -- то, что ожидает ML‑сервис
                               gender                   TEXT,
                               age_range                TEXT,
                               style_preference         TEXT,
                               temperature_sensitivity  TEXT,
                               preferred_categories     JSONB,
                               formality_preference     TEXT,

    -- дополнительные поля из Go‑домена
                               style_preferences        TEXT,
                               size                     TEXT,
                               height                   INTEGER,
                               weight                   INTEGER,
                               preferred_colors         JSONB,
                               disliked_colors          JSONB,

                               created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                               updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                               UNIQUE (user_id)
);

-- Агрегированная статистика по пользователю
CREATE TABLE user_stats (
                            user_id               INTEGER PRIMARY KEY
                                REFERENCES users(id) ON DELETE CASCADE,
                            total_recommendations INTEGER          NOT NULL DEFAULT 0,
                            average_rating        DOUBLE PRECISION NOT NULL DEFAULT 0,
                            favorite_count        INTEGER          NOT NULL DEFAULT 0,
                            achievement_count     INTEGER          NOT NULL DEFAULT 0,
                            last_active           TIMESTAMPTZ,
                            most_used_category    TEXT
);

-- ============================================
-- CLOTHING
-- ============================================

-- Справочник категорий (для UI/аналитики)
CREATE TABLE clothing_categories (
                                     id          SERIAL PRIMARY KEY,
                                     name        VARCHAR(50) UNIQUE NOT NULL,
                                     description TEXT,
                                     created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Можно сразу завести базовые категории
INSERT INTO clothing_categories (name, description)
VALUES
    ('outerwear', 'Верхняя одежда'),
    ('upper',     'Верх (футболки, свитшоты, рубашки)'),
    ('lower',     'Низ (штаны, юбки, шорты)'),
    ('footwear',  'Обувь'),
    ('accessories', 'Аксессуары')
    ON CONFLICT (name) DO NOTHING;

-- Основная таблица вещей
CREATE TABLE clothing_items (
                                id                  SERIAL PRIMARY KEY,
                                user_id             INTEGER
                                    REFERENCES users(id) ON DELETE CASCADE,

                                name                VARCHAR(100) NOT NULL,
                                category            VARCHAR(50)  NOT NULL,
                                subcategory         VARCHAR(50),
                                icon_emoji          VARCHAR(10)  NOT NULL,

    -- доменные поля
                                ml_score            DOUBLE PRECISION,
                                confidence          DOUBLE PRECISION,
                                weather_suitability VARCHAR(50),

    -- признаки, которые ожидает ML‑сервис
                                min_temp            DOUBLE PRECISION,
                                max_temp            DOUBLE PRECISION,
                                weather_conditions  TEXT,
                                style               TEXT,
                                warmth_level        DOUBLE PRECISION,      -- используется как числовой признак
                                formality_level     TEXT,                  -- может быть числом или категорией (как в датасете)

    -- расширенные атрибуты для единой модели вещей
                                gender              TEXT,
                                master_category     TEXT,
                                season              TEXT,
                                base_colour         TEXT,
                                usage               TEXT,
                                source              TEXT DEFAULT 'catalog',  -- 'wardrobe', 'catalog', 'kaggle_seed', ...
                                is_owned            BOOLEAN DEFAULT FALSE,
                                owner_user_id       BIGINT,

                                created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clothing_items_user_id   ON clothing_items(user_id);
CREATE INDEX idx_clothing_items_category  ON clothing_items(category);
CREATE INDEX idx_clothing_items_created_at ON clothing_items(created_at);

-- Create wardrobe_items table for personal wardrobe items
CREATE TABLE wardrobe_items (
    user_id          BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clothing_item_id BIGINT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, clothing_item_id)
);

-- Add indexes for performance optimization
CREATE INDEX idx_clothing_items_cat_temp
    ON clothing_items (category, COALESCE(gender, 'unknown'), COALESCE(season, 'all'));

CREATE INDEX idx_clothing_items_source_cat
    ON clothing_items (source, category);

CREATE INDEX idx_clothing_items_gender
    ON clothing_items (gender);

CREATE INDEX idx_clothing_items_season
    ON clothing_items (season);

CREATE INDEX idx_clothing_items_source
    ON clothing_items (source);

CREATE INDEX idx_wardrobe_items_user
    ON wardrobe_items (user_id);

CREATE INDEX idx_clothing_items_owner
    ON clothing_items (owner_user_id);

-- Update existing clothing_items to have 'wardrobe' source for user-owned items
UPDATE clothing_items
SET source = 'wardrobe',
    is_owned = TRUE,
    owner_user_id = user_id
WHERE user_id IS NOT NULL;

-- Add updated_at trigger for wardrobe_items table
CREATE OR REPLACE FUNCTION update_wardrobe_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trg_wardrobe_items_updated_at
    BEFORE UPDATE ON wardrobe_items
    FOR EACH ROW
    EXECUTE FUNCTION update_wardrobe_items_updated_at();

-- ============================================
-- RECOMMENDATIONS
-- ============================================

CREATE TABLE recommendations (
                                 id           SERIAL PRIMARY KEY,
                                 user_id      INTEGER
                                     REFERENCES users(id) ON DELETE CASCADE,

    -- Погода на момент рекомендации:
                                 temperature  DOUBLE PRECISION NOT NULL,
                                 weather      VARCHAR(100)     NOT NULL,
                                 min_temp     DOUBLE PRECISION,
                                 max_temp     DOUBLE PRECISION,
                                 will_rain    BOOLEAN,
                                 will_snow    BOOLEAN,
                                 location     VARCHAR(100),

    -- ML‑метаданные:
                                 outfit_score DOUBLE PRECISION,
                                 ml_powered   BOOLEAN      NOT NULL DEFAULT FALSE,
                                 algorithm    VARCHAR(50),

                                 created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Элементы рекомендации (снапшот вещи на момент выдачи)
CREATE TABLE recommendation_items (
                                      id                SERIAL PRIMARY KEY,
                                      recommendation_id INTEGER NOT NULL
                                          REFERENCES recommendations(id) ON DELETE CASCADE,
                                      clothing_item_id  INTEGER NOT NULL
                                          REFERENCES clothing_items(id)   ON DELETE CASCADE,

    -- поля, с которыми работает RecommendationRepository
                                      name              VARCHAR(100),
                                      category          VARCHAR(50),
                                      icon_emoji        VARCHAR(10),
                                      ml_score          DOUBLE PRECISION,
                                      confidence        DOUBLE PRECISION,

    -- старые/дополнительные поля (можно использовать для другого функционала)
                                      confidence_score  DOUBLE PRECISION,
                                      position          INTEGER,

                                      created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                      UNIQUE (recommendation_id, clothing_item_id)
);

CREATE INDEX idx_recommendations_user_id     ON recommendations(user_id);
CREATE INDEX idx_recommendations_created_at  ON recommendations(created_at);

CREATE INDEX idx_recommendation_items_rec_id       ON recommendation_items(recommendation_id);
CREATE INDEX idx_recommendation_items_clothing_id  ON recommendation_items(clothing_item_id);

-- ============================================
-- FAVORITES, ACHIEVEMENTS, RATINGS
-- ============================================

CREATE TABLE favorite_outfits (
                                  id                SERIAL PRIMARY KEY,
                                  user_id           INTEGER NOT NULL
                                      REFERENCES users(id)          ON DELETE CASCADE,
                                  recommendation_id INTEGER NOT NULL
                                      REFERENCES recommendations(id) ON DELETE CASCADE,
                                  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                  UNIQUE (user_id, recommendation_id)
);

CREATE TABLE achievements (
                              id          SERIAL PRIMARY KEY,
                              code        VARCHAR(50) UNIQUE NOT NULL,
                              name        VARCHAR(100) NOT NULL,
                              description TEXT,
                              icon        VARCHAR(50),
                              created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_achievements (
                                   id             SERIAL PRIMARY KEY,
                                   user_id        INTEGER NOT NULL
                                       REFERENCES users(id)        ON DELETE CASCADE,
                                   achievement_id INTEGER NOT NULL
                                       REFERENCES achievements(id) ON DELETE CASCADE,
                                   unlocked_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                   UNIQUE (user_id, achievement_id)
);

CREATE TABLE user_ratings (
                              id                SERIAL PRIMARY KEY,
                              user_id           INTEGER NOT NULL
                                  REFERENCES users(id)          ON DELETE CASCADE,
                              recommendation_id INTEGER NOT NULL
                                  REFERENCES recommendations(id) ON DELETE CASCADE,
                              rating            INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
                              feedback          TEXT,
                              created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                              UNIQUE (user_id, recommendation_id)
);

CREATE INDEX idx_user_favorites_user_id     ON favorite_outfits(user_id);
CREATE INDEX idx_user_achievements_user_id  ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_ach_id   ON user_achievements(achievement_id);
CREATE INDEX idx_user_ratings_user_id       ON user_ratings(user_id);

-- ============================================
-- OUTFIT PLANS
-- ============================================

CREATE TABLE outfit_plans (
                              id         SERIAL PRIMARY KEY,
                              user_id    INTEGER NOT NULL
                                  REFERENCES users(id) ON DELETE CASCADE,
                              date       DATE    NOT NULL,
                              item_ids   JSONB   NOT NULL,  -- список id вещей на день
                              notes      TEXT,
                              created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                              updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                              deleted_at TIMESTAMPTZ,

                              UNIQUE (user_id, date, deleted_at)
);

CREATE INDEX idx_outfit_plans_user_date ON outfit_plans(user_id, date);

-- ============================================
-- TRIGGERS (updated_at)
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_clothing_items_updated_at
    BEFORE UPDATE ON clothing_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_outfit_plans_updated_at
    BEFORE UPDATE ON outfit_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;