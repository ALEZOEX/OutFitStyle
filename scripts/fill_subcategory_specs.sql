-- Заполнение subcategory_specs
-- Категория: upper (верх)
INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco) VALUES
('upper', 'футболка', 1, 20, 35),
('upper', 'рубашка', 1, 15, 30),
('upper', 'свитер', 5, 5, 15),
('upper', 'худи', 4, 10, 20),
('upper', 'куртка', 6, 0, 15),
('upper', 'пальто', 7, -5, 10),
('upper', 'жилет', 3, 10, 20),
('upper', 'толстовка', 4, 10, 20),
('upper', 'кардиган', 4, 10, 20),
('upper', 'джемпер', 5, 5, 15);

-- Категория: lower (низ)
INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco) VALUES
('lower', 'джинсы', 3, 5, 25),
('lower', 'брюки', 2, 10, 25),
('lower', 'шорты', 1, 20, 35),
('lower', 'юбка', 2, 15, 30),
('lower', 'легинсы', 3, 10, 25),
('lower', 'штаны', 3, 5, 20),
('lower', 'чинос', 2, 10, 25);

-- Категория: footwear (обувь)
INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco) VALUES
('footwear', 'кроссовки', 2, 10, 25),
('footwear', 'ботинки', 5, 0, 15),
('footwear', 'туфли', 1, 15, 30),
('footwear', 'сандалии', 1, 20, 35),
('footwear', 'кеды', 2, 10, 25),
('footwear', 'сапоги', 6, -10, 5),
('footwear', 'лоферы', 2, 10, 25);

-- Категория: accessory (аксессуары)
INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco) VALUES
('accessory', 'шапка', 3, -10, 10),
('accessory', 'шарф', 3, -5, 10),
('accessory', 'перчатки', 4, -10, 10),
('accessory', 'ремень', 1, 0, 35),
('accessory', 'сумка', 1, 0, 35),
('accessory', 'носки', 2, 0, 30),
('accessory', 'колготки', 3, 0, 20);
