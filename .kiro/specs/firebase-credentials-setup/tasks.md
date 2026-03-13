# План реализации: Настройка Firebase Admin Credentials

- [x] 1. Получить Firebase service account credentials
  - Перейти в Google Cloud Console для проекта `outfitstyle-ce15f`
  - Перейти в Service Accounts
  - Найти service account `outfitstyle-admin@outfitstyle-ce15f.iam.gserviceaccount.com`
  - Создать новый JSON key (если его еще нет)
  - Скачать JSON файл с credentials
  - **Ожидаемый результат**: JSON файл с полями `type`, `project_id`, `private_key`, `client_email`, и т.д.
  - _Требования: 2.5, 2.6_

- [x] 2. Добавить Firebase credentials в `.env`
  - Открыть файл `.env`
  - Добавить одну из двух переменных:
    - **Вариант A** (рекомендуется): `FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json`
    - **Вариант B**: `FIREBASE_CREDENTIALS_JSON={"type":"service_account",...}` (скопировать содержимое JSON)
  - Сохранить файл
  - **Ожидаемый результат**: `.env` содержит `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON`
  - _Требования: 2.1, 2.5, 2.6_

- [x] 3. Создать файл `firebase-credentials.json` (если используется Вариант A)
  - Создать файл `firebase-credentials.json` в корне проекта (рядом с `.env`)
  - Скопировать содержимое JSON файла, скачанного из Google Cloud Console
  - Убедиться, что файл содержит все необходимые поля:
    - `type`: "service_account"
    - `project_id`: "outfitstyle-ce15f"
    - `private_key_id`
    - `private_key` (с `\n` для переносов строк)
    - `client_email`: "outfitstyle-admin@outfitstyle-ce15f.iam.gserviceaccount.com"
    - `client_id`
    - `auth_uri`
    - `token_uri`
    - `auth_provider_x509_cert_url`
    - `client_x509_cert_url`
  - Сохранить файл
  - **Ожидаемый результат**: `firebase-credentials.json` содержит валидный JSON с credentials
  - _Требования: 2.1, 2.5_

- [x] 4. Добавить `firebase-credentials.json` в `.gitignore`
  - Открыть файл `.gitignore`
  - Добавить строку: `firebase-credentials.json`
  - Сохранить файл
  - **Ожидаемый результат**: `firebase-credentials.json` не будет закоммичен в git
  - _Требования: 3.1_

- [x] 5. Перезапустить backend
  - Остановить текущий процесс backend (если он запущен)
  - Запустить backend заново
  - Проверить логи на сообщение об инициализации Firebase:
    - Если используется `FIREBASE_CREDENTIALS_PATH`: "firebase: initialized with credentials file"
    - Если используется `FIREBASE_CREDENTIALS_JSON`: "firebase: initialized with credentials JSON"
  - **Ожидаемый результат**: Backend успешно инициализирует Firebase Admin SDK
  - _Требования: 2.1, 2.5, 2.6_

- [x] 6. Проверить, что Google Sign-In работает
  - Открыть web клиент в браузере
  - Нажать на кнопку "Sign in with Google"
  - Выбрать Google аккаунт
  - Проверить, что вход успешен (нет ошибки 401)
  - Проверить, что клиент получил `access_token` (проверить Network tab в DevTools)
  - Проверить, что последующие API запросы работают (notifications, wardrobe, recommendations)
  - **Ожидаемый результат**: Google Sign-In работает, клиент получает `access_token`, API запросы успешны
  - _Требования: 2.2, 2.3, 2.4_

- [x] 7. Проверить, что email/password аутентификация продолжает работать
  - Открыть web клиент в браузере
  - Нажать на кнопку "Sign up" или "Sign in"
  - Ввести email и пароль
  - Проверить, что вход успешен
  - Проверить, что API запросы работают
  - **Ожидаемый результат**: Email/password аутентификация работает как раньше
  - _Требования: 3.2_

- [x] 8. Проверить graceful degradation (опционально)
  - Временно удалить `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON` из `.env`
  - Перезапустить backend
  - Проверить логи на warning: "firebase: credentials not configured, Firebase auth will be disabled"
  - Проверить, что email/password аутентификация продолжает работать
  - Проверить, что Google Sign-In возвращает 401 (ожидаемо)
  - Вернуть `FIREBASE_CREDENTIALS_PATH` или `FIREBASE_CREDENTIALS_JSON` в `.env`
  - **Ожидаемый результат**: Backend gracefully деградирует без Firebase credentials
  - _Требования: 3.1, 3.2_

- [x] 9. Проверить обработку ошибок
  - Временно установить неверный путь в `FIREBASE_CREDENTIALS_PATH` (например, `./nonexistent.json`)
  - Перезапустить backend
  - Проверить логи на error: "firebase: failed to read credentials file"
  - Проверить, что backend продолжает работать (не crash)
  - Проверить, что email/password аутентификация продолжает работать
  - Вернуть правильный путь в `FIREBASE_CREDENTIALS_PATH`
  - **Ожидаемый результат**: Backend gracefully обрабатывает ошибки
  - _Требования: 3.5_

- [x] 10. Финальная проверка
  - Убедиться, что все тесты пройдены
  - Убедиться, что Google Sign-In работает
  - Убедиться, что email/password аутентификация работает
  - Убедиться, что все API запросы работают с `access_token`
  - Убедиться, что `firebase-credentials.json` добавлен в `.gitignore`
  - **Ожидаемый результат**: Все требования выполнены, проблема с 401 ошибками решена
  - _Требования: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.5_
