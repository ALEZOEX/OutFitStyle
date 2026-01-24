# Рекомендации по тестированию

## Структура тестов

### 1. Модульные тесты (Unit Tests)
- Размещаются рядом с тестируемым кодом
- Имя файла: `имя_файла_test.go`
- Пример: `auth_service.go` → `auth_service_test.go`
- Используют моки для зависимостей

### 2. Интеграционные тесты (Integration Tests)
- Размещаются в `test/integration/` в корне сервера
- Имя файла: `имя_компонента_integration_test.go`
- Используют реальные зависимости (база данных, внешние API)

### 3. E2E тесты (End-to-End Tests)
- Размещаются в `test/e2e/` в корне сервера
- Тестируют полные сценарии через API

## Пример структуры

```
server/
├── internal/
│   └── core/
│       └── application/
│           └── services/
│               ├── auth_service.go
│               └── auth_service_test.go      # Модульные тесты для AuthService
├── test/
│   ├── integration/
│   │   ├── auth_service_integration_test.go  # Интеграционные тесты
│   │   └── recommendation_service_integration_test.go
│   └── e2e/
│       └── api_e2e_test.go                 # E2E тесты API
└── TESTING_STRUCTURE.md                     # Документация по тестированию
```

## Типы тестов

### 1. Модульные (Unit)
- Тестируют отдельные функции и методы
- Используют моки для зависимостей
- Быстрые и надежные
- Покрытие: 70%+ для критических компонентов

### 2. Интеграционные (Integration)
- Тестируют взаимодействие между компонентами
- Используют реальные зависимости
- Проверяют корректность интеграции
- Покрытие: 50%+ для основных сценариев

### 3. E2E (End-to-End)
- Тестируют полные сценарии использования
- Используют реальный API
- Проверяют работоспособность системы в целом
- Покрытие: 30%+ для основных пользовательских сценариев

## Пример модульного теста

```go
func TestAuthService_Register(t *testing.T) {
    // Подготовка
    mockUserRepo := new(MockUserRepository)
    authService := NewAuthService(mockUserRepo, nil, nil, nil)

    // Тестовые данные
    input := domain.UserRegistration{
        Email:    "test@example.com",
        Password: "password123",
    }

    // Ожидания
    mockUserRepo.On("GetUserByEmail", mock.Anything, "test@example.com").Return(nil, repositories.ErrNotFound)
    mockUserRepo.On("CreateUser", mock.Anything, mock.AnythingOfType("*domain.User")).Return(nil)

    // Выполнение
    result, err := authService.Register(context.Background(), input, DeviceInfo{})

    // Проверка
    assert.NoError(t, err)
    assert.NotNil(t, result.User)

    // Проверка вызовов
    mockUserRepo.AssertExpectations(t)
}
```

## Пример интеграционного теста

```go
func TestAuthService_Register_Integration(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping integration test")
    }

    // Подключение к тестовой базе данных
    db, err := ConnectTestDB()
    require.NoError(t, err)
    defer db.Close()

    // Создание реальных репозиториев
    userRepo := pg.NewUserRepository(db.Pool())
    sessionRepo := pg.NewSessionRepository(db.Pool())

    // Создание сервиса с реальными зависимостями
    authService := services.NewAuthService(userRepo, sessionRepo, nil, nil)

    // Тестирование
    ctx := context.Background()
    input := domain.UserRegistration{
        Email:    "integration_test@example.com",
        Password: "password123",
    }

    result, err := authService.Register(ctx, input, services.DeviceInfo{})
    assert.NoError(t, err)
    assert.NotNil(t, result.User)

    // Проверка, что пользователь создан в базе
    user, err := userRepo.GetUserByEmail(ctx, input.Email)
    assert.NoError(t, err)
    assert.NotNil(t, user)
}
```

## Покрытие кода

- Цель: не менее 70% покрытия для критических компонентов
- Использовать `go test -cover` для проверки покрытия
- Покрытие бизнес-логики особенно важно
- Использовать `go test -race` для проверки гонок
- Использовать `go vet` и `staticcheck` для статического анализа