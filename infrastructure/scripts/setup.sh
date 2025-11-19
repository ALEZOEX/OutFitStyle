#!/bin/bash
# Setup script for OutfitStyle development environment
set -e
echo "🚀 Setting up OutfitStyle development environment..."
# Check required tools
REQUIRED_TOOLS=("docker" "docker-compose" "git" "make")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "❌ $tool is not installed. Please install it first."
        exit 1
    fi
done
echo "✅ All required tools are installed"
# Create environment files
echo "🔧 Creating environment files..."
cd infrastructure/docker-compose
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env file from example"
fi
if [ ! -f .env.prod ]; then
    cp .env.example .env.prod
    echo "✅ Created .env.prod file from example"
    # Generate secure secrets for production
    echo "🔐 Generating secure secrets..."
    JWT_SECRET=$(openssl rand -base64 32)
    sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" .env.prod
    DB_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env.prod
    echo "✅ Generated secure secrets for production"
fi
cd ../..
# Build and start services
echo "🐳 Building and starting Docker services..."
cd infrastructure/docker-compose
docker-compose up -d --build
echo "✅ Docker services started successfully"
# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10
# Check service status
docker-compose ps
echo "🎉 Setup completed successfully!"
echo ""
echo "🔧 Next steps:"
echo "1. Check API health: curl http://localhost:8080/health"
echo "2. Check ML service health: curl http://localhost:5000/health"
echo "3. Run Flutter client: cd client && flutter run"
echo "4. Open browser: http://localhost:8081"