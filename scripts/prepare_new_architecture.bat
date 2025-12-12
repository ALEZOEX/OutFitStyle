@echo off
REM Скрипт для подготовки и запуска OutfitStyle с новой архитектурой

echo 🚀 Начало подготовки проекта OutfitStyle

REM 1. Убедимся, что все контейнеры остановлены
echo ⏹️ Остановка запущенных контейнеров
docker compose down

REM 2. Применение миграций базы данных
echo 🗄️ Применение миграций к базе данных
docker exec -i outfitstyle-db psql -U Admin -d outfitstyle -f /docker-entrypoint-initdb.d/init.sql
docker exec -i outfitstyle-db psql -U Admin -d outfitstyle -f /migrations/002_expand_clothing_schema.up.sql
docker exec -i outfitstyle-db psql -U Admin -d outfitstyle -f /migrations/003_add_ml_attributes.up.sql

REM 3. Запуск импорта Kaggle данных
echo 📦 Запуск скрипта импорта Kaggle данных
if exist "C:\Users\Admin\GolandProjects\outfitstyle\scripts\import_kaggle_styles.py" (
    echo Копирование скрипта в контейнер...
    docker cp C:\Users\Admin\GolandProjects\outfitstyle\scripts\import_kaggle_styles.py outfitstyle-ml:/app/import_kaggle_styles.py
    docker exec outfitstyle-ml pip install pandas psycopg2-binary python-dotenv
    docker exec outfitstyle-ml python /app/import_kaggle_styles.py
) else (
    echo ⚠️ Файл скрипта импорта не найден
    REM файл уже скопирован ранее, пытаемся выполнить его
    docker exec outfitstyle-ml python /app/import_kaggle_styles.py
)

REM 4. Запуск проекта с обновленной архитектурой
echo 🔄 Перезапуск проекта с новой архитектурой
docker compose up --build -d

REM 5. Проверка состояния контейнеров
echo 🔍 Проверка состояния контейнеров
docker compose ps

echo ✅ Проект OutfitStyle успешно подготовлен с новой архитектурой!
echo 📊 Теперь система использует Retrieval → Ranking с приоритетами:
echo    1. Личный гардероб (wardrobe) - максимальный приоритет
echo    2. Каталог (catalog) - средний приоритет 
echo    3. Kaggle датасет (kaggle_seed) - базовая линия