package handlers

import (
	"io"
	"net/http"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

// BillingHandler обработчик запросов биллинга
type BillingHandler struct {
	paymentSvc *services.PaymentService
	log        *zap.Logger
}

// NewBillingHandler создаёт новый обработчик биллинга
func NewBillingHandler(paymentSvc *services.PaymentService, log *zap.Logger) *BillingHandler {
	return &BillingHandler{
		paymentSvc: paymentSvc,
		log:        log,
	}
}

// RegisterWebhook регистрирует webhook маршруты
func (h *BillingHandler) RegisterWebhook(r *mux.Router) {
	r.HandleFunc("/webhook/{provider}", h.Webhook).Methods(http.MethodPost)
}

// RegisterProtected регистрирует защищённые маршруты
func (h *BillingHandler) RegisterProtected(r *mux.Router) {
	r.HandleFunc("/refund", h.Refund).Methods(http.MethodPost)
	r.HandleFunc("/payments", h.GetPayments).Methods(http.MethodGet)
}

// Webhook godoc
// @Summary Webhook от платежного провайдера
// @Description Обрабатывает уведомления от платежных систем
// @Tags billing
// @Accept json
// @Produce json
// @Param provider path string true "Платежный провайдер (yookassa, stripe, dummy)"
// @Success 200 {object} map[string]any
// @Router /api/v1/billing/webhook/{provider} [post]
func (h *BillingHandler) Webhook(w http.ResponseWriter, r *http.Request) {
	provider := mux.Vars(r)["provider"]
	defer r.Body.Close()

	body, err := io.ReadAll(r.Body)
	if err != nil {
		h.log.Error("webhook read body failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, errFailedToReadBody)
		return
	}

	headers := make(map[string]string)
	for k, v := range r.Header {
		if len(v) > 0 {
			headers[k] = v[0]
		}
	}

	if err := h.paymentSvc.HandleWebhook(r.Context(), provider, headers, body); err != nil {
		h.log.Error("webhook handle failed", zap.Error(err), zap.String("provider", provider))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}

// RefundRequest запрос на возврат средств
type RefundRequest struct {
	TransactionID int64   `json:"transaction_id" validate:"required"`
	Amount        *float64 `json:"amount,omitempty"`
	Reason        string   `json:"reason" validate:"required"`
}

// Refund godoc
// @Summary Вернуть средства
// @Description Создаёт возврат средств по транзакции
// @Tags billing
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body RefundRequest true "Запрос на возврат средств"
// @Success 200 {object} map[string]any
// @Router /api/v1/billing/refund [post]
func (h *BillingHandler) Refund(w http.ResponseWriter, r *http.Request) {
	// В реальной реализации нужна проверка прав (admin только)
	// Для MVP возвращаем not implemented
	resp.Error(w, http.StatusNotImplemented, errNotImplemented)
}

// GetPayments godoc
// @Summary Получить историю платежей
// @Description Возвращает список платежей пользователя
// @Tags billing
// @Produce json
// @Security BearerAuth
// @Param page query int false "Номер страницы" default(1)
// @Param limit query int false "Размер страницы" default(20)
// @Success 200 {object} map[string]any
// @Router /api/v1/billing/payments [get]
func (h *BillingHandler) GetPayments(w http.ResponseWriter, r *http.Request) {
	// Делегируем subscription handler
	// В реальной реализации можно разделить логику
	resp.Success(w, map[string]any{"payments": []any{}})
}
