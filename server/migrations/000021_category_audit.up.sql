-- 000021_category_audit.up.sql
-- Creates category_audit table for tracking category changes

CREATE TABLE category_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    old_category TEXT NOT NULL,
    new_category TEXT NOT NULL,
    changed_by TEXT NOT NULL, -- 'import', 'ml_classifier', or user_id
    changed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    reason TEXT,
    confidence NUMERIC(4,3), -- ML confidence score if applicable

    CONSTRAINT category_audit_category_check
        CHECK (old_category IN ('outerwear','upper','lower','footwear','accessory') AND
               new_category IN ('outerwear','upper','lower','footwear','accessory'))
);

CREATE INDEX idx_category_audit_item ON category_audit(item_id);
CREATE INDEX idx_category_audit_changed_at ON category_audit(changed_at DESC);
CREATE INDEX idx_category_audit_changed_by ON category_audit(changed_by);
