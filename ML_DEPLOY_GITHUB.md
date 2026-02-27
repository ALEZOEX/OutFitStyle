# Деплой ML Service через GitHub Actions

## Автоматический деплой

При пуше в ветку `main` с изменениями в `ml-service/`:
1. Собирается Docker image
2. Пушится в GitHub Container Registry
3. Деплоится на k3s сервер

## Настройка

### 1. Создай секреты в GitHub Repository Settings → Secrets → Actions

**KUBECONFIG** (base64 encoded kubeconfig):
```bash
# На сервере
cat ~/.kube/config | base64 -w 0
# Скопируй вывод и вставь в GitHub Secrets
```

### 2. Создай Environment "production" в GitHub

Settings → Environments → New environment → `production`

Добавь тот же **KUBECONFIG** secret в environment.

## Ручной триггер

```bash
# Локально
git add .
git commit -m "Update ML service"
git push origin main
```

GitHub Actions автоматически:
1. ✅ Build & Push image
2. ✅ Deploy to k3s
3. ✅ Health check

## Мониторинг

GitHub Actions → Build and Deploy ML Service → View logs

## Откат

```bash
# На сервере
kubectl rollout undo deployment/ml-service -n outfitstyle
```
