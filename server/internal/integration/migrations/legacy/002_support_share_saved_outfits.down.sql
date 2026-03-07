-- 002_support_share_saved_outfits.down.sql

DROP TABLE IF EXISTS app_feedback CASCADE;

DROP TABLE IF EXISTS support_messages CASCADE;
DROP TABLE IF EXISTS support_tickets CASCADE;

DROP TABLE IF EXISTS shared_outfits CASCADE;
DROP TABLE IF EXISTS saved_outfits CASCADE;