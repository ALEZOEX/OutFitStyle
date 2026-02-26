# Настройка Google Sign-In для Web

## Проблема
Google Sign-In на веб-сайте возвращал ошибку 400 `redirect_uri_mismatch`.

## Причина проблемы

Пакет `google_sign_in` для Flutter Web использует Firebase Auth OAuth flow. 
Redirect URI определяется автоматически и имеет формат:
```
https://<project-id>.firebaseapp.com/__/auth/handler
```

Для локальной разработки также может использоваться:
```
http://localhost:<port>/__auth__/callback
```

## Решение

### 1. Настройка Google Cloud Console (КРИТИЧНО)

#### Пошаговая инструкция:

1. **Откройте Google Cloud Console**
   - Перейдите на https://console.cloud.google.com/
   - Выберите проект **outfitstyle-ce15f** (или создайте новый)

2. **Перейдите к Credentials**
   - В левом меню: **APIs & Services** → **Credentials**
   - Или напрямую: https://console.cloud.google.com/apis/credentials

3. **Найдите OAuth 2.0 Client ID**
   - Найдите существующий Client ID типа **Web application**
   - Или создайте новый: **CREATE CREDENTIALS** → **OAuth client ID**
   - Тип приложения: **Web application**

4. **Добавьте Authorized JavaScript origins**
   ```
   http://localhost:8080
   http://localhost:3000
   https://outfitstyle.app
   https://www.outfitstyle.app
   https://outfitstyle-ce15f.firebaseapp.com
   ```

5. **Добавьте Authorized redirect URIs** (самое важное!)
   ```
   # Firebase Auth handler (основной для google_sign_in)
   https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler
   
   # Локальная разработка (может использоваться для popup flow)
   http://localhost:8080/__auth__/callback
   http://localhost:3000/__auth__/callback
   
   # Продакшен
   https://outfitstyle.app/__auth__/callback
   https://www.outfitstyle.app/__auth__/callback
   ```

6. **Сохраните изменения**
   - Нажмите **SAVE**
   - Скопируйте **Client ID** (должен совпадать с используемым в коде)

> **Важно:** Изменения в Google Cloud Console могут применяться до 5 минут.

### 2. Настройка Firebase Console

1. **Откройте Firebase Console**
   - Перейдите на https://console.firebase.google.com/
   - Выберите проект **outfitstyle-ce15f**

2. **Настройте Authentication**
   - Перейдите в **Authentication** → **Sign-in method**
   - Включите провайдер **Google**
   - Добавьте **Web SDK configuration**:
     - Client ID: `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com`
     - Client Secret: (получить в Google Cloud Console)

3. **Добавьте Authorized domains**
   - Перейдите во вкладку **Authorized domains**
   - Добавьте домены:
     - `localhost` (для разработки)
     - `outfitstyle-ce15f.firebaseapp.com`
     - `outfitstyle.app` (для продакшена)

### 4. Настройка Бэкенда (Go)

#### Переменные окружения:
```bash
# Обязательно: Google Client ID должен совпадать с используемым во Flutter
GOOGLE_CLIENT_ID=242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret

# CORS для веба
CORS_ALLOWED_ORIGINS=http://localhost:8080,https://outfitstyle.app
```

### 5. Проверка работы

#### Логи Flutter Web (откройте DevTools Console):
```
[GoogleSignIn Web] Начало входа через Google
[GoogleSignIn Web] Пользователь авторизован: user@gmail.com
[GoogleSignIn Web] Google ID Token получен: yes
[GoogleSignIn Web] Отправка токена на бэкенд: /api/v1/auth/google
[GoogleSignIn Web] Ответ от бэкенда: status=200
[GoogleSignIn Web] Токены получены: access=eyJhb...
[GoogleSignIn Web] Сессия сохранена
```

#### Логи Бэкенда:
```
Google Sign-In запрос
  token_length: 1234
  token_prefix: eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...
  remote_addr: 127.0.0.1
  user_agent: Mozilla/5.0...

Вызов AuthService.GoogleSignIn
  client_id: 242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com

Google Sign-In успешен
  user_id: abc123...
  email: user@gmail.com
  display_name: John Doe
  is_new_user: false
```

### 6. Частые проблемы и решения

#### Ошибка 401 Unauthorized

**Причина 1**: Неправильный токен
- Проверьте, что используется Google ID Token, а не Firebase ID Token
- В логах Flutter должно быть: `Google ID Token получен: yes`

**Причина 2**: Неверный Client ID
- Проверьте, что `GOOGLE_CLIENT_ID` на бэкенде совпадает с `clientId` во Flutter
- Client ID должен быть типа **Web application**

**Причина 3**: Токен просрочен
- Google ID Token действителен 1 час
- Попробуйте выйти и войти снова

#### Токены не сохраняются

**Для Web**:
- Откройте DevTools > Application > Local Storage
- Проверьте наличие ключей: `os_access_token`, `os_refresh_token`, `os_expires_at`
- Если пусто - проверьте, что не включен режим инкогнито (localStorage может блокироваться)

#### Popup блокируется браузером

- Разрешите popup для вашего домена
- Или используйте `signInMode: SignInMode.redirect` вместо `popup`

### 7. Тестирование

#### Локально:
```bash
# Запуск бэкенда
cd server
go run cmd/server/main.go

# Запуск Flutter Web
cd client
flutter run -d chrome --web-port=8080
```

#### Проверка в браузере:
1. Откройте `http://localhost:8080`
2. Нажмите "Войти через Google"
3. Разрешите popup
4. Выберите аккаунт Google
5. Проверьте консоль на наличие логов
6. Проверьте localStorage на наличие токенов

### 8. Структура файлов

```
client/lib/src/services/
├── auth_storage.dart          # Экспорт в зависимости от платформы
├── auth_storage_web.dart      # Web: localStorage
├── auth_storage_io.dart       # Mobile: flutter_secure_storage
├── auth_service.dart          # Экспорт в зависимости от платформы
├── auth_service_web.dart      # Web: GoogleSignIn + Firebase Auth
└── auth_service_io.dart       # Mobile: GoogleSignIn

server/internal/
├── api/handlers/auth_handler.go
├── core/application/services/auth_service.go
└── infrastructure/external/google_auth.go
```

## Изменения в этом PR

### Flutter
- ✅ Создан `auth_storage_web.dart` с использованием `dart:html localStorage`
- ✅ Создан `auth_storage_io.dart` для мобильных платформ
- ✅ Обновлён `auth_service_web.dart`: получение Google ID Token через `GoogleSignIn`
- ✅ Добавлено подробное логирование для отладки

### Бэкенд (Go)
- ✅ Добавлен метод `GoogleClientID()` в `AuthService`
- ✅ Добавлен метод `GetDisplayName()` в `User`
- ✅ Улучшено логирование в `GoogleSignIn` handler
- ✅ Добавлена информация о remote_addr и user_agent

## Как проверить что работает

1. **Очистите localStorage браузера**:
   ```javascript
   localStorage.clear()
   ```

2. **Запустите приложение** и войдите через Google

3. **Проверьте консоль браузера** - должны быть логи:
   ```
   [GoogleSignIn Web] Google ID Token получен: yes
   [GoogleSignIn Web] Токены получены
   [GoogleSignIn Web] Сессия сохранена
   ```

4. **Проверьте localStorage**:
   ```javascript
   localStorage.getItem('os_access_token')  // должен быть токен
   localStorage.getItem('os_refresh_token') // должен быть токен
   ```

5. **Проверьте логи бэкенда** - должно быть:
   ```
   Google Sign-In успешен
   ```

6. **Обновите страницу** - сессия должна сохраниться

## Чеклист: Быстрая диагностика redirect_uri_mismatch

### Шаг 1: Проверка Google Cloud Console

- [ ] Откройте https://console.cloud.google.com/apis/credentials
- [ ] Найдите OAuth 2.0 Client ID: `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com`
- [ ] Проверьте **Authorized redirect URIs** - должны включать:
  - [ ] `https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler` (основной для google_sign_in)
  - [ ] `http://localhost:8080/__auth__/callback` (для локальной разработки)
- [ ] Проверьте **Authorized JavaScript origins**:
  - [ ] `http://localhost:8080`
  - [ ] `https://outfitstyle-ce15f.firebaseapp.com`
- [ ] Тип Client ID: **Web application**

### Шаг 2: Проверка кода Flutter

- [ ] Откройте `client/lib/src/services/auth_service_web.dart`
- [ ] Проверьте `_webClientId`: `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com`
- [ ] Убедитесь что `clientId` и `serverClientId` установлены в `_webClientId`
- [ ] Проверьте что не используется параметр `redirectUri` (не поддерживается в web)

### Шаг 3: Проверка Firebase Console

- [ ] Откройте https://console.firebase.google.com/project/outfitstyle-ce15f/authentication/providers
- [ ] Проверьте что **Google** провайдер включён
- [ ] Проверьте **Web SDK configuration**:
  - Client ID: `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com`
  - Client Secret: (должен быть указан)
- [ ] Проверьте **Authorized domains**:
  - [ ] `localhost`
  - [ ] `outfitstyle-ce15f.firebaseapp.com`

### Шаг 4: Проверка бэкенда

- [ ] Проверьте `.env` файл сервера:
  ```bash
  GOOGLE_CLIENT_ID=242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
  ```
- [ ] Перезапустите сервер после изменений

### Шаг 5: Тестирование

1. Очистите кэш браузера: `Ctrl+Shift+Delete` → Clear cache
2. Откройте DevTools Console (F12)
3. Попробуйте войти через Google
4. Проверьте консоль на ошибки

## Диагностика ошибок

### Ошибка: redirect_uri_mismatch

**Симптомы:**
- Google возвращает ошибку 400 с `error=redirect_uri_mismatch`
- Popup закрывается сразу после открытия
- В консоли браузера ошибка OAuth2

**Причины:**
1. Redirect URI в Google Cloud Console не совпадает с используемым
2. Не добавлен Firebase Auth handler URI
3. Неправильный проект Firebase связан с Google Cloud

**Решение:**
```
1. Откройте Google Cloud Console:
   https://console.cloud.google.com/apis/credentials

2. Найдите OAuth 2.0 Client ID:
   242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com

3. Добавьте Authorized redirect URIs:
   → https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler
   → http://localhost:8080/__auth__/callback

4. Проверьте Firebase Console:
   https://console.firebase.google.com/project/outfitstyle-ce15f/authentication/providers
   → Google → Web SDK configuration
   → Client ID должен совпадать

5. Подождите 2-5 минут (применение настроек Google)

6. Очистите кэш браузера и попробуйте снова
```

### Ошибка: invalid_client

**Причины:**
- Неверный Client ID
- Client ID не типа "Web application"
- Client Secret не указан в Firebase

**Решение:**
- Проверьте что Client ID в коде совпадает с Google Cloud Console
- Убедитесь что тип приложения: **Web application**
- Проверьте что Client Secret указан в Firebase Console

### Ошибка: access_denied

**Причины:**
- Пользователь отменил вход
- Popup заблокирован браузером

**Решение:**
- Разрешите popup для `localhost:8080`
- Проверьте настройки блокировщиков рекламы

## Ссылки

- [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)
- [Firebase Console - Authentication](https://console.firebase.google.com/project/outfitstyle-ce15f/authentication)
- [google_sign_in package documentation](https://pub.dev/packages/google_sign_in)
- [FlutterFire Authentication](https://firebase.flutter.dev/docs/auth/overview)
