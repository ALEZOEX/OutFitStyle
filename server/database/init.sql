--Создание таблиц
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUEREFERENCES users(id) ON DELETE CASCADE,
    gender VARCHAR(20),
    age_range VARCHAR(20),
    style_preference VARCHAR(50),
    color_preference TEXT[],
    temperature_sensitivity VARCHAR(20) DEFAULT 'normal',
    preferred_categories TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS clothing_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    min_temp DECIMAL(5,2),
    max_temp DECIMAL(5,2),
    weather_conditions TEXT[],
    style VARCHAR(50),
    warmth_level INTEGER CHECK (warmth_level BETWEEN 0 AND 10),
    formality_level INTEGER CHECK (formality_level BETWEEN 0 AND 10),
    icon_emoji VARCHAR(10),
    created_at TIMESTAMP DEFAULTCURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS recommendations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    location VARCHAR(255),
    temperature DECIMAL(5,2),
    feels_like DECIMAL(5,2),
    weather VARCHAR(50),
    humidity INTEGER,
    wind_speed DECIMAL(5,2),
    algorithm_version VARCHAR(50),
    ml_confidence DECIMAL(5,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS recommendation_items (
    id SERIAL PRIMARY KEY,
    recommendation_id INTEGER REFERENCES recommendations(id) ON DELETE CASCADE,
    clothing_item_id INTEGER REFERENCES clothing_items(id) ON DELETE CASCADE,
    ml_score DECIMAL(5,4),
    position INTEGER,
    UNIQUE(recommendation_id, clothing_item_id)
);

CREATE TABLE IF NOT EXISTS ratings (
    id SERIAL PRIMARY KEY,
    recommendation_id INTEGER REFERENCES recommendations(id) ON DELETE CASCADE,
    user_idINTEGER REFERENCES users(id),
    clothing_item_id INTEGER REFERENCES clothing_items(id),
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 5),
    comfort_rating INTEGER CHECK (comfort_rating BETWEEN 1 AND 5),
    style_rating INTEGER CHECK (style_rating BETWEEN 1 AND 5),
    weather_match_rating INTEGERCHECK (weather_match_rating BETWEEN 1 AND 5),
    too_warm BOOLEAN DEFAULT false,
    too_cold BOOLEAN DEFAULT false,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS usage_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    recommendation_id INTEGER REFERENCES recommendations(id),
    clicked BOOLEAN DEFAULT false,
    viewed_duration INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_recommendations_user ON recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_created ON recommendations(created_at DESC);
CREATE INDEX IF NOTEXISTS idx_ratings_user ON ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_ratings_item ON ratings(clothing_item_id);
CREATE INDEX IF NOT EXISTS idx_usage_user ON usage_history(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendation_items_rec ON recommendation_items(recommendation_id);

-- Вставка предметов одежды
INSERT INTO clothing_items (name, category, subcategory, min_temp, max_temp, weather_conditions, style, warmth_level, formality_level, icon_emoji) VALUES
('Пуховик', 'outerwear', 'winter_jacket', -40, -5, ARRAY['clear', 'snow','wind'], 'casual', 10, 5, '🧥'),
('Зимняя парка', 'outerwear', 'winter_parka', -30, 0, ARRAY['clear', 'snow', 'wind'], 'casual', 9, 4, '🧥'),
('Термобелье', 'upper', 'base_layer', -40, 5, ARRAY['clear', 'snow'], 'sporty', 9, 2, '👕'),
('Термоштаны', 'lower', 'thermal_pants', -40, 0, ARRAY['clear', 'snow'], 'sporty', 9, 2, '👖'),
('Ушанка', 'accessories', 'winter_hat', -40, -5, ARRAY['clear', 'snow', 'wind'], 'casual', 9, 3, '🧢'),
('Зимние перчатки', 'accessories', 'winter_gloves', -35, -5, ARRAY['clear', 'snow'], 'sporty', 9, 3, '🧤'),
('Шарф', 'accessories', 'scarf', -40, 5, ARRAY['clear', 'snow', 'wind'], 'elegant', 8, 6, '🧣'),
('Зимние ботинки', 'footwear', 'winter_boots', -35, 0, ARRAY['clear', 'snow'], 'casual', 9, 5, '👢'),
('Куртка-бомбер', 'outerwear', 'bomber', 0, 15, ARRAY['clear', 'clouds'], 'casual', 6, 5, '🧥'),
('Кожаная куртка', 'outerwear', 'leather_jacket', 5, 18, ARRAY['clear', 'clouds'], 'casual', 5, 7, '🧥'),
('Джинсовая куртка', 'outerwear', 'denim_jacket', 0, 12, ARRAY['clear', 'clouds'], 'casual', 5, 4, '🧥'),
('Свитер', 'upper', 'sweater', 0, 15, ARRAY['clear', 'clouds'], 'casual', 6, 5, '👕'),
('Водолазка', 'upper', 'turtleneck', 5, 15, ARRAY['clear', 'clouds'], 'business', 4, 7, '👕'),
('Джинсы утепленные', 'lower', 'warm_jeans', -5, 12, ARRAY['clear','clouds'], 'casual', 5, 4, '👖'),
('Ботинки', 'footwear', 'chukka', 0, 15, ARRAY['clear', 'clouds'], 'casual', 5, 6, '👞'),
('Ветровка', 'outerwear', 'windbreaker', 10, 20, ARRAY['clear', 'clouds', 'wind'], 'sporty', 3, 3, '🧥'),
('Легкая куртка', 'outerwear', 'light_jacket', 12, 22, ARRAY['clear', 'clouds'], 'casual', 3, 5, '🧥'),
('Кардиган', 'upper', 'cardigan', 12, 20, ARRAY['clear', 'clouds'], 'casual', 3, 6, '👕'),
('Рубашка фланель', 'upper', 'flannel_shirt', 10, 18, ARRAY['clear', 'clouds'], 'casual', 4, 5, '👔'),
('Чинос', 'lower', 'chinos', 8, 25, ARRAY['clear', 'clouds'], 'business', 2, 7, '👖'),
('Высокие кеды', 'footwear', 'high_tops', 8, 22, ARRAY['clear', 'clouds'], 'casual', 3, 4,'👟'),
('Олимпийка', 'outerwear', 'track_jacket', 15, 23, ARRAY['clear', 'clouds'], 'sporty', 2, 3, '🧥'),
('Джинсовка легкая', 'outerwear', 'denim_light', 18, 25, ARRAY['clear'], 'casual', 2, 4, '🧥'),
('Рубашка короткий рукав', 'upper', 'short_shirt', 18, 28, ARRAY['clear', 'clouds'], 'casual',1, 6, '👔'),
('Поло', 'upper', 'polo', 18, 30, ARRAY['clear', 'clouds'], 'casual', 1, 6, '👕'),
('Джинсы', 'lower', 'jeans', 10, 28, ARRAY['clear', 'clouds'], 'casual', 2, 5, '👖'),
('Кроссовки', 'footwear', 'sneakers', 10, 35, ARRAY['clear', 'clouds'], 'casual', 2,4, '👟'),
('Мокасины', 'footwear', 'loafers', 15, 30, ARRAY['clear'], 'business', 1, 7, '👞'),
('Футболка', 'upper', 'tshirt', 20, 35, ARRAY['clear', 'clouds'], 'casual', 1, 3, '👕'),
('Льняная рубашка', 'upper', 'linen_shirt', 23, 35, ARRAY['clear'], 'casual', 1, 6, '👔'),
('Шорты джинсовые', 'lower', 'denim_shorts', 22, 35, ARRAY['clear'], 'casual', 1, 3, '🩳'),
('Чиносы летние', 'lower', 'summer_chinos', 20,32, ARRAY['clear'], 'casual', 1, 5, '👖'),
('Легкие кеды', 'footwear', 'canvas_sneakers', 18, 35, ARRAY['clear'], 'casual', 1, 3, '👟'),
('Майка', 'upper', 'tank_top', 25, 45, ARRAY['clear'], 'casual', 1, 2, '👕'),
('Шорты спортивные', 'lower', 'sport_shorts', 25, 45, ARRAY['clear'],'sporty', 1, 2, '🩳'),
('Сандалии', 'footwear', 'sandals', 22, 45, ARRAY['clear'], 'casual', 1, 2, '👡'),
('Дождевик', 'outerwear', 'raincoat', 5, 25, ARRAY['rain', 'drizzle'], 'casual', 2, 3, '🧥'),
('Плащ', 'outerwear', 'trench_coat', 8, 20, ARRAY['rain', 'drizzle'], 'business', 3, 8, '🧥'),
('Зонт', 'accessories', 'umbrella', -10, 35, ARRAY['rain', 'drizzle'], 'casual', 0, 4, '☂️'),
('Резиновые сапоги', 'footwear', 'rain_boots', -5, 20, ARRAY['rain', 'snow'], 'casual', 3, 2, '👢'),
('Пиджак', 'outerwear', 'blazer', 15, 28, ARRAY['clear', 'clouds'], 'business', 2, 9, '🤵'),
('Костюм', 'upper', 'suit', 15, 28, ARRAY['clear', 'clouds'], 'business', 2, 10, '🤵'),
('Рубашка белая', 'upper', 'dress_shirt', 15, 30, ARRAY['clear', 'clouds'], 'business', 1, 9, '👔'),
('Брюки классические', 'lower', 'dress_pants', 10, 30, ARRAY['clear', 'clouds'], 'business', 2, 9, '👖'),
('Оксфорды', 'footwear', 'oxford_shoes', 5, 30, ARRAY['clear', 'clouds'], 'business', 1, 10, '👞'),
('Толстовка', 'upper', 'hoodie',10, 20, ARRAY['clear', 'clouds'], 'sporty', 4, 3, '👕'),
('Спортивная футболка', 'upper', 'sport_tee', 18, 35, ARRAY['clear'], 'sporty', 1, 2, '👕'),
('Леггинсы', 'lower', 'leggings', 10, 25, ARRAY['clear', 'clouds'], 'sporty', 2, 2, '👖'),
('Кроссовки для бега', 'footwear', 'running_shoes', 5, 35, ARRAY['clear', 'clouds'], 'sporty', 2, 2, '👟'),
('Бейсболка', 'accessories', 'baseball_cap', 15, 40, ARRAY['clear'], 'sporty', 0, 2, '🧢'),
('Солнцезащитные очки', 'accessories', 'sunglasses', 15, 45, ARRAY['clear'], 'casual', 0, 5, '🕶️')
ON CONFLICT DO NOTHING;

-- Тестовые пользователи
INSERTINTO users (email, name) VALUES 
('alex@example.com', 'Alex'),
('maria@example.com', 'Maria'),
('john@example.com', 'John')
ON CONFLICT (email) DO NOTHING;

-- Профили пользователей
INSERT INTO user_profiles (user_id, gender, age_range, style_preference, temperature_sensitivity, preferred_categories) 
SELECT id, 'male', '25-35', 'casual', 'cold', ARRAY['casual', 'sporty']
FROM users WHERE email = 'alex@example.com'
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO user_profiles (user_id, gender, age_range, style_preference, temperature_sensitivity, preferred_categories) 
SELECT id, 'female', '18-25', 'elegant', 'normal', ARRAY['elegant', 'business']
FROM users WHERE email = 'maria@example.com'
ON CONFLICT (user_id) DONOTHING;

INSERT INTO user_profiles (user_id, gender, age_range, style_preference, temperature_sensitivity, preferred_categories) 
SELECT id, 'male', '35-45', 'business', 'warm', ARRAY['business', 'casual']
FROM users WHERE email = 'john@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- Таблица для избранных комплектов
CREATE TABLE IF NOT EXISTS favorite_outfits (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    recommendation_id INTEGER REFERENCES recommendations(id) ON DELETE CASCADE NOT NULL,
    custom_name VARCHAR(100),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, recommendation_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorite_outfits(user_id);

-- Определения достижений (статичные данные)
CREATE TABLE IF NOT EXISTS achievement_definitions (
    id VARCHAR(50) PRIMARY KEY,
    nameVARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    icon VARCHAR(10) NOT NULL,
    required_count INTEGER DEFAULT 1
);

-- Прогресс пользователей по достижениям
CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    achievement_id VARCHAR(50) REFERENCES achievement_definitions(id) ON DELETE CASCADE NOT NULL,
    progress INTEGER DEFAULT 0,
    unlocked_at TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);

-- Вставка базовых достижений
INSERT INTO achievement_definitions (id, name, description, icon, required_count) VALUES
('first_recommendation', 'Первые шаги', 'Получите первую рекомендацию', '🎯', 1),
('first_rating', 'Критик моды', 'Оцените первую рекомендацию', '⭐', 1),
('rating_master', 'Эксперт стиля', 'Оцените 50 рекомендаций', '🏆', 50),
('week_streak', 'Неделя стиля', 'Используйте приложение 7 дней подряд', '🔥', 7),
('rainy_day', 'Непогода нипочем', 'Получите рекомендацию в дождливый день', '☔', 1),
('cold_warrior','Полярник', 'Получите рекомендацию при температуре ниже -10°C', '❄️', 1),
('profile_complete', 'Все по полочкам', 'Полностью заполните свой профиль', '✅', 1),
('sharer', 'Инфлюенсер', 'Поделитесь своим первым комплектом одежды', '🚀', 1)
ON CONFLICT (id) DO NOTHING;
