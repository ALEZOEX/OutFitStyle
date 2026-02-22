#!/bin/bash
#
# Скрипт развёртывания OutfitStyle в Kubernetes (k3s)
#
# Использование:
#   ./deploy.sh [apply|rollback|status|cleanup]
#
# Команды:
#   apply   - Применить все манифесты и развернуть приложение
#   rollback - Откатить развёртывание (удалить все ресурсы)
#   status  - Показать статус развёртывания
#   cleanup - Полная очистка (включая PVC)
#

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Переменные
NAMESPACE="outfitstyle"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS=(
    "namespace.yaml"
    "landing-page-configmap.yaml"
    "postgres.yaml"
    "redis.yaml"
    "backend.yaml"
    "ml-service.yaml"
    "frontend.yaml"
    "ingress.yaml"
)

# Мониторинг и инфраструктура (опционально)
INFRA_MANIFESTS=(
    "monitoring-deployment.yaml"
    "grafana.yaml"
    "servicemonitor.yaml"
    "kafka.yaml"
)

# Функция для вывода сообщений
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
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl не найден. Пожалуйста, установите kubectl."
        exit 1
    fi
}

# Проверка подключения к кластеру
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Не удалось подключиться к Kubernetes кластеру."
        exit 1
    fi
    log_success "Подключение к кластеру установлено"
}

# Применение манифестов
apply_manifests() {
    log_info "Начало развёртывания OutfitStyle..."

    # Проверка secrets
    if [ ! -f "${SCRIPT_DIR}/secrets.yaml" ]; then
        log_warn "Файл secrets.yaml не найден. Создайте его на основе secrets.yaml.example"
        log_info "Пример: cp ${SCRIPT_DIR}/secrets.yaml.example ${SCRIPT_DIR}/secrets.yaml"
        exit 1
    fi

    # Применение namespace
    log_info "Создание namespace ${NAMESPACE}..."
    kubectl apply -f "${SCRIPT_DIR}/namespace.yaml"

    # Применение secrets
    log_info "Применение secrets..."
    kubectl apply -f "${SCRIPT_DIR}/secrets.yaml"

    # Применение основных манифестов
    for manifest in "${MANIFESTS[@]}"; do
        if [ "$manifest" != "namespace.yaml" ]; then
            log_info "Применение ${manifest}..."
            kubectl apply -f "${SCRIPT_DIR}/${manifest}"
        fi
    done

    # Применение инфраструктуры (мониторинг, kafka)
    log_info "Применение инфраструктуры (Prometheus, Grafana, Kafka)..."
    for manifest in "${INFRA_MANIFESTS[@]}"; do
        if [ -f "${SCRIPT_DIR}/${manifest}" ]; then
            log_info "Применение ${manifest}..."
            kubectl apply -f "${SCRIPT_DIR}/${manifest}"
        fi
    done

    log_success "Все манифесты применены!"

    # Ожидание готовности подов
    log_info "Ожидание готовности подов..."
    wait_for_pods

    # Вывод информации
    show_status
}

# Ожидание готовности подов
wait_for_pods() {
    log_info "Ожидание готовности PostgreSQL..."
    kubectl wait --for=condition=ready pod -l app=postgres -n ${NAMESPACE} --timeout=120s || log_warn "PostgreSQL не готова в течение 120с"
    
    log_info "Ожидание готовности Redis..."
    kubectl wait --for=condition=ready pod -l app=redis -n ${NAMESPACE} --timeout=60s || log_warn "Redis не готов в течение 60с"
    
    log_info "Ожидание готовности Backend..."
    kubectl wait --for=condition=ready pod -l app=backend -n ${NAMESPACE} --timeout=120s || log_warn "Backend не готов в течение 120с"
    
    log_info "Ожидание готовности ML Service..."
    kubectl wait --for=condition=ready pod -l app=ml-service -n ${NAMESPACE} --timeout=120s || log_warn "ML Service не готов в течение 120с"
    
    log_info "Ожидание готовности Frontend..."
    kubectl wait --for=condition=ready pod -l app=frontend -n ${NAMESPACE} --timeout=60s || log_warn "Frontend не готов в течение 60с"
}

# Откат развёртывания
rollback() {
    log_warn "Начало отката развёртывания..."
    
    for manifest in "${MANIFESTS[@]}"; do
        if [ -f "${SCRIPT_DIR}/${manifest}" ]; then
            log_info "Удаление ресурсов из ${manifest}..."
            kubectl delete -f "${SCRIPT_DIR}/${manifest}" --ignore-not-found=true || true
        fi
    done
    
    # Удаление secrets и namespace
    kubectl delete -f "${SCRIPT_DIR}/secrets.yaml" --ignore-not-found=true || true
    kubectl delete -f "${SCRIPT_DIR}/namespace.yaml" --ignore-not-found=true || true
    
    log_success "Откат завершён"
}

# Полная очистка (включая PVC)
cleanup() {
    log_warn "Начало полной очистки (включая PersistentVolumeClaims)..."
    
    # Удаление PVC
    log_info "Удаление PersistentVolumeClaims..."
    kubectl delete pvc --all -n ${NAMESPACE} --ignore-not-found=true || true
    
    # Откат развёртывания
    rollback
    
    log_success "Полная очистка завершена"
}

# Показать статус
show_status() {
    echo ""
    log_info "=== Статус развёртывания ==="
    echo ""

    # Поды
    log_info "Поды:"
    kubectl get pods -n ${NAMESPACE} -o wide
    echo ""

    # Сервисы
    log_info "Сервисы:"
    kubectl get svc -n ${NAMESPACE} -o wide
    echo ""

    # Ingress
    log_info "Ingress:"
    kubectl get ingress -n ${NAMESPACE} -o wide
    echo ""

    # PVC
    log_info "PersistentVolumeClaims:"
    kubectl get pvc -n ${NAMESPACE} -o wide
    echo ""

    # Доступ к Grafana
    log_info "=== Доступ к мониторингу ==="
    echo "Grafana: http://outfitstyle.play2go.cloud/grafana"
    echo "Prometheus: http://outfitstyle.play2go.cloud/prometheus"
    echo ""

    # События
    log_info "Последние события:"
    kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp' | tail -10
}

# Основная функция
main() {
    check_kubectl
    check_cluster
    
    case "${1:-apply}" in
        apply)
            apply_manifests
            ;;
        rollback)
            rollback
            ;;
        status)
            show_status
            ;;
        cleanup)
            cleanup
            ;;
        *)
            echo "Использование: $0 {apply|rollback|status|cleanup}"
            echo ""
            echo "Команды:"
            echo "  apply    - Применить все манифесты и развернуть приложение"
            echo "  rollback - Откатить развёртывание (удалить все ресурсы)"
            echo "  status   - Показать статус развёртывания"
            echo "  cleanup  - Полная очистка (включая PVC)"
            exit 1
            ;;
    esac
}

main "$@"
