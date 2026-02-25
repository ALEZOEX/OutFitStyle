-- ============================================
-- Скрипт проверки исправлений гардероба и достижений
-- Запуск: psql -U outfitstyle -d outfitstyle -f scripts/check_fixes.sql
-- ============================================

\echo '========================================'
\echo 'ПРОВЕРКА ИСПРАВЛЕНИЙ БД'
\echo '========================================'

\echo ''
\echo '1. Таблица wardrobe_items - поле item_data'
\echo '-------------------------------------------'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'wardrobe_items' AND column_name = 'item_data';

\echo ''
\echo '2. Статистика wardrobe_items'
\echo '-----------------------------'
SELECT 
  COUNT(*) as total_items,
  COUNT(*) FILTER (WHERE item_data IS NOT NULL) as with_item_data,
  COUNT(*) FILTER (WHERE item_data IS NULL) as without_item_data
FROM wardrobe_items;

\echo ''
\echo '3. Таблица achievements - структура'
\echo '------------------------------------'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'achievements'
ORDER BY ordinal_position;

\echo ''
\echo '4. Достижения (активные)'
\echo '------------------------'
SELECT code, name, icon_emoji, points, category, is_active
FROM achievements
WHERE is_active = true
ORDER BY category, sort_order
LIMIT 10;

\echo ''
\echo '5. Таблица user_achievements - структура'
\echo '-----------------------------------------'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_achievements'
ORDER BY ordinal_position;

\echo ''
\echo '6. Статистика user_achievements по статусам'
\echo '--------------------------------------------'
SELECT status, COUNT(*) as count
FROM user_achievements
GROUP BY status;

\echo ''
\echo '7. Проверка индексов wardrobe_items'
\echo '------------------------------------'
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'wardrobe_items'
ORDER BY indexname;

\echo ''
\echo '8. Проверка индексов achievements'
\echo '----------------------------------'
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'achievements'
ORDER BY indexname;

\echo ''
\echo '========================================'
\echo 'ПРОВЕРКА ЗАВЕРШЕНА'
\echo '========================================'
