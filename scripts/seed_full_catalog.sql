-- Заполнение subcategory_specs и clothing_items

-- 1. Заполняем subcategory_specs
INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok) VALUES
-- outerwear
('outerwear', 'jacket', 3, 5, 20, true, false, true),
('outerwear', 'coat', 5, 0, 15, true, true, true),
('outerwear', 'parka', 7, -10, 5, true, true, true),
('outerwear', 'vest', 2, 10, 20, false, false, true),
('outerwear', 'poncho', 3, 5, 18, true, false, true),
-- upper
('upper', 'tshirt', 1, 15, 30, false, false, false),
('upper', 'shirt', 2, 10, 25, false, false, false),
('upper', 'blouse', 2, 10, 25, false, false, false),
('upper', 'sweater', 5, 5, 15, false, false, true),
('upper', 'hoodie', 4, 10, 20, false, false, true),
('upper', 'blazer', 3, 10, 20, false, false, false),
('upper', 'cardigan', 4, 5, 18, false, false, true),
-- lower
('lower', 'jeans', 4, 5, 25, false, false, true),
('lower', 'trousers', 3, 10, 25, false, false, true),
('lower', 'shorts', 1, 20, 35, false, false, false),
('lower', 'skirt', 2, 15, 28, false, false, false),
('lower', 'leggings', 3, 5, 20, false, false, true),
('lower', 'joggers', 3, 10, 22, false, false, true),
-- footwear
('footwear', 'sneakers', 2, 10, 25, true, false, true),
('footwear', 'boots', 6, -5, 15, true, true, true),
('footwear', 'sandals', 1, 20, 35, false, false, false),
('footwear', 'loafers', 2, 10, 25, false, false, false),
('footwear', 'heels', 1, 15, 28, false, false, false),
-- accessory
('accessory', 'scarf', 4, -5, 15, false, false, true),
('accessory', 'hat', 3, -10, 15, false, false, true),
('accessory', 'gloves', 5, -15, 10, false, true, true),
('accessory', 'belt', 1, 5, 30, false, false, false),
('accessory', 'sunglasses', 1, 15, 35, false, false, false)
ON CONFLICT (category, subcategory) DO NOTHING;

-- 2. Заполняем clothing_items тестовыми вещами (100 штук)
-- outerwear: jacket, coat, parka, vest, poncho
INSERT INTO clothing_items (id, name, description, category, subcategory, gender, style, usage, season, base_colour, warmth_level, formality_level, min_temp, max_temp, rain_ok, snow_ok, wind_ok, materials, fit, pattern, source, is_owned, is_active, created_at)
SELECT gen_random_uuid(), 'Тест ' || g.i || ' jacket', 'Описание', 'outerwear', 'jacket', 'unisex', (ARRAY['casual','sport','street','classic','business'])[floor(random()*5+1)::INTEGER], (ARRAY['daily','work','formal','sport','outdoor'])[floor(random()*5+1)::INTEGER], (ARRAY['winter','spring','autumn','all'])[floor(random()*4+1)::INTEGER], (ARRAY['black','gray','navy','brown','green'])[floor(random()*5+1)::INTEGER], floor(random()*10+1)::INTEGER, floor(random()*5+1)::INTEGER, -10+floor(random()*20)::INTEGER, 15+floor(random()*15)::INTEGER, true, false, true, ARRAY['polyester'], 'regular', 'solid', 'synthetic', false, true, now() FROM generate_series(1, 20) AS g(i);

-- upper: tshirt, shirt, sweater, hoodie, blazer
INSERT INTO clothing_items (id, name, description, category, subcategory, gender, style, usage, season, base_colour, warmth_level, formality_level, min_temp, max_temp, rain_ok, snow_ok, wind_ok, materials, fit, pattern, source, is_owned, is_active, created_at)
SELECT gen_random_uuid(), 'Тест ' || g.i || ' tshirt', 'Описание', 'upper', 'tshirt', 'unisex', (ARRAY['casual','sport','street','classic','business'])[floor(random()*5+1)::INTEGER], (ARRAY['daily','work','sport','party'])[floor(random()*4+1)::INTEGER], (ARRAY['spring','summer','all'])[floor(random()*3+1)::INTEGER], (ARRAY['white','black','gray','blue','red','green'])[floor(random()*6+1)::INTEGER], floor(random()*5+1)::INTEGER, floor(random()*3+1)::INTEGER, 15+floor(random()*10)::INTEGER, 25+floor(random()*10)::INTEGER, false, false, false, ARRAY['cotton'], 'regular', 'solid', 'synthetic', false, true, now() FROM generate_series(1, 20) AS g(i);

INSERT INTO clothing_items (id, name, description, category, subcategory, gender, style, usage, season, base_colour, warmth_level, formality_level, min_temp, max_temp, rain_ok, snow_ok, wind_ok, materials, fit, pattern, source, is_owned, is_active, created_at)
SELECT gen_random_uuid(), 'Тест ' || g.i || ' sweater', 'Описание', 'upper', 'sweater', 'unisex', (ARRAY['casual','classic','business','smart_casual'])[floor(random()*4+1)::INTEGER], (ARRAY['daily','work','outdoor'])[floor(random()*3+1)::INTEGER], (ARRAY['spring','autumn','winter','all'])[floor(random()*4+1)::INTEGER], (ARRAY['gray','navy','brown','black','beige'])[floor(random()*5+1)::INTEGER], floor(random()*10+1)::INTEGER, floor(random()*5+1)::INTEGER, 5+floor(random()*10)::INTEGER, 15+floor(random()*10)::INTEGER, false, false, true, ARRAY['wool','cotton'], 'regular', 'solid', 'synthetic', false, true, now() FROM generate_series(1, 20) AS g(i);

-- lower: jeans, trousers, shorts, joggers
INSERT INTO clothing_items (id, name, description, category, subcategory, gender, style, usage, season, base_colour, warmth_level, formality_level, min_temp, max_temp, rain_ok, snow_ok, wind_ok, materials, fit, pattern, source, is_owned, is_active, created_at)
SELECT gen_random_uuid(), 'Тест ' || g.i || ' jeans', 'Описание', 'lower', 'jeans', 'unisex', (ARRAY['casual','street','classic','smart_casual'])[floor(random()*4+1)::INTEGER], (ARRAY['daily','work','outdoor'])[floor(random()*3+1)::INTEGER], (ARRAY['spring','summer','autumn','all'])[floor(random()*4+1)::INTEGER], (ARRAY['blue','black','gray','navy'])[floor(random()*4+1)::INTEGER], floor(random()*10+1)::INTEGER, floor(random()*5+1)::INTEGER, 5+floor(random()*15)::INTEGER, 25+floor(random()*10)::INTEGER, false, false, true, ARRAY['cotton','denim'], (ARRAY['slim','regular','relaxed'])[floor(random()*3+1)::INTEGER], 'solid', 'synthetic', false, true, now() FROM generate_series(1, 20) AS g(i);

-- footwear: sneakers, boots, sandals
INSERT INTO clothing_items (id, name, description, category, subcategory, gender, style, usage, season, base_colour, warmth_level, formality_level, min_temp, max_temp, rain_ok, snow_ok, wind_ok, materials, fit, pattern, source, is_owned, is_active, created_at)
SELECT gen_random_uuid(), 'Тест ' || g.i || ' sneakers', 'Описание', 'footwear', 'sneakers', 'unisex', (ARRAY['casual','sport','street'])[floor(random()*3+1)::INTEGER], (ARRAY['daily','sport','outdoor'])[floor(random()*3+1)::INTEGER], (ARRAY['spring','summer','autumn','all'])[floor(random()*4+1)::INTEGER], (ARRAY['white','black','gray','blue'])[floor(random()*4+1)::INTEGER], floor(random()*10+1)::INTEGER, floor(random()*3+1)::INTEGER, 10+floor(random()*10)::INTEGER, 25+floor(random()*10)::INTEGER, true, false, true, ARRAY['leather','synthetic'], 'regular', 'solid', 'synthetic', false, true, now() FROM generate_series(1, 20) AS g(i);

-- Проверка результата
SELECT source, COUNT(*) as count FROM clothing_items GROUP BY source ORDER BY count DESC;
SELECT category, subcategory, COUNT(*) as count FROM clothing_items GROUP BY category, subcategory ORDER BY count DESC LIMIT 10;
