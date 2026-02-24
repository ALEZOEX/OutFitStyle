#!/bin/bash
#
# РЎРєСЂРёРїС‚ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ OutfitStyle РІ Kubernetes (k3s)
#
# РСЃРїРѕР»СЊР·РѕРІР°РЅРёРµ:
#   ./deploy.sh [apply|rollback|status|cleanup|rebuild-indexes]
#
# РљРѕРјР°РЅРґС‹:
#   apply           - РџСЂРёРјРµРЅРёС‚СЊ РІСЃРµ РјР°РЅРёС„РµСЃС‚С‹ Рё СЂР°Р·РІРµСЂРЅСѓС‚СЊ РїСЂРёР»РѕР¶РµРЅРёРµ
#   rollback        - РћС‚РєР°С‚РёС‚СЊ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёРµ (СѓРґР°Р»РёС‚СЊ РІСЃРµ СЂРµСЃСѓСЂСЃС‹)
#   status          - РџРѕРєР°Р·Р°С‚СЊ СЃС‚Р°С‚СѓСЃ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ
#   cleanup         - РџРѕР»РЅР°СЏ РѕС‡РёСЃС‚РєР° (РІРєР»СЋС‡Р°СЏ PVC)
#   rebuild-indexes - Р СѓС‡РЅРѕР№ Р·Р°РїСѓСЃРє РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ
#

set -e

# Р¦РІРµС‚Р° РґР»СЏ РІС‹РІРѕРґР°
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# РџРµСЂРµРјРµРЅРЅС‹Рµ
NAMESPACE="outfitstyle"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS=(
    "namespace.yaml"
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

# Р¤СѓРЅРєС†РёСЏ РґР»СЏ РІС‹РІРѕРґР° СЃРѕРѕР±С‰РµРЅРёР№
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

# РџСЂРѕРІРµСЂРєР° РЅР°Р»РёС‡РёСЏ kubectl
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl РЅРµ РЅР°Р№РґРµРЅ. РџРѕР¶Р°Р»СѓР№СЃС‚Р°, СѓСЃС‚Р°РЅРѕРІРёС‚Рµ kubectl."
        exit 1
    fi
}

# РџСЂРѕРІРµСЂРєР° РїРѕРґРєР»СЋС‡РµРЅРёСЏ Рє РєР»Р°СЃС‚РµСЂСѓ
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        log_error "РќРµ СѓРґР°Р»РѕСЃСЊ РїРѕРґРєР»СЋС‡РёС‚СЊСЃСЏ Рє Kubernetes РєР»Р°СЃС‚РµСЂСѓ."
        exit 1
    fi
    log_success "РџРѕРґРєР»СЋС‡РµРЅРёРµ Рє РєР»Р°СЃС‚РµСЂСѓ СѓСЃС‚Р°РЅРѕРІР»РµРЅРѕ"
}

# РџСЂРёРјРµРЅРµРЅРёРµ РјР°РЅРёС„РµСЃС‚РѕРІ
apply_manifests() {
    log_info "РќР°С‡Р°Р»Рѕ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ OutfitStyle..."

    # РџСЂРѕРІРµСЂРєР° secrets
    if [ ! -f "${SCRIPT_DIR}/secrets.yaml" ]; then
        log_warn "Р¤Р°Р№Р» secrets.yaml РЅРµ РЅР°Р№РґРµРЅ. РЎРѕР·РґР°Р№С‚Рµ РµРіРѕ РЅР° РѕСЃРЅРѕРІРµ secrets.yaml.example"
        log_info "РџСЂРёРјРµСЂ: cp ${SCRIPT_DIR}/secrets.yaml.example ${SCRIPT_DIR}/secrets.yaml"
        exit 1
    fi

    # РџСЂРёРјРµРЅРµРЅРёРµ namespace
    log_info "РЎРѕР·РґР°РЅРёРµ namespace ${NAMESPACE}..."
    kubectl apply -f "${SCRIPT_DIR}/namespace.yaml"

    # РџСЂРёРјРµРЅРµРЅРёРµ secrets
    log_info "РџСЂРёРјРµРЅРµРЅРёРµ secrets..."
    kubectl apply -f "${SCRIPT_DIR}/secrets.yaml"

    # РћС‡РёСЃС‚РєР° СЃС‚Р°СЂС‹С… РЅРµРЅСѓР¶РЅС‹С… СЂРµСЃСѓСЂСЃРѕРІ
    log_info "РћС‡РёСЃС‚РєР° СЃС‚Р°СЂС‹С… СЂРµСЃСѓСЂСЃРѕРІ..."
    kubectl delete deployment grafana -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete deployment prometheus -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete deployment kafka -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete deployment zookeeper -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete svc grafana -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete svc prometheus -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete svc kafka -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete svc zookeeper -n ${NAMESPACE} --ignore-not-found=true || true
    kubectl delete pvc grafana-pvc -n ${NAMESPACE} --ignore-not-found=true || true
    log_success "РЎС‚Р°СЂС‹Рµ СЂРµСЃСѓСЂСЃС‹ СѓРґР°Р»РµРЅС‹"

    # РџСЂРёРјРµРЅРµРЅРёРµ РјРёРіСЂР°С†РёР№ Р‘Р”
    log_info "РџСЂРёРјРµРЅРµРЅРёРµ РјРёРіСЂР°С†РёР№ Р±Р°Р·С‹ РґР°РЅРЅС‹С…..."
    if [ -f "${SCRIPT_DIR}/migrate-job.yaml" ]; then
        # РЈРґР°Р»СЏРµРј СЃС‚Р°СЂС‹Р№ job, РµСЃР»Рё СЃСѓС‰РµСЃС‚РІСѓРµС‚
        kubectl delete job/migrate -n ${NAMESPACE} --ignore-not-found=true || true
        # РџСЂРёРјРµРЅСЏРµРј РЅРѕРІС‹Р№ job
        kubectl apply -f "${SCRIPT_DIR}/migrate-job.yaml"
        # Р–РґС‘Рј Р·Р°РІРµСЂС€РµРЅРёСЏ РјРёРіСЂР°С†РёР№
        log_info "РћР¶РёРґР°РЅРёРµ Р·Р°РІРµСЂС€РµРЅРёСЏ РјРёРіСЂР°С†РёР№ (РґРѕ 5 РјРёРЅСѓС‚)..."
        if kubectl wait --for=condition=complete job/migrate -n ${NAMESPACE} --timeout=300s; then
            log_success "РњРёРіСЂР°С†РёРё СѓСЃРїРµС€РЅРѕ РїСЂРёРјРµРЅРµРЅС‹!"
        else
            log_warn "РњРёРіСЂР°С†РёРё РЅРµ Р·Р°РІРµСЂС€РµРЅС‹ РІ С‚РµС‡РµРЅРёРµ 5 РјРёРЅСѓС‚. РџСЂРѕРІРµСЂСЊС‚Рµ Р»РѕРіРё:"
            kubectl logs job/migrate -n ${NAMESPACE} || echo "Р›РѕРіРё РЅРµРґРѕСЃС‚СѓРїРЅС‹"
            log_warn "РџСЂРѕРґРѕР»Р¶Р°РµРј СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёРµ..."
        fi
    fi

    # РџСЂРёРјРµРЅРµРЅРёРµ РѕСЃРЅРѕРІРЅС‹С… РјР°РЅРёС„РµСЃС‚РѕРІ
    for manifest in "${MANIFESTS[@]}"; do
        if [ "$manifest" != "namespace.yaml" ]; then
            log_info "РџСЂРёРјРµРЅРµРЅРёРµ ${manifest}..."
            kubectl apply -f "${SCRIPT_DIR}/${manifest}"
        fi
    done

    # РџСЂРёРјРµРЅРµРЅРёРµ landing page
    log_info "РџСЂРёРјРµРЅРµРЅРёРµ landing page..."
    for manifest in "${LANDING_MANIFESTS[@]}"; do
        if [ -f "${SCRIPT_DIR}/${manifest}" ]; then
            log_info "РџСЂРёРјРµРЅРµРЅРёРµ ${manifest}..."
            kubectl apply -f "${SCRIPT_DIR}/${manifest}"
        fi
    done

    # РџСЂРёРјРµРЅРµРЅРёРµ CronJob РґР»СЏ РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ
    log_info "РџСЂРёРјРµРЅРµРЅРёРµ CronJob РґР»СЏ РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ..."
    if [ -f "${SCRIPT_DIR}/rebuild-indexes-cronjob.yaml" ]; then
        kubectl apply -f "${SCRIPT_DIR}/rebuild-indexes-cronjob.yaml"
        log_success "CronJob rebuild-indexes РїСЂРёРјРµРЅС‘РЅ (Р·Р°РїСѓСЃРє 1-РіРѕ С‡РёСЃР»Р° РєР°Р¶РґРѕРіРѕ РјРµСЃСЏС†Р° РІ 03:00)"
    fi

    log_success "Р’СЃРµ РјР°РЅРёС„РµСЃС‚С‹ РїСЂРёРјРµРЅРµРЅС‹!"

    # РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё РїРѕРґРѕРІ
    log_info "РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё РїРѕРґРѕРІ..."
    wait_for_pods

    # Р’С‹РІРѕРґ РёРЅС„РѕСЂРјР°С†РёРё
    show_status
}

# РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё РїРѕРґРѕРІ
wait_for_pods() {
    log_info "РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё PostgreSQL..."
    kubectl wait --for=condition=ready pod -l app=postgres -n ${NAMESPACE} --timeout=120s || log_warn "PostgreSQL РЅРµ РіРѕС‚РѕРІР° РІ С‚РµС‡РµРЅРёРµ 120СЃ"
    
    log_info "РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё Redis..."
    kubectl wait --for=condition=ready pod -l app=redis -n ${NAMESPACE} --timeout=60s || log_warn "Redis РЅРµ РіРѕС‚РѕРІ РІ С‚РµС‡РµРЅРёРµ 60СЃ"
    
    log_info "РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё Backend..."
    kubectl wait --for=condition=ready pod -l app=backend -n ${NAMESPACE} --timeout=120s || log_warn "Backend РЅРµ РіРѕС‚РѕРІ РІ С‚РµС‡РµРЅРёРµ 120СЃ"
    
    log_info "РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё ML Service..."
    kubectl wait --for=condition=ready pod -l app=ml-service -n ${NAMESPACE} --timeout=120s || log_warn "ML Service РЅРµ РіРѕС‚РѕРІ РІ С‚РµС‡РµРЅРёРµ 120СЃ"
    
    log_info "РћР¶РёРґР°РЅРёРµ РіРѕС‚РѕРІРЅРѕСЃС‚Рё Frontend..."
    kubectl wait --for=condition=ready pod -l app=frontend -n ${NAMESPACE} --timeout=60s || log_warn "Frontend РЅРµ РіРѕС‚РѕРІ РІ С‚РµС‡РµРЅРёРµ 60СЃ"
}

# РћС‚РєР°С‚ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ
rollback() {
    log_warn "РќР°С‡Р°Р»Рѕ РѕС‚РєР°С‚Р° СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ..."
    
    for manifest in "${MANIFESTS[@]}"; do
        if [ -f "${SCRIPT_DIR}/${manifest}" ]; then
            log_info "РЈРґР°Р»РµРЅРёРµ СЂРµСЃСѓСЂСЃРѕРІ РёР· ${manifest}..."
            kubectl delete -f "${SCRIPT_DIR}/${manifest}" --ignore-not-found=true || true
        fi
    done
    
    # РЈРґР°Р»РµРЅРёРµ secrets Рё namespace
    kubectl delete -f "${SCRIPT_DIR}/secrets.yaml" --ignore-not-found=true || true
    kubectl delete -f "${SCRIPT_DIR}/namespace.yaml" --ignore-not-found=true || true
    
    log_success "РћС‚РєР°С‚ Р·Р°РІРµСЂС€С‘РЅ"
}

# РџРѕР»РЅР°СЏ РѕС‡РёСЃС‚РєР° (РІРєР»СЋС‡Р°СЏ PVC)
cleanup() {
    log_warn "РќР°С‡Р°Р»Рѕ РїРѕР»РЅРѕР№ РѕС‡РёСЃС‚РєРё (РІРєР»СЋС‡Р°СЏ PersistentVolumeClaims)..."

    # РЈРґР°Р»РµРЅРёРµ PVC
    log_info "РЈРґР°Р»РµРЅРёРµ PersistentVolumeClaims..."
    kubectl delete pvc --all -n ${NAMESPACE} --ignore-not-found=true || true

    # РћС‚РєР°С‚ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ
    rollback

    log_success "РџРѕР»РЅР°СЏ РѕС‡РёСЃС‚РєР° Р·Р°РІРµСЂС€РµРЅР°"
}

# Р СѓС‡РЅРѕР№ Р·Р°РїСѓСЃРє РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ
rebuild_indexes_manual() {
    log_warn "Р СѓС‡РЅРѕР№ Р·Р°РїСѓСЃРє РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ..."

    # РЎРѕР·РґР°С‘Рј job РІСЂСѓС‡РЅСѓСЋ
    kubectl create job --from=cronjob/rebuild-indexes rebuild-indexes-manual -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

    log_info "РћР¶РёРґР°РЅРёРµ Р·Р°РІРµСЂС€РµРЅРёСЏ Р·Р°РґР°С‡Рё..."
    kubectl wait --for=condition=complete job/rebuild-indexes-manual -n ${NAMESPACE} --timeout=7200s || log_error "Р—Р°РґР°С‡Р° РЅРµ Р·Р°РІРµСЂС€РµРЅР° РІ С‚РµС‡РµРЅРёРµ 2 С‡Р°СЃРѕРІ"

    # Р’С‹РІРѕРґ Р»РѕРіРѕРІ
    log_info "Р›РѕРіРё Р·Р°РґР°С‡Рё:"
    kubectl logs job/rebuild-indexes-manual -n ${NAMESPACE}

    # РЈРґР°Р»РµРЅРёРµ Р·Р°РґР°С‡Рё
    kubectl delete job/rebuild-indexes-manual -n ${NAMESPACE} --ignore-not-found=true || true

    log_success "РџРµСЂРµСЃРѕР·РґР°РЅРёРµ РёРЅРґРµРєСЃРѕРІ Р·Р°РІРµСЂС€РµРЅРѕ"
}

# РџРѕРєР°Р·Р°С‚СЊ СЃС‚Р°С‚СѓСЃ
show_status() {
    echo ""
    log_info "=== РЎС‚Р°С‚СѓСЃ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ ==="
    echo ""

    # РџРѕРґС‹
    log_info "РџРѕРґС‹:"
    kubectl get pods -n ${NAMESPACE} -o wide
    echo ""

    # Jobs
    log_info "Jobs (РјРёРіСЂР°С†РёРё Рё РїРµСЂРµСЃРѕР·РґР°РЅРёРµ РёРЅРґРµРєСЃРѕРІ):"
    kubectl get jobs -n ${NAMESPACE} -o wide
    echo ""

    # CronJobs
    log_info "CronJobs:"
    kubectl get cronjobs -n ${NAMESPACE} -o wide
    echo ""

    # РџРѕСЃР»РµРґРЅРёРµ СЃРѕР±С‹С‚РёСЏ
    log_info "РџРѕСЃР»РµРґРЅРёРµ СЃРѕР±С‹С‚РёСЏ:"
    kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp' | tail -20
    echo ""

    # РЎС‚Р°С‚СѓСЃ РјРёРіСЂР°С†РёР№
    log_info "РЎС‚Р°С‚СѓСЃ РјРёРіСЂР°С†РёР№:"
    if kubectl get job/migrate -n ${NAMESPACE} &>/dev/null; then
        kubectl get job/migrate -n ${NAMESPACE} -o wide
        echo ""
        log_info "РџРѕСЃР»РµРґРЅРёРµ Р»РѕРіРё РјРёРіСЂР°С†РёР№:"
        kubectl logs job/migrate -n ${NAMESPACE} --tail=20 || echo "Р›РѕРіРё РЅРµРґРѕСЃС‚СѓРїРЅС‹"
    else
        echo "Job migrate РЅРµ РЅР°Р№РґРµРЅ"
    fi
    echo ""

    # РЎС‚Р°С‚СѓСЃ РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ
    log_info "РЎС‚Р°С‚СѓСЃ РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ:"
    if kubectl get cronjob/rebuild-indexes -n ${NAMESPACE} &>/dev/null; then
        kubectl get cronjob/rebuild-indexes -n ${NAMESPACE} -o wide
        echo ""
        log_info "РџРѕСЃР»РµРґРЅРёРµ Р·Р°РґР°С‡Рё РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ:"
        kubectl get jobs -n ${NAMESPACE} -l app=rebuild-indexes --sort-by='.metadata.creationTimestamp' -o wide | tail -5
    else
        echo "CronJob rebuild-indexes РЅРµ РЅР°Р№РґРµРЅ"
    fi
    echo ""

    # РЎРµСЂРІРёСЃС‹
    log_info "РЎРµСЂРІРёСЃС‹:"
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

# РћСЃРЅРѕРІРЅР°СЏ С„СѓРЅРєС†РёСЏ
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
            echo "РСЃРїРѕР»СЊР·РѕРІР°РЅРёРµ: $0 {apply|rollback|status|cleanup|rebuild-indexes}"
            echo ""
            echo "РљРѕРјР°РЅРґС‹:"
            echo "  apply           - РџСЂРёРјРµРЅРёС‚СЊ РІСЃРµ РјР°РЅРёС„РµСЃС‚С‹ Рё СЂР°Р·РІРµСЂРЅСѓС‚СЊ РїСЂРёР»РѕР¶РµРЅРёРµ"
            echo "  rollback        - РћС‚РєР°С‚РёС‚СЊ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёРµ (СѓРґР°Р»РёС‚СЊ РІСЃРµ СЂРµСЃСѓСЂСЃС‹)"
            echo "  status          - РџРѕРєР°Р·Р°С‚СЊ СЃС‚Р°С‚СѓСЃ СЂР°Р·РІС‘СЂС‚С‹РІР°РЅРёСЏ"
            echo "  cleanup         - РџРѕР»РЅР°СЏ РѕС‡РёСЃС‚РєР° (РІРєР»СЋС‡Р°СЏ PVC)"
            echo "  rebuild-indexes - Р СѓС‡РЅРѕР№ Р·Р°РїСѓСЃРє РїРµСЂРµСЃРѕР·РґР°РЅРёСЏ РёРЅРґРµРєСЃРѕРІ"
            exit 1
            ;;
    esac
}

main "$@"
