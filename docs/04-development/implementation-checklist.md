# Чек-лист для разработчика

## Если ты хочешь добавить новую функцию

### 1. Подумай что нужно сделать

- [ ] Это новая страница в приложении?
- [ ] Это новый API запрос?
- [ ] Это изменение в базе данных?
- [ ] Это новая ML фича?

### 2. Настрой окружение

- [ ] Установлен Docker
- [ ] Установлен Go
- [ ] Установлен Python
- [ ] Установлен Flutter

### 3. Напиши код

**Backend (Go):**
- [ ] Создай новый handler в `server/internal/api/handlers/`
- [ ] Добавь route в `server/internal/api/routes/`
- [ ] Напиши тесты

**Frontend (Flutter):**
- [ ] Создай новый экран в `client/lib/src/screens/`
- [ ] Добавь виджеты в `client/lib/src/widgets/`
- [ ] Обнови навигацию

**База данных:**
- [ ] Создай миграцию в `server/migrations/`
- [ ] Обнови модели в `server/internal/core/domain/`

### 4. Проверь себя

- [ ] Код компилируется: `go build ./...`
- [ ] Тесты проходят: `go test ./...`
- [ ] Flutter анализ: `flutter analyze`
- [ ] Docker контейнеры запускаются

### 5. Закоммить

- [ ] Осмысленное сообщение коммита
- [ ] Нет лишних файлов (.env, секреты)
- [ ] Код отформатирован

## Частые задачи

### Добавить новый API endpoint

1. Создай handler: `server/internal/api/handlers/my_handler.go`
2. Добавь route: `server/internal/api/routes/my_routes.go`
3. Напиши тест: `server/internal/api/handlers/my_handler_test.go`

### Добавить новую таблицу в БД

1. Создай миграцию: `server/migrations/000X_my_table.up.sql`
2. Обнови домен: `server/internal/core/domain/domain.go`
3. Добавь репозиторий: `server/internal/infrastructure/persistence/postgres/`

### Добавить новый экран во Flutter

1. Создай экран: `client/lib/src/screens/my_screen.dart`
2. Добавь роут: `client/lib/src/routes/app_router.dart`
3. Добавь кнопку на предыдущем экране

## Советы

- Смотри существующий код как пример
- Запускай тесты перед коммитом
- Не коммить .env файлы с паролями!
- Пиши понятные имена переменных
