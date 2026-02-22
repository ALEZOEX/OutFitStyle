#!/bin/bash
# Проброс портов для локальной разработки с k3s кластером
# Позволяет получить доступ к сервисам внутри кластера

set -e

echo "🔌 Проброс портов OutfitStyle..."

# Проверка наличия kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl не найден. Установите kubectl."
    exit 1
fi

# Функция для проброса порта с обработкой Ctrl+C
port_forward() {
    local namespace=$1
    local resource_type=$2
    local resource_name=$3
    local local_port=$4
    local remote_port=$5
    local description=$6
    
    echo "   $description: localhost:$local_port -> $resource_name:$remote_port"
    kubectl port-forward -n "$namespace" "$resource_type/$resource_name" "$local_port:$remote_port" &
}

# Очистка предыдущих процессов port-forward при выходе
cleanup() {
    echo ""
    echo "🛑 Остановка проброса портов..."
    pkill -f "kubectl port-forward" 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

NAMESPACE="outfitstyle"

# API Server
port_forward "$NAMESPACE" "svc" "api-service" 8080 80 "API Server"

# ML Service
port_forward "$NAMESPACE" "svc" "ml-service" 8000 80 "ML Service"

# PostgreSQL (для отладки)
port_forward "$NAMESPACE" "svc" "postgres" 5432 5432 "PostgreSQL"

# Redis (для отладки)
port_forward "$NAMESPACE" "svc" "redis" 6379 6379 "Redis"

# Nginx (внешний доступ)
port_forward "$NAMESPACE" "svc" "nginx" 8081 80 "Nginx (альтернативный)"

echo ""
echo "✅ Порты проброшены!"
echo ""
echo "📍 Доступные эндпоинты:"
echo "   API:       http://localhost:8080"
echo "   ML:        http://localhost:8000"
echo "   PostgreSQL: localhost:5432"
echo "   Redis:     localhost:6379"
echo "   Nginx:     http://localhost:8081"
echo ""
echo "🛑 Нажмите Ctrl+C для остановки"

# Ожидание сигнала завершения
wait
