# Настройка Firebase Auth для Google Sign-In (Flutter Web)

## Обзор

Данный документ описывает настройку Firebase Authentication для входа через Google во Flutter Web приложении OutfitStyle.

## Преимущества использования Firebase Auth

Вместо пакета `google_sign_in` используется нативный `firebase_auth` с `signInWithPopup()`:

- ✅ **Не требует настройки redirect_uri** в Google Cloud Console
- ✅ **Firebase сам управляет OAuth flow**
- ✅ **Проще код и надёжнее** работает на Flutter Web
- ✅ **Нет ошибки redirect_uri_mismatch**

## Шаг 1: Настройка Firebase Console

### 1.1 Откройте Firebase Console
Перейдите в [Firebase Console](https://console.firebase.google.com/) и выберите проект **outfitstyle-ce15f**

### 1.2 Включите Google Auth Provider

1. В левом меню выберите **Authentication** → **Sign-in method**
2. Нажмите **Google** в списке провайдеров
3. Переключите в состояние **Enabled**
4. Укажите:
   - **Project support email**: ваш email для поддержки
   - **Public-facing name**: OutfitStyle (или оставьте по умолчанию)
5. Нажмите **Save**

### 1.3 Настройте авторизованные домены

1. В разделе **Authentication** → **Settings** → **Authorized domains**
2. Добавьте домены, с которых будет работать вход:
   - `localhost` (для разработки)
   - `127.0.0.1` (для разработки)
   - `outfitstyle-ce15f.firebaseapp.com` (Firebase Hosting)
   - Ваш продакшен домен (например, `app.outfitstyle.com`)

## Шаг 2: Настройка Google Cloud Console

### 2.1 Откройте Google Cloud Console
Перейдите в [Google Cloud Console](https://console.cloud.google.com/) и выберите проект **outfitstyle-ce15f**

### 2.2 Проверьте OAuth 2.0 Client ID

1. Перейдите в **APIs & Services** → **Credentials**
2. Найдите **Web client (auto created by Google Service)** - это клиент, созданный Firebase
3. Убедитесь, что в **Authorized JavaScript origins** указаны:
   - `http://localhost`
   - `http://localhost:PORT` (ваш порт разработки)
   - `https://outfitstyle-ce15f.firebaseapp.com`
   - Ваш продакшен домен

### 2.3 (Опционально) Создайте новый OAuth Client ID

Если нужно создать новый клиент:

1. Нажмите **Create Credentials** → **OAuth client ID**
2. Тип приложения: **Web application**
3. Name: `OutfitStyle Flutter Web`
4. **Authorized JavaScript origins**:
   - `http://localhost`
   - `http://localhost:8080` (или ваш порт)
   - `https://outfitstyle-ce15f.firebaseapp.com`
   - Ваш продакшен домен
5. **НЕ ТРЕБУЕТСЯ** настраивать **Authorized redirect URIs** - Firebase сам управляет redirect

## Шаг 3: Проверка конфигурации Flutter

### 3.1 Firebase Options

Убедитесь, что файл `client/lib/firebase_options.dart` содержит правильные настройки:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyCf4ePEMDigZuvniagDut8uWgc0O2NbSdk',
  appId: '1:242419520610:web:4a7393ff88f9727ecc2d3b',
  messagingSenderId: '242419520610',
  projectId: 'outfitstyle-ce15f',
  authDomain: 'outfitstyle-ce15f.firebaseapp.com',
  storageBucket: 'outfitstyle-ce15f.firebasestorage.app',
);
```

### 3.2 Инициализация Firebase

В `client/lib/main.dart` Firebase инициализируется при старте:

```dart
if (kIsWeb) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
```

## Шаг 4: Тестирование

### 4.1 Запустите приложение

```bash
cd client
flutter run -d chrome
```

### 4.2 Проверьте вход через Google

1. Нажмите кнопку **Войти через Google**
2. Должно открыться popup окно Google OAuth
3. Выберите аккаунт или введите credentials
4. После успешного входа проверьте:
   - Токены сохранены в localStorage
   - Пользователь перенаправлен в приложение
   - Бэкенд получил и верифицировал токен

### 4.3 Проверьте консоль браузера

В консоли должны быть логи:
```
[Firebase Auth Web] Начало входа через Google (signInWithPopup)
[Firebase Auth Web] Пользователь авторизован: user@example.com
[Firebase Auth Web] ID Token получен: yes
[Firebase Auth Web] Отправка токена на бэкенд: /api/v1/auth/google
[Firebase Auth Web] Ответ от бэкенда: status=200
[Firebase Auth Web] Токены получены: access=abc...xyz
[Firebase Auth Web] Сессия сохранена
```

## Шаг 5: Настройка бэкенда (Go API)

### 5.1 Google Client ID на бэкенде

В `.env` файле бэкенда укажите Google Client ID:

```env
GOOGLE_CLIENT_ID=242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
```

### 5.2 Верификация токена

Бэкенд должен уметь верифицировать:
1. **Google OAuth ID Token** (предпочтительно) - из `credential.idToken`
2. **Firebase ID Token** (fallback) - из `user.getIdToken()`

## Troubleshooting

### Ошибка: popup-closed-by-user
**Причина**: Пользователь закрыл popup окно  
**Решение**: Это нормальное поведение, пользователь отменил вход

### Ошибка: popup-blocked
**Причина**: Браузер заблокировал popup  
**Решение**: Разрешите всплывающие окна для localhost/домена

### Ошибка: network-request-failed
**Причина**: Нет подключения к интернету  
**Решение**: Проверьте сеть

### Ошибка: redirect_uri_mismatch
**Причина**: Используется старый `google_sign_in` пакет  
**Решение**: Убедитесь, что используется `firebase_auth.signInWithPopup()`

### Ошибка: invalid-credential
**Причина**: Неправильный Client ID или проблема с токеном  
**Решение**: 
1. Проверьте Client ID в Firebase Console
2. Убедитесь, что домен добавлен в Authorized domains
3. Проверьте, что токен передаётся на бэкенд корректно

## Миграция с google_sign_in

Если ранее использовался `google_sign_in`:

1. **Обновите зависимости** в `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_auth: ^6.1.4  # Уже есть
     # google_sign_in можно оставить для mobile
   ```

2. **Обновите `auth_service_web.dart`** (выполнено в этом PR)

3. **Проверьте бэкенд** - должен принимать токены из обоих источников

## Дополнительные ресурсы

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth/web/google-signin)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/auth/social/#google)
- [Google Identity Services](https://developers.google.com/identity/gsi/web)
