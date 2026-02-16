# Интеграция системы подписок в main.go

## Изменения в cmd/server/main.go

### 1. Добавить новые репозитории

После существующих репозиториев добавить:

```go
// ---------- Subscription Repositories ----------
subscriptionPlanRepo := subscription.NewSubscriptionPlanRepo(db.Pool())
userSubscriptionRepo := subscription.NewUserSubscriptionRepo(db.Pool())
subscriptionUsageRepo := subscription.NewSubscriptionUsageRepo(db.Pool())
subscriptionTxRepo := subscription.NewSubscriptionTransactionRepo(db.Pool())
promoCodeRepo := subscription.NewPromoCodeRepo(db.Pool())
promoRedemptionRepo := subscription.NewPromoRedemptionRepo(db.Pool())
familyMemberRepo := subscription.NewFamilyMemberRepo(db.Pool())
```

### 2. Обновить инициализацию SubscriptionService

Заменить:
```go
subService := services.NewSubscriptionService(subRepo)
```

На:
```go
subService := services.NewSubscriptionService(
    subscriptionPlanRepo,
    userSubscriptionRepo,
    subscriptionUsageRepo,
    subscriptionTxRepo,
    promoCodeRepo,
    promoRedemptionRepo,
    familyMemberRepo,
    logger,
)
```

### 3. Обновить инициализацию PaymentService

Добавить после инициализации gateways:

```go
// ---------- Payment Service ----------
yookassaConfig := &domain.YooKassaConfig{
    ShopID:    cfg.Payments.YooKassaShopID,
    SecretKey: cfg.Payments.YooKassaSecretKey,
    BaseURL:   cfg.Payments.YooKassaBaseURL,
}

// Создаём YooKassa gateway с полной реализацией
yookassaGateway := services.NewYooKassaGateway(yookassaConfig, logger)

// Обновляем map gateways
gateways := map[string]domain.PaymentGateway{
    "dummy":    services.NewDummyGateway(logger),
    "yookassa": yookassaGateway,
}

paymentService := services.NewPaymentService(
    yookassaConfig,
    userSubscriptionRepo,
    subscriptionTxRepo,
    subscriptionPlanRepo,
    promoCodeRepo,
    gateways,
    logger,
)
```

### 4. Обновить инициализацию BillingService

Заменить:
```go
billingService := services.NewBillingService(subRepo, billingRepo, promoRepo, gateways)
```

На:
```go
billingService := services.NewBillingService(
    billingRepo,
    promoRepo,
    gateways,
)
```

### 5. Обновить инициализацию Handlers

Заменить:
```go
subHandler := handlers.NewSubscriptionHandler(subService, logger)
billingHandler := handlers.NewBillingHandler(billingService, logger)
```

На:
```go
subHandler := handlers.NewSubscriptionHandler(subService, paymentService, logger)
paymentHandler := handlers.NewPaymentHandler(paymentService, logger)
billingHandler := handlers.NewBillingHandler(paymentService, logger)
```

### 6. Зарегистрировать новые routes

В секции регистрации маршрутов добавить:

```go
// Subscription routes
routes.RegisterSubscriptionRoutes(router, subHandler)
routes.RegisterSubscriptionProtectedRoutes(authenticated, subHandler)
routes.RegisterPaymentRoutes(router, paymentHandler)
routes.RegisterBillingRoutes(router, billingHandler)
```

## Применение миграций

Перед запуском применить миграции:

```bash
migrate -path server/migrations -database "postgres://user:pass@localhost:5432/dbname?sslmode=disable" up
```

Или через Docker:

```bash
docker-compose exec server migrate -path /app/migrations -database "postgres://..." up
```

## Проверка

После запуска проверить:

1. GET http://localhost:8080/api/v1/subscription/plans - список планов
2. GET http://localhost:8080/api/v1/subscription/current (с токеном) - текущая подписка
3. Webhook: POST http://localhost:8080/api/v1/payment/webhook/yookassa
