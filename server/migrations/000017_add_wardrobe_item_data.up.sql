-- 000017_add_wardrobe_item_data.up.sql
-- Добавление поля item_data для хранения денормализованных данных clothing_item
-- Это позволяет загружать вещи гардероба без JOIN с clothing_items

-- Добавляем поле item_data в wardrobe_items
ALTER TABLE wardrobe_items
ADD COLUMN IF NOT EXISTS item_data JSONB;

-- Индекс для быстрого поиска по данным в item_data
CREATE INDEX IF NOT EXISTS idx_wardrobe_items_item_data_gin
ON wardrobe_items USING gin(item_data);

-- Заполняем существующие записи данными из clothing_items
-- Это денормализация для производительности
UPDATE wardrobe_items wi
SET item_data = jsonb_build_object(
    'id', ci.id,
    'name', ci.name,
    'category', ci.category,
    'subcategory', ci.subcategory,
    'style', ci.style,
    'season', ci.season,
    'base_colour', ci.base_colour,
    'pattern', ci.pattern,
    'fit', ci.fit,
    'gender', ci.gender,
    'source', ci.source,
    'is_owned', ci.is_owned,
    'is_active', ci.is_active,
    'image_url', ci.image_url,
    'icon_emoji', ci.icon_emoji
)
FROM clothing_items ci
WHERE wi.clothing_item_id = ci.id
  AND wi.item_data IS NULL;

COMMENT ON COLUMN wardrobe_items.item_data IS 'Денормализованные данные clothing_item для быстрого доступа без JOIN';
