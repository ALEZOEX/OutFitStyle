# Требования к исправлению: Настройка Firebase Admin Credentials

## Введение

Backend не может верифицировать Firebase ID токены при входе через Google Sign-In, потому что Firebase Admin SDK не инициализирован. Это происходит из-за отсутствия Firebase service account credentials в переменных окружения. Когда пользователь пытается войти через Google, backend возвращает 401 Unauthorized, и клиент никогда не получает `access_token` для последующих API запросов.

## Анализ проблемы

### Текущее поведение (дефект)

1.1 КОГДА пользователь пытается войти через Google Sign-In И отправляет Firebase ID token на `/api/v1/auth/google` ТОГДА backend не может верифицировать токен, потому что Firebase Admin SDK не инициализирован

1.2 КОГДА backend пытается инициализировать Firebase Admin SDK ТОГДА он ищет `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON` в переменных окружения

1.3 КОГДА переменные окружения не содержат Firebase credentials ТОГДА backend логирует warning и отключает Firebase auth

1.4 КОГДА Firebase auth отключен ТОГДА все запросы на `/api/v1/auth/google` возвращают 401 Unauthorized

1.5 КОГДА клиент получает 401 от `/api/v1/auth/google` ТОГДА он не может получить `access_token` и все последующие API запросы падают с 401

### Ожидаемое поведение (правильное)

2.1 КОГДА backend стартует ТОГДА он должен успешно инициализировать Firebase Admin SDK с использованием credentials из переменных окружения

2.2 КОГДА пользователь отправляет Firebase ID token на `/api/v1/auth/google` ТОГДА backend должен верифицировать токен через Firebase Admin SDK

2.3 КОГДА Firebase ID token верифицирован ТОГДА backend должен создать или обновить пользователя и вернуть `access_token`

2.4 КОГДА клиент получает `access_token` от `/api/v1/auth/google` ТОГДА он может использовать его для аутентификации всех последующих API запросов

2.5 КОГДА переменная окружения `FIREBASE_CREDENTIALS_PATH` установлена ТОГДА backend должен прочитать credentials из файла

2.6 КОГДА переменная окружения `FIREBASE_CREDENTIALS_JSON` установлена ТОГДА backend должен использовать credentials из строки

### Неизменяемое поведение (предотвращение регрессии)

3.1 КОГДА backend стартует БЕЗ Firebase credentials ТОГДА он должен логировать warning, но продолжить работу (graceful degradation)

3.2 КОГДА пользователь входит через email/password ТОГДА система должна продолжать работать без Firebase

3.3 КОГДА пользователь входит через Google И credentials настроены ТОГДА система должна создавать нового пользователя автоматически

3.4 КОГДА пользователь входит через Google И пользователь уже существует ТОГДА система должна обновить его профиль данными из Google

3.5 КОГДА Firebase credentials неверные или истекли ТОГДА backend должен вернуть 401 Unauthorized (не crash)

## Корневая причина

Backend использует Firebase Admin SDK для верификации Google ID токенов. Инициализация SDK требует service account credentials, которые должны быть предоставлены через:

1. **FIREBASE_CREDENTIALS_PATH** — путь к JSON файлу с credentials
2. **FIREBASE_CREDENTIALS_JSON** — содержимое JSON как строка окружения

В текущей конфигурации `.env` обе переменные отсутствуют, поэтому Firebase Admin SDK не инициализируется, и все попытки верифицировать Google токены падают с ошибкой.

**Код в `server/internal/api/middleware/firebase_admin_client.go` (строки 23-68):**
- Проверяет `FIREBASE_CREDENTIALS_PATH` и `FIREBASE_CREDENTIALS_JSON`
- Если обе пусты, логирует warning и возвращает `nil`
- Backend продолжает работу, но Google auth не работает

**Результат:**
- Все запросы на `/api/v1/auth/google` возвращают 401 Unauthorized
- Клиент не может получить `access_token`
- Все последующие API запросы падают с 401

## Требуемые изменения

### Файл: `.env`

Добавить одну из двух переменных окружения:

**Вариант 1 — путь к файлу (рекомендуется для production):**
```
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
```

**Вариант 2 — JSON как строка (для Docker/CI):**
```
FIREBASE_CREDENTIALS_JSON={"type":"service_account","project_id":"outfitstyle-ce15f",...}
```

### Файл: `firebase-credentials.json` (если используется Вариант 1)

Создать файл с Firebase service account credentials:
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

## Свойства корректности

**Свойство 1: Firebase Admin SDK инициализирован**

_Для любого_ запуска backend, если `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON` установлены, Firebase Admin SDK ДОЛЖЕН успешно инициализироваться и быть готовым к верификации Google ID токенов.

**Валидирует требования:** 2.1, 2.5, 2.6

**Свойство 2: Google Sign-In работает**

_Для любого_ запроса на `/api/v1/auth/google` с валидным Firebase ID token, backend ДОЛЖЕН верифицировать токен, создать/обновить пользователя и вернуть `access_token` с кодом 200 OK.

**Валидирует требования:** 2.2, 2.3, 2.4

**Свойство 3: Graceful degradation**

_Для любого_ запуска backend БЕЗ Firebase credentials, backend ДОЛЖЕН логировать warning, продолжить работу, и email/password аутентификация ДОЛЖНА продолжать работать.

**Валидирует требования:** 3.1, 3.2

**Свойство 4: Обработка ошибок**

_Для любого_ запроса на `/api/v1/auth/google` с неверным или истекшим Firebase ID token, backend ДОЛЖЕН вернуть 401 Unauthorized (не crash).

**Валидирует требования:** 3.5
