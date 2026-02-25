# Настройка Google Sign-In для Web

## Проблема
Google Sign-In на веб-сайте возвращал ошибку 401, токены не сохранялись после входа.

## Решение

### 1. Изменения в Flutter Web

#### AuthStorage для Web
- Создан отдельный файл `auth_storage_web.dart` с использованием `dart:html localStorage`
- `flutter_secure_storage` не работает на вебе по умолчанию
- Токены теперь сохраняются в `localStorage` с префиксом `os_`

#### AuthService для Web
- **Критично**: Используется `GoogleSignIn.signIn()` для получения **Google ID Token**, а не Firebase ID Token
- Firebase Auth `getIdToken()` возвращает Firebase токен, который не подходит для бэкенда
- Бэкенд ожидает Google ID Token для верификации через `google.golang.org/api/idtoken`

### 2. Настройка Google Cloud Console

#### Требуемые настройки OAuth 2.0

1. Откройте [Google Cloud Console](https://console.cloud.google.com/)
2. Перейдите в **APIs & Services** > **Credentials**
3. Создайте или отредактируйте **OAuth 2.0 Client ID** типа **Web application**

#### Обязательные поля:

**Authorized JavaScript origins:**
```
http://localhost:8080
http://localhost:3000
https://outfitstyle.app
https://www.outfitstyle.app
```

**Authorized redirect URIs:**
```
http://localhost:8080/auth/callback
http://localhost:3000/auth/callback
https://outfitstyle.app/auth/callback
https://www.outfitstyle.app/auth/callback
```

#### Client ID для приложения:
```
242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
```

### 3. Настройка Firebase Console

1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Выберите проект **outfitstyle-ce15f**
3. Перейдите в **Authentication** > **Sign-in method**
4. Включите **Google** провайдер
5. Добавьте домен в **Authorized domains**:
   - `outfitstyle-ce15f.firebaseapp.com`
   - `localhost` (для разработки)
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
