-- Добавление индексов для лучшей производительности запросов
CREATE INDEX idx_wardrobe_items_warmth_level ON wardrobe_items(warmth_level);
CREATE INDEX idx_recommendations_occasion ON recommendations(occasion);
CREATE INDEX idx_recommendations_weather_condition ON recommendations(weather_condition);

-- Добавление составного индекса для распространенного шаблона запросов
CREATE INDEX idx_wardrobe_items_user_category ON wardrobe_items(user_id, category);