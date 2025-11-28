-- ============================================
--  OutfitStyle – initial schema (Go + ML)
-- ============================================

-- Чистим на случай повторной инициализации (для пустой БД безопасно)
DROP TABLE IF EXISTS user_ratings CASCADE;
DROP TABLE IF EXISTS user_achievements CASCADE;
DROP TABLE IF EXISTS achievements CASCADE;
DROP TABLE IF EXISTS favorite_outfits CASCADE;
DROP TABLE IF EXISTS recommendation_items CASCADE;
DROP TABLE IF EXISTS recommendations CASCADE;
DROP TABLE IF EXISTS outfit_plans CASCADE;
DROP TABLE IF EXISTS clothing_items CASCADE;
DROP TABLE IF EXISTS clothing_categories CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS user_stats CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP FUNCTION IF EXISTS update_updated_at_column();

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
                       updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE user_profiles (
                               id                       SERIAL PRIMARY KEY,
                               user_id                  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- то, что ожидает ML-сервис
                               gender                   TEXT,
                               age_range                TEXT,
                               style_preference         TEXT,
                               temperature_sensitivity  TEXT,
                               preferred_categories     JSONB,
                               formality_preference     TEXT,

    -- дополнительные поля из Go-домена
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

CREATE TABLE user_stats (
                            user_id               INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
                            total_recommendations INTEGER         NOT NULL DEFAULT 0,
                            average_rating        DOUBLE PRECISION NOT NULL DEFAULT 0,
                            favorite_count        INTEGER         NOT NULL DEFAULT 0,
                            achievement_count     INTEGER         NOT NULL DEFAULT 0,
                            last_active           TIMESTAMPTZ,
                            most_used_category    TEXT
);

-- ============================================
-- CLOTHING
-- ============================================

CREATE TABLE clothing_categories (
                                     id          SERIAL PRIMARY KEY,
                                     name        VARCHAR(50) UNIQUE NOT NULL,
                                     description TEXT,
                                     created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE clothing_items (
                                id                  SERIAL PRIMARY KEY,
                                user_id             INTEGER REFERENCES users(id) ON DELETE CASCADE,
                                name                VARCHAR(100) NOT NULL,
                                category            VARCHAR(50)  NOT NULL,
                                subcategory         VARCHAR(50),
                                icon_emoji          VARCHAR(10)  NOT NULL,

    -- доменные поля
                                ml_score            DOUBLE PRECISION,
                                confidence          DOUBLE PRECISION,
                                weather_suitability VARCHAR(50),

    -- то, что ожидает ML-сервис
                                min_temp            DOUBLE PRECISION,
                                max_temp            DOUBLE PRECISION,
                                weather_conditions  TEXT,
                                style               TEXT,
                                warmth_level        DOUBLE PRECISION,
                                formality_level     TEXT,

                                created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
                                updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clothing_items_user_id ON clothing_items(user_id);
CREATE INDEX idx_clothing_items_category ON clothing_items(category);

-- ============================================
-- RECOMMENDATIONS
-- ============================================

CREATE TABLE recommendations (
                                 id           SERIAL PRIMARY KEY,
                                 user_id      INTEGER REFERENCES users(id) ON DELETE CASCADE,

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

CREATE TABLE recommendation_items (
                                      id                SERIAL PRIMARY KEY,
                                      recommendation_id INTEGER NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
                                      clothing_item_id  INTEGER NOT NULL REFERENCES clothing_items(id)   ON DELETE CASCADE,

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

CREATE INDEX idx_recommendations_user_id    ON recommendations(user_id);
CREATE INDEX idx_recommendations_created_at ON recommendations(created_at);

-- ============================================
-- FAVORITES, ACHIEVEMENTS, RATINGS
-- ============================================

CREATE TABLE favorite_outfits (
                                  id                SERIAL PRIMARY KEY,
                                  user_id           INTEGER NOT NULL REFERENCES users(id)          ON DELETE CASCADE,
                                  recommendation_id INTEGER NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
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
                                   user_id        INTEGER NOT NULL REFERENCES users(id)        ON DELETE CASCADE,
                                   achievement_id INTEGER NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
                                   unlocked_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                   UNIQUE (user_id, achievement_id)
);

CREATE TABLE user_ratings (
                              id                SERIAL PRIMARY KEY,
                              user_id           INTEGER NOT NULL REFERENCES users(id)          ON DELETE CASCADE,
                              recommendation_id INTEGER NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
                              rating            INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
                              feedback          TEXT,
                              created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                              UNIQUE (user_id, recommendation_id)
);

CREATE INDEX idx_user_favorites_user_id    ON favorite_outfits(user_id);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_ratings_user_id      ON user_ratings(user_id);

-- ============================================
-- OUTFIT PLANS
-- ============================================

CREATE TABLE outfit_plans (
                              id         SERIAL PRIMARY KEY,
                              user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                              date       DATE    NOT NULL,
                              item_ids   JSONB   NOT NULL,
                              notes      TEXT,
                              created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                              updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                              deleted_at TIMESTAMPTZ
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