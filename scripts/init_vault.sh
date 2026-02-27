#!/bin/bash
#
# Инициализация HashiCorp Vault и миграция секретов
#
# Использование:
#   ./init_vault.sh
#

set -euo pipefail

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Переменные
VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-outfitstyle-vault-token}"
VAULT_PATH="secret/outfitstyle"

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $*"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $*"
}

# Проверка Vault
log "Проверка подключения к Vault..."
export VAULT_ADDR
export VAULT_TOKEN

if ! vault status > /dev/null 2>&1; then
    error "Vault недоступен по адресу $VAULT_ADDR"
    exit 1
fi

log "Vault доступен ✓"

# Включение KV secrets engine
log "Включение KV secrets engine v2..."
vault secrets enable -path=secret kv 2>/dev/null || true

# Чтение секретов из .env
log "Чтение секретов из .env файла..."

if [[ ! -f ".env" ]]; then
    error ".env файл не найден"
    exit 1
fi

# Database
log "Миграция секретов базы данных..."
DB_PASSWORD=$(grep POSTGRES_PASSWORD .env | cut -d'=' -f2)
vault kv put $VAULT_PATH/database \
    username=outfitstyle \
    password="$DB_PASSWORD" \
    database=outfitstyle \
    host=postgres \
    port=5432

# JWT
log "Миграция JWT секретов..."
JWT_SECRET=$(grep JWT_SECRET .env | cut -d'=' -f2)
vault kv put $VAULT_PATH/jwt \
    secret="$JWT_SECRET" \
    access_ttl=1h \
    refresh_ttl=90d

# API Keys
log "Миграция API ключей..."
OPENWEATHER_KEY=$(grep OPENWEATHER_API_KEY .env | cut -d'=' -f2)
GOOGLE_CLIENT_ID=$(grep GOOGLE_CLIENT_ID .env | cut -d'=' -f2)
GOOGLE_CLIENT_SECRET=$(grep GOOGLE_CLIENT_SECRET .env | cut -d'=' -f2)

vault kv put $VAULT_PATH/api-keys \
    openweather="$OPENWEATHER_KEY" \
    google_client_id="$GOOGLE_CLIENT_ID" \
    google_client_secret="$GOOGLE_CLIENT_SECRET"

# ML Service
log "Миграция секретов ML сервиса..."
ML_API_KEY=$(grep ML_SERVICE_API_KEY .env | cut -d'=' -f2)
vault kv put $VAULT_PATH/ml-service \
    api_key="$ML_API_KEY"

# Vault policy для приложения
log "Создание политики для приложения..."
vault policy write outfitstyle-app - <<EOF
# Доступ к секретам приложения
path "$VAULT_PATH/database" {
  capabilities = ["read"]
}

path "$VAULT_PATH/jwt" {
  capabilities = ["read"]
}

path "$VAULT_PATH/api-keys" {
  capabilities = ["read"]
}

path "$VAULT_PATH/ml-service" {
  capabilities = ["read"]
}
EOF

log "Политика создана ✓"

# Вывод информации
log ""
log "============================"
log "Vault инициализирован!"
log "============================"
log ""
log "Секреты доступны по путям:"
log "  $VAULT_PATH/database"
log "  $VAULT_PATH/jwt"
log "  $VAULT_PATH/api-keys"
log "  $VAULT_PATH/ml-service"
log ""
log "Политика: outfitstyle-app"
log ""
log "Пример получения секрета:"
log "  vault kv get $VAULT_PATH/database"
log ""

# Проверка
log "Проверка..."
vault kv get $VAULT_PATH/database

log ""
log "✅ Vault готов к использованию!"
