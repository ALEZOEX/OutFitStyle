# 🚀 Быстрая настройка Google OAuth для Firebase Auth

## Проблема
```
Firebase Auth возвращает ошибку 400 redirect_uri_mismatch 
с параметром origin=https://app.outfitstyle.ru
```

---

## ⚡ Быстрое решение (5 минут)

### 1️⃣ Google Cloud Console

**Откройте:** https://console.cloud.google.com/apis/credentials

**Найдите OAuth 2.0 Client ID:**
```
Name: Web client (auto created by Google Service)
Client ID: 242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com
```

**Добавьте в "Authorized JavaScript origins":**
```
https://app.outfitstyle.ru
https://outfitstyle-ce15f.firebaseapp.com
```

**Добавьте в "Authorized redirect URIs":**
```
https://app.outfitstyle.ru/__/auth/handler
https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler
```

**Нажмите SAVE и подождите 2-5 минут.**

---

### 2️⃣ Firebase Console

**Откройте:** https://console.firebase.google.com/project/outfitstyle-ce15f/authentication/settings

**В секции "Authorized domains" добавьте:**
```
app.outfitstyle.ru
```

---

### 3️⃣ Проверка

**Очистите кэш браузера** и попробуйте войти через Google снова.

---

## 📋 Полный чеклист

- [ ] Открыл Google Cloud Console
- [ ] Выбрал проект `outfitstyle-ce15f`
- [ ] Нашёл OAuth 2.0 Client ID (Web application)
- [ ] Добавил `https://app.outfitstyle.ru` в Authorized JavaScript origins
- [ ] Добавил `https://outfitstyle-ce15f.firebaseapp.com` в Authorized JavaScript origins
- [ ] Добавил `https://app.outfitstyle.ru/__/auth/handler` в Authorized redirect URIs
- [ ] Добавил `https://outfitstyle-ce15f.firebaseapp.com/__/auth/handler` в Authorized redirect URIs
- [ ] Сохранил изменения в Google Cloud Console
- [ ] Подождал 2-5 минут
- [ ] Открыл Firebase Console
- [ ] Добавил `app.outfitstyle.ru` в Authorized domains
- [ ] Очистил кэш браузера
- [ ] Проверил вход через Google

---

## 🔍 Если не работает

1. **Подождите ещё 5 минут** — настройки Google применяются не сразу
2. **Очистите кэш полностью** — `Ctrl+Shift+Delete` → Clear cache
3. **Попробуйте режим инкогнито** — исключите проблемы с кэшем
4. **Проверьте Client ID в коде** — должен совпадать с Google Cloud Console

---

## 📖 Полная инструкция

См. [`docs/SETUP_GOOGLE_OAUTH.md`](SETUP_GOOGLE_OAUTH.md)
