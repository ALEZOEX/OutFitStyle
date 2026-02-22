-- Тестовые данные для clothing_items с UUID
-- Заполнение каталога вещей

-- Генерируем тестовые вещи с UUID
DO $$
DECLARE
    item_id UUID;
    i INTEGER;
BEGIN
    -- Удалим старые тестовые данные
    DELETE FROM wardrobe_items WHERE clothing_item_id IN (SELECT id FROM clothing_items WHERE source = 'test_seed');
    DELETE FROM clothing_items WHERE source = 'test_seed';

    -- Создадим 50 тестовых вещей
    FOR i IN 1..50 LOOP
        item_id := gen_random_uuid();
        
        INSERT INTO clothing_items (
            id, name, description, category, subcategory, gender, style, usage, season,
            base_colour, warmth_level, formality_level, min_temp, max_temp,
            rain_ok, snow_ok, wind_ok, materials, source, is_owned, is_active, created_at
        ) VALUES (
            item_id,
            'Тестовая вещь ' || i,
            'Описание тестовой вещи',
            (ARRAY['outerwear','upper','lower','footwear','accessory'])[floor(random()*5+1)],
            'basic',
            'unisex',
            (ARRAY['casual','sport','street','classic','business'])[floor(random()*5+1)],
            (ARRAY['daily','work','formal','sport','outdoor','travel','party'])[floor(random()*7+1)],
            (ARRAY['winter','spring','summer','autumn','all'])[floor(random()*5+1)],
            (ARRAY['black','white','gray','navy','beige','brown','green','blue','red'])[floor(random()*9+1)],
            floor(random()*10+1)::INTEGER,
            floor(random()*5+1)::INTEGER,
            -20 + floor(random()*40)::INTEGER,
            10 + floor(random()*30)::INTEGER,
            true, true, true,
            ARRAY['cotton'],
            'synthetic',
            false,
            true,
            now()
        );
    END LOOP;

    RAISE NOTICE 'Создано 50 тестовых вещей в каталоге';
END $$;

-- Проверка результата
SELECT source, COUNT(*) as count FROM clothing_items GROUP BY source ORDER BY count DESC;
