@echo off
REM OutfitStyle Deployment Script for Windows

echo 🚀 Starting OutfitStyle Deployment...

REM Check if docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    exit /b 1
)

REM Check if docker-compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ docker-compose is not installed. Please install Docker Desktop first.
    exit /b 1
)

REM Build and start services
echo 🏗️  Building Docker images...
docker-compose -f docker-compose.prod.yml build

echo サービ 起動中...
docker-compose -f docker-compose.prod.yml up -d

echo ⏱  Waiting for services to start...
timeout /t 10 /nobreak >nul

REM Check if services are running
echo 🔍 Checking service status...
docker-compose -f docker-compose.prod.yml ps

echo ✅ Deployment completed!
echo 🌐 Web client available at http://localhost
echo 📡 API available at http://localhost:8080