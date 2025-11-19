#!/bin/bash

# Database seeding script for OutfitStyle server

set -e

echo "🌱 Seeding database..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Set default values if not in environment
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-password}
DB_NAME=${DB_NAME:-outfitstyle}

# Connect to database and seed initial data
echo "Seeding initial data to database: $DB_NAME"

# Create initial user
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << EOF
-- Insert default user
INSERT INTO users (id, username, email, created_at) 
VALUES (1, 'default_user', 'user@example.com', NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert clothing categories
INSERT INTO clothing_categories (name, description) 
VALUES 
  ('outerwear', 'Верхняя одежда'),
  ('upper', 'Верх'),
  ('lower', 'Низ'),
  ('footwear', 'Обувь'),
  ('accessories', 'Аксессуары')
ON CONFLICT (name) DO NOTHING;

-- Insert sample achievements
INSERT INTO achievements (name, description, icon) 
VALUES 
  ('first_recommendation', 'Первая рекомендация', '👕'),
  ('cold_warrior', 'Холодный воин', '🥶'),
  ('rainy_day', 'Дождливый день', '🌧️'),
  ('heat_master', 'Мастер жары', '🔥')
ON CONFLICT (name) DO NOTHING;
EOF

echo "✅ Database seeding completed!"