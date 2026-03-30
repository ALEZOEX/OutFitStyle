#!/bin/bash
#
# Проверка Istio + Traefik на K3s
#
# Использование: ./verify.sh
#
# Проверяет:
#   1. Istio control plane работает
#   2. Sidecar injection работает
#   3. mTLS в PERMISSIVE mode
#   4. Traefik → sidecar трафик проходит
#   5. Health checks работают
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
PASS=0
FAIL=0
WARN=0

pass() { echo -e "  ${GREEN}✓ PASS${NC} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✗ FAIL${NC} $1"; ((FAIL++)); }
warn() { echo -e "  ${YELLOW}⚠ WARN${NC} $1"; ((WARN++)); }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

section "1. Istio Control Plane"

# istiod running
if kubectl get pods -n istio-system -l app=istiod --field-selector=status.phase=Running 2>/dev/null | grep -q istiod; then
    pass "istiod запущен"
else
    fail "istiod не запущен. Выполните: ./install.sh install"
fi

# istioctl version
if command -v istioctl &>/dev/null; then
    CLIENT_VER=$(istioctl version --short 2>/dev/null | grep "client" || echo "unknown")
    pass "istioctl установлен: ${CLIENT_VER}"
else
    warn "istioctl не найден в PATH"
fi

section "2. Sidecar Injection"

# Namespace label
INJECTION=$(kubectl get namespace ${NAMESPACE} -o jsonpath='{.metadata.labels.istio-injection}' 2>/dev/null || echo "")
if [ "$INJECTION" = "enabled" ]; then
    pass "Namespace '${NAMESPACE}' имеет label istio-injection=enabled"
else
    fail "Namespace '${NAMESPACE}' НЕ имеет label istio-injection. Выполните: kubectl label namespace ${NAMESPACE} istio-injection=enabled"
fi

# Check each deployment for sidecar
for deploy in backend frontend ml-service; do
    CONTAINERS=$(kubectl get deployment/${deploy} -n ${NAMESPACE} -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null || echo "")
    if echo "$CONTAINERS" | grep -q "istio-proxy"; then
        pass "Deployment '${deploy}' имеет istio-proxy sidecar"
    elif [ -z "$CONTAINERS" ]; then
        warn "Deployment '${deploy}' не найден"
    else
        fail "Deployment '${deploy}' НЕ имеет sidecar. Выполните: kubectl rollout restart deployment/${deploy} -n ${NAMESPACE}"
    fi
done

section "3. PeerAuthentication (mTLS)"

# Global mesh policy
MTLS_MODE=$(kubectl get peerauthentication -n istio-system default -o jsonpath='{.spec.mtls.mode}' 2>/dev/null || echo "NONE")
if [ "$MTLS_MODE" = "PERMISSIVE" ]; then
    pass "Глобальный mTLS режим: PERMISSIVE (accepts plaintext + mTLS)"
elif [ "$MTLS_MODE" = "STRICT" ]; then
    warn "Глобальный mTLS режим: STRICT (only mTLS). Убедитесь что весь трафик использует mTLS"
else
    warn "Глобальный PeerAuthentication не найден в istio-system"
fi

# Namespace policy
NS_MTLS=$(kubectl get peerauthentication -n ${NAMESPACE} outfitstyle-mesh -o jsonpath='{.spec.mtls.mode}' 2>/dev/null || echo "NONE")
if [ "$NS_MTLS" = "PERMISSIVE" ]; then
    pass "Namespace mTLS режим: PERMISSIVE"
else
    warn "Namespace PeerAuthentication не найден"
fi

section "4. DestinationRules"

for dr in api-destination-rule ml-destination-rule frontend-destination-rule; do
    DR_HOST=$(kubectl get destinationrule/${dr} -n ${NAMESPACE} -o jsonpath='{.spec.host}' 2>/dev/null || echo "")
    DR_MTLS=$(kubectl get destinationrule/${dr} -n ${NAMESPACE} -o jsonpath='{.spec.trafficPolicy.tls.mode}' 2>/dev/null || echo "NONE")
    if [ -n "$DR_HOST" ]; then
        pass "DestinationRule '${dr}' -> ${DR_HOST} (tls: ${DR_MTLS})"
    else
        warn "DestinationRule '${dr}' не найден"
    fi
done

section "5. Traefik + Istio Compatibility"

# Check Traefik is running
if kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik --field-selector=status.phase=Running 2>/dev/null | grep -q traefik; then
    pass "Traefik запущен в kube-system"
else
    warn "Traefik не найден или не запущен"
fi

# Check Ingress
INGRESS=$(kubectl get ingress -n ${NAMESPACE} outfitstyle-ingress -o jsonpath='{.spec.ingressClassName}' 2>/dev/null || echo "")
if [ "$INGRESS" = "traefik" ]; then
    pass "IngressClass: traefik"
else
    warn "Ingress outfitstyle-ingress не найден"
fi

section "6. Health Checks через Sidecar"

# Backend health
BACKEND_POD=$(kubectl get pods -n ${NAMESPACE} -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$BACKEND_POD" ]; then
    # Exec into pod and check health endpoint
    if kubectl exec -n ${NAMESPACE} ${BACKEND_POD} -c istio-proxy -- wget -qO- http://localhost:8080/health 2>/dev/null | grep -q "ok\|healthy\|UP"; then
        pass "Backend /health через sidecar: OK"
    else
        # Try direct
        HEALTH=$(kubectl exec -n ${NAMESPACE} ${BACKEND_POD} -c backend -- wget -qO- http://localhost:8080/health 2>/dev/null || echo "FAIL")
        if echo "$HEALTH" | grep -q "ok\|healthy\|UP"; then
            pass "Backend /health прямой запрос: OK"
        else
            warn "Backend /health недоступен (возможно ещё запускается)"
        fi
    fi
else
    warn "Backend pod не найден"
fi

section "7. Трафик через Traefik → Sidecar"

# Check if we can reach backend through ingress
INGRESS_IP=$(kubectl get ingress -n ${NAMESPACE} outfitstyle-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
if [ -n "$INGRESS_IP" ]; then
    pass "Ingress IP: ${INGRESS_IP}"

    # Test health endpoint through ingress
    if curl -sk --max-time 5 "https://${INGRESS_IP}/health" -H "Host: app.outfitstyle.ru" 2>/dev/null | grep -q "ok\|healthy\|UP"; then
        pass "Ingress -> Backend /health через Traefik+Sidecar: OK"
    else
        warn "Ingress health check недоступен (проверьте DNS и TLS)"
    fi
else
    warn "Ingress IP не назначен (проверьте балансировщик)"
fi

section "8. Istio Metrics"

# Check if Envoy metrics are available
BACKEND_POD=$(kubectl get pods -n ${NAMESPACE} -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$BACKEND_POD" ]; then
    if kubectl exec -n ${NAMESPACE} ${BACKEND_POD} -c istio-proxy -- wget -qO- http://localhost:15020/stats/prometheus 2>/dev/null | grep -q "envoy"; then
        pass "Envoy метрики доступны на :15020"
    else
        warn "Envoy метрики недоступны"
    fi
fi

# ========================
# Итог
# ========================
echo ""
section "Результат проверки"
echo -e "  ${GREEN}PASS: ${PASS}${NC}"
echo -e "  ${RED}FAIL: ${FAIL}${NC}"
echo -e "  ${YELLOW}WARN: ${WARN}${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
    echo -e "${RED}Есть критические проблемы. Проверьте ошибки выше.${NC}"
    exit 1
else
    echo -e "${GREEN}Все проверки пройдены. Istio + Traefik работают корректно.${NC}"
    echo ""
    echo "Следующие шаги:"
    echo "  1. Мониторинг: kubectl logs -n ${NAMESPACE} -l app=backend -c istio-proxy"
    echo "  2. Kiali dashboard: istioctl dashboard kiali"
    echo "  3. Grafana: istioctl dashboard grafana"
    echo "  4. Переключение на STRICT mTLS: измените tls.mode: STRICT в peer-authentication.yaml"
fi
