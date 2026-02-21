# Kafka Setup Guide - OutfitStyle

## Обзор

Этот документ описывает настройку Apache Kafka для платформы OutfitStyle. Kafka используется для асинхронной обработки событий:
- События рекомендаций (recommendation events)
- Пользовательские события (user events)
- События обратной связи (feedback events)

## Архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Go API        │    │   Kafka         │    │   ML Service    │
│   (Producer)    │───►│   (Broker)      │───►│   (Consumer)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Zookeeper     │
                       │   (Coordination)│
                       └─────────────────┘
```

## Быстрый старт

### 1. Запуск Kafka

Kafka вынесена в отдельный compose-файл для опционального запуска:

```bash
# Запуск только Kafka и Zookeeper
docker compose -f docker-compose.kafka.yml up -d

# Запуск всех сервисов включая Kafka
docker compose -f docker-compose.dev.yml -f docker-compose.kafka.yml up -d
```

### 2. Проверка статуса

```bash
# Проверка статуса сервисов
docker compose -f docker-compose.kafka.yml ps

# Проверка логов Zookeeper
docker compose -f docker-compose.kafka.yml logs zookeeper

# Проверка логов Kafka
docker compose -f docker-compose.kafka.yml logs kafka
```

### 3. Kafka UI (веб-интерфейс)

После запуска откройте в браузере: http://localhost:8090

Kafka UI позволяет:
- Просматривать топики
- Мониторить сообщения
- Управлять конфигурацией

## Конфигурация

### Переменные окружения

Добавьте в `.env`:

```bash
# Kafka Configuration
KAFKA_BROKERS=localhost:9092
KAFKA_TOPIC_RECOMMENDATIONS=recommendations
KAFKA_TOPIC_EVENTS=user_events
EVENTING_ENABLED=1
```

### Топики

Kafka автоматически создаёт топики при первой публикации (auto.create.topics.enable=true):

| Топик | Описание | Partitions |
|-------|----------|------------|
| `recommendations` | События рекомендаций | 3 |
| `user_events` | Пользовательские события | 3 |

### Порты

| Сервис | Порт | Описание |
|--------|------|----------|
| Kafka (external) | 9092 | Доступ с хоста (localhost) |
| Kafka (internal) | 29092 | Доступ внутри Docker сети |
| Zookeeper | 2181 | Координация Kafka |
| Kafka UI | 8090 | Веб-интерфейс |

## Тестирование

### 1. Проверка подключения

```bash
# Проверка доступности Kafka
docker compose -f docker-compose.kafka.yml exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

### 2. Создание топика вручную

```bash
docker compose -f docker-compose.kafka.yml exec kafka kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic recommendations \
  --partitions 3 \
  --replication-factor 1
```

### 3. Публикация тестового сообщения

```bash
docker compose -f docker-compose.kafka.yml exec kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic recommendations

> {"event_type": "test", "user_id": "123", "timestamp": "2026-02-21T12:00:00Z"}
```

### 4. Чтение сообщений

```bash
docker compose -f docker-compose.kafka.yml exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic recommendations \
  --from-beginning
```

### 5. Просмотр топиков

```bash
docker compose -f docker-compose.kafka.yml exec kafka kafka-topics --list \
  --bootstrap-server localhost:9092
```

## Интеграция с Go API

### Конфигурация в main.go

```go
// Event Publisher
var eventPublisher eventing.EventPublisher
if cfg.Eventing.Enabled && len(cfg.Eventing.KafkaBrokers) > 0 {
    kafkaPublisher = eventing.NewKafkaEventPublisher(
        cfg.Eventing.KafkaBrokers, 
        cfg.Eventing.KafkaTopicRecommendations,
    )
    eventPublisher = kafkaPublisher
}
```

### Публикация событий

```go
// В RecommendationService
err := r.eventPublisher.PublishRecommendationRequested(
    ctx, 
    userID, 
    context, 
    candidates,
)
```

## Остановка и очистка

### Остановка сервисов

```bash
docker compose -f docker-compose.kafka.yml down
```

### Остановка с удалением данных

```bash
docker compose -f docker-compose.kafka.yml down -v
```

## Решение проблем

### Kafka не запускается

1. Проверьте логи:
   ```bash
   docker compose -f docker-compose.kafka.yml logs kafka
   ```

2. Убедитесь что Zookeeper здоров:
   ```bash
   docker compose -f docker-compose.kafka.yml ps zookeeper
   ```

### Ошибки подключения

1. Проверьте что порт 9092 не занят:
   ```bash
   netstat -ano | findstr :9092
   ```

2. Проверьте advertised listeners в логах Kafka

### Проблемы с Zookeeper

Перезапустите Zookeeper перед Kafka:

```bash
docker compose -f docker-compose.kafka.yml restart zookeeper
docker compose -f docker-compose.kafka.yml restart kafka
```

## Production конфигурация

Для продакшена рекомендуется:

1. **Увеличить репликацию**:
   ```yaml
   KAFKA_DEFAULT_REPLICATION_FACTOR: 3
   KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
   ```

2. **Настроить безопасность**:
   ```yaml
   KAFKA_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,EXTERNAL:SASL_SSL
   KAFKA_SASL_MECHANISM: PLAIN
   ```

3. **Увеличить ресурсы**:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '2.0'
         memory: 2G
   ```

4. **Использовать внешний Zookeeper ансамбль**

## Мониторинг

### Метрики Kafka

Kafka экспортирует метрики через JMX. Для сбора метрик:

1. Настройте JMX exporter
2. Добавьте Prometheus scrape config
3. Создайте дашборды в Grafana

### Ключевые метрики

- `kafka_server_brokertopicmetrics_messagesin_persec` - входящие сообщения
- `kafka_server_brokertopicmetrics_bytesin_persec` - входящие байты
- `kafka_server_replicamanager_underreplicatedpartitions` - проблемные партиции
- `kafka_controller_kafkacontroller_offlinepartitionscount` - офлайн партиции

## Ссылки

- [Официальная документация Kafka](https://kafka.apache.org/documentation/)
- [Confluent Platform Documentation](https://docs.confluent.io/platform/current/)
- [Kafka UI Documentation](https://github.com/provectus/kafka-ui)
