-- 002_support_share_saved_outfits.up.sql
-- Adds: saved_outfits, shared_outfits, support_tickets/messages, app_feedback

-- =========================
-- SAVED OUTFITS
-- =========================
CREATE TABLE IF NOT EXISTS saved_outfits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    name VARCHAR(100) NOT NULL,
    description TEXT,

    items JSONB NOT NULL,

    occasions TEXT[],
    seasons TEXT[],
    min_temp INTEGER,
    max_temp INTEGER,

    thumbnail_url TEXT,
    is_favorite BOOLEAN DEFAULT false,
    times_worn INTEGER DEFAULT 0,
    last_worn_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_saved_outfits_user ON saved_outfits(user_id);

-- =========================
-- SHARED OUTFITS
-- =========================
CREATE TABLE IF NOT EXISTS shared_outfits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    recommendation_id UUID REFERENCES recommendations(id),
    saved_outfit_id UUID REFERENCES saved_outfits(id),

    share_code VARCHAR(20) UNIQUE NOT NULL,

    is_public BOOLEAN DEFAULT true,
    show_user_name BOOLEAN DEFAULT false,

    views_count INTEGER DEFAULT 0,
    saves_count INTEGER DEFAULT 0,

    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT shared_outfits_one_ref_check
      CHECK (
        (recommendation_id IS NOT NULL AND saved_outfit_id IS NULL)
        OR (recommendation_id IS NULL AND saved_outfit_id IS NOT NULL)
      )
);

CREATE INDEX IF NOT EXISTS idx_shared_outfits_user ON shared_outfits(user_id);
CREATE INDEX IF NOT EXISTS idx_shared_outfits_code ON shared_outfits(share_code);

-- =========================
-- SUPPORT
-- =========================
CREATE TABLE IF NOT EXISTS support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,

    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    subject VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal',

    status VARCHAR(20) DEFAULT 'open',
    assigned_to UUID REFERENCES users(id),

    contact_email VARCHAR(255),

    app_version VARCHAR(20),
    device_info JSONB,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_support_tickets_user ON support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON support_tickets(status);

CREATE TABLE IF NOT EXISTS support_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,

    sender_type VARCHAR(20) NOT NULL, -- 'user'|'admin'|'system'
    sender_id UUID REFERENCES users(id),

    message TEXT NOT NULL,
    attachments JSONB,

    is_internal BOOLEAN DEFAULT false,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_support_messages_ticket ON support_messages(ticket_id);

-- updated_at trigger for support_tickets
DO $$ BEGIN
    CREATE TRIGGER update_support_tickets_updated_at
    BEFORE UPDATE ON support_tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- =========================
-- APP FEEDBACK
-- =========================
CREATE TABLE IF NOT EXISTS app_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,

    type VARCHAR(20) NOT NULL, -- bug|idea|other etc

    screen VARCHAR(100),
    app_version VARCHAR(20),
    device_info JSONB,

    message TEXT NOT NULL,
    attachments TEXT[],

    status VARCHAR(20) DEFAULT 'new',
    response TEXT,
    responded_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_feedback_user ON app_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_app_feedback_created ON app_feedback(created_at);