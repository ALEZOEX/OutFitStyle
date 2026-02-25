-- 000019_seed_achievements.up.sql
-- Начальные данные для достижений

INSERT INTO achievements (code, name, description, icon_emoji, points, condition_type, condition_value, category, is_active, sort_order)
VALUES
    -- Для новых пользователей
    ('first_outfit', 'Первый образ', 'Получите первую рекомендацию образа', '👔', 10, 'recommendations_count', 1, 'beginner', true, 1),
    ('first_week', 'Первая неделя', 'Используйте приложение 7 дней', '📅', 20, 'days_since_signup', 7, 'beginner', true, 2),
    
    -- Гардероб
    ('wardrobe_10', 'Коллекционер', 'Добавьте 10 вещей в гардероб', '👕', 20, 'wardrobe_size', 10, 'wardrobe', true, 10),
    ('wardrobe_50', 'Модник', 'Добавьте 50 вещей в гардероб', '👗', 50, 'wardrobe_size', 50, 'wardrobe', true, 11),
    ('wardrobe_100', 'Гуру стиля', 'Добавьте 100 вещей в гардероб', '🎩', 100, 'wardrobe_size', 100, 'wardrobe', true, 12),
    ('favorites_10', 'Избранное', 'Добавьте 10 вещей в избранное', '⭐', 30, 'favorite_items', 10, 'wardrobe', true, 13),
    
    -- Активность
    ('streak_7', 'Неделя стиля', 'Используйте приложение 7 дней подряд', '🔥', 30, 'streak_days', 7, 'engagement', true, 20),
    ('streak_30', 'Месяц стиля', 'Используйте приложение 30 дней подряд', '💪', 100, 'streak_days', 30, 'engagement', true, 21),
    ('daily_user_30', 'Постоянный клиент', 'Заходите в приложение 30 дней (не обязательно подряд)', '📆', 50, 'active_days', 30, 'engagement', true, 22),
    
    -- Качество
    ('perfect_10', 'Перфекционист', 'Получите 10 оценок 5 звёзд', '⭐', 40, 'perfect_ratings', 10, 'quality', true, 30),
    ('perfect_50', 'Эксперт стиля', 'Получите 50 оценок 5 звёзд', '🏆', 150, 'perfect_ratings', 50, 'quality', true, 31),
    ('rate_100', 'Оценщик', 'Оцените 100 рекомендаций', '📊', 60, 'total_ratings', 100, 'quality', true, 32),
    
    -- Исследования
    ('all_weather', 'Всепогодный', 'Получите рекомендации для 5 типов погоды', '🌤️', 60, 'weather_types', 5, 'explorer', true, 40),
    ('all_seasons', 'Все сезоны', 'Используйте вещи для всех 4 сезонов', '🍂', 80, 'seasons_used', 4, 'explorer', true, 41),
    ('style_explorer', 'Исследователь стилей', 'Попробуйте 5 разных стилей', '🎨', 50, 'styles_used', 5, 'explorer', true, 42),
    ('category_master', 'Мастер категорий', 'Используйте вещи из 5 категорий', '📦', 70, 'categories_used', 5, 'explorer', true, 43),
    
    -- Социальные
    ('first_share', 'Первый шар', 'Поделитесь первым образом', '📤', 25, 'shares_count', 1, 'social', true, 50),
    ('popular_creator', 'Популярный автор', 'Получите 100 лайков на свои образы', '❤️', 200, 'total_likes', 100, 'social', true, 51)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon_emoji = EXCLUDED.icon_emoji,
    points = EXCLUDED.points,
    condition_type = EXCLUDED.condition_type,
    condition_value = EXCLUDED.condition_value,
    category = EXCLUDED.category,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order,
    updated_at = NOW();

COMMENT ON TABLE achievements IS 'Система достижений пользователей с очками и условиями получения';
