# 🔒 OutFitStyle Security Guide

## Руководство по безопасности

Этот документ описывает настройки безопасности для OutFitStyle и инструкции по развёртыванию.

---

## 📋 Быстрый старт

### 1. Генерация секретов

**Перед запуском** сгенерируйте безопасные секреты:

```bash
# JWT Secret (минимум 256 бит / 32 символа)
JWT_SECRET=$(openssl rand -base64 64)

# API Key Pepper
API_KEY_PEPPER=$(openssl rand -hex 32)

# Admin API Key
ADMIN_API_KEY=$(openssl rand -hex 32)
```

### 2. Настройка .env файла

Скопируйте `.env.example` в `.env` и заполните значения:

```bash
cp .env.example .env
```

**Обязательные переменные:**
- `JWT_SECRET` - минимум 32 символа
- `API_KEY_PEPPER` - минимум 64 символа
- `ADMIN_API_KEY` - минимум 64 символа
- `OPENWEATHER_API_KEY` - получить на openweathermap.org
- `CORS_ALLOWED_ORIGINS` - конкретные домены (не *!)

---

## 🔐 Исправленные уязвимости

### Критические (Critical)

#### ✅ 1. Учётные данные БД
**Было:** Хардкод паролей в Python скриптах и docker-compose.yml  
**Стало:** Все пароли через environment variables

**Файлы:**
- `server/marketplace-service/main.py` - требует `DB_PASSWORD`
- `market-service/core/config.py` - требует `DATABASE_URL`
- `infrastructure/docker-compose.yml` - использует `${DATABASE_URL}`

#### ✅ 2. JWT Secret
**Было:** `JWT_SECRET: "dev-secret-dev-secret-dev-secret-dev-secret"`  
**Стало:** `${JWT_SECRET}` - требует установки в .env

#### ✅ 3. Admin API Key
**Было:** `ADMIN_API_KEY: "dev-admin-key"`  
**Стало:** `${ADMIN_API_KEY}` - требует генерации случайного ключа

### Высокие (High)

#### ✅ 4. Политика паролей
**Было:** Минимум 8 символов без требований сложности  
**Стало:** 
- Минимум 12 символов
- Хотя бы 1 заглавная буква
- Хотя бы 1 строчная буква
- Хотя бы 1 цифра
- Хотя бы 1 специальный символ

**Файл:** `server/internal/validation/validator.go`

#### ✅ 5. Rate Limiting
**Статус:** Уже реализован на уровне всего API (Redis-based)  
**Файл:** `server/internal/api/middleware/middleware.go`

#### ✅ 6. Token Storage
**Было:** Предсказуемые ключи (`os_access_token`)  
**Стало:** Обфусцированные ключи + encrypted SharedPreferences

**Файлы:**
- `client/lib/src/services/auth_storage_io.dart` - flutter_secure_storage
- `client/lib/src/services/auth_storage_web.dart` - обфусцированные ключи

### Средние (Medium)

#### ✅ 7. CORS
**Было:** `CORS_ALLOWED_ORIGINS=*`  
**Стало:** Whitelist конкретных origin

**Файл:** `server/.env.example`

#### ✅ 8. Security Headers
**Добавлены:**
- `X-Frame-Options: DENY` - защита от clickjacking
- `X-Content-Type-Options: nosniff` - запрет MIME sniffing
- `X-XSS-Protection: 1; mode=block` - XSS фильтр
- `Strict-Transport-Security` - HTTPS принудительно
- `Content-Security-Policy` - ограничение ресурсов
- `Referrer-Policy` - контроль referrer
- `Permissions-Policy` - отключение функций
- `Cache-Control` - запрет кэширования чувствительных данных

**Файл:** `server/internal/api/middleware/middleware.go`

---

## 🚀 Production Checklist

### Перед деплоем

- [ ] Сгенерированы все секреты (JWT, API keys)
- [ ] `.env` файл добавлен в `.gitignore`
- [ ] CORS настроен на конкретные домены
- [ ] SSL/TLS включён для БД и Redis
- [ ] Rate limiting настроен (100 запросов/мин)
- [ ] Security headers добавлены
- [ ] Пароли БД изменены с дефолтных
- [ ] Firebase API keys ограничены в Firebase Console

### Firebase Security

Firebase API ключи **не являются секретами**, но должны быть ограничены:

1. **Firebase Console → Project Settings → General**
2. Добавьте SHA-1 fingerprint для Android
3. Добавьте bundle ID для iOS
4. Включите **App Check** для дополнительной защиты

### Docker Security

```bash
# НЕ используйте docker-compose.yml для production!
# Используйте docker-compose.prod.yml с секретами

# Создайте .env файл
cp .env.example .env

# Отредактируйте .env с безопасными значениями
nano .env

# Запустите с production конфигом
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📊 Security Headers Пример

```http
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=(), payment=()
Cache-Control: no-store, no-cache, must-revalidate
Pragma: no-cache
Expires: 0
```

---

## 🔍 Monitoring

### Логи безопасности

Все чувствительные данные маскируются в логах:
- IP адреса: `***.***.***.123`
- Токены: `abc12345...xyz`
- Пароли: никогда не логируются

### Rate Limit Violations

Нарушения rate limiting записываются в БД:
- Identifier (user ID или IP)
- Endpoint
- Limit value
- Current value

---

## 🛡️ Best Practices

### Пароли пользователей

✅ **Требуется:**
- Минимум 12 символов
- Заглавные и строчные буквы
- Цифры и специальные символы
- Проверка на утечки (HaveIBeenPwned)

❌ **Запрещено:**
- Простые пароли (123456, password)
- Повторяющиеся символы (aaaaaaaa)
- Последовательности (abcdef, 123456)

### Сессии и токены

- Access token: 15 минут
- Refresh token: 30 дней (720 часов)
- Token rotation при refresh
- Session invalidation при logout

### API Security

- JWT Bearer authentication
- API key для бизнес-партнёров
- Rate limiting per user/IP
- Input validation на всех endpoint'ах

---

## 📞 Security Contact

По вопросам безопасности обращайтесь:
- **Email:** security@outfitstyle.app
- **PGP Key:** [ссылка на PGP ключ]

---

## 📝 Changelog

### 2026-03-02
- ✅ Усиlena политика паролей (8 → 12 символов + сложность)
- ✅ Добавлены security headers
- ✅ CORS изменён с * на whitelist
- ✅ Token storage улучшен (obfuscated keys + encryption)
- ✅ Все секреты вынесены в environment variables
- ✅ Удалены хардкод паролей из Python скриптов

### Previous
- Rate limiting реализован
- JWT authentication настроен
- Redis cache для сессий

---

**Последнее обновление:** 2026-03-02  
**Следующий аудит:** 2026-06-02
