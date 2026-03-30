#!/bin/bash
#
# Установка TLS для PostgreSQL и Redis в K3s кластере
#
# Использование:
#   ./setup-db-tls.sh [apply|status|verify|rollback]
#
# Шаги:
#   1. Установить cert-manager (если не установлен)
#   2. Применить сертификаты (CA + postgres + redis)
#   3. Сгенерировать пароли и обновить secrets
#   4. Перезапустить postgres и redis с TLS
#   5. Перезапустить backend с новыми connection strings
#

set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="outfitstyle"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_prerequisites() {
    for cmd in kubectl openssl; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd не найден"
            exit 1
        fi
    done

    if ! kubectl cluster-info &> /dev/null; then
        log_error "Нет подключения к кластеру"
        exit 1
    fi
}

# ========================
# Установка cert-manager
# ========================
ensure_cert_manager() {
    if kubectl get namespace cert-manager &> /dev/null; then
        log_success "cert-manager уже установлен"
        return
    fi

    log_info "Установка cert-manager..."
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

    log_info "Ожидание готовности cert-manager (до 2 минут)..."
    kubectl wait --for=condition=Available deployment/cert-manager -n cert-manager --timeout=120s
    kubectl wait --for=condition=Available deployment/cert-manager-webhook -n cert-manager --timeout=120s
    kubectl wait --for=condition=Available deployment/cert-manager-cainjector -n cert-manager --timeout=120s

    log_success "cert-manager установлен"
}

# ========================
# Генерация паролей
# ========================
generate_passwords() {
    log_info "Генерация паролей..."

    REDIS_PASSWORD=$(openssl rand -base64 32)
    DB_PASSWORD=$(openssl rand -base64 16)
    JWT_SECRET=$(openssl rand -base64 48)

    log_success "Пароли сгенерированы"

    echo ""
    log_warn "=== СОХРАНИТЕ ЭТИ ПАРОЛИ ==="
    echo -e "  Redis password: ${YELLOW}${REDIS_PASSWORD}${NC}"
    echo -e "  DB password:    ${YELLOW}${DB_PASSWORD}${NC}"
    echo -e "  JWT secret:     ${YELLOW}${JWT_SECRET}${NC}"
    echo ""

    # Сохраняем в файл (для справки)
    cat > "${SCRIPT_DIR}/.generated-passwords.txt" <<EOF
Generated at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
REDIS_PASSWORD=${REDIS_PASSWORD}
DB_PASSWORD=${DB_PASSWORD}
JWT_SECRET=${JWT_SECRET}
EOF
    log_warn "Пароли сохранены в .generated-passwords.txt (УДАЛИТЕ после применения!)"
}

# ========================
# Применение сертификатов
# ========================
apply_certificates() {
    log_info "Применение сертификатов cert-manager..."
    kubectl apply -f "${SCRIPT_DIR}/db-tls-certificates.yaml"

    log_info "Ожидание готовности сертификатов (до 2 минут)..."
    for cert in internal-ca postgres-tls redis-tls backend-client-tls; do
        local attempts=0
        while [ $attempts -lt 24 ]; do
            if kubectl get certificate/${cert} -n ${NAMESPACE} -o jsonpath='{.status.conditions[0].status}' 2>/dev/null | grep -q "True"; then
                log_success "Certificate '${cert}' готов"
                break
            fi
            sleep 5
            ((attempts++))
        done
        if [ $attempts -ge 24 ]; then
            log_error "Certificate '${cert}' не готов за 2 минуты"
            kubectl describe certificate/${cert} -n ${NAMESPACE}
            exit 1
        fi
    done

    log_success "Все сертификаты выпущены"
}

# ========================
# Обновление secrets
# ========================
update_secrets() {
    local REDIS_PASSWORD="$1"
    local DB_PASSWORD="$2"
    local JWT_SECRET="$3"

    log_info "Обновление outfitstyle-secrets..."

    # Получаем текущие значения (сохраняем что не меняем)
    CURRENT_SECRET=$(kubectl get secret outfitstyle-secrets -n ${NAMESPACE} -o jsonpath='{.data}' 2>/dev/null || echo "{}")

    kubectl patch secret outfitstyle-secrets -n ${NAMESPACE} --type merge -p "{
        \"stringData\": {
            \"db-password\": \"${DB_PASSWORD}\",
            \"database-url\": \"postgresql://outfitstyle:${DB_PASSWORD}@postgres.outfitstyle.svc.cluster.local:5432/outfitstyle?sslmode=require\",
            \"redis-password\": \"${REDIS_PASSWORD}\",
            \"redis-url\": \"rediss://redis.outfitstyle.svc.cluster.local:6379\",
            \"jwt-secret\": \"${JWT_SECRET}\"
        }
    }"

    log_success "Secrets обновлены"
}

# ========================
# Rolling restart
# ========================
rolling_restart() {
    log_info "Перезапуск PostgreSQL с TLS..."
    kubectl rollout restart deployment/postgres -n ${NAMESPACE}
    kubectl rollout status deployment/postgres -n ${NAMESPACE} --timeout=180s

    log_info "Перезапуск Redis с TLS..."
    kubectl rollout restart deployment/redis -n ${NAMESPACE}
    kubectl rollout status deployment/redis -n ${NAMESPACE} --timeout=120s

    log_info "Перезапуск Backend с новыми connection strings..."
    kubectl rollout restart deployment/backend -n ${NAMESPACE}
    kubectl rollout status deployment/backend -n ${NAMESPACE} --timeout=180s

    log_success "Все deployments перезапущены"
}

# ========================
# Проверка
# ========================
verify() {
    echo ""
    log_info "=== Проверка TLS для PostgreSQL и Redis ==="
    echo ""

    # PostgreSQL TLS
    log_info "PostgreSQL TLS:"
    PG_POD=$(kubectl get pods -n ${NAMESPACE} -l app=postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$PG_POD" ]; then
        PG_SSL=$(kubectl exec -n ${NAMESPACE} ${PG_POD} -- psql -U outfitstyle -d outfitstyle -c "SHOW ssl;" -t 2>/dev/null | tr -d ' ' || echo "ERROR")
        if [ "$PG_SSL" = "on" ]; then
            log_success "  PostgreSQL SSL: ON"
        else
            log_error "  PostgreSQL SSL: ${PG_SSL}"
        fi

        PG_TLS_VER=$(kubectl exec -n ${NAMESPACE} ${PG_POD} -- psql -U outfitstyle -d outfitstyle -c "SELECT version();" -t 2>/dev/null | head -1 || echo "ERROR")
        log_info "  PostgreSQL version: ${PG_TLS_VER}"
    else
        log_warn "  PostgreSQL pod не найден"
    fi

    echo ""

    # Redis TLS
    log_info "Redis TLS:"
    REDIS_POD=$(kubectl get pods -n ${NAMESPACE} -l app=redis -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$REDIS_POD" ]; then
        REDIS_INFO=$(kubectl exec -n ${NAMESPACE} ${REDIS_POD} -- redis-cli --tls \
            --cert /etc/redis/certs/tls.crt \
            --key /etc/redis/certs/tls.key \
            --cacert /etc/redis/certs/ca.crt \
            -h 127.0.0.1 -p 6379 \
            -a "$(kubectl get secret outfitstyle-secrets -n ${NAMESPACE} -o jsonpath='{.data.redis-password}' | base64 -d)" \
            info server 2>/dev/null | grep -E "redis_version|tcp_port" || echo "ERROR")

        if [ "$REDIS_INFO" != "ERROR" ]; then
            log_success "  Redis TLS: работает"
            echo "  ${REDIS_INFO}" | while read line; do log_info "    $line"; done
        else
            log_error "  Redis TLS: недоступен"
        fi
    else
        log_warn "  Redis pod не найден"
    fi

    echo ""

    # Backend connectivity
    log_info "Backend connectivity:"
    BACKEND_POD=$(kubectl get pods -n ${NAMESPACE} -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$BACKEND_POD" ]; then
        # Check health endpoint
        HEALTH=$(kubectl exec -n ${NAMESPACE} ${BACKEND_POD} -c backend -- wget -qO- http://localhost:8080/health 2>/dev/null || echo "ERROR")
        if echo "$HEALTH" | grep -q "ok\|healthy\|UP"; then
            log_success "  Backend /health: OK"
        else
            log_warn "  Backend /health: ${HEALTH}"
        fi
    else
        log_warn "  Backend pod не найден"
    fi

    echo ""

    # Certificate status
    log_info "Certificate status:"
    for cert in internal-ca postgres-tls redis-tls; do
        STATUS=$(kubectl get certificate/${cert} -n ${NAMESPACE} -o jsonpath='{.status.conditions[0].status}' 2>/dev/null || echo "NotFound")
        READY=$(kubectl get certificate/${cert} -n ${NAMESPACE} -o jsonpath='{.status.conditions[0].reason}' 2>/dev/null || echo "unknown")
        if [ "$STATUS" = "True" ]; then
            log_success "  ${cert}: Ready"
        else
            log_warn "  ${cert}: ${STATUS} (${READY})"
        fi
    done

    echo ""

    # TLS secrets exist
    log_info "TLS Secrets:"
    for secret in internal-ca-secret postgres-tls-secret redis-tls-secret; do
        if kubectl get secret/${secret} -n ${NAMESPACE} &>/dev/null; then
            KEYS=$(kubectl get secret/${secret} -n ${NAMESPACE} -o jsonpath='{.data}' | grep -o '"[^"]*"' | tr -d '"' | tr '\n' ' ')
            log_success "  ${secret}: exists (${KEYS})"
        else
            log_error "  ${secret}: NOT FOUND"
        fi
    done
}

# ========================
# Rollback
# ========================
rollback() {
    log_warn "=== Откат TLS конфигурации ==="

    log_info "Удаление сертификатов..."
    kubectl delete -f "${SCRIPT_DIR}/db-tls-certificates.yaml" --ignore-not-found=true || true

    log_info "Возврат на plaintext Redis URL..."
    kubectl patch secret outfitstyle-secrets -n ${NAMESPACE} --type merge -p '{
        "stringData": {
            "redis-url": "redis://redis.outfitstyle.svc.cluster.local:6379",
            "database-url": "postgresql://outfitstyle:CHANGE_ME@postgres.outfitstyle.svc.cluster.local:5432/outfitstyle?sslmode=disable"
        }
    }' || true

    log_info "Перезапуск на plaintext..."
    kubectl rollout restart deployment/postgres -n ${NAMESPACE} || true
    kubectl rollout restart deployment/redis -n ${NAMESPACE} || true
    kubectl rollout restart deployment/backend -n ${NAMESPACE} || true

    log_success "Откат завершён"
}

# ========================
# Основная функция
# ========================
main() {
    check_prerequisites

    case "${1:-apply}" in
        apply)
            ensure_cert_manager
            generate_passwords
            apply_certificates
            update_secrets "$REDIS_PASSWORD" "$DB_PASSWORD" "$JWT_SECRET"
            rolling_restart
            sleep 10
            verify
            ;;
        status)
            verify
            ;;
        verify)
            verify
            ;;
        rollback)
            rollback
            ;;
        *)
            echo "Использование: $0 {apply|status|verify|rollback}"
            echo ""
            echo "Команды:"
            echo "  apply    - Установить TLS для PostgreSQL и Redis"
            echo "  status   - Показать текущий статус TLS"
            echo "  verify   - Проверить TLS подключения"
            echo "  rollback - Откатить на plaintext"
            exit 1
            ;;
    esac
}

main "$@"
