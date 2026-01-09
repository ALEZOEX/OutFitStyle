-- Drop all tables in reverse order
DROP TABLE IF EXISTS recommendation_feedback;
DROP TABLE IF EXISTS recommendations;
DROP TABLE IF EXISTS wardrobe_items;
DROP TABLE IF EXISTS user_preferences;
DROP TABLE IF EXISTS users;

-- Drop trigger function
DROP FUNCTION IF EXISTS update_updated_at_column();