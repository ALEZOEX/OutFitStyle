-- 004_seed_catalog.up.sql
-- Заполняет subcategory_specs + несколько каталогов clothing_items (синтетических) и один образец партнера.

-- =========================
-- subcategory_specs
-- =========================
INSERT INTO subcategory_specs (
  subcategory, category,
  typical_min_temp, typical_max_temp, typical_warmth_level,
  typical_formality, typical_styles,
  default_rain_ok, default_snow_ok, default_wind_ok,
  layer_position, can_be_standalone,
  description, icon_emoji
) VALUES
('coat',         'outerwear', -10,  10, 6, 3, ARRAY['classic','smart_casual','business'], TRUE, TRUE, TRUE, 5, TRUE, 'Пальто', '🧥'),
('raincoat',     'outerwear',  -5,  15, 3, 2, ARRAY['casual','classic'], TRUE, FALSE, FALSE, 5, TRUE, 'Дождевик', '🌧️'),
('tshirt',       'upper',      15,  30, 1, 1, ARRAY['casual','street','sport'], FALSE, FALSE, FALSE, 2, TRUE, 'Футболка', '👕'),
('hoodie',       'upper',       0,  18, 4, 1, ARRAY['casual','street'], TRUE, TRUE, TRUE, 3, TRUE, 'Худи', '🧢'),
('jeans',        'lower',       5,  22, 3, 1, ARRAY['casual','street'], TRUE, TRUE, TRUE, 1, TRUE, 'Джинсы', '👖'),
('pants',        'lower',       0,  22, 3, 3, ARRAY['business','classic','smart_casual'], TRUE, TRUE, TRUE, 1, TRUE, 'Брюки', '👖'),
('sneakers',     'footwear',    5,  25, 2, 1, ARRAY['casual','sport','street'], TRUE, TRUE, TRUE, 0, TRUE, 'Кроссовки', '👟'),
('boots',        'footwear',   -5,  15, 5, 2, ARRAY['casual','outdoor'], TRUE, TRUE, TRUE, 0, TRUE, 'Ботинки', '🥾'),
('hat',          'accessory', -10,  10, 3, 1, ARRAY['casual','outdoor'], TRUE, TRUE, TRUE, 6, TRUE, 'Шапка', '🧢'),
('umbrella',     'accessory',   0,  25, 1, 1, ARRAY['casual','classic'], TRUE, FALSE, FALSE, 6, TRUE, 'Зонт', '☂️')
ON CONFLICT (subcategory) DO UPDATE SET
  category = EXCLUDED.category,
  typical_min_temp = EXCLUDED.typical_min_temp,
  typical_max_temp = EXCLUDED.typical_max_temp,
  typical_warmth_level = EXCLUDED.typical_warmth_level,
  typical_formality = EXCLUDED.typical_formality,
  typical_styles = EXCLUDED.typical_styles,
  default_rain_ok = EXCLUDED.default_rain_ok,
  default_snow_ok = EXCLUDED.default_snow_ok,
  default_wind_ok = EXCLUDED.default_wind_ok,
  layer_position = EXCLUDED.layer_position,
  can_be_standalone = EXCLUDED.can_be_standalone,
  description = EXCLUDED.description,
  icon_emoji = EXCLUDED.icon_emoji;

-- =========================
-- partners (один демо)
-- =========================
INSERT INTO partners (id, name, code, affiliate_url_template, is_active)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'Demo Partner',
  'demo',
  'https://shop.example.com/item/{sku}?aff=outfitstyle',
  TRUE
)
ON CONFLICT (code) DO NOTHING;

-- =========================
-- clothing_items (синтетический каталог)
-- Использовать фиксированные UUID для идемпотентности
-- =========================
INSERT INTO clothing_items (
  id, name, description,
  category, subcategory,
  min_temp, max_temp, warmth_level,
  rain_ok, snow_ok, wind_ok,
  style, formality_level, base_colour, pattern, fit,
  gender, season,
  usage, materials, brand,
  icon_emoji,
  source, owner_id, is_owned,
  partner_id, partner_sku, partner_url, partner_price, partner_currency,
  is_active
) VALUES
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
  'Classic Coat', 'Тёплое классическое пальто',
  'outerwear','coat',
  -10, 10, 6,
  TRUE, TRUE, TRUE,
  'classic', 4, 'black', 'solid', 'regular',
  'unisex','autumn',
  ARRAY['work','daily'], ARRAY['wool'], 'OutfitStyle',
  '🧥',
  'synthetic', NULL, FALSE,
  NULL, NULL, NULL, NULL, NULL,
  TRUE
),
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
  'Raincoat', 'Лёгкий дождевик',
  'outerwear','raincoat',
  -5, 15, 3,
  TRUE, FALSE, FALSE,
  'casual', 2, 'navy', 'solid', 'regular',
  'unisex','spring',
  ARRAY['daily','travel'], ARRAY['polyester'], 'OutfitStyle',
  '🌧️',
  'synthetic', NULL, FALSE,
  '11111111-1111-1111-1111-111111111111', 'RC-001',
  'https://shop.example.com/raincoat/RC-001',
  3999, 'RUB',
  TRUE
),
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
  'Basic T-Shirt', 'Хлопковая футболка',
  'upper','tshirt',
  15, 30, 1,
  FALSE, FALSE, FALSE,
  'casual', 1, 'white', 'solid', 'regular',
  'unisex','summer',
  ARRAY['daily'], ARRAY['cotton'], 'OutfitStyle',
  '👕',
  'synthetic', NULL, FALSE,
  NULL, NULL, NULL, NULL, NULL,
  TRUE
),
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
  'Blue Jeans', 'Универсальные джинсы',
  'lower','jeans',
  5, 22, 3,
  TRUE, TRUE, TRUE,
  'street', 2, 'blue', 'solid', 'regular',
  'unisex','all',
  ARRAY['daily'], ARRAY['denim'], 'OutfitStyle',
  '👖',
  'synthetic', NULL, FALSE,
  NULL, NULL, NULL, NULL, NULL,
  TRUE
),
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
  'Sneakers', 'Кроссовки на каждый день',
  'footwear','sneakers',
  5, 25, 2,
  TRUE, TRUE, TRUE,
  'sport', 1, 'white', 'solid', 'regular',
  'unisex','all',
  ARRAY['daily','sport'], ARRAY['leather'], 'OutfitStyle',
  '👟',
  'synthetic', NULL, FALSE,
  NULL, NULL, NULL, NULL, NULL,
  TRUE
),
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
  'Warm Hat', 'Тёплая шапка',
  'accessory','hat',
  -10, 10, 3,
  TRUE, TRUE, TRUE,
  'outdoor', 1, 'gray', 'solid', 'regular',
  'unisex','winter',
  ARRAY['daily','outdoor'], ARRAY['wool'], 'OutfitStyle',
  '🧢',
  'synthetic', NULL, FALSE,
  NULL, NULL, NULL, NULL, NULL,
  TRUE
)
ON CONFLICT (id) DO NOTHING;