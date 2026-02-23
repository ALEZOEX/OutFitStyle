#!/bin/bash
#
# Скрипт развёртывания OutfitStyle в Kubernetes (k3s)
#
# Использование:
#   ./deploy.sh [apply|rollback|status|cleanup|rebuild-indexes]
#
# Команды:
#   apply           - Применить все манифесты и развернуть приложение
#   rollback        - Откатить развёртывание (удалить все ресурсы)
#   status          - Показать статус развёртывания
#   cleanup         - Полная очистка (включая PVC)
#   rebuild-indexes - Ручной запуск пересоздания индексов
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

# Landing page (React)
LANDING_MANIFESTS=(
    "landing-deployment.yaml"
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

    # Применение миграций БД
    log_info "Применение миграций базы данных..."
    if [ -f "${SCRIPT_DIR}/migrate-job.yaml" ]; then
        # Удаляем старый job, если существует
        kubectl delete job/migrate -n ${NAMESPACE} --ignore-not-found=true || true
        # Применяем новый job
        kubectl apply -f "${SCRIPT_DIR}/migrate-job.yaml"
        # Ждём завершения миграций
        log_info "Ожидание завершения миграций (до 5 минут)..."
        if kubectl wait --for=condition=complete job/migrate -n ${NAMESPACE} --timeout=300s; then
            log_success "Миграции успешно применены!"
        else
            log_warn "Миграции не завершены в течение 5 минут. Проверьте логи:"
            kubectl logs job/migrate -n ${NAMESPACE} || echo "Логи недоступны"
            log_warn "Продолжаем развёртывание..."
        fi
    fi

    # Применение основных манифестов
    for manifest in "${MANIFESTS[@]}"; do
        if [ "$manifest" != "namespace.yaml" ]; then
            log_info "Применение ${manifest}..."
            kubectl apply -f "${SCRIPT_DIR}/${manifest}"
        fi
    done

    # Применение landing page
    log_info "Применение landing page..."
    for manifest in "${LANDING_MANIFESTS[@]}"; do
        if [ -f "${SCRIPT_DIR}/${manifest}" ]; then
            log_info "Применение ${manifest}..."
            kubectl apply -f "${SCRIPT_DIR}/${manifest}"
        fi
    done

    # Применение CronJob для пересоздания индексов
    log_info "Применение CronJob для пересоздания индексов..."
    if [ -f "${SCRIPT_DIR}/rebuild-indexes-cronjob.yaml" ]; then
        kubectl apply -f "${SCRIPT_DIR}/rebuild-indexes-cronjob.yaml"
        log_success "CronJob rebuild-indexes применён (запуск 1-го числа каждого месяца в 03:00)"
    fi

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

# Ручной запуск пересоздания индексов
rebuild_indexes_manual() {
    log_warn "Ручной запуск пересоздания индексов..."

    # Создаём job вручную
    kubectl create job --from=cronjob/rebuild-indexes rebuild-indexes-manual -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

    log_info "Ожидание завершения задачи..."
    kubectl wait --for=condition=complete job/rebuild-indexes-manual -n ${NAMESPACE} --timeout=7200s || log_error "Задача не завершена в течение 2 часов"

    # Вывод логов
    log_info "Логи задачи:"
    kubectl logs job/rebuild-indexes-manual -n ${NAMESPACE}

    # Удаление задачи
    kubectl delete job/rebuild-indexes-manual -n ${NAMESPACE} --ignore-not-found=true || true

    log_success "Пересоздание индексов завершено"
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

    # Jobs
    log_info "Jobs (миграции и пересоздание индексов):"
    kubectl get jobs -n ${NAMESPACE} -o wide
    echo ""

    # CronJobs
    log_info "CronJobs:"
    kubectl get cronjobs -n ${NAMESPACE} -o wide
    echo ""

    # Последние события
    log_info "Последние события:"
    kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp' | tail -20
    echo ""

    # Статус миграций
    log_info "Статус миграций:"
    if kubectl get job/migrate -n ${NAMESPACE} &>/dev/null; then
        kubectl get job/migrate -n ${NAMESPACE} -o wide
        echo ""
        log_info "Последние логи миграций:"
        kubectl logs job/migrate -n ${NAMESPACE} --tail=20 || echo "Логи недоступны"
    else
        echo "Job migrate не найден"
    fi
    echo ""

    # Статус пересоздания индексов
    log_info "Статус пересоздания индексов:"
    if kubectl get cronjob/rebuild-indexes -n ${NAMESPACE} &>/dev/null; then
        kubectl get cronjob/rebuild-indexes -n ${NAMESPACE} -o wide
        echo ""
        log_info "Последние задачи пересоздания индексов:"
        kubectl get jobs -n ${NAMESPACE} -l app=rebuild-indexes --sort-by='.metadata.creationTimestamp' -o wide | tail -5
    else
        echo "CronJob rebuild-indexes не найден"
    fi
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
        rebuild-indexes)
            rebuild_indexes_manual
            ;;
        *)
            echo "Использование: $0 {apply|rollback|status|cleanup|rebuild-indexes}"
            echo ""
            echo "Команды:"
            echo "  apply           - Применить все манифесты и развернуть приложение"
            echo "  rollback        - Откатить развёртывание (удалить все ресурсы)"
            echo "  status          - Показать статус развёртывания"
            echo "  cleanup         - Полная очистка (включая PVC)"
            echo "  rebuild-indexes - Ручной запуск пересоздания индексов"
            exit 1
            ;;
    esac
}

main "$@"
