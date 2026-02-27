#!/bin/bash
#
# Деплой новой ML модели на production сервер
#
# Использование:
#   ./deploy_ml_model.sh [путь_к_модели]
#
# Пример:
#   ./deploy_ml_model.sh ml-service/models/model.cbm
#

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Пути
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MODEL_PATH="${1:-$PROJECT_ROOT/ml-service/models/model.cbm}"
MANIFEST_PATH="${1:-$PROJECT_ROOT/ml-service/models/model.pkl}"

# Сервер (замените на ваши данные)
SERVER_USER="${DEPLOY_USER:-root}"
SERVER_HOST="${DEPLOY_HOST:-outfitstyle.ru}"
SERVER_PATH="${DEPLOY_MODEL_PATH:-/opt/outfitstyle/ml-models}"

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $*"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $*"
}

# Проверка существования модели
if [[ ! -f "$MODEL_PATH" ]]; then
    error "Модель не найдена: $MODEL_PATH"
    exit 1
fi

if [[ ! -f "$MANIFEST_PATH" ]]; then
    error "Manifest не найден: $MANIFEST_PATH"
    exit 1
fi

log "Деплой ML модели на сервер"
log "============================"
log "Модель: $MODEL_PATH"
log "Manifest: $MANIFEST_PATH"
log "Сервер: $SERVER_USER@$SERVER_HOST:$SERVER_PATH"

# Копирование модели на сервер
log "Копирование модели на сервер..."
scp "$MODEL_PATH" "$SERVER_USER@$SERVER_HOST:$SERVER_PATH/model.cbm"
scp "$MANIFEST_PATH" "$SERVER_USER@$SERVER_HOST:$SERVER_PATH/model.pkl"

log "Модель скопирована на сервер"

# Перезапуск ML сервиса
log "Перезапуск ML сервиса..."
ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
    cd /opt/outfitstyle
    docker-compose restart ml-service
    sleep 5
    docker-compose ps ml-service
EOF

# Проверка здоровья ML сервиса
log "Проверка здоровья ML сервиса..."
HEALTH_STATUS=$(ssh "$SERVER_USER@$SERVER_HOST" "curl -s http://localhost:8000/health | jq -r '.model_loaded'")

if [[ "$HEALTH_STATUS" == "true" ]]; then
    log "✅ ML сервис работает, модель загружена"
else
    error "❌ ML сервис не загрузил модель"
    warn "Проверьте логи: ssh $SERVER_USER@$SERVER_HOST 'docker-compose logs ml-service'"
    exit 1
fi

# Версия модели
log "Версия модели:"
ssh "$SERVER_USER@$SERVER_HOST" << EOF
    cd /opt/outfitstyle
    docker-compose exec -T ml-service python -c "
import pickle
with open('models/model.pkl', 'rb') as f:
    manifest = pickle.load(f)
print(f\"  Model kind: {manifest.get('model_kind', 'unknown')}\")
print(f\"  Version: {manifest.get('version', 'unknown')}\")
print(f\"  Features: {len(manifest.get('feature_columns', []))}\")
print(f\"  Metrics: {manifest.get('metrics', {})}\")
"
EOF

log "============================"
log "✅ Деплой завершён успешно!"
log "============================"
