#!/bin/bash
# Скрипт для выполнения всех этапов подготовки системы

echo "=== Подготовка системы OutfitStyle ==="

# 1. Применяем миграции
echo "1. Применение миграций..."
docker exec outfitstyle-db psql -U Admin -d outfitstyle -f /migrations/003_add_ml_attributes.up.sql

# 2. Копируем и запускаем скрипт импорта
echo "2. Копирование и выполнение скрипта импорта..."
docker cp C:\Users\Admin\GolandProjects\outfitstyle\scripts\import_kaggle_styles_docker.py outfitstyle-ml:/app/import_kaggle_styles.py

echo "3. Установка зависимостей и запуск импорта..."
docker exec outfitstyle-ml pip install python-dotenv
docker exec outfitstyle-ml python /app/import_kaggle_styles.py

echo "=== Все этапы завершены успешно! ==="
echo "Теперь система готова к работе с новой архитектурой:"
echo "- Единый каталог вещей с приоритетами источников"
echo "- ML-ранжирование с учетом source и is_owned"
echo "- Retrieval → Ranking архитектура"
echo "- Исправлены проблемы с темной темой"
echo ""
echo "Для проверки статуса выполните: docker compose ps"