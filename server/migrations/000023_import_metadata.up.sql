-- 000023_import_metadata.up.sql
-- Creates import_metadata table for tracking catalog imports

CREATE TABLE import_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    total_items INT NOT NULL DEFAULT 0,
    successful_items INT NOT NULL DEFAULT 0,
    skipped_items INT NOT NULL DEFAULT 0,
    validation_report_path TEXT,
    status TEXT NOT NULL DEFAULT 'running'
        CHECK (status IN ('running', 'completed', 'failed'))
);

CREATE INDEX idx_import_metadata_completed_at ON import_metadata(completed_at DESC);
CREATE INDEX idx_import_metadata_status ON import_metadata(status);
