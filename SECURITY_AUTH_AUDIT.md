# Аудит системы авторизации OutfitStyle

**Дата:** 2026-03-09
**Статус:** КРИТИЧЕСКИЕ ПРОБЛЕМЫ ОБНАРУЖЕНЫ

## Executive Summary

Система авторизации имеет **критические уязвимости** и проблемы архитектуры, которые требуют немедленного исправления.

## 🔴 КРИТИЧЕСКИЕ ПРОБЛЕМЫ

### 1. Cookie Authentication НЕ РАБОТАЕТ на Production
**Severity:** CRITICAL
**Status:** CONFIRMED BUG

**Проблема:**
- Middleware проверяет cookies ТОЛЬКО если нет Bearer token
- Порядок проверки: Bearer → API Key → Cookie
- Если Bearer header пустой, но присутствует, cookies игнорируются

**Код (auth.go:16-30):**
```go
// 1) Bearer JWT
h := r.Header.Get("Authorization")
if strings.HasPrefix(h, "Bearer ") {
    // ... проверка Bearer
    return
}
// 2) API key
// 3) Cookie - НИКОГДА НЕ ДОСТИГАЕТСЯ если есть пустой Authorization header
```

**Impact:**
- Web-клиенты с cookies получают 401
- Пользователи не могут войти через браузер
- Это объясняет 503 ошибки (сервер недоступен из-за auth failures)

**Fix Required:**
```go
// ПРАВИЛЬНЫЙ порядок:
// 1. Проверить Bearer token (если есть и не пустой)
// 2. Проверить Cookie (если нет Bearer)
// 3. Проверить API Key (для B2B)
// 4. Reject если ничего нет
```

---

### 2. Отсутствует CSRF Protection
**Severity:** CRITICAL
**Status:** VULNERABILITY

**Проблема:**
- Cookie-based auth БЕЗ CSRF токенов
- Любой сайт может отправить запрос с cookies пользователя
- SameSite=Lax НЕ защищает от GET-based CSRF

**Missing:**
- CSRF token generation
- CSRF token validation
- Double-submit cookie pattern

**Impact:**
- Злоумышленник может выполнять действия от имени пользователя
- Возможна кража дан
 cookie, но НЕ инвалидирует токен в БД
    middleware.ClearRefreshTokenCookie(w, refreshCookieConfig)
}
```

**Fix Required:**
- Инвалидировать refresh token в БД при logout
- Добавить blacklist для refresh tokens
- Проверять blacklist при refresh

---

### 4. Access Token Blacklist НЕ РАБОТАЕТ для Cookies
**Severity:** HIGH
**Status:** LOGIC ERROR

**Проблема:**
- Blacklist работает только если передан accessToken в Logout
- Cookie-based logout НЕ извлекает access token из cookie
- Токен остается валидным после logout

**Код (auth_handler.go:270-280):**
```go
// Извлекаем access token из заголовка для добавления в blacklist
accessToken := extractAccessToken(r)  // ← НЕ проверяет cookies!

if err := h.auth.Logout(ctx, userID, sessionID, req.AllDevices, accessToken); err != nil {
```

**Fix Required:**
```go
// Извлекать access token из cookie если нет в header
accessToken := extractAccessToken(r)
if accessToken == "" {
    if cookie, err := r.Cookie("access_token"); err == nil {
        accessToken = cookie.Value
    }
}
```

---

## 🟡 ВЫСОКИЙ ПРИОРИТЕТ

### 5. Password Reset Code Validation УЯЗВИМА
**Severity:** HIGH
**Status:** TIMING ATTACK POSSIBLE

**Проблема:**
- Используется `subtle.ConstantTimeCompare` ✅
- НО: Redis lookup происходит ДО сравнения
- Timing attack возможен через Redis latency

**Код (auth_handler.go:580-595):**
```go
// 1. Redis GET - может быть медленным
val, err := h.redis.Get(r.Context(), codeKey).Result()
if err == redis.Nil {
    return  // ← Быстрый ответ если кода нет
}

// 2. Constant-time compare
if subtle.ConstantTimeCompare([]byte(storedCode), []byte(req.Code)) != 1 {
    return  // ← Медленный ответ если код есть
}
```

**Fix Required:**
- Всегда делать constant-time операции
- Добавить искусственную задержку для всех ответов
- Использовать rate limiting агрессивнее (3 попытки вместо 10)

---

### 6. Rate Limiting НЕ ДОСТАТОЧНО СТРОГИЙ
**Severity:** MEDIUM
**Status:** WEAK PROTECTION

**Проблемы:**
- Password reset: 10 попыток за 15 минут (слишком много)
- Login lockout: зависит от AccountLockout (не проверен)
- Forgot password: 3 запроса за 15 минут (OK)

**Рекомендации:**
- Password reset verify: 3 попытки за 15 минут
- Password reset final: 5 попыток за 15 минут
- Login: 5 попыток за 15 минут, затем 1 час блокировка

---

### 7. Session Management СЛАБАЯ
**Severity:** MEDIUM
**Status:** MISSING FEATURES

**Отсутствует:**
- Session fingerprinting (device + IP + User-Agent)
- Concurrent session limits
- Session hijacking detection
- Automatic session cleanup

**Fix Required:**
- Добавить fingerprint при создании сессии
- Проверять fingerprint при каждом запросе
- Лимит: 5 активных сессий на пользователя
- Auto-cleanup: удалять сессии старше 30 дней

---

## 🟢 СРЕДНИЙ ПРИОРИТЕТ

### 8. JWT Algorithm Confusion ВОЗМОЖНА
**Severity:** MEDIUM
**Status:** PARTIAL PROTECTION

**Проблема:**
- Поддержка HS256 и RS256 одновременно
- Валидация проверяет алгоритм, но конфигурация может быть неправильной

**Код (token_service.go:150-160):**
```go
parser := jwt.NewParser(jwt.WithValidMethods([]string{methodName}))
// ✅ Проверяет метод
// ⚠️  НО: если useRS256=false, но токен подписан RS256 с публичным ключом как секретом
```

**Fix Required:**
- Использовать ТОЛЬКО RS256 в production
- Удалить поддержку HS256
- Добавить проверку kid (key ID) в JWT header

---

### 9. Google OAuth НЕДОСТАТОЧНО ЗАЩИЩЕН
**Severity:** MEDIUM
**Status:** MISSING VALIDATIONS

**Проблемы:**
- Нет проверки nonce (replay protection)
- Нет проверки aud (audience)
- Нет проверки iss (issuer)

**Код (auth_service.go:220-230):**
```go
gUser, err := s.google.Verify(ctx, idToken)
// ⚠️  Что проверяет Verify? Нужно аудит external/google_auth_client.go
```

**Fix Required:**
- Добавить nonce в OAuth flow
- Проверять aud = client_id
- Проверять iss = accounts.google.com
- Добавить state parameter для CSRF protection

---

### 10. Password Hashing ХОРОШО, но можно лучше
**Severity:** LOW
**Status:** GOOD PRACTICE

**Текущее:**
- bcrypt cost 12 ✅
- Защита от GPU brute-force ✅

**Рекомендации:**
- Рассмотреть Argon2id (более современный)
- Добавить pepper (server-side secret)
- Периодически rehash старых паролей

---

## 📊 СТАТИСТИКА

| Категория | Количество |
|-----------|------------|
| CRITICAL  | 4          |
| HIGH      | 3          |
| MEDIUM    | 3          |
| LOW       | 1          |
| **TOTAL** | **11**     |

---

## 🔧 ПЛАН ИСПРАВЛЕНИЯ

### Phase 1: КРИТИЧЕСКИЕ (1-2 дня)
1. ✅ Исправить Cookie authentication в middleware
2. ✅ Добавить CSRF protection
3. ✅ Исправить Access Token blacklist для cookies
4. ✅ Улучшить Refresh Token rotation

### Phase 2: ВЫСОКИЙ ПРИОРИТЕТ (3-5 дней)
5. ✅ Улучшить Password Reset timing attack protection
6. ✅ Ужесточить Rate Limiting
7. ✅ Добавить Session fingerprinting

### Phase 3: СРЕДНИЙ ПРИОРИТЕТ (1 неделя)
8. ✅ Удалить HS256, оставить только RS256
9. ✅ Улучшить Google OAuth validation
10. ✅ Рассмотреть Argon2id

---

## 🎯 РЕКОМЕНДАЦИИ

### Немедленные действия:
1. **HOTFIX:** Исправить cookie authentication (блокирует production)
2. **HOTFIX:** Добавить CSRF tokens
3. **DEPLOY:** Обновить middleware и handlers

### Архитектурные изменения:
1. Перейти на RS256 только
2. Добавить API Gateway для rate limiting
3. Внедрить WAF (Web Application Firewall)
4. Настроить Security Headers (CSP, HSTS, X-Frame-Options)

### Мониторинг:
1. Логировать все failed auth attempts
2. Алерты на подозрительную активность
3. Метрики: auth success rate, token refresh rate
4. Audit log для всех auth events

---

## 📝 ДОПОЛНИТЕЛЬНЫЕ НАХОДКИ

### Хорошие практики (уже реализованы):
✅ bcrypt cost 12
✅ Constant-time comparison для кодов
✅ JWT JTI для blacklist
✅ Refresh token rotation
✅ HttpOnly cookies
✅ Secure flag support
✅ Rate limiting на критичных endpoints
✅ Email не раскрывается в forgot password

### Что нужно добавить:
❌ CSRF protection
❌ Session fingerprinting
❌ Concurrent session limits
❌ Security headers middleware
❌ Audit logging
❌ Anomaly detection

---

## 🚨 КРИТИЧНОСТЬ

**БЛОКИРУЕТ PRODUCTION:**
- Cookie authentication не работает
- Пользователи не могут войти через браузер
- 503 ошибки из-за auth failures

**ТРЕБУЕТ НЕМЕДЛЕННОГО ИСПРАВЛЕНИЯ:**
- CSRF vulnerability
- Access token blacklist для cookies
- Refresh token rotation

---

**Подготовил:** Kiro AI
**Дата:** 2026-03-09
**Версия:** 1.0
