-- 000019_seed_achievements.down.sql
-- Откат: удаление тестовых достижений

DELETE FROM achievements
WHERE code IN (
    'first_outfit', 'first_week',
    'wardrobe_10', 'wardrobe_50', 'wardrobe_100', 'favorites_10',
    'streak_7', 'streak_30', 'daily_user_30',
    'perfect_10', 'perfect_50', 'rate_100',
    'all_weather', 'all_seasons', 'style_explorer', 'category_master',
    'first_share', 'popular_creator'
);
