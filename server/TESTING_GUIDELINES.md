# Рекомендации по тестированию

## Типы тестов

### 1. Модульные тесты
- Размещаются в тех же пакетах, что и тестируемый код
- Имя файла: `имя_файла_test.go`
- Проверяют отдельные функции и методы

### 2. Интеграционные тесты
- Размещаются в `internal/core/application/services/test/`
- Проверяют взаимодействие между несколькими компонентами
- Используют реальные или мок-реализации зависимостей

### 3. Тесты валидации
- Размещаются в `internal/validation/test/`
- Проверяют корректность работы валидаторов

## Структура тестов

### Для сервисов:
```
internal/core/application/services/
├── auth_service.go
├── auth_service_test.go
├── user_service.go
├── user_service_test.go
└── test/
    ├── fixtures.go (фикстуры для тестов)
    └── mocks.go (моки для тестов)
```

### Для валидации:
```
internal/validation/
├── validator.go
├── validator_test.go
└── test/
    └── validation_fixtures.go
```

## Пример теста

```go
// auth_service_test.go
package services

import (
    "context"
    "testing"
)

func TestAuthService_Register(t *testing.T) {
    // Подготовка
    service := NewAuthService(mockUserRepo, mockSessionRepo, ...)
    
    // Выполнение
    result, err := service.Register(context.Background(), validInput)
    
    // Проверка
    assert.NoError(t, err)
    assert.NotNil(t, result.User)
}
```

## Покрытие кода

- Цель: не менее 70% покрытия для критических компонентов
- Использовать `go test -cover` для проверки покрытия
- Покрытие бизнес-логики особенно важно