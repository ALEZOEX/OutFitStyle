#!/bin/bash
#
# Скрипт добавления Firebase credentials в Kubernetes secret
#
# Использование:
#   ./setup-firebase-secret.sh [path-to-credentials.json]
#
# Если путь не указан, используется firebase-credentials.json из корня проекта
#

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NAMESPACE="outfitstyle"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_FILE="${1:-${SCRIPT_DIR}/../firebase-credentials.json}"
SECRET_NAME="firebase-credentials-secret"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка наличия kubectl
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl не найден. Пожалуйста, установите kubectl."
    exit 1
fi

# Проверка подключения к кластеру
if ! kubectl cluster-info &> /dev/null; then
    log_error "Не удалось подключиться к Kubernetes кластеру."
    exit 1
fi
log_success "Подключение к кластеру установлено"

# Проверка файла credentials
if [ ! -f "$CREDENTIALS_FILE" ]; then
    log_error "Файл credentials не найден: $CREDENTIALS_FILE"
    log_info "Укажите путь к файлу как аргумент скрипта:"
    echo "  $0 /path/to/firebase-credentials.json"
    exit 1
fi
log_success "Файл credentials найден: $CREDENTIALS_FILE"

# Проверка namespace
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    log_warn "Namespace $NAMESPACE не найден. Создаю..."
    kubectl create namespace $NAMESPACE
fi

# Создание секрета
log_info "Создание секрета $SECRET_NAME в namespace $NAMESPACE..."

# Проверяем, существует ли уже секрет
if kubectl get secret $SECRET_NAME -n $NAMESPACE &> /dev/null; then
    log_warn "Секрет уже существует. Обновляю..."
    kubectl delete secret $SECRET_NAME -n $NAMESPACE
fi

# Создаём новый секрет
kubectl create secret generic $SECRET_NAME \
    --from-file=credentials.json="$CREDENTIALS_FILE" \
    -n $NAMESPACE

log_success "Секрет успешно создан"

# Проверка создания
log_info "Проверка секрета..."
kubectl get secret $SECRET_NAME -n $NAMESPACE -o yaml | grep -E "name|namespace|created"

# Перезапуск backend для применения секрета
log_info "Перезапуск backend deployment..."
kubectl rollout restart deployment/backend -n $NAMESPACE

log_info "Ожидание готовности backend..."
kubectl rollout status deployment/backend -n $NAMESPACE --timeout=120s

log_success "Backend перезапущен"

# Вывод информации
echo ""
log_success "Готово!"
echo ""
echo "Следующие шаги:"
echo "1. Проверьте логи backend:"
echo "   kubectl logs -n $NAMESPACE deploy/backend --tail=50"
echo ""
echo "2. Проверьте, что Firebase Admin SDK инициализирован:"
echo "   Ищите в логах '[Firebase] Admin SDK инициализирован'"
echo ""
echo "3. Протестируйте аутентификацию через Google"
echo ""
