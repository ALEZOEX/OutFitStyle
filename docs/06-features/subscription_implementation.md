# Реализация системы подписок OutfitStyle

## Статус реализации

✅ **Завершено:**

### 1. Миграции БД
- `000013_subscription_system.up.sql` - полная схема системы подписок
- `000013_subscription_system.down.sql` - откат миграций

**Таблицы:**
- `subscription_plans` - планы подписок (Free, Premium, Pro, Business)
- `user_subscriptions` - активные подписки пользователей
- `subscription_usage` - использование лимитов
- `subscription_transactions` - история транзакций
- `promo_codes` - промокоды
- `promo_redemptions` - использованные промокоды
- `family_members` - семейные аккаунты

### 2. Domain модели
- `domain/subscription.go` - основные модели подписок
- `domain/subscription_limits.go` - лимиты и статусы
- `domain/payment.go` - платежные модели с YooKassa
- `domain/promo.go` - обновлённые модели промокодов

### 3. Репозитории
- `repo/subscription/subscription_repo.go` - планы и подписки
- `repo/subscription/usage_transaction_repo.go` - использование и транзакции
- `repo/subscription/promo_family_repo.go` - промокоды и семейные аккаунты

**Интерфейсы:**
- `SubscriptionPlanRepository`
- `UserSubscriptionRepository`
- `SubscriptionUsageRepository`
- `SubscriptionTransactionRepository`
- `PromoCodeRepository`
- `PromoRedemptionRepository`
- `FamilyMemberRepository`

### 4. Сервисы
- `services/subscription_service.go` - управление подписками
- `services/payment_service.go` - платежи с YooKassa интеграцией
- `services/billing_service.go` - обработка webhook

**Функциональность:**
- Оформление подписки
- Отмена подписки
- Изменение плана (upgrade)
- Проверка лимитов
- Применение промокодов
- Семейные аккаунты
- Пробный период (14 дней)

### 5. API Handlers
- `handlers/subscription_handler.go` - основные endpoints
- `handlers/billing_handler.go` - webhook обработчик

**Endpoints:**
```
GET  /api/v1/subscription/plans          # Список планов
GET  /api/v1/subscription/current        # Текущая подписка
POST /api/v1/subscription/subscribe      # Оформить подписку
POST /api/v1/subscription/cancel         # Отменить подписку
POST /api/v1/subscription/upgrade        # Изменить план
POST /api/v1/subscription/promo          # Применить промокод
GET  /api/v1/subscription/transactions   # История транзакций
GET  /api/v1/subscription/family         # Семейные участники
POST /api/v1/subscription/family/invite  # Пригласить участника
POST /api/v1/subscription/family/accept  # Принять приглашение
POST /api/v1/subscription/family/remove  # Удалить участника
POST /api/v1/subscription/trial/start    # Начать пробный период
POST /api/v1/payment/webhook/{provider}  # Webhook от платежной системы
```

### 6. Routes
- `routes/subscription_routes.go` - регистрация маршрутов

### 7. Swagger документация
- `docs/subscriptions_swagger.go` - полная API документация

### 8. Тесты
- `services/subscription_service_test.go` - unit тесты сервисов
- `services/payment_service_test.go` - тесты YooKassa gateway

### 9. Конфигурация
- Обновлён `.env.example` с переменными для YooKassa
- `docs/SUBSCRIPTION_INTEGRATION.md` - инструкция по интеграции

### 10. Документация
- `docs/subscriptions.md` - полная документация системы

## Планы подписок

| План | Цена/мес | Цена/год | Рекомендации | Вещи | История | Семейные |
|------|----------|----------|--------------|------|---------|----------|
| Free | 0₽ | 0₽ | 3/день | 50 | 7 дней | 0 |
| Premium | 299₽ | 2990₽ | 20/день | 500 | 90 дней | 0 |
| Pro | 599₽ | 5990₽ | ∞ | 5000 | 1 год | 3 |
| Business | 1990₽ | 19900₽ | ∞ | 50000 | 2 года | 0 |

## YooKassa интеграция

### Настройка
```env
YOOKASSA_SHOP_ID=your_shop_id
YOOKASSA_SECRET_KEY=your_secret_key
YOOKASSA_BASE_URL=https://api.yookassa.ru/v3
```

### Webhook
URL: `https://your-domain.com/api/v1/payment/webhook/yookassa`

События:
- `payment.succeeded`
- `payment.canceled`
- `payment.waiting_for_capture`

## Применение миграций

```bash
migrate -path server/migrations -database "postgres://user:pass@localhost:5432/dbname?sslmode=disable" up
```

## Интеграция в main.go

См. `docs/SUBSCRIPTION_INTEGRATION.md` для подробных инструкций по интеграции в точку входа приложения.

## Тестирование

### Unit тесты
```bash
cd server
go test ./internal/core/application/services/... -v
```

### Проверка сборки
```bash
go build ./...
```

## Известные ограничения

1. **main.go требует ручной доработки** - необходимо обновить инициализацию сервисов в `cmd/server/main.go` согласно инструкции в `docs/SUBSCRIPTION_INTEGRATION.md`

2. **Старый subscription_repository.go** - перемещён в `subscription_repository.go.bak`, так как использовал устаревшую модель данных

3. **BillingService** - обновлён для работы с новыми интерфейсами, старые методы помечены как устаревшие

## Следующие шаги

1. Применить миграции к базе данных
2. Обновить `cmd/server/main.go` согласно инструкции
3. Настроить YooKassa webhook в личном кабинете
4. Протестировать полный цикл оформления подписки
5. Настроить мониторинг и алертинг

## Контакты

По вопросам интеграции: support@outfitstyle.app
