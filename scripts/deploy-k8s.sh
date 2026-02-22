#!/bin/bash
# Скрипт деплоя OutfitStyle на k3s сервер
# Предназначен для VPS с 4 GB RAM (тариф LC-2)

set -e

echo "🚀 Деплой OutfitStyle на k3s..."

# Проверка наличия kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl не найден. Установите kubectl."
    exit 1
fi

# Проверка подключения к кластеру
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Нет подключения к Kubernetes кластеру."
    echo "   Проверьте настройку kubeconfig или выполните:"
    echo "   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
    exit 1
fi

# Применить namespace
echo "📦 Создание namespace..."
kubectl apply -f k8s/namespace.yaml

# Применить секреты
echo "🔐 Применение секретов..."
if [ ! -f "k8s/secrets.yaml" ]; then
    echo "❌ Файл k8s/secrets.yaml не найден!"
    echo "   Скопируйте k8s/secrets.yaml.example в k8s/secrets.yaml"
    echo "   и заполните реальными значениями."
    exit 1
fi
kubectl apply -f k8s/secrets.yaml

# Применить PVC
echo "💾 Создание PersistentVolumeClaim..."
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/redis-pvc.yaml

# Применить миграции (Job)
echo "🔄 Применение миграций базы данных..."
kubectl apply -f k8s/migrate-job.yaml

# Подождать завершения миграции
echo "⏳ Ожидание завершения миграций (до 300 секунд)..."
if kubectl wait --for=condition=complete job/migrate -n outfitstyle --timeout=300s 2>/dev/null; then
    echo "✅ Миграции завершены успешно."
else
    echo "⚠️  Миграции не завершены в течение 300 секунд."
    echo "   Проверьте статус: kubectl get pods -n outfitstyle"
    echo "   Логи: kubectl logs -n outfitstyle -l job-name=migrate"
    # Не прерываем деплой, возможно миграции уже были выполнены ранее
fi

# Применить основные сервисы (оптимизированные для LC-2)
echo "🚀 Деплой основных сервисов (LC-2 оптимизация)..."
kubectl apply -f k8s/deployment.lc2.yaml

# Применить nginx
echo "🌐 Деплой nginx..."
kubectl apply -f k8s/nginx-deployment.yaml

# Применить ingress (если нужен)
if [ -f "k8s/ingress.yaml" ]; then
    echo "🔗 Применение Ingress..."
    kubectl apply -f k8s/ingress.yaml
fi

# Применить HPA
if [ -f "k8s/hpa.yaml" ]; then
    echo "📊 Применение HorizontalPodAutoscaler..."
    kubectl apply -f k8s/hpa.yaml
fi

echo ""
echo "✅ Деплой завершён!"
echo ""
echo "📊 Статус подов:"
kubectl get pods -n outfitstyle
echo ""
echo "🔗 Статус сервисов:"
kubectl get svc -n outfitstyle
echo ""
echo "📝 Полезные команды:"
echo "   kubectl get pods -n outfitstyle"
echo "   kubectl logs -n outfitstyle -l app=api"
echo "   kubectl logs -n outfitstyle -l app=ml-service"
echo "   kubectl describe pod -n outfitstyle <pod-name>"
