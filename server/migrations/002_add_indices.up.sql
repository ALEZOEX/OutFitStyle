-- Add indices for better query performance
CREATE INDEX idx_wardrobe_items_warmth_level ON wardrobe_items(warmth_level);
CREATE INDEX idx_recommendations_occasion ON recommendations(occasion);
CREATE INDEX idx_recommendations_weather_condition ON recommendations(weather_condition);

-- Add composite index for common query pattern
CREATE INDEX idx_wardrobe_items_user_category ON wardrobe_items(user_id, category);