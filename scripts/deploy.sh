#!/bin/bash

# OutfitStyle Deployment Script

set -e  # Exit on any error

echo "🚀 Starting OutfitStyle Deployment..."

# Check if docker is installed
if ! command -v docker &> /dev/null
then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null
then
    echo "❌ docker-compose is not installed. Please install docker-compose first."
    exit 1
fi

# Build and start services
echo "🏗️  Building Docker images..."
docker-compose -f docker-compose.prod.yml build

echo "サービ 起動中..."
docker-compose -f docker-compose.prod.yml up -d

echo "⏱  Waiting for services to start..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
docker-compose -f docker-compose.prod.yml ps

echo "✅ Deployment completed!"
echo "🌐 Web client available at http://localhost"
echo "📡 API available at http://localhost:8080"