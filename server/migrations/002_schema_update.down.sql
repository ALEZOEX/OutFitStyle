-- 002_schema_update.down.sql

ALTER TABLE recommendations
DROP COLUMN IF EXISTS temperature,
  DROP COLUMN IF EXISTS weather,
  DROP COLUMN IF EXISTS outfit_score,
  DROP COLUMN IF EXISTS algorithm,
  DROP COLUMN IF EXISTS location,
  DROP COLUMN IF EXISTS min_temp,
  DROP COLUMN IF EXISTS max_temp,
  DROP COLUMN IF EXISTS will_rain,
  DROP COLUMN IF EXISTS will_snow;

DROP TABLE IF EXISTS outfit_plans;