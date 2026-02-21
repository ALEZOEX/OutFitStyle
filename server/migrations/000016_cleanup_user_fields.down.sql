-- 000016_cleanup_user_fields.down.sql
-- Откат изменений: восстановление date_of_birth и удаление синхронизации

-- ============================================================================
-- 1. Восстанавливаем колонку date_of_birth
-- ============================================================================
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS date_of_birth DATE;

-- Копируем значения из birth_date обратно в date_of_birth
UPDATE public.users
SET date_of_birth = birth_date
WHERE date_of_birth IS NULL AND birth_date IS NOT NULL;

-- ============================================================================
-- 2. Удаляем триггер синхронизации
-- ============================================================================
DROP TRIGGER IF EXISTS trg_sync_user_verification_fields ON public.users;
DROP FUNCTION IF EXISTS sync_user_verification_fields();

-- ============================================================================
-- 3. Откатываем синхронизацию is_verified/verified_at
-- ============================================================================
-- Сбрасываем is_verified в FALSE для всех (так как было изначально)
-- (опционально, можно оставить как есть)
