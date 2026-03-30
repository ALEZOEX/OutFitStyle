#!/bin/bash
#
# Установка Istio на K3s кластер
#
# Использование:
#   ./install.sh [install|uninstall|status]
#
# Важно:
#   - Traefik остаётся ingress controller (K3s built-in)
#   - Istio используется как service mesh (mTLS, observability)
#   - Начинаем с PERMISSIVE mTLS (не ломаем существующий трафик)
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
ISTIO_VERSION="1.24.3"
ISTIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../k8s" && pwd)"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl не найден"
        exit 1
    fi
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Нет подключения к кластеру"
        exit 1
    fi
    log_success "kubectl подключён к кластеру"
}

# ========================
# Установка Istio
# ========================
install_istio() {
    log_info "=== Установка Istio ${ISTIO_VERSION} на K3s ==="

    # 1. Скачиваем istioctl если нет
    if ! command -v istioctl &> /dev/null; then
        log_info "Установка istioctl ${ISTIO_VERSION}..."
        curl -sL https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
        export PATH="$PWD/istio-${ISTIO_VERSION}/bin:$PATH"

        if [[ ":$PATH:" != *":$PWD/istio-${ISTIO_VERSION}/bin:"* ]]; then
            log_warn "Добавьте в PATH: export PATH=\"\$PWD/istio-${ISTIO_VERSION}/bin:\$PATH\""
        fi
    fi

    log_info "istioctl version: $(istioctl version --short 2>/dev/null || echo 'unknown')"

    # 2. Предварительная проверка
    log_info "Запуск istioctl pre-check..."
    istioctl x precheck || {
        log_warn "Pre-check обнаружил проблемы, но продолжаем..."
    }

    # 3. Установка Istio с профилем "default"
    #    - Не ставим свой ingress gateway (используем Traefik)
    #    - Sidecar injection будет работать через namespace label
    log_info "Установка Istio control plane..."

    cat <<EOF | istioctl install -y -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: outfitstyle-istio
spec:
  profile: default
  meshConfig:
    # Включаем доступные адаптеры для K3s
    accessLogFile: /dev/stdout
    accessLogEncoding: JSON

    # Настройки mTLS - начинаем с PERMISSIVE
    defaultConfig:
      holdApplicationUntilProxyStarts: true
      tracing:
        sampling: 10.0

    # Разрешаем plaintext от Traefik (K3s ingress)
    outboundTrafficPolicy:
      mode: ALLOW_ANY

  components:
    # Отключаем Istio ingress gateway - используем Traefik
    ingressGateways:
      - name: istio-ingressgateway
        enabled: false

    # Оставляем egress gateway
    egressGateways:
      - name: istio-egressgateway
        enabled: true

    # Pilot (istiod) - обязательно
    pilot:
      k8s:
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 1Gi
        hpaSpec:
          minReplicas: 1
          maxReplicas: 2
EOF

    log_success "Istio control plane установлен"

    # 4. Ждём готовности istiod
    log_info "Ожидание готовности istiod..."
    kubectl rollout status deployment/istiod -n istio-system --timeout=180s || {
        log_warn "istiod не готов за 180с, проверьте: kubectl get pods -n istio-system"
    }
    log_success "istiod готов"

    # 5. Включаем sidecar injection для namespace outfitstyle
    log_info "Включение sidecar injection для namespace '${NAMESPACE}'..."
    kubectl label namespace ${NAMESPACE} istio-injection=enabled --overwrite
    log_success "Sidecar injection включён для namespace '${NAMESPACE}'"

    # 6. Применяем манифесты
    log_info "Применение Istio manifests..."

    # PeerAuthentication - PERMISSIVE mode
    log_info "  -> PeerAuthentication (PERMISSIVE mTLS)..."
    kubectl apply -f "${ISTIO_DIR}/peer-authentication.yaml"

    # DestinationRules с mTLS
    log_info "  -> DestinationRules..."
    kubectl apply -f "${ISTIO_DIR}/destination-rule.yaml"

    # ServiceEntries
    log_info "  -> ServiceEntries..."
    kubectl apply -f "${ISTIO_DIR}/service-entries.yaml"

    log_success "Все Istio manifests применены"

    # 7. Перезапуск deployments для инжекта sidecar'ов
    log_info "Перезапуск deployments для sidecar injection..."
    for deploy in backend frontend ml-service; do
        if kubectl get deployment/${deploy} -n ${NAMESPACE} &>/dev/null; then
            log_info "  -> Rolling restart: ${deploy}"
            kubectl rollout restart deployment/${deploy} -n ${NAMESPACE}
        fi
    done

    # 8. Ждём готовности подов
    log_info "Ожидание готовности подов (до 3 минут)..."
    sleep 10
    for deploy in backend frontend ml-service; do
        if kubectl get deployment/${deploy} -n ${NAMESPACE} &>/dev/null; then
            kubectl rollout status deployment/${deploy} -n ${NAMESPACE} --timeout=180s || {
                log_warn "${deploy} не готов за 180с"
            }
        fi
    done

    log_success "=== Istio установлен и настроен ==="
    echo ""
    show_status
}

# ========================
# Удаление Istio
# ========================
uninstall_istio() {
    log_warn "=== Удаление Istio ==="

    # Удаляем manifests
    kubectl delete -f "${ISTIO_DIR}/peer-authentication.yaml" --ignore-not-found=true || true
    kubectl delete -f "${ISTIO_DIR}/destination-rule.yaml" --ignore-not-found=true || true
    kubectl delete -f "${ISTIO_DIR}/service-entries.yaml" --ignore-not-found=true || true

    # Убираем label injection
    kubectl label namespace ${NAMESPACE} istio-injection- || true

    # Удаляем Istio control plane
    istioctl uninstall --purge -y || true

    # Перезапуск deployments без sidecar
    log_info "Перезапуск deployments без sidecar..."
    for deploy in backend frontend ml-service; do
        if kubectl get deployment/${deploy} -n ${NAMESPACE} &>/dev/null; then
            kubectl rollout restart deployment/${deploy} -n ${NAMESPACE}
        fi
    done

    # Удаляем CRD (опционально)
    # kubectl delete crd -l release=istio || true

    log_success "Istio удалён"
}

# ========================
# Статус
# ========================
show_status() {
    echo ""
    log_info "=== Статус Istio ==="
    echo ""

    log_info "Istio control plane:"
    kubectl get pods -n istio-system 2>/dev/null || echo "  Istio не установлен"
    echo ""

    log_info "Sidecar injection для namespace '${NAMESPACE}':"
    kubectl get namespace ${NAMESPACE} -o jsonpath='{.metadata.labels.istio-injection}' 2>/dev/null || echo "  не настроен"
    echo ""

    log_info "Поды с sidecar:"
    kubectl get pods -n ${NAMESPACE} -o jsonpath='{range .items[*]}{.metadata.name}: {range .spec.containers[*]}{.name} {end}{"\n"}{end}' 2>/dev/null
    echo ""

    log_info "PeerAuthentication:"
    kubectl get peerauthentication -n ${NAMESPACE} 2>/dev/null || echo "  не найдены"
    kubectl get peerauthentication -n istio-system 2>/dev/null || true
    echo ""

    log_info "DestinationRules:"
    kubectl get destinationrules -n ${NAMESPACE} 2>/dev/null || echo "  не найдены"
    echo ""

    log_info "mTLS статус:"
    istioctl x describe pod $(kubectl get pods -n ${NAMESPACE} -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) -n ${NAMESPACE} 2>/dev/null || echo "  нет подов с sidecar"
    echo ""
}

# ========================
# Основная функция
# ========================
main() {
    check_kubectl

    case "${1:-install}" in
        install)
            install_istio
            ;;
        uninstall)
            uninstall_istio
            ;;
        status)
            show_status
            ;;
        *)
            echo "Использование: $0 {install|uninstall|status}"
            exit 1
            ;;
    esac
}

main "$@"
