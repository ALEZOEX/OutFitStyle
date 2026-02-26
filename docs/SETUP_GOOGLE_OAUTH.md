# Настройка Google OAuth для Firebase Auth (OutfitStyle)

> **Дата обновления:** 26 февраля 2026 г.  
> **Проект Firebase:** `outfitstyle-ce15f`  
> **Основной домен:** `https://app.outfitstyle.ru`

---

## 🚨 Решение проблемы: redirect_uri_mismatch

### Симптом
```
Firebase Auth возвращает ошибку 400 redirect_uri_mismatch 
с параметром origin=https://app.outfitstyle.ru
```

### Причина
Google Cloud Console не знает о вашем домене `app.outfitstyle.ru`. Необходимо добавить его в список разрешённых origin и redirect URI.

---

## 📋 Чеклист настройки

### Необходимые URL для добавления

| Тип настройки | URL | Обязательно |
|--------------|-----|-------------|
| **Authorized JavaScript origins** | `https://app.outfitstyle.ru` | ✅ Да |
| **Authorized JavaScript origins** | `https://outfitstyle-ce15f.firebaseapp.com` | ✅ Да |
| **Authorized redirect URIs** | `https://app.outfitstyle.ru/__/auth/handler` | ✅ Да |
| **Authorized redirect URIs** | `https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler` | ✅ Да |

---

## 🔧 Пошаговая инструкция

### Шаг 1: Google Cloud Console

#### 1.1 Откройте Google Cloud Console

Перейдите по ссылке:  
👉 https://console.cloud.google.com/apis/credentials

#### 1.2 Выберите проект

В выпадающем списке проектов выберите:  
**`outfitstyle-ce15f`**

> Если проект не отображается, убедитесь что вы вошли в тот же Google-аккаунт, который используется для Firebase Console.

#### 1.3 Найдите OAuth 2.0 Client ID

В разделе **OAuth 2.0 Client IDs** найдите запись:
- **Name:** `Web client (auto created by Google Service)`
- **Type:** `Web application`
- **Client ID:** `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com`

> ⚠️ **Важно:** Не создавайте новый Client ID, если уже существует созданный Firebase. Используйте существующий.

#### 1.4 Отредактируйте Client ID

Кликните на название Client ID (карандаш ✏️) для редактирования.

#### 1.5 Добавьте Authorized JavaScript origins

В секции **Authorized JavaScript origins** добавьте:

```
https://app.outfitstyle.ru
https://outfitstyle-ce15f.firebaseapp.com
```

> 💡 **Примечание:** Для локальной разработки также рекомендуется добавить:
> ```
> http://localhost:8080
> http://localhost:3000
> http://127.0.0.1:8080
> ```

#### 1.6 Добавьте Authorized redirect URIs

В секции **Authorized redirect URIs** добавьте:

```
https://app.outfitstyle.ru/__/auth/handler
https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler
```

> 💡 **Примечание:** Для локальной разработки также рекомендуется добавить:
> ```
> http://localhost:8080/__auth__/callback
> http://localhost:3000/__auth__/callback
> ```

#### 1.7 Сохраните изменения

Нажмите кнопку **SAVE** внизу страницы.

#### 1.8 Дождитесь применения настроек

⏳ Настройки Google Cloud Console применяются в течение **2-5 минут**.

---

### Шаг 2: Firebase Console

#### 2.1 Откройте Firebase Console

Перейдите по ссылке:  
👉 https://console.firebase.google.com/project/outfitstyle-ce15f/authentication/providers

#### 2.2 Проверьте провайдер Google

1. В разделе **Sign-in method** найдите **Google**
2. Убедитесь что переключатель в положении **Enabled** (зелёный)
3. Если провайдер отключён — включите его

#### 2.3 Проверьте Web SDK configuration

В настройках Google провайдера проверьте:

| Параметр | Значение |
|----------|----------|
| **Project support email** | Ваш email для поддержки |
| **Public-facing name** | `OutfitStyle` |
| **Client ID** | `242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com` |
| **Client Secret** | Должен быть указан (скрыт) |

#### 2.4 Проверьте Authorized domains

1. Перейдите во вкладку **Settings** (в разделе Authentication)
2. В секции **Authorized domains** добавьте:

```
app.outfitstyle.ru
localhost
127.0.0.1
outfitstyle-ce15f.firebaseapp.com
```

> 💡 Если домен уже есть в списке — ничего менять не нужно.

#### 2.5 Сохраните изменения

Нажмите **Save** или **Add domain** в зависимости от действия.

---

### Шаг 3: Проверка конфигурации Flutter

#### 3.1 Проверьте firebase_options.dart

Откройте файл `client/lib/firebase_options.dart` и убедитесь что `authDomain` указан:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyCf4ePEMDigZuvniagDut8uWgc0O2NbSdk',
  appId: '1:242419520610:web:4a7393ff88f9727ecc2d3b',
  messagingSenderId: '242419520610',
  projectId: 'outfitstyle-ce15f',
  authDomain: 'outfitstyle-ce15f.firebaseapp.com',  // ✅ Должен быть указан
  storageBucket: 'outfitstyle-ce15f.firebasestorage.app',
);
```

#### 3.2 Проверьте auth_service_web.dart

Откройте файл `client/lib/src/services/auth_service_web.dart` и убедитесь что Client ID совпадает:

```dart
static const _webClientId = '242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com';
```

---

### Шаг 4: Проверка бэкенда (Go API)

#### 4.1 Проверьте .env файл

В файле `.env` сервера (или в переменных окружения Docker) проверьте:

```bash
GOOGLE_CLIENT_ID=242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
```

#### 4.2 Перезапустите сервер

После изменений в `.env` перезапустите сервер:

```bash
# Локально
cd server
go run cmd/server/main.go

# Docker
docker-compose restart server
```

---

## ✅ Проверка работы

### 1. Очистите кэш браузера

```
Ctrl + Shift + Delete → Clear cache
```

Или в DevTools:
```javascript
localStorage.clear();
sessionStorage.clear();
```

### 2. Запустите приложение

```bash
cd client
flutter run -d chrome --web-port=8080
```

### 3. Проверьте вход через Google

1. Откройте `http://localhost:8080` (или `https://app.outfitstyle.ru`)
2. Нажмите кнопку **Войти через Google**
3. Выберите аккаунт Google

### 4. Проверьте консоль браузера (F12)

Ожидаемые логи:
```
[Firebase Auth Web] Начало входа через Google (signInWithPopup)
[Firebase Auth Web] Пользователь авторизован: user@example.com
[Firebase Auth Web] ID Token получен: yes
[Firebase Auth Web] Отправка токена на бэкенд: /api/v1/auth/google
[Firebase Auth Web] Ответ от бэкенда: status=200
```

### 5. Проверьте localStorage

В DevTools Console выполните:
```javascript
localStorage.getItem('os_access_token')   // Должен вернуть токен
localStorage.getItem('os_refresh_token')  // Должен вернуть токен
localStorage.getItem('os_expires_at')     // Должен вернуть timestamp
```

---

## 🔍 Диагностика проблем

### Ошибка: redirect_uri_mismatch

**Симптомы:**
- Ошибка 400 при попытке входа
- Popup закрывается сразу
- В консоли: `OAuth2 error: redirect_uri_mismatch`

**Проверьте:**

1. **Google Cloud Console:**
   - ✅ Открыли https://console.cloud.google.com/apis/credentials
   - ✅ Выбран проект `outfitstyle-ce15f`
   - ✅ Нашли OAuth 2.0 Client ID (Web application)
   - ✅ Добавили `https://app.outfitstyle.ru` в Authorized JavaScript origins
   - ✅ Добавили `https://app.outfitstyle.ru/__/auth/handler` в Authorized redirect URIs
   - ✅ Сохранили и подождали 5 минут

2. **Firebase Console:**
   - ✅ Открыли https://console.firebase.google.com/project/outfitstyle-ce15f/authentication
   - ✅ Google провайдер включён
   - ✅ Домен `app.outfitstyle.ru` добавлен в Authorized domains

3. **Код Flutter:**
   - ✅ `authDomain` указан в `firebase_options.dart`
   - ✅ Client ID совпадает в `auth_service_web.dart`

**Решение:**
```
1. Проверьте все пункты выше
2. Очистите кэш браузера полностью
3. Подождите ещё 5 минут (настройки Google применяются не сразу)
4. Попробуйте в режиме инкогнито
5. Проверьте что используете правильный проект Firebase/Google Cloud
```

### Ошибка: invalid_client

**Причины:**
- Неверный Client ID в коде
- Client ID не типа "Web application"
- Client Secret не указан в Firebase

**Решение:**
1. Проверьте что Client ID в коде совпадает с Google Cloud Console
2. Убедитесь что тип приложения: **Web application**
3. Проверьте что Client Secret указан в Firebase Console

### Ошибка: access_denied

**Причины:**
- Пользователь отменил вход
- Popup заблокирован браузером

**Решение:**
- Разрешите popup для вашего домена
- Отключите блокировщики рекламы на время входа

### Ошибка: network-request-failed

**Причины:**
- Нет подключения к интернету
- Блокировка Google сервисов (корпоративный фаервол)

**Решение:**
- Проверьте подключение к интернету
- Попробуйте с другого устройства/сети

---

## 📸 Скриншоты (описание интерфейса)

### Google Cloud Console → Credentials

```
┌─────────────────────────────────────────────────────────────┐
│  APIs & Services > Credentials                              │
├─────────────────────────────────────────────────────────────┤
│  + CREATE CREDENTIALS    ▼                                  │
│                                                              │
│  OAuth 2.0 Client IDs                                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Name                      │ Type           │ Client ID │ │
│  ├────────────────────────────────────────────────────────┤ │
│  │ Web client (auto created) │ Web application │ 242419... │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Google Cloud Console → Edit Client ID

```
┌─────────────────────────────────────────────────────────────┐
│  Edit OAuth 2.0 Client ID                                   │
├─────────────────────────────────────────────────────────────┤
│  Name: Web client (auto created by Google Service)          │
│                                                              │
│  Authorized JavaScript origins:                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ https://app.outfitstyle.ru              [✕]            │ │
│  │ https://outfitstyle-ce15f.firebaseapp.com [✕]          │ │
│  │ + ADD URI                                               │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Authorized redirect URIs:                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ https://app.outfitstyle.ru/__/auth/handler [✕]        │ │
│  │ https://outfitstyle-ce15f.firebaseapp.com/__/auth/... [✕]│ │
│  │ + ADD URI                                               │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│                           [CANCEL]  [SAVE]                  │
└─────────────────────────────────────────────────────────────┘
```

### Firebase Console → Authentication → Settings

```
┌─────────────────────────────────────────────────────────────┐
│  Authentication > Settings                                  │
├─────────────────────────────────────────────────────────────┤
│  Authorized domains                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ outfitstyle-ce15f.firebaseapp.com       [Delete]       │ │
│  │ localhost                               [Delete]       │ │
│  │ app.outfitstyle.ru                      [Delete]       │ │
│  │ + Add domain                                            │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Полезные ссылки

| Ресурс | Ссылка |
|--------|--------|
| Google Cloud Console | https://console.cloud.google.com/apis/credentials |
| Firebase Console | https://console.firebase.google.com/project/outfitstyle-ce15f |
| Firebase Auth Docs | https://firebase.google.com/docs/auth/web/google-signin |
| FlutterFire Auth | https://firebase.flutter.dev/docs/auth/social/#google |
| Google Identity | https://developers.google.com/identity/gsi/web |

---

## 📝 История изменений

| Дата | Изменение |
|------|-----------|
| 26.02.2026 | Добавлена инструкция для `app.outfitstyle.ru` |
| 26.02.2026 | Обновлены скриншоты и чеклист диагностики |

---

## 🆘 Контакты

При возникновении проблем:
1. Проверьте все пункты чеклиста выше
2. Изучите логи в консоли браузера
3. Проверьте логи бэкенда
4. Убедитесь что настройки Google Cloud применились (подождите 5 минут)
