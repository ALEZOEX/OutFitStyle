# Быстрый деплой на VPS (LC-2, 4 GB RAM)

## 1. Купить сервер

- **Timeweb Cloud LC-2** (~280₽/мес)
- Ubuntu 24.04
- 2 ядра, 4 GB RAM, 60 GB SSD

## 2. Подключиться и настроить

```bash
ssh root@<ip>

# Обновление + swap
apt update && apt upgrade -y
apt install -y curl git netcat-openbsd
fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# k3s
curl -sfL https://get.k3s.io | sh -

# Проверка
kubectl get nodes
```

## 3. Деплой проекта

```bash
git clone <repo> outfitstyle
cd outfitstyle

cp k8s/secrets.yaml.example k8s/secrets.yaml
nano k8s/secrets.yaml  # заполнить

./scripts/deploy-k8s.sh
```

## 4. Проверка

```bash
kubectl get pods -n outfitstyle
```

---

**Подробная инструкция:** [docs/deployment/k8s-lc2-setup.md](docs/deployment/k8s-lc2-setup.md)
