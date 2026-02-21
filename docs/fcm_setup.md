# Настройка Firebase Cloud Messaging (FCM) для OutfitStyle

Этот документ описывает процесс получения и настройки учётных данных Firebase Cloud Messaging для отправки push-уведомлений.

## 📋 Требования

- Аккаунт Google/Firebase
- Проект OutfitStyle в Firebase Console
- Файл сервисных учётных данных (service account key)

## 🔑 Получение FCM Credentials

### Шаг 1: Создайте проект в Firebase Console

1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Нажмите **"Add project"** или выберите существующий проект OutfitStyle
3. Следуйте инструкциям мастера создания проекта

### Шаг 2: Включите Cloud Messaging

1. В меню слева выберите **Build** → **Cloud Messaging**
2. Если Messaging ещё не включён, нажмите **"Get started"**

### Шаг 3: Создайте сервисный аккаунт

1. Нажмите на иконку **шестерёнки** (⚙️) рядом с "Project Overview"
2. Выберите **Project settings**
3. Перейдите на вкладку **Service accounts**
4. Нажмите **"Generate new private key"**
5. Прочитайте предупреждение и нажмите **"Generate key"**
6. JSON файл будет загружен на ваш компьютер

### Шаг 4: Сохраните файл учётных данных

1. Создайте директорию для учётных данных:
   ```bash
   mkdir -p config/fcm
   ```

2. Переместите загруженный JSON файл:
   ```bash
   mv ~/Downloads/your-project-firebase-adminsdk-xxxxx.json config/fcm/serviceAccountKey.json
   ```

3. **Важно:** Убедитесь, что файл не попадёт в git:
   ```bash
   # Проверьте .gitignore
   echo "config/fcm/" >> .gitignore
   ```

## ⚙️ Настройка сервера

### Шаг 5: Обновите переменные окружения

Добавьте в ваш `.env` файл (локально) или в secrets manager (продакшен):

```env
FCM_CREDENTIALS_FILE=config/fcm/serviceAccountKey.json
```

### Шаг 6: Проверьте права доступа к файлу

Убедитесь, что процесс сервера имеет доступ к файлу:

```bash
# Для Linux/Mac
chmod 600 config/fcm/serviceAccountKey.json
chown your_user:your_group config/fcm/serviceAccountKey.json

# Для Windows (PowerShell)
icacls config\fcm\serviceAccountKey.json /grant your_user:F
```

## 🧪 Тестирование

### Регистрация device token

После запуска сервера зарегистрируйте токен устройства:

```bash
curl -X POST http://localhost:8080/api/v1/notifications/register-device \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "token": "YOUR_FCM_DEVICE_TOKEN",
    "platform": "android",
    "device_id": "device-12345"
  }'
```

### Пример ответа

```json
{
  "success": true
}
```

## 📱 Получение FCM токена на клиенте

### Android (Kotlin/Java)

```kotlin
// Используя Firebase Messaging
FirebaseMessaging.getInstance().token
    .addOnCompleteListener { task ->
        if (!task.isSuccessful) {
            Log.w("FCM", "Fetching FCM registration token failed", task.exception)
            return@addOnCompleteListener
        }
        
        // Получаем токен
        val token = task.result
        Log.d("FCM", "FCM Token: $token")
        
        // Отправляем токен на сервер
        sendTokenToServer(token)
    }
```

### iOS (Swift)

```swift
// В AppDelegate или SceneDelegate
import FirebaseMessaging

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Запрашиваем разрешение на уведомления
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    
    return true
}

func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    
    Messaging.messaging().token { token, error in
        if let error = error {
            print("Error fetching FCM token: \(error)")
        } else if let token = token {
            print("FCM Token: \(token)")
            // Отправляем токен на сервер
            self.sendTokenToServer(token)
        }
    }
}
```

### Flutter (Dart)

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getFCMToken() async {
  final messaging = FirebaseMessaging.instance;
  
  // Запрашиваем разрешение
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    final token = await messaging.getToken();
    print('FCM Token: $token');
    return token;
  } else {
    print('User declined permission');
    return null;
  }
}
```

## 🔍 Диагностика

### Проверка инициализации FCM

При запуске сервера проверьте логи:

```
INFO  FCM: using credentials file  file=config/fcm/serviceAccountKey.json
INFO  FCM client initialized successfully
INFO  Push notification service initialized
```

Если учётные данные не найдены:

```
WARN  FCM credentials not configured, push notifications disabled
```

Если файл не найден:

```
WARN  FCM client initialization failed, push notifications disabled
      credentials_file=config/fcm/serviceAccountKey.json
      error="FCM credentials file not found: config/fcm/serviceAccountKey.json"
```

### Тестирование отправки через Firebase Console

1. Откройте Firebase Console
2. Выберите ваш проект
3. **Engage** → **Messaging**
4. Нажмите **"New campaign"** → **"Send your first message"**
5. Введите текст уведомления
6. Выберите аудиторию для тестирования
7. Отправьте тестовое сообщение

## 🔒 Безопасность

### Никогда не коммитьте учётные данные в git

Файл `serviceAccountKey.json` содержит приватные ключи. Добавьте его в `.gitignore`:

```gitignore
# Firebase credentials
config/fcm/*.json
*.json
!package.json
```

### Используйте secrets manager в продакшене

Для продакшена используйте:
- Google Secret Manager
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault

Пример загрузки из Secret Manager:

```bash
gcloud secrets versions access latest --secret=fcm-credentials > config/fcm/serviceAccountKey.json
```

### Ограничьте права сервисного аккаунта

В Firebase Console → Service accounts:
- Убедитесь, что аккаунт имеет только необходимые права
- Минимальные права: **Firebase Cloud Messaging API**

## 📊 Мониторинг

### Метрики FCM

Сервер логирует следующие метрики:
- Количество отправленных уведомлений
- Количество успешных/неуспешных отправок
- Ошибки валидации токенов

Пример лога отправки:

```
INFO  Push notification sent
      user_id=550e8400-e29b-41d4-a716-446655440000
      title="Новая рекомендация по одежде"
      tokens_total=2
      tokens_success=2
      tokens_failed=0
```

### Обработка невалидных токенов

При получении ошибки `messaging/invalid-registration-token` сервер автоматически деактивирует токен в базе данных.

## 🐛 Решение проблем

### Ошибка: "Failed to initialize Firebase App"

**Причина:** Неправильный путь к файлу или неверный формат JSON.

**Решение:**
1. Проверьте путь в `FCM_CREDENTIALS_FILE`
2. Убедитесь, что файл существует
3. Проверьте формат JSON (должен быть валидный service account key)

### Ошибка: "messaging/invalid-registration-token"

**Причина:** Токен устройства устарел или недействителен.

**Решение:**
1. Клиент должен запросить новый токен
2. Сервер автоматически деактивирует невалидные токены

### Ошибка: "messaging/quota-exceeded"

**Причина:** Превышен лимит отправок FCM.

**Решение:**
1. Проверьте квоты в Firebase Console
2. Реализуйте rate limiting на стороне сервера
3. Рассмотрите upgrade тарифа Firebase

## 📚 Дополнительные ресурсы

- [Firebase Cloud Messaging документация](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Admin SDK для Go](https://firebase.google.com/docs/reference/admin/go)
- [Firebase Console](https://console.firebase.google.com/)

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи сервера
2. Проверьте Firebase Console → Cloud Messaging → Reports
3. Обратитесь к документации Firebase
