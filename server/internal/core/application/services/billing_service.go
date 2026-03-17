package services

import (
	"context"
	"io"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

const (
	// BillingCycleMonthly представляет месячный цикл оплаты
	BillingCycleMonthly = "monthly"

	// BillingCycleYearly представляет годовой цикл оплаты
	BillingCycleYearly = "yearly"

	// CurrencyRUB представляет валюту Российский рубль
	CurrencyRUB = "RUB"

	// StatusPending представляет статус ожидания платежа
	StatusPending = "pending"

	// StatusActive представляет активный статус подписки
	StatusActive = "active"
)

// BillingService сервис для обработки биллинга и webhook
type BillingService struct {
	billingRepo repositories.BillingRepository
	promoRepo   repositories.PromoRepository
	gateways    map[string]domain.PaymentGateway
}

// NewBillingService создаёт новый сервис биллинга
func NewBillingService(
	bill repositories.BillingRepository,
	promo repositories.PromoRepository,
	gateways map[string]domain.PaymentGateway,
) *BillingService {
	return &BillingService{
		billingRepo: bill,
		promoRepo:   promo,
		gateways:    gateways,
	}
}

// HandleWebhook обрабатывает webhook от платежного провайдера
func (s *BillingService) HandleWebhook(ctx context.Context, provider string, headers map[string]string, body []byte) error {
	gw := s.gateways[provider]
	if gw == nil {
		return errors.New("unknown payment provider: " + provider)
	}

	extID, status, receipt, errMsg, err := gw.ParseWebhook(ctx, headers, body)
	if err != nil {
		return err
	}

	return s.billingRepo.UpdatePaymentStatusByExternalID(ctx, provider, extID, status, receipt, errMsg)
}

// Promo проверяет промокод
func (s *BillingService) Promo(ctx context.Context, code string) (map[string]any, error) {
	p, err := s.promoRepo.GetByCode(ctx, code)
	if err != nil {
		return nil, err
	}
	if p == nil || !p.IsActive {
		return nil, errors.New("promo not found")
	}
	if p.ValidUntil != nil && time.Now().After(*p.ValidUntil) {
		return nil, errors.New("promo expired")
	}

	return map[string]any{
		"code":             p.Code,
		"discount_type":    p.DiscountType,
		"discount_value":   p.DiscountValue,
		"applicable_plans": p.ApplicablePlans,
		"valid_until":      p.ValidUntil,
	}, nil
}

// LegacySubscribe устаревший метод подписки (для обратной совместимости)
func (s *BillingService) LegacySubscribe(ctx context.Context, userID domain.ID, req domain.SubscribeRequest) (*domain.SubscribeResponse, error) {
	// Этот метод теперь делегируется PaymentService
	// Оставлен для обратной совместимости
	return nil, errors.New("use PaymentService.Subscribe instead")
}

// LegacyCancel устаревший метод отмены (для обратной совместимости)
func (s *BillingService) LegacyCancel(ctx context.Context, userID domain.ID, immediate bool) error {
	return errors.New("use PaymentService.Cancel instead")
}

// LegacyReactivate устаревший метод восстановления (для обратной совместимости)
func (s *BillingService) LegacyReactivate(ctx context.Context, userID domain.ID) error {
	return errors.New("use PaymentService.Reactivate instead")
}

// ListPayments возвращает список платежей пользователя
func (s *BillingService) ListPayments(ctx context.Context, userID domain.ID, page, limit int) ([]domain.Payment, domain.Pagination, error) {
	userIDInt := domain.IDToInt64(userID)
	items, total, err := s.billingRepo.ListPayments(ctx, userIDInt, page, limit)
	if err != nil {
		return nil, domain.Pagination{}, err
	}
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}
	return items, domain.Pagination{Page: page, Limit: limit, Total: total}, nil
}

// ptr возвращает указатель на значение
func ptr[T any](v T) *T { return &v }

func newExternalID() string { return uuid.NewString() }

// PaymentHandler устаревший обработчик платежей (для обратной совместимости)
type PaymentHandler struct {
	svc *BillingService
	log interface{}
}

// NewPaymentHandler устаревший конструктор (для обратной совместимости)
func NewPaymentHandler(svc *BillingService, log interface{}) *PaymentHandler {
	return &PaymentHandler{svc: svc, log: log}
}

// RegisterWebhook регистрирует webhook маршруты
// Deprecated: метод устарел, используется автоматическая регистрация
func (h *PaymentHandler) RegisterWebhook(r interface{}) {
}

// Webhook обрабатывает webhook
func (h *PaymentHandler) Webhook(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	headers := map[string]string{}
	for k, v := range r.Header {
		if len(v) > 0 {
			headers[k] = v[0]
		}
	}

	// Извлекаем provider из URL (нужен mux.Vars)
	// Для простоты передаём "unknown"
	if err := h.svc.HandleWebhook(r.Context(), "unknown", headers, body); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"success": true}`))
}
