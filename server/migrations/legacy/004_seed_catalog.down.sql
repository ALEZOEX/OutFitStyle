-- 004_seed_catalog.down.sql

DELETE FROM clothing_items
WHERE id IN (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6'
);

DELETE FROM partners WHERE code = 'demo';

DELETE FROM subcategory_specs
WHERE subcategory IN ('coat','raincoat','tshirt','hoodie','jeans','pants','sneakers','boots','hat','umbrella');