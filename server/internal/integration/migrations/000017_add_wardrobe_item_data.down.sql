-- 000017_add_wardrobe_item_data.down.sql
-- Откат миграции: удаление поля item_data

DROP INDEX IF EXISTS idx_wardrobe_items_item_data_gin;

ALTER TABLE wardrobe_items
DROP COLUMN IF EXISTS item_data;
