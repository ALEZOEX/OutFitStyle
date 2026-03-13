# Дизайн: Настройка Firebase Admin Credentials

## Обзор

Backend не может верифицировать Google ID токены, потому что Firebase Admin SDK не инициализирован из-за отсутствия credentials в переменных окружения. Решение простое: добавить `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON` в `.env` файл.

Код для инициализации Firebase Admin SDK уже реализован в `server/internal/api/middleware/firebase_admin_client.go` и корректно обрабатывает обе переменные окружения. Нужно только предоставить credentials.

## Словарь

- **Bug_Condition (C)**: Запросы на `/api/v1/auth/google` падают с 401, потому что Firebase Admin SDK не инициализирован
- **Property (P)**: Firebase Admin SDK успешно инициализирован и верифицирует Google ID токены
- **Preservation**: Email/password аутентификация продолжает работать, graceful degradation при отсутствии credentials
- **Firebase Admin SDK**: Библиотека для верификации Firebase ID токенов на backend
- **Service Account**: Учетная запись Google Cloud для программного доступа к Firebase
- **FIREBASE_CREDENTIALS_PATH**: Переменная окружения с путем к JSON файлу credentials
- **FIREBASE_CREDENTIALS_JSON**: Переменная окружения с JSON credentials как строка

## Детали проблемы

### Bug Condition

Когда пользователь пытается войти через Google Sign-In:

1. Клиент получает Firebase ID token
2. Клиент отправляет token на `/api/v1/auth/google`
3. Backend пытается верифицировать token через Firebase Admin SDK
4. **Firebase Admin SDK не инициализирован** (credentials отсутствуют)
5. Backend возвращает 401 Unauthorized
6. Клиент не получает `access_token`
7. Все последующие API запросы падают с 401

**Формальная спецификация:**
```
FUNCTION isBugCondition(request)
  INPUT: request of type HTTP Request
  OUTPUT: boolean

  RETURN request.path == '/api/v1/auth/google'
         AND request.method == 'POST'
         AND firebaseAdminSDKNotInitialized()
         AND firebaseIDTokenProvided(request)
END FUNCTION
```

### Примеры

- **Google Sign-In**: Пользователь нажимает "Sign in with Google", получает Firebase ID token, отправляет на backend → backend возвращает 401
яемые поведения:**
- Email/password аутентификация должна продолжать работать
- Если credentials не предоставлены, backend должен логировать warning и продолжить работу
- Все остальные API endpoints должны продолжать работать
- Обработка ошибок должна быть graceful (не crash)

**Область:**
Все операции, которые не зависят от Firebase auth, должны быть полностью не затронуты этим изменением.

## Гипотетическая корневая причина

Анализ кода показывает:

1. **Firebase Admin SDK инициализируется в `firebase_admin_client.go`** (строки 23-68)
   - Проверяет `FIREBASE_CREDENTIALS_PATH` и `FIREBASE_CREDENTIALS_JSON`
   - Если обе пусты, логирует warning и возвращает `nil`

2. **Backend использует Firebase SDK в `auth_service.go`** (строка 346)
   - Вызывает `s.google.Verify(ctx, idToken)` для верификации Google токена
   - Если SDK не инициализирован, это падает с ошибкой

3. **В `.env` отсутствуют credentials**
   - `FIREBASE_CREDENTIALS_PATH` не установлена
   - `FIREBASE_CREDENTIALS_JSON` не установлена
   - Поэтому Firebase Admin SDK не инициализируется

**Почему это вызывает 401 ошибки:**
- Backend не может верифицировать Google ID token
- Возвращает 401 Unauthorized
- Клиент не получает `access_token`
- Все последующие API запросы падают с 401

## Свойства корректности

**Свойство 1: Firebase Admin SDK инициализирован**

_Для любого_ запуска backend, если `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON` установлены, Firebase Admin SDK ДОЛЖЕН успешно инициализироваться.

**Валидирует требования:** 2.1, 2.5, 2.6

**Свойство 2: Google Sign-In работает**

_Для любого_ запроса на `/api/v1/auth/google` с валидным Firebase ID token, backend ДОЛЖЕН верифицировать token и вернуть `access_token`.

**Валидирует требования:** 2.2, 2.3, 2.4

**Свойство 3: Graceful degradation**

_Для любого_ запуска backend БЕЗ Firebase credentials, backend ДОЛЖЕН логировать warning и продолжить работу.

**Валидирует требования:** 3.1, 3.2

## Реализация исправления

### Требуемые изменения

**Файл 1**: `.env`

**Изменение 1**: Добавить `FIREBASE_CREDENTIALS_PATH`
```
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
```

Или **Изменение 2**: Добавить `FIREBASE_CREDENTIALS_JSON`
```
FIREBASE_CREDENTIALS_JSON={"type":"service_account",...}
```

**Файл 2**: `firebase-credentials.json` (если используется FIREBASE_CREDENTIALS_PATH)

**Содержимое**: Firebase service account JSON
```json
{
  "type": "service_account",
  "project_id": "outfitstyle-ce15f",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "outfitstyle-admin@outfitstyle-ce15f.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

## Стратегия тестирования

### Подход валидации

Двухфазный подход: сначала подтвердить, что проблема существует (Firebase SDK не инициализирован), затем проверить, что исправление работает.

### Проверка Bug Condition

**Цель**: Подтвердить, что Google Sign-In падает с 401 из-за отсутствия Firebase credentials.

**План тестирования**:
1. Запустить backend БЕЗ `FIREBASE_CREDENTIALS_PATH` и `FIREBASE_CREDENTIALS_JSON`
2. Попытаться войти через Google Sign-In
3. Проверить, что `/api/v1/auth/google` возвращает 401 Unauthorized
4. Проверить логи backend на warning о Firebase credentials

**Ожидаемый результат**:
- Запрос на `/api/v1/auth/google` возвращает 401
- Логи содержат: "firebase: credentials not configured, Firebase auth will be disabled"

### Проверка исправления

**Цель**: Проверить, что Google Sign-In работает после добавления Firebase credentials.

**План тестирования**:
1. Добавить `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON` в `.env`
2. Перезапустить backend
3. Попытаться войти через Google Sign-In
4. Проверить, что `/api/v1/auth/google` возвращает 200 OK с `access_token`
5. Проверить, что последующие API запросы работают с `access_token`

**Ожидаемый результат**:
- Запрос на `/api/v1/auth/google` возвращает 200 OK
- Ответ содержит `access_token`
- Логи содержат: "firebase: initialized with credentials file" или "firebase: initialized with credentials JSON"
- Последующие API запросы работают с `access_token`

### Unit тесты

- Проверить, что Firebase Admin SDK инициализируется с `FIREBASE_CREDENTIALS_PATH`
- Проверить, что Firebase Admin SDK инициализируется с `FIREBASE_CREDENTIALS_JSON`
- Проверить, что Firebase Admin SDK логирует warning при отсутствии credentials
- Проверить, что backend продолжает работать без Firebase credentials

### Integration тесты

- Полный flow Google Sign-In: получить Firebase token → отправить на backend → получить `access_token` → использовать для API запросов
- Проверить, что email/password аутентификация продолжает работать
- Проверить graceful degradation при отсутствии credentials
- Проверить обработку ошибок при неверных credentials
