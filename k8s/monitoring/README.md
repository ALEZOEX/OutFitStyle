# Monitoring Stack для OutfitStyle K8s

## Компоненты

| Компонент | Версия | Описание |
|-----------|--------|----------|
| Prometheus | v2.54.1 | Сбор и хранение метрик |
| Grafana | 11.4.0 | Визуализация и дашборды |

## Развёртывание

```bash
cd k8s/monitoring

# Применить все манифесты
kubectl apply -f namespace.yaml
kubectl apply -f prometheus-rbac.yaml
kubectl apply -f prometheus-configmap.yaml
kubectl apply -f prometheus-rules.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f grafana-configmap.yaml
kubectl apply -f grafana-deployment.yaml
kubectl apply -f grafana-dashboard-k8s.yaml
kubectl apply -f grafana-ingress.yaml

# Или одной командой
kubectl apply -f . -n monitoring
```

## Доступ

| Сервис | URL | Credentials |
|--------|-----|-------------|
| Grafana | https://grafana.outfitstyle.ru | admin / grafana-admin-password-change-me |
| Prometheus | http://prometheus.monitoring.svc.cluster.local:9090 | internal only |

## Проверка статуса

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get ingressroute -n monitoring
```

## Дашборды

### K8s Cluster Health
- CPU Usage (OutfitStyle namespace)
- Memory Usage (OutfitStyle namespace)
- Pod Restarts

## Alerts

| Alert | Severity | Описание |
|-------|----------|----------|
| PodCrashLooping | warning | Pod перезапускается >3 раз за 15 мин |
| PodNotReady | warning | Pod не готов >5 мин |
| HighHTTP5xxErrors | critical | >10 5xx ошибок/сек |
| HighHTTP4xxErrors | warning | >50 4xx ошибок/сек |
| HighCPUUsage | warning | CPU >80% |
| HighMemoryUsage | warning | Memory >80% |
| HighDiskUsage | warning | Disk >80% |
| CertificateExpirySoon | warning | SSL истекает <7 дней |
| BackendDown | critical | API недоступен >5 мин |
| MLServiceDown | critical | ML Service недоступен >5 мин |

## Prometheus Jobs

| Job | Target | Port |
|-----|--------|------|
| prometheus | localhost | 9090 |
| kubernetes-apiservers | kubernetes.default | 443 |
| kubernetes-nodes | все ноды | 10250 |
| kubernetes-pods | pod с аннотацией | любой |
| outfitstyle-api | app=api | 8080 |
| outfitstyle-ml | app=ml-service | 8000 |
| traefik | app=traefik | 9100 |

## Добавление нового дашборда

1. Создайте JSON файл дашборда в Grafana UI
2. Export → Save to file
3. Создайте ConfigMap:
```bash
kubectl create configmap grafana-dashboard-new \
  --from-file=new-dashboard.json=/path/to/dashboard.json \
  -n monitoring
kubectl label configmap grafana-dashboard-new app=grafana -n monitoring
```

## Изменение пароля Grafana

```bash
kubectl patch secret grafana-credentials -n monitoring \
  -p '{"stringData":{"admin-password":"new-password"}}'
kubectl rollout restart deployment/grafana -n monitoring
```

## Troubleshooting

### Prometheus не стартует
```bash
kubectl logs -n monitoring deployment/prometheus
kubectl describe pod -n monitoring -l app=prometheus
```

### Grafana недоступна
```bash
kubectl logs -n monitoring deployment/grafana
kubectl get ingressroute grafana-ingressroute -n monitoring -o yaml
```

### Метрики не собираются
```bash
# Проверка targets
curl http://prometheus.monitoring:9090/api/v1/targets

# Проверка service discovery
kubectl get endpoints -n outfitstyle
```
