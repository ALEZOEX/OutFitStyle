-- 000001_init.up.sql
-- Базовая схема OutfitStyle (UUID everywhere). Для golang-migrate.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- updated_at helper
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- subcategory specs
CREATE TABLE IF NOT EXISTS subcategory_specs (
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

-- users
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  username TEXT UNIQUE,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,

  first_name TEXT,
  last_name TEXT,
  date_of_birth DATE,
  gender TEXT,
  location TEXT,

  preferences JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- clothing_items (каталог/вещи)
CREATE TABLE IF NOT EXISTS clothing_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  name TEXT NOT NULL,
  description TEXT,

  category    TEXT NOT NULL,
  subcategory TEXT NOT NULL,

  gender TEXT NOT NULL DEFAULT 'unisex' CHECK (gender IN ('unisex')),

  style  TEXT NOT NULL CHECK (style IN ('casual','sport','street','classic','business','smart_casual','outdoor')),
  usage  TEXT NOT NULL CHECK (usage IN ('daily','work','formal','sport','outdoor','travel','party')),
  season TEXT NOT NULL CHECK (season IN ('winter','spring','summer','autumn','all')),

  base_colour TEXT CHECK (base_colour IN ('black','white','gray','navy','beige','brown','green','blue','red','pink','yellow','orange','purple')),

  formality_level SMALLINT CHECK (formality_level BETWEEN 1 AND 5),
  warmth_level    SMALLINT CHECK (warmth_level BETWEEN 1 AND 10),

  min_temp SMALLINT,
  max_temp SMALLINT,
  CONSTRAINT clothing_items_temp_check CHECK (min_temp IS NULL OR max_temp IS NULL OR min_temp <= max_temp),

  rain_ok BOOLEAN NOT NULL DEFAULT TRUE,
  snow_ok BOOLEAN NOT NULL DEFAULT TRUE,
  wind_ok BOOLEAN NOT NULL DEFAULT TRUE,

  materials TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],

  fit     TEXT CHECK (fit IN ('slim','regular','relaxed','oversized')),
  pattern TEXT CHECK (pattern IN ('solid','striped','checked','printed','camo')),

  brand TEXT,

  image_url TEXT,
  thumbnail_url TEXT,
  icon_emoji TEXT,

  source TEXT NOT NULL DEFAULT 'synthetic'
    CHECK (source IN ('synthetic','user','partner','manual')),

  owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
  is_owned BOOLEAN NOT NULL DEFAULT FALSE,

  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT clothing_items_subcategory_fk
    FOREIGN KEY (category, subcategory)
    REFERENCES subcategory_specs (category, subcategory)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

DROP TRIGGER IF EXISTS trg_clothing_items_updated_at ON clothing_items;
CREATE TRIGGER trg_clothing_items_updated_at
BEFORE UPDATE ON clothing_items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- wardrobe_items (личные вещи пользователя)
CREATE TABLE IF NOT EXISTS wardrobe_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  clothing_item_id UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,

  custom_name TEXT,
  notes TEXT,
  tags TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],

  purchase_date DATE,
  purchase_price NUMERIC(12,2),
  purchase_currency TEXT,

  wear_count INT NOT NULL DEFAULT 0,
  last_worn_at TIMESTAMPTZ,

  is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  condition TEXT NOT NULL DEFAULT 'good',

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(user_id, clothing_item_id)
);

DROP TRIGGER IF EXISTS trg_wardrobe_items_updated_at ON wardrobe_items;
CREATE TRIGGER trg_wardrobe_items_updated_at
BEFORE UPDATE ON wardrobe_items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- weather_data
CREATE TABLE IF NOT EXISTS weather_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  location TEXT NOT NULL,

  temperature DOUBLE PRECISION NOT NULL,
  feels_like DOUBLE PRECISION,
  weather_condition TEXT,
  humidity INT,
  wind_speed DOUBLE PRECISION,

  observed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- recommendations (снимок рекомендации)
CREATE TABLE IF NOT EXISTS recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  weather_id UUID REFERENCES weather_data(id) ON DELETE SET NULL,

  outfit_score NUMERIC(6,4),
  algorithm_used TEXT,
  ml_powered BOOLEAN NOT NULL DEFAULT FALSE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- recommendation_items (элементы рекомендации)
CREATE TABLE IF NOT EXISTS recommendation_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  recommendation_id UUID NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
  clothing_item_id UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,

  name TEXT,
  category TEXT,
  icon_emoji TEXT,

  ml_score NUMERIC(6,4),
  confidence NUMERIC(6,4),
  position INT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(recommendation_id, clothing_item_id)
);

-- favorites / achievements / ratings
CREATE TABLE IF NOT EXISTS user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recommendation_id UUID NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, recommendation_id)
);

CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, achievement_id)
);

CREATE TABLE IF NOT EXISTS user_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recommendation_id UUID NOT NULL REFERENCES recommendations(id) ON DELETE CASCADE,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  feedback TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, recommendation_id)
);

-- indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE INDEX IF NOT EXISTS idx_clothing_items_cat_subcat ON clothing_items(category, subcategory);
CREATE INDEX IF NOT EXISTS idx_clothing_items_cat_warmth ON clothing_items(category, warmth_level);
CREATE INDEX IF NOT EXISTS idx_clothing_items_temp ON clothing_items(min_temp, max_temp);

CREATE INDEX IF NOT EXISTS idx_wardrobe_items_user ON wardrobe_items(user_id);
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_item ON wardrobe_items(clothing_item_id);

CREATE INDEX IF NOT EXISTS idx_recommendations_user_created_at ON recommendations(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_weather_location_time ON weather_data(location, observed_at DESC);
