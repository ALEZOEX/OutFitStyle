#!/bin/bash
# Настройка swap 2GB на сервере для OutfitStyle
# Рекомендуется для VPS с 4 GB RAM (тариф LC-2)

set -e

echo "🔧 Настройка swap 2GB..."

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Скрипт должен быть запущен от root"
    echo "   Выполните: sudo $0"
    exit 1
fi

# Проверка, есть ли уже swap
if [ -f /swapfile ]; then
    echo "⚠️  Swap файл уже существует"
    swapon --show
    echo ""
    echo "✅ Swap уже настроен!"
    exit 0
fi

# Создание swap файла
echo "📁 Создание swap файла /swapfile (2GB)..."
fallocate -l 2G /swapfile

# Установка безопасных прав
echo "🔒 Установка прав доступа (600)..."
chmod 600 /swapfile

# Инициализация swap
echo "💾 Инициализация swap..."
mkswap /swapfile

# Включение swap
echo "▶️  Включение swap..."
swapon /swapfile

# Добавление в fstab для постоянного включения
echo "📝 Добавление в /etc/fstab..."
if ! grep -q "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
else
    echo "⚠️  Запись уже есть в /etc/fstab"
fi

# Настройка swappiness (тенденция использования swap)
echo "⚙️  Настройка vm.swappiness=10..."
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
fi

# Применение настроек sysctl
sysctl -p 2>/dev/null || true

echo ""
echo "✅ Swap настроен!"
echo ""
echo "📊 Статус swap:"
swapon --show
echo ""
echo "💡 Рекомендации:"
echo "   - swappiness=10 уменьшает использование swap"
echo "   - Для мониторинга: free -h, swapon --show, cat /proc/swaps"
