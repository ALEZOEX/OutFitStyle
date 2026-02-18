# DevOps практики для OutfitStyle

## CI/CD Pipeline

### GitHub Actions
**Конфигурация**:
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: Run tests
        run: go test ./... -v
      - name: Run linters
        run: |
          go vet ./...
          golangci-lint run
```

**Этапы**:
1. **Build**: Сборка образов Docker
2. **Test**: Запуск unit и интеграционных тестов
3. **Security Scan**: Проверка уязвимостей в зависимостях
4. **Deploy**: Развертывание в staging/production

### GitFlow
**Ветки**:
- `main` - стабильная продакшен версия
- `develop` - основная разработка
- `feature/*` - новые функции
- `release/*` - подготовка релизов
- `hotfix/*` - срочные исправления

## Infrastructure as Code (IaC)

### Terraform
**Структура**:
```
terraform/
├── environments/
│   ├── prod/
│   └── staging/
├── modules/
│   ├── kubernetes/
│   ├── database/
│   └── monitoring/
└── variables.tf
```

**Ресурсы**:
- Kubernetes кластеры
- Базы данных PostgreSQL
- Сетевые ресурсы
- Мониторинг и логирование

### Helm Charts
**Структура**:
```
charts/
├── outfitstyle-api/
├── outfitstyle-ml/
├── kafka/
└── istio/
```

## Container Orchestration

### Kubernetes
**Deployment Strategy**:
- Blue-Green для минимизации времени простоя
- Canary releases для постепенного развертывания
- Rolling updates для непрерывного обновления

**Configuration**:
- ConfigMaps для настроек
- Secrets для чувствительных данных
- Namespaces для изоляции окружений

### Docker
**Multi-stage builds**:
```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o main .

# Runtime stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
CMD ["./main"]
```

## Monitoring & Observability

### Prometheus + Grafana
**Метрики**:
- Application metrics (requests, errors, duration)
- System metrics (CPU, memory, disk)
- Business metrics (registrations, recommendations)

**Alerting**:
- Slack notifications
- PagerDuty integration
- Custom dashboards

### ELK Stack
**Components**:
- Elasticsearch: хранение логов
- Logstash: обработка логов
- Kibana: визуализация логов

## Security Practices

### Secret Management
**HashiCorp Vault**:
- Dynamic secrets
- PKI engine
- Transit encryption
- Identity-based access

### Image Scanning
**Trivy**:
- Vulnerability scanning
- Misconfiguration detection
- SBOM generation

## Backup & Recovery

### Database Backups
**pgBackRest**:
- Continuous archiving
- Point-in-time recovery
- Compression and encryption

### Disaster Recovery
**Strategies**:
- Cross-region replication
- Automated failover
- Regular DR drills

## Performance Optimization

### Load Testing
**Tools**:
- k6 for load testing
- Grafana for visualization
- Automated performance regression tests

### Auto-scaling
**HPA Configuration**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## GitOps

### ArgoCD
**Configuration**:
- Declarative deployments
- Sync policies
- Rollback capabilities

**Benefits**:
- Git as single source of truth
- Automated synchronization
- Rollback to any commit

## Testing in Production

### Feature Flags
**Library**: Unleash
**Use cases**:
- Gradual feature rollout
- A/B testing
- Kill switches

### Chaos Engineering
**Tools**: Chaos Mesh
**Scenarios**:
- Pod failures
- Network partitions
- Resource exhaustion