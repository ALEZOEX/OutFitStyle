#!/bin/bash
# Скрипт развёртывания мониторинга OutfitStyle

set -e

NAMESPACE="monitoring"
SERVER="root@app.outfitstyle.ru"

echo "=== Deploying Monitoring Stack to OutfitStyle K8s ==="

# Создаём namespace
echo "[1/6] Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# RBAC для Prometheus
echo "[2/6] Applying RBAC..."
kubectl apply -f prometheus-rbac.yaml -n $NAMESPACE

# ConfigMaps
echo "[3/6] Applying ConfigMaps..."
kubectl apply -f prometheus-configmap.yaml -n $NAMESPACE
kubectl apply -f prometheus-rules.yaml -n $NAMESPACE
kubectl apply -f grafana-configmap.yaml -n $NAMESPACE
kubectl apply -f grafana-dashboard-k8s.yaml -n $NAMESPACE

# Secrets
echo "[4/6] Applying Secrets..."
kubectl apply -f grafana-deployment.yaml -n $NAMESPACE

# Deployments & Services
echo "[5/6] Applying Deployments and Services..."
kubectl apply -f prometheus-deployment.yaml -n $NAMESPACE
kubectl apply -f grafana-deployment.yaml -n $NAMESPACE

# Ingress
echo "[6/6] Applying IngressRoute..."
kubectl apply -f grafana-ingress.yaml -n $NAMESPACE

echo ""
echo "=== Monitoring Stack Deployed! ==="
echo ""
echo "Access Grafana: https://grafana.outfitstyle.ru"
echo "Default credentials: admin / grafana-admin-password-change-me"
echo ""
echo "Check status:"
echo "  kubectl get pods -n monitoring"
echo "  kubectl get svc -n monitoring"
echo ""
