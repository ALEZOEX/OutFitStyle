-- Migration: Initialize OutfitStyle schema with Planner → Retrieval → Ranking architecture

-- Create schema migrations table for tracking applied migrations
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(20) PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert initial migration version
INSERT INTO schema_migrations (version) VALUES ('0001') ON CONFLICT (version) DO NOTHING;

-- Create enum types
CREATE TYPE source_type AS ENUM ('synthetic', 'user', 'partner', 'manual');
CREATE TYPE gender_type AS ENUM ('unisex');
CREATE TYPE style_type AS ENUM ('casual', 'sport', 'street', 'classic', 'business', 'smart_casual', 'outdoor');
CREATE TYPE usage_type AS ENUM ('daily', 'work', 'formal', 'sport', 'outdoor', 'travel', 'party');
CREATE TYPE season_type AS ENUM ('winter', 'spring', 'summer', 'autumn', 'all');
CREATE TYPE colour_type AS ENUM ('black', 'white', 'gray', 'navy', 'beige', 'brown', 'green', 'blue', 'red', 'pink', 'yellow', 'orange', 'purple');
CREATE TYPE fit_type AS ENUM ('slim', 'regular', 'relaxed', 'oversized');
CREATE TYPE pattern_type AS ENUM ('solid', 'striped', 'checked', 'printed', 'camo');

-- Create subcategory_specs table (dictionary + planner norms)
CREATE TABLE subcategory_specs (
  category        TEXT NOT NULL,
  subcategory     TEXT NOT NULL,

  warmth_min      SMALLINT NOT NULL CHECK (warmth_min BETWEEN 1 AND 10),
  temp_min_reco   SMALLINT NOT NULL,
  temp_max_reco   SMALLINT NOT NULL CHECK (temp_min_reco <= temp_max_reco),

  rain_ok         BOOLEAN NOT NULL DEFAULT TRUE,
  snow_ok         BOOLEAN NOT NULL DEFAULT TRUE,
  wind_ok         BOOLEAN NOT NULL DEFAULT TRUE,

  PRIMARY KEY (category, subcategory),

  CONSTRAINT subcategory_specs_category_check
    CHECK (category IN ('outerwear','upper','lower','footwear','accessory'))
);

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(20),
    location VARCHAR(100),
    preferences JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create clothing_items table (catalog)
CREATE TABLE clothing_items (
  id               BIGINT PRIMARY KEY,
  name             TEXT NOT NULL,

  category         TEXT NOT NULL,
  subcategory      TEXT NOT NULL,

  gender           TEXT NOT NULL DEFAULT 'unisex' CHECK (gender IN ('unisex')),

  style            TEXT NOT NULL CHECK (style IN ('casual','sport','street','classic','business','smart_casual','outdoor')),
  usage            TEXT NOT NULL CHECK (usage IN ('daily','work','formal','sport','outdoor','travel','party')),
  season           TEXT NOT NULL CHECK (season IN ('winter','spring','summer','autumn','all')),
  base_colour      TEXT NOT NULL CHECK (base_colour IN ('black','white','gray','navy','beige','brown','green','blue','red','pink','yellow','orange','purple')),

  formality_level  SMALLINT NOT NULL CHECK (formality_level BETWEEN 1 AND 5),
  warmth_level     SMALLINT NOT NULL CHECK (warmth_level BETWEEN 1 AND 10),

  min_temp         SMALLINT NOT NULL,
  max_temp         SMALLINT NOT NULL,
  CONSTRAINT clothing_items_temp_check CHECK (min_temp <= max_temp),

  materials        TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],

  fit              TEXT NOT NULL CHECK (fit IN ('slim','regular','relaxed','oversized')),
  pattern          TEXT NOT NULL CHECK (pattern IN ('solid','striped','checked','printed','camo')),

  icon_emoji       TEXT NOT NULL,
  source           TEXT NOT NULL DEFAULT 'synthetic',
  is_owned         BOOLEAN NOT NULL DEFAULT FALSE,

  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT clothing_items_source_check CHECK (source IN ('synthetic','user','partner','manual')),

  CONSTRAINT clothing_items_subcategory_fk
    FOREIGN KEY (category, subcategory)
    REFERENCES subcategory_specs (category, subcategory)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- Create wardrobe_items table (user's personal items)
CREATE TABLE wardrobe_items (
  id               BIGINT PRIMARY KEY,
  user_id          BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  clothing_item_id BIGINT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  quantity         INTEGER DEFAULT 1,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create weather data table
CREATE TABLE weather_data (
    id SERIAL PRIMARY KEY,
    location VARCHAR(100) NOT NULL,
    temperature DECIMAL(5, 2) NOT NULL,
    feels_like DECIMAL(5, 2),
    weather_condition VARCHAR(50),
    humidity INTEGER,
    wind_speed DECIMAL(5, 2),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create recommendations table
CREATE TABLE recommendations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    weather_id INTEGER REFERENCES weather_data(id) ON DELETE SET NULL,
    outfit_score DECIMAL(5, 4),
    algorithm_used VARCHAR(50),
    ml_powered BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create recommendation items table (junction table)
CREATE TABLE recommendation_items (
    id SERIAL PRIMARY KEY,
    recommendation_id INTEGER REFERENCES recommendations(id) ON DELETE CASCADE,
    clothing_item_id INTEGER REFERENCES clothing_items(id) ON DELETE CASCADE,
    confidence_score DECIMAL(5, 4),
    position INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(recommendation_id, clothing_item_id)
);

-- Create user favorites table
CREATE TABLE user_favorites (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    recommendation_id INTEGER REFERENCES recommendations(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, recommendation_id)
);

-- Create achievements table
CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user achievements table
CREATE TABLE user_achievements (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Create user ratings table
CREATE TABLE user_ratings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    recommendation_id INTEGER REFERENCES recommendations(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, recommendation_id)
);

-- Create indexes for efficient retrieval
CREATE INDEX clothing_items_cat_subcat_idx ON clothing_items (category, subcategory);
CREATE INDEX clothing_items_cat_warmth_idx ON clothing_items (category, warmth_level);
CREATE INDEX clothing_items_cat_style_idx ON clothing_items (category, style);
CREATE INDEX clothing_items_temp_idx ON clothing_items (min_temp, max_temp);
CREATE INDEX wardrobe_items_user_idx ON wardrobe_items (user_id);
CREATE INDEX wardrobe_items_clothing_item_idx ON wardrobe_items (clothing_item_id);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_clothing_items_category ON clothing_items(category);
CREATE INDEX idx_clothing_items_subcategory ON clothing_items(subcategory);
CREATE INDEX idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX idx_recommendations_created_at ON recommendations(created_at);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_ratings_user_id ON user_ratings(user_id);
CREATE INDEX idx_weather_data_location_timestamp ON weather_data(location, timestamp);

-- Add updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clothing_items_updated_at BEFORE UPDATE ON clothing_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wardrobe_items_updated_at BEFORE UPDATE ON wardrobe_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default subcategory specs (25 subcategories with norms)
INSERT INTO subcategory_specs
(category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok)
VALUES
-- outerwear (5)
('outerwear','parka',      8, -25,   5, TRUE, TRUE, TRUE),
('outerwear','puffer',     9, -30,   2, TRUE, TRUE, TRUE),
('outerwear','coat',       6, -10,  10, TRUE, TRUE, TRUE),
('outerwear','softshell',  4,  -5,  15, TRUE, TRUE, TRUE),
('outerwear','raincoat',   3,  -5,  15, TRUE, TRUE, FALSE),

-- upper (6)
('upper','tshirt',         1,  15,  30, TRUE, TRUE, FALSE),
('upper','longsleeve',     2,  10,  22, TRUE, TRUE, FALSE),
('upper','shirt',          2,  10,  25, TRUE, TRUE, FALSE),
('upper','hoodie',         4,   0,  15, TRUE, TRUE, TRUE),
('upper','sweater',        5,  -5,  12, TRUE, TRUE, TRUE),
('upper','thermal_top',    7, -25,   5, TRUE, TRUE, TRUE),

-- lower (5)
('lower','shorts',         1,  18,  35, TRUE, TRUE, FALSE),
('lower','jeans',          3,   5,  20, TRUE, TRUE, TRUE),
('lower','pants',          3,   0,  22, TRUE, TRUE, TRUE),
('lower','thermal_pants',  7, -25,   5, TRUE, TRUE, TRUE),
('lower','skirt',          2,  10,  25, TRUE, TRUE, FALSE),

-- footwear (5)
('footwear','sandals',     1,  15,  35, TRUE, FALSE, FALSE),
('footwear','sneakers',    2,   5,  25, TRUE, TRUE, TRUE),
('footwear','boots',       5,  -5,  15, TRUE, TRUE, TRUE),
('footwear','winter_boots',8, -30,   5, TRUE, TRUE, TRUE),
('footwear','loafers',     2,  10,  25, TRUE, FALSE, FALSE),

-- accessory (5)
('accessory','hat',        3, -10,  10, TRUE, TRUE, TRUE),
('accessory','scarf',      4, -20,   5, TRUE, TRUE, TRUE),
('accessory','gloves',     4, -20,   5, TRUE, TRUE, TRUE),
('accessory','umbrella',   1,   0,  25, TRUE, FALSE, FALSE),
('accessory','bag',        1, -35,  35, TRUE, TRUE, TRUE)
ON CONFLICT (category, subcategory) DO UPDATE SET
  warmth_min    = EXCLUDED.warmth_min,
  temp_min_reco = EXCLUDED.temp_min_reco,
  temp_max_reco = EXCLUDED.temp_max_reco,
  rain_ok       = EXCLUDED.rain_ok,
  snow_ok       = EXCLUDED.snow_ok,
  wind_ok       = EXCLUDED.wind_ok;