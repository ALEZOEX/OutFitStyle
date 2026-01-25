# Event-driven архитектура для OutfitStyle

## Компоненты

### Брокер сообщений
- Apache Kafka или RabbitMQ для очереди сообщений
- Используется для асинхронной обработки рекомендаций

### Типы событий
- RecommendationRequestedEvent
- RecommendationProcessedEvent
- UserFeedbackEvent
- ModelTrainingEvent

### Сервисы
- Publisher событий (API Service)
- Consumer событий (ML Service)
- Processor событий (Recommendation Engine)