@echo off
chcp 65001 > nul
REM Script to run project with resource limitations

echo Starting OutfitStyle project with resource limitations...

REM Check if Docker is running
docker system df >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not running. Please start Docker.
    pause
    exit /b 1
)

REM Clean unused resources before starting
echo Cleaning unused resources...
docker system prune -f

REM Start project with resource limitations
echo Starting project...
docker-compose -f docker-compose.dev.yml up --build

echo Project started with resource limitations.
echo To stop, press Ctrl+C
pause