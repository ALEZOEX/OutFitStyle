-- 000018_fix_achievements_schema.up.sql
-- Исправление структуры таблицы achievements для соответствия коду
-- Добавление недостающих полей: code, icon_emoji, points, is_active

-- Добавляем поле code (уникальный код достижения)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS code VARCHAR(50);

-- Добавляем поле icon_emoji (эмодзи для отображения)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS icon_emoji VARCHAR(10);

-- Добавляем поле points (очки за достижение)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS points INTEGER NOT NULL DEFAULT 0;

-- Добавляем поле is_active (активно ли достижение)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- Добавляем поле condition_type (тип условия для достижения)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS condition_type VARCHAR(50);

-- Добавляем поле condition_value (значение условия)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS condition_value INTEGER NOT NULL DEFAULT 0;

-- Добавляем поле condition_data (дополнительные данные условия)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS condition_data JSONB;

-- Добавляем поле category (категория достижения)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS category VARCHAR(50);

-- Добавляем поле sort_order (порядок сортировки)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;

-- Добавляем поле is_secret (секретное достижение)
ALTER TABLE achievements
ADD COLUMN IF NOT EXISTS is_secret BOOLEAN NOT NULL DEFAULT false;

-- Обновляем существующие записи: генерируем code из name
UPDATE achievements
SET code = LOWER(REPLACE(REPLACE(name, ' ', '_'), '.', ''))
WHERE code IS NULL;

-- Обновляем icon_emoji из старого поля icon
UPDATE achievements
SET icon_emoji = icon
WHERE icon_emoji IS NULL AND icon IS NOT NULL;

-- Устанавливаем points по умолчанию для существующих записей
UPDATE achievements
SET points = 10
WHERE points = 0;

-- Делаем поле code NOT NULL после заполнения
ALTER TABLE achievements
ALTER COLUMN code SET NOT NULL;

-- Создаем уникальный индекс на code
CREATE UNIQUE INDEX IF NOT EXISTS idx_achievements_code ON achievements(code);

-- Индекс для активных достижений
CREATE INDEX IF NOT EXISTS idx_achievements_active ON achievements(is_active) WHERE is_active = true;

-- Индекс для категории достижений
CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category);

-- Комментарии
COMMENT ON COLUMN achievements.code IS 'Уникальный код достижения для идентификации в коде';
COMMENT ON COLUMN achievements.icon_emoji IS 'Эмодзи для визуального отображения достижения';
COMMENT ON COLUMN achievements.points IS 'Количество очков за получение достижения';
COMMENT ON COLUMN achievements.is_active IS 'Флаг активности достижения (неактивные не показываются пользователям)';
COMMENT ON COLUMN achievements.condition_type IS 'Тип условия: recommendations_count, wardrobe_size, streak_days, perfect_ratings, weather_types, styles_used';
COMMENT ON COLUMN achievements.condition_value IS 'Целевое значение условия для получения достижения';
COMMENT ON COLUMN achievements.category IS 'Категория: beginner, wardrobe, engagement, quality, explorer';
