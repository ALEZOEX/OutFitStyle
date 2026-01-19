-- 003_trips.up.sql

CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    name VARCHAR(100) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    destination_lat DECIMAL(10, 8),
    destination_lon DECIMAL(11, 8),

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    occasions TEXT[],
    packing_list JSONB,

    status VARCHAR(20) DEFAULT 'planning',

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_trips_user ON trips(user_id);
CREATE INDEX IF NOT EXISTS idx_trips_dates ON trips(start_date, end_date);