# Стратегия тестирования OutfitStyle

## 📊 Уровни тестирования

```
         ┌─────────────┐
         │   E2E       │  < 10% (критические пути)
         ├─────────────┤
         │Integration  │  20-30% (API, БД, внешние сервисы)
         ├─────────────┤
         │   Unit      │  60-70% (бизнес-логика)
         └─────────────┘
```

---

## 🧪 Backend (Go)

### Unit тесты

**Что тестировать:**
- Сервисы (business logic)
- Handlers (HTTP обработка)
- Utilities

**Пример:**

```go
// internal/services/auth_test.go
func TestAuthService_GoogleLogin(t *testing.T) {
    // Arrange
    mockRepo := NewMockRepository()
    service := NewAuthService(mockRepo)
    
    // Act
    tokens, err := service.GoogleLogin(ctx, validIDToken)
    
    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, tokens)
    assert.NotEmpty(t, tokens.AccessToken)
}
```

**Запуск:**
```bash
go test ./internal/services/... -v
go test -coverprofile=coverage.out ./...
```

### Integration тесты

**Что тестировать:**
- API endpoints
- Database queries
- Внешние сервисы (Google OAuth, YooKassa)

**Пример:**
```go
// internal/handlers/auth_integration_test.go
//go:build integration

func TestAuthHandler_GoogleLogin_Integration(t *testing.T) {
    // Реальная БД и сервисы
}
```

**Запуск:**
```bash
go test -tags=integration ./internal/handlers/...
```

---

## 📱 Flutter Client

### Unit тесты

**Что тестировать:**
- Providers (Riverpod)
- Repositories
- Use Cases

**Пример:**
```dart
// features/auth/providers/auth_provider_test.dart
void testAuthProvider_googleLogin() {
  // Arrange
  final authRepo = MockAuthRepository();
  when(authRepo.signInWithGoogle()).thenAnswer(
    (_) async => TokenPair(...)
  );
  
  // Act
  final notifier = AuthNotifier(authRepo);
  await notifier.googleLogin();
  
  // Assert
  expect(notifier.state, isA<AuthAuthenticated>());
}
```

**Запуск:**
```bash
flutter test
flutter test --coverage
```

### Widget тесты

**Что тестировать:**
- Отдельные виджеты
- Экраны (в изоляции)

**Пример:**
```dart
testWidgets('AuthScreen shows Google button', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: AuthScreen())),
  );
  
  expect(find.byIcon(Icons.login), findsOneWidget);
});
```

### Integration тесты

**Что тестировать:**
- Критические user flows
- Навигация между экранами

**Пример:**
```dart
// integration_test/auth_flow_test.dart
void main() {
  testWidgets('Complete auth flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Tap Google button
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();
    
    // Verify navigation
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

**Запуск:**
```bash
flutter test integration_test/
```

---

## 🤖 ML Service

### Unit тесты

**Что тестировать:**
- Feature engineering
- Model inference
- Data validation

**Пример:**
```python
# tests/test_inference.py
def test_model_predict():
    model = load_model('model.cbm')
    features = create_features(temperature=20, condition='sunny')
    
    prediction = model.predict(features)
    
    assert len(prediction) > 0
    assert all(0 <= p <= 1 for p in prediction)
```

**Запуск:**
```bash
pytest tests/ -v
pytest --cov=ml_service tests/
```

### Integration тесты

**Что тестировать:**
- API endpoints
- Full inference pipeline

**Пример:**
```python
# tests/test_api.py
def test_recommendation_endpoint():
    response = client.post('/api/v1/recommend', json={
        'user_id': 'test',
        'weather': {'temp': 20, 'condition': 'sunny'}
    })
    
    assert response.status_code == 200
    assert 'recommendations' in response.json()
```

---

## 📈 Coverage требования

| Компонент | Min Coverage |
|-----------|--------------|
| **Backend Services** | 80% |
| **Backend Handlers** | 70% |
| **Flutter Providers** | 80% |
| **Flutter Widgets** | 50% |
| **ML Inference** | 90% |

---

## 🔄 CI/CD интеграция

### GitHub Actions workflow

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - run: go test ./... -coverprofile=coverage.out
      
  test-flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      
  test-ml:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
      - run: pip install -r requirements.txt
      - run: pytest tests/ --cov=ml_service
```

---

## 📝 Best Practices

### 1. Пишите тестируемый код

```go
// ❌ Плохо: сложно тестировать
func GetUser(id string) (*User, error) {
    db := connectToDatabase()
    // ...
}

// ✅ Хорошо: легко мокать
func GetUser(ctx context.Context, repo Repository, id string) (*User, error) {
    return repo.GetUser(ctx, id)
}
```

### 2. Используйте моки

```dart
// ❌ Плохо: реальные зависимости
final authRepo = AuthRepository();

// ✅ Хорошо: моки для тестов
final authRepo = MockAuthRepository();
```

### 3. Тестируйте поведение, не реализацию

```python
# ❌ Плохо: проверка внутренних деталей
assert model._layers[0].weights == expected

# ✅ Хорошо: проверка результата
assert model.predict(input) == expected_output
```

### 4. Называйте тесты понятно

```go
// ❌ Плохо
func TestAuth(t *testing.T) {}

// ✅ Хорошо
func TestAuthService_GoogleLogin_WithValidToken_ReturnsTokens(t *testing.T) {}
```

---

## 🐛 Отладка тестов

### Backend
```bash
# Запуск конкретного теста
go test -run TestAuthService_GoogleLogin -v

# Debug с delve
dlv test ./internal/services -- TestAuthService_GoogleLogin
```

### Flutter
```bash
# Запуск конкретного теста
flutter test test/auth_provider_test.dart

# С выводом логов
flutter test --reporter=expanded
```

### ML Service
```bash
# Запуск конкретного теста
pytest tests/test_inference.py::test_model_predict -v

# С pdb для отладки
pytest tests/test_inference.py -s
```

---

## 📚 Ресурсы

- [Go Testing](https://golang.org/pkg/testing/)
- [Flutter Testing](https://flutter.dev/docs/testing)
- [pytest](https://docs.pytest.org/)

---

**Обновлено:** Февраль 2026
