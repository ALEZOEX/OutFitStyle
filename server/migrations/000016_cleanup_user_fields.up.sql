-- 000016_cleanup_user_fields.up.sql
-- Удаление дублирующих колонок и синхронизация полей верификации

-- ============================================================================
-- 1. Удаляем дублирующую колонку date_of_birth
-- ============================================================================
-- Копируем оставшиеся значения из date_of_birth в birth_date (если есть)
UPDATE public.users
SET birth_date = date_of_birth
WHERE birth_date IS NULL AND date_of_birth IS NOT NULL;

-- Удаляем старую колонку date_of_birth
ALTER TABLE public.users DROP COLUMN IF EXISTS date_of_birth;

-- ============================================================================
-- 2. Синхронизируем is_verified и verified_at
-- ============================================================================
-- Устанавливаем verified_at для всех верифицированных пользователей
UPDATE public.users
SET verified_at = created_at
WHERE is_verified = TRUE AND verified_at IS NULL;

-- Устанавливаем is_verified = TRUE для всех, у кого есть verified_at
UPDATE public.users
SET is_verified = TRUE
WHERE verified_at IS NOT NULL AND is_verified = FALSE;

-- ============================================================================
-- 3. Добавляем триггер для авто-синхронизации is_verified и verified_at
-- ============================================================================
CREATE OR REPLACE FUNCTION sync_user_verification_fields()
RETURNS TRIGGER AS $$
BEGIN
  -- Если is_verified установлен в TRUE, но verified_at пустой
  IF NEW.is_verified = TRUE AND NEW.verified_at IS NULL THEN
    NEW.verified_at := NOW();
  END IF;

  -- Если verified_at установлен, но is_verified = FALSE
  IF NEW.verified_at IS NOT NULL AND NEW.is_verified = FALSE THEN
    NEW.is_verified := TRUE;
  END IF;

  -- Если оба поля "сброшены"
  IF NEW.verified_at IS NULL AND NEW.is_verified = TRUE THEN
    NEW.is_verified := FALSE;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_user_verification_fields ON public.users;
CREATE TRIGGER trg_sync_user_verification_fields
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION sync_user_verification_fields();

-- ============================================================================
-- 4. Добавляем комментарий к birth_date
-- ============================================================================
COMMENT ON COLUMN public.users.birth_date IS 'Дата рождения пользователя (единое поле, date_of_birth удалена)';
