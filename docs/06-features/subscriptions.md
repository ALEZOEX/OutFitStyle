# Система подписок OutfitStyle

Полная система платных подписок с интеграцией платежной системы YooKassa.

## Обзор

Система поддерживает 4 тарифных плана:

| План | Цена/мес | Цена/год | Рекомендации/день | Вещи | История | Семейные аккаунты |
|------|----------|----------|-------------------|------|---------|-------------------|
| **Free** | 0₽ | 0₽ | 3 | 50 | 7 дней | 0 |
| **Premium** | 299₽ | 2990₽ | 20 | 500 | 90 дней | 0 |
| **Pro** | 599₽ | 5990₽ | ∞ | 5000 | 1 год | 3 |
| **Business** | 1990₽ | 19900₽ | ∞ | 50000 | 2 года | 0 |

## Фичи планов

### Free
- Базовые рекомендации (3 в день)
- Уведомления о погоде
- Трекинг стиля
- До 50 вещей в гардеробе
- История рекомендаций 7 дней

### Premium (+ ML-персонализация)
- Персонализация на основе ML
- 20 рекомендаций в день
- До 500 вещей в гардеробе
- История рекомендаций 90 дней
- Приоритетная поддержка
- Расширенная аналитика
- Календарь образов

### Pro (+ Семейный доступ)
- Безлимитные рекомендации
- До 5000 вещей в гардеробе
- История рекомендаций 1 год
- Доступ для 3 членов семьи
- Экспорт данных
- API доступ

### Business (+ White-label)
- Полноценный API доступ
- До 50000 вещей в гардеробе
- История рекомендаций 2 года
- White-label решение
- Выделенная поддержка
- Кастомные интеграции
- SLA

## Пробный период

- **14 дней** Premium для новых пользователей
- Карта не требуется
- Автоматическая активация при регистрации

## Архитектура

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Layer                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  Handlers   │  │   Routes    │  │ Middleware  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                      Service Layer                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ SubscriptionSvc │  │  PaymentSvc     │  │  BillingSvc     │  │
│  │                 │  │  (YooKassa)     │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    Repository Layer                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │ PlanRepo │ │ SubRepo  │ │ UsageRepo│ │ PromoRepo│           │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                       Database                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ subscription │  │   user_subs  │  │  transactions│          │
│  │    _plans    │  │              │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## База данных

### Таблицы

1. **subscription_plans** - Планы подписок
2. **user_subscriptions** - Активные подписки пользователей
3. **subscription_usage** - Использование лимитов
4. **subscription_transactions** - История транзакций
5. **promo_codes** - Промокоды
6. **promo_redemptions** - Использованные промокоды
7. **family_members** - Семейные аккаунты

### Миграции

```bash
# Применить миграции
migrate -path server/migrations -database "postgres://..." up

# Откатить миграции
migrate -path server/migrations -database "postgres://..." down
```

## API Endpoints

### Публичные

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/subscription/plans` | Список планов |

### Защищённые (требуют авторизации)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/subscription/current` | Текущая подписка |
| POST | `/api/v1/subscription/subscribe` | Оформить подписку |
| POST | `/api/v1/subscription/cancel` | Отменить подписку |
| POST | `/api/v1/subscription/upgrade` | Изменить план |
| POST | `/api/v1/subscription/promo` | Применить промокод |
| GET | `/api/v1/subscription/transactions` | История транзакций |
| GET | `/api/v1/subscription/family` | Семейные участники |
| POST | `/api/v1/subscription/family/invite` | Пригласить участника |
| POST | `/api/v1/subscription/family/accept` | Принять приглашение |
| POST | `/api/v1/subscription/family/remove` | Удалить участника |
| POST | `/api/v1/subscription/trial/start` | Начать пробный период |

### Webhooks

| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/v1/payment/webhook/{provider}` | Webhook от платежной системы |

## Интеграция с YooKassa

### Настройка

1. Зарегистрируйтесь в [YooKassa для разработчиков](https://yookassa.ru/developers)
2. Получите `shopId` и `secretKey`
3. Добавьте в `.env`:

```env
YOOKASSA_SHOP_ID=your_shop_id
YOOKASSA_SECRET_KEY=your_secret_key
YOOKASSA_BASE_URL=https://api.yookassa.ru/v3
```

### Webhook

Настройте webhook в личном кабинете YooKassa:
- URL: `https://your-domain.com/api/v1/payment/webhook/yookassa`
- События: `payment.succeeded`, `payment.canceled`, `payment.waiting_for_capture`

### Формат webhook

```json
{
  "type": "payment.succeeded",
  "object": {
    "id": "2d3df78f-000f-5000-9000-15b3448744a5",
    "status": "succeeded",
    "amount": {
      "value": "299.00",
      "currency": "RUB"
    },
    "metadata": {
      "user_id": "123",
      "subscription_id": "456"
    }
  }
}
```

## Промокоды

### Типы скидок

- `percentage` - процентная скидка (например, 20%)
- `fixed_amount` - фиксированная сумма (например, 100₽)
- `free_trial` - дополнительный пробный период
- `free_month` - бесплатный месяц

### Создание промокода

```sql
INSERT INTO promo_codes (
    code, name, discount_type, discount_value,
    applicable_plans, valid_until, is_active
) VALUES (
    'WELCOME20', 'Приветственная скидка',
    'percentage', 20,
    '["premium", "pro", "business"]'::jsonb,
    '2025-12-31',
    true
);
```

## Лимиты

### Проверка лимитов

Лимиты проверяются через middleware:

```go
// Middleware для рекомендаций
func (l *SubscriptionLimiter) EnforceRecommendationsLimit() mux.MiddlewareFunc

// Middleware для гардероба
func (l *SubscriptionLimiter) EnforceWardrobeLimit() mux.MiddlewareFunc
```

### Сброс лимитов

Дневные лимиты сбрасываются автоматически:

```sql
-- Вызывается по крону (каждый день в 00:00)
SELECT reset_daily_subscription_usage();
```

## Тестирование

### Unit тесты

```bash
cd server
go test ./internal/core/application/services/... -v
```

### Integration тесты

```bash
# Запустить тестовую БД
docker-compose -f docker-compose.test.yml up -d

# Запустить тесты
go test ./internal/api/handlers/... -v -tags=integration
```

### Тестовый платежный шлюз

Для разработки используется `DummyGateway`:

```json
{
  "plan_code": "premium",
  "billing_cycle": "monthly",
  "payment_provider": "dummy"
}
```

## Мониторинг

### Метрики Prometheus

- `subscription_active_total` - количество активных подписок
- `subscription_trials_total` - количество активных триалов
- `payment_transactions_total` - количество транзакций
- `payment_revenue_total` - общая выручка
- `subscription_limits_exceeded_total` - превышения лимитов

### Логи

Ключевые события логируются:

```json
{
  "level": "info",
  "message": "subscription created",
  "user_id": "uuid",
  "plan": "premium",
  "amount": 299,
  "provider": "yookassa"
}
```

## Безопасность

### Webhook подписи

YooKassa использует HMAC-SHA256 для подписи webhook:

```go
func (g *YooKassaGateway) VerifyWebhookSignature(ctx, headers, body) error
```

### Идемпотентность

Все платежные операции идемпотентны благодаря `Idempotence-Key`.

### Валидация

- Проверка статуса плана перед покупкой
- Валидация промокодов (срок, лимиты, применимость)
- Проверка прав доступа к семейным функциям

## Откат изменений

### Откат миграции

```bash
migrate -path server/migrations -database "postgres://..." down 1
```

### Отмена подписки

Пользователь может отменить подписку:
- Немедленно (`immediate: true`)
- В конце периода (`immediate: false`, по умолчанию)

### Возврат средств

Только через admin API:

```bash
POST /api/v1/billing/refund
{
  "transaction_id": 123,
  "amount": 299,
  "reason": "Customer request"
}
```

## Развёртывание

### Переменные окружения

```env
# Обязательные
YOOKASSA_SHOP_ID=
YOOKASSA_SECRET_KEY=

# Опциональные
SUBSCRIPTION_TRIAL_DAYS=14
SUBSCRIPTION_CURRENCY=RUB
PAYMENT_RETURN_URL=https://app.outfitstyle.app/payment/return
```

### Kubernetes (опционально)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: yookassa-credentials
type: Opaque
stringData:
  shop-id: "your_shop_id"
  secret-key: "your_secret_key"
```

## Ссылки

- [Документация YooKassa](https://yookassa.ru/developers/api)
- [Swagger API](http://localhost:8080/swagger)
- [Миграции БД](server/migrations/000013_subscription_system.up.sql)
