-- 002_schema_update.up.sql
-- Расширение recommendations и создание outfit_plans под текущий код

-- Добавляем недостающие колонки в recommendations
ALTER TABLE recommendations
    ADD COLUMN IF NOT EXISTS temperature DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS weather VARCHAR(100),
    ADD COLUMN IF NOT EXISTS outfit_score DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS algorithm VARCHAR(50),
    ADD COLUMN IF NOT EXISTS location VARCHAR(100),
    ADD COLUMN IF NOT EXISTS min_temp DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS max_temp DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS will_rain BOOLEAN,
    ADD COLUMN IF NOT EXISTS will_snow BOOLEAN;

-- Создаём таблицу outfit_plans, если её ещё нет
CREATE TABLE IF NOT EXISTS outfit_plans (
                                            id SERIAL PRIMARY KEY,
                                            user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    item_ids JSONB NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

CREATE INDEX IF NOT EXISTS idx_outfit_plans_user_date
    ON outfit_plans(user_id, date);