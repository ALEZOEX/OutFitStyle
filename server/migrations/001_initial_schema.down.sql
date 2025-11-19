-- Rollback initial schema migration

-- Drop triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_clothing_items_updated_at ON clothing_items;

-- Drop trigger function
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop indexes
DROP INDEX IF EXISTS idx_clothing_items_user_id;
DROP INDEX IF EXISTS idx_clothing_items_category;
DROP INDEX IF EXISTS idx_recommendations_user_id;
DROP INDEX IF EXISTS idx_recommendations_created_at;
DROP INDEX IF EXISTS idx_user_favorites_user_id;
DROP INDEX IF EXISTS idx_user_achievements_user_id;
DROP INDEX IF EXISTS idx_user_ratings_user_id;
DROP INDEX IF EXISTS idx_weather_data_location_timestamp;

-- Drop tables in reverse order of creation
DROP TABLE IF EXISTS user_ratings;
DROP TABLE IF EXISTS user_achievements;
DROP TABLE IF EXISTS achievements;
DROP TABLE IF EXISTS user_favorites;
DROP TABLE IF EXISTS recommendation_items;
DROP TABLE IF EXISTS recommendations;
DROP TABLE IF EXISTS weather_data;
DROP TABLE IF EXISTS clothing_items;
DROP TABLE IF EXISTS clothing_categories;
DROP TABLE IF EXISTS users;