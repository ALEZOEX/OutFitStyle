#!/bin/bash
# Скрипт для генерации кода для ачивок

echo "Запуск генерации кода для ачивок..."

# Переходим в директорию клиента
cd D:\outfitstyle\client

# Запускаем build runner
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "Генерация кода завершена!"