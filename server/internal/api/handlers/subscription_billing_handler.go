package handlers

import (
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strings"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

// SubscriptionBillingHandler устаревший обработчик (для обратной совместимости)
// Рекомендуется использовать SubscriptionHandler и PaymentHandler
type SubscriptionBillingHandler struct {
	billing *services.BillingService
	log     *zap.Logger
}

// NewSubscriptionBillingHandler создаёт обработчик (для обратной совместимости)
func NewSubscriptionBillingHandler(b *services.BillingService, log *zap.Logger) *SubscriptionBillingHandler {
	return &SubscriptionBillingHandler{billing: b, log: log}
}

// RegisterProtected регистрирует защищённые маршруты (для обратной совместимости)
func (h *SubscriptionBillingHandler) RegisterProtected(r *mux.Router) {
	// Маршруты теперь обрабатываются в SubscriptionHandler
	// Эти заглушки для обратной совместимости
	r.HandleFunc("/subscribe", h.SubscribeDeprecated).Methods(http.MethodPost)
	r.HandleFunc("/cancel", h.CancelDeprecated).Methods(http.MethodPost)
	r.HandleFunc("/reactivate", h.ReactivateDeprecated).Methods(http.MethodPost)
	r.HandleFunc("/promo", h.Promo).Methods(http.MethodPost)
	r.HandleFunc("/payments", h.Payments).Methods(http.MethodGet)
}

// RegisterWebhook регистрирует webhook маршруты
func (h *SubscriptionBillingHandler) RegisterWebhook(r *mux.Router) {
	r.HandleFunc("/webhook/{provider}", h.Webhook).Methods(http.MethodPost)
}

// SubscribeDeprecated устаревший метод (для обратной совместимости)
func (h *SubscriptionBillingHandler) SubscribeDeprecated(w http.ResponseWriter, r *http.Request) {
	resp.Error(w, http.StatusNotImplemented, errors.New("use /api/v1/subscription/subscribe instead"))
}

// CancelDeprecated устаревший метод (для обратной совместимости)
func (h *SubscriptionBillingHandler) CancelDeprecated(w http.ResponseWriter, r *http.Request) {
	resp.Error(w, http.StatusNotImplemented, errors.New("use /api/v1/subscription/cancel instead"))
}

// ReactivateDeprecated устаревший метод (для обратной совместимости)
func (h *SubscriptionBillingHandler) ReactivateDeprecated(w http.ResponseWriter, r *http.Request) {
	resp.Error(w, http.StatusNotImplemented, errors.New("use PaymentService instead"))
}

// Promo проверяет промокод
func (h *SubscriptionBillingHandler) Promo(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req domain.PromoRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	promo, err := h.billing.Promo(r.Context(), req.Code)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"promo": promo})
}

// Payments возвращает список платежей
func (h *SubscriptionBillingHandler) Payments(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	items, pagination, err := h.billing.ListPayments(r.Context(), userID, page, limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list payments"))
		return
	}

	resp.Success(w, map[string]any{
		"payments":   items,
		"pagination": pagination,
	})
}

// Webhook обрабатывает webhook от платежного провайдера
func (h *SubscriptionBillingHandler) Webhook(w http.ResponseWriter, r *http.Request) {
	provider := strings.ToLower(mux.Vars(r)["provider"])
	if provider == "" {
		resp.Error(w, http.StatusBadRequest, errors.New("provider required"))
		return
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	headers := map[string]string{}
	for k, v := range r.Header {
		if len(v) > 0 {
			headers[strings.ToLower(k)] = v[0]
		}
	}

	if err := h.billing.HandleWebhook(r.Context(), provider, headers, body); err != nil {
		h.log.Warn("webhook failed", zap.String("provider", provider), zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}
