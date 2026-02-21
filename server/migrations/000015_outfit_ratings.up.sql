-- 000015_outfit_ratings.up.sql
-- Система рейтинга рекомендаций одежды (-10 до +10)
-- Пользователи оценивают рекомендации (1-5 звёзд), конвертируется в quality_score

-- ============================================================================
-- 1. outfit_ratings - оценки пользователей для рекомендаций
-- ============================================================================
CREATE TABLE IF NOT EXISTS outfit_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recommendation_id UUID NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
    outfit_items UUID[], -- ID вещей в наряде (для анализа)
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- 1-5 звёзд
    quality_score INTEGER NOT NULL DEFAULT 0 CHECK (quality_score >= -10 AND quality_score <= 10), -- -10 до +10
    feedback TEXT, -- Текстовый отзыв
    thermal_feedback VARCHAR(20), -- "too_hot", "too_cold", "just_right"
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT outfit_ratings_user_recommendation_unique UNIQUE (user_id, recommendation_id)
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_outfit_ratings_user_id ON outfit_ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_outfit_ratings_recommendation_id ON outfit_ratings(recommendation_id);
CREATE INDEX IF NOT EXISTS idx_outfit_ratings_created_at ON outfit_ratings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_outfit_ratings_quality_score ON outfit_ratings(quality_score);

-- ============================================================================
-- 2. recommendation_quality - представление для среднего рейтинга
-- ============================================================================
CREATE OR REPLACE VIEW recommendation_quality_stats AS
SELECT 
    recommendation_id,
    COUNT(*) as rating_count,
    AVG(rating) as avg_rating,
    AVG(quality_score) as avg_quality_score,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    STDDEV(quality_score) as quality_score_stddev,
    COUNT(*) FILTER (WHERE rating >= 4) as positive_count,
    COUNT(*) FILTER (WHERE rating <= 2) as negative_count
FROM outfit_ratings
GROUP BY recommendation_id;

-- ============================================================================
-- 3. user_rating_stats - статистика оценок пользователя
-- ============================================================================
CREATE OR REPLACE VIEW user_rating_stats AS
SELECT 
    user_id,
    COUNT(*) as total_ratings,
    AVG(rating) as avg_rating,
    AVG(quality_score) as avg_quality_score,
    COUNT(*) FILTER (WHERE rating >= 4) as positive_ratings,
    COUNT(*) FILTER (WHERE rating <= 2) as negative_ratings,
    MAX(created_at) as last_rated_at
FROM outfit_ratings
GROUP BY user_id;

-- ============================================================================
-- 4. low_quality_items - вещи с низким рейтингом (для ML фильтрации)
-- ============================================================================
CREATE OR REPLACE VIEW low_quality_items AS
SELECT 
    unnest(outfit_items) as clothing_item_id,
    COUNT(*) as times_in_low_rating,
    AVG(quality_score) as avg_quality_score
FROM outfit_ratings
WHERE quality_score < -5
GROUP BY unnest(outfit_items)
HAVING AVG(quality_score) < -5;

-- ============================================================================
-- 5. Триггер для автоматического расчёта quality_score при вставке
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_quality_score()
RETURNS TRIGGER AS $$
BEGIN
    -- Конвертация 1-5 → -10 до +10: (rating - 3) * 5
    -- 1 → -10, 2 → -5, 3 → 0, 4 → 5, 5 → 10
    NEW.quality_score := (NEW.rating - 3) * 5;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_calculate_quality_score ON outfit_ratings;
CREATE TRIGGER trg_calculate_quality_score
    BEFORE INSERT ON outfit_ratings
    FOR EACH ROW EXECUTE FUNCTION calculate_quality_score();

-- ============================================================================
-- 6. Комментарии к таблицам
-- ============================================================================
COMMENT ON TABLE outfit_ratings IS 'Оценки пользователей для рекомендаций одежды (1-5 звёзд → -10 до +10)';
COMMENT ON COLUMN outfit_ratings.rating IS 'Оценка пользователя 1-5 звёзд';
COMMENT ON COLUMN outfit_ratings.quality_score IS 'Конвертированная оценка качества: (rating - 3) * 5, диапазон -10..+10';
COMMENT ON COLUMN outfit_ratings.outfit_items IS 'ID вещей в наряде для анализа качества рекомендаций';
COMMENT ON VIEW recommendation_quality_stats IS 'Статистика качества по каждой рекомендации';
COMMENT ON VIEW user_rating_stats IS 'Статистика оценок пользователя';
COMMENT ON VIEW low_quality_items IS 'Вещи с низким рейтингом для исключения из рекомендаций ML';
