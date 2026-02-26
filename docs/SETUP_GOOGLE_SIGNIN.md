# Инструкция: Исправление redirect_uri_mismatch для Google Sign-In

## Краткое резюме

**Проблема:** Google возвращает ошибку 400 `redirect_uri_mismatch` при попытке входа через Google на сайте.

**Причина:** Пакет `google_sign_in` для Flutter Web использует Firebase Auth OAuth flow. Redirect URI должен быть зарегистрирован в Google Cloud Console.

**Решение:** Добавить правильные redirect URI в Google Cloud Console и проверить настройки Firebase.

---

## Какие redirect URI нужно добавить в Google Cloud Console

### 1. Откройте Google Cloud Console

Перейдите на: https://console.cloud.google.com/apis/credentials

### 2. Найдите OAuth 2.0 Client ID

Client ID: `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com`

Тип: **Web application**

### 3. Добавьте Authorized redirect URIs

```
# Firebase Auth handler (ОСНОВНОЙ - используется google_sign_in)
https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler

# Локальная разработка (popup flow)
http://localhost:8080/__auth__/callback
http://localhost:3000/__auth__/callback

# Продакшен
https://outfitstyle.app/__auth__/callback
https://www.outfitstyle.app/__auth__/callback
```

### 4. Добавьте Authorized JavaScript origins

```
http://localhost:8080
http://localhost:3000
https://outfitstyle.app
https://www.outfitstyle.app
https://outfitstyle-ce15f.firebaseapp.com
```

### 5. Сохраните и подождите

Нажмите **SAVE** и подождите 2-5 минут для применения настроек.

---

## Что проверить в коде

### Файл: `client/lib/src/services/auth_service_web.dart`

Проверьте что `_webClientId` совпадает с Google Cloud Console:

```dart
static const _webClientId = '242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com';

_googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: _webClientId,
  serverClientId: _webClientId,
  // redirectUri НЕ используется в web-версии google_sign_in
)
```

**Важно:** Параметр `redirectUri` не поддерживается в web-версии `google_sign_in`. Redirect управляется автоматически через Firebase Auth.

---

## Проверка Firebase Console

1. Откройте: https://console.firebase.google.com/project/outfitstyle-ce15f/authentication/providers

2. Проверьте **Google** провайдер:
   - Включён
   - Web SDK configuration заполнен:
     - Client ID: `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com`
     - Client Secret: (должен быть указан)

3. Проверьте **Authorized domains**:
   - `localhost`
   - `outfitstyle-ce15f.firebaseapp.com`

---

## Проверка бэкенда (Go)

### Файл: `.env`

```bash
GOOGLE_CLIENT_ID=242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
```

Перезапустите сервер после изменений.

---

## Пошаговая инструкция по настройке

### Шаг 1: Google Cloud Console

1. Откройте https://console.cloud.google.com/apis/credentials
2. Выберите проект **outfitstyle-ce15f**
3. Найдите OAuth 2.0 Client ID (Web application)
4. Добавьте redirect URIs (см. выше)
5. Добавьте JavaScript origins (см. выше)
6. Сохраните
7. Подождите 2-5 минут

### Шаг 2: Firebase Console

1. Откройте https://console.firebase.google.com/project/outfitstyle-ce15f/authentication/providers
2. Нажмите **Google**
3. Проверьте Web SDK configuration
4. Проверьте Authorized domains
5. Сохраните

### Шаг 3: Тестирование

1. Очистите кэш браузера: `Ctrl+Shift+Delete` → Clear cache
2. Откройте DevTools Console (F12)
3. Запустите Flutter Web: `flutter run -d chrome --web-port=8080`
4. Нажмите "Войти через Google"
5. Проверьте консоль на ошибки

---

## Диагностика

### Ошибка сохраняется

**Проверьте:**

1. **Client ID совпадает?**
   - В коде: `auth_service_web.dart`
   - В Google Cloud Console
   - В Firebase Console
   - В бэкенде `.env`

2. **Redirect URI добавлен?**
   - Откройте https://console.cloud.google.com/apis/credentials
   - Проверьте Authorized redirect URIs
   - Должен быть: `https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler`

3. **Проект Firebase связан с Google Cloud?**
   - Firebase Console → Project Settings → General
   - Проверьте Project ID: `outfitstyle-ce15f`
   - Google Cloud Console → Выберите тот же проект

4. **Настройки применились?**
   - Подождите 5 минут после изменений
   - Очистите кэш браузера
   - Перезапустите приложение

### Логи для отладки

**Браузер (DevTools Console):**
```
[GoogleSignIn Web] Начало входа через Google
[GoogleSignIn Web] Пользователь авторизован: user@gmail.com
[GoogleSignIn Web] Google ID Token получен: yes
```

**Бэкенд (Go):**
```
Google Sign-In запрос
  token_length: 1234
  client_id: 242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
Google Sign-In успешен
  user_id: abc123...
  email: user@gmail.com
```

---

## Изменения в этом PR

### Файлы изменены:

1. **`client/lib/src/services/auth_service_web.dart`**
   - Обновлён комментарий о том что redirectUri не используется в web
   - Добавлена документация о необходимости настройки в Google Cloud Console

2. **`docs/google-signin-web-setup.md`**
   - Полностью переписана документация
   - Добавлена причина проблемы
   - Добавлены пошаговые инструкции
   - Добавлен чеклист для диагностики
   - Добавлена секция по устранению ошибок

3. **`docs/SETUP_GOOGLE_SIGNIN.md`** (новый файл)
   - Краткая инструкция для быстрой настройки

---

## Ссылки

- [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)
- [Firebase Console - Authentication](https://console.firebase.google.com/project/outfitstyle-ce15f/authentication/providers)
- [google_sign_in package](https://pub.dev/packages/google_sign_in)
- [FlutterFire Authentication](https://firebase.flutter.dev/docs/auth/overview)
- [Google Identity Services Documentation](https://developers.google.com/identity/gsi/web)
