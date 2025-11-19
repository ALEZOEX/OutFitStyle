#!/bin/bash
# Production deployment script for OutfitStyle

set -e
echo "🚀 Starting production deployment..."

# Check environment variables
REQUIRED_VARS=(
    "WEATHER_API_KEY"
    "DB_PASSWORD"
    "JWT_SECRET"
    "CORS_ALLOWED_ORIGINS"
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Required environment variable $var is not set"
        exit 1
    fi
done

echo "✅ All required environment variables are set"

# Pull latest images
echo "📥 Pulling latest Docker images..."
docker pull outfitstyle/api:latest
docker pull outfitstyle/ml-service:latest

# Stop existing containers
echo "🛑 Stopping existing services..."
docker-compose -f infrastructure/docker-compose/docker-compose.prod.yml down

# Start new services
echo "🆙 Starting new services..."
docker-compose -f infrastructure/docker-compose/docker-compose.prod.yml up -d --force-recreate

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check health status
echo "🔍 Checking service health..."

SERVICES=("api" "ml-service" "postgres" "redis")

for service in "${SERVICES[@]}"; do
    if docker-compose -f infrastructure/docker-compose/docker-compose.prod.yml exec -T $service curl -f http://localhost:8080/health >/dev/null 2>&1; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service is not healthy"
        exit 1
    fi
done

echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Verify application is accessible at https://your-domain.com"
echo "2. Check logs for any issues: docker-compose logs -f"
echo "3. Monitor metrics at http://your-domain.com/metrics"
echo "4. Set up monitoring and alerting"