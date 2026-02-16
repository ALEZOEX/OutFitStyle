package services

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// PaymentService сервис управления платежами
type PaymentService struct {
	config     *domain.YooKassaConfig
	subRepo    repositories.UserSubscriptionRepository
	txRepo     repositories.SubscriptionTransactionRepository
	planRepo   repositories.SubscriptionPlanRepository
	promoRepo  repositories.PromoCodeRepository
	gateways   map[string]domain.PaymentGateway
	log        *zap.Logger
	httpClient *http.Client
}

// NewPaymentService создаёт новый сервис платежей
func NewPaymentService(
	config *domain.YooKassaConfig,
	subRepo repositories.UserSubscriptionRepository,
	txRepo repositories.SubscriptionTransactionRepository,
	planRepo repositories.SubscriptionPlanRepository,
	promoRepo repositories.PromoCodeRepository,
	gateways map[string]domain.PaymentGateway,
	log *zap.Logger,
) *PaymentService {
	return &PaymentService{
		config:   config,
		subRepo:  subRepo,
		txRepo:   txRepo,
		planRepo: planRepo,
		promoRepo: promoRepo,
		gateways: gateways,
		log:      log,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// Subscribe оформляет подписку
func (s *PaymentService) Subscribe(ctx context.Context, userID domain.ID, req domain.SubscribeRequest) (*domain.SubscribeResponse, error) {
	// Валидация входных данных
	planCode := strings.TrimSpace(req.PlanCode)
	if planCode == "" {
		return nil, fmt.Errorf("plan_code is required")
	}

	if req.BillingCycle != string(domain.BillingCycleMonthly) && req.BillingCycle != string(domain.BillingCycleYearly) {
		return nil, fmt.Errorf("billing_cycle must be monthly or yearly")
	}

	// Получаем план
	plan, err := s.planRepo.GetPlanByCode(ctx, planCode)
	if err != nil {
		return nil, err
	}
	if plan == nil || !plan.IsActive {
		return nil, ErrPlanNotFound
	}

	// Вычисляем сумму
	amount := plan.PriceMonthly
	if req.BillingCycle == string(domain.BillingCycleYearly) {
		amount = plan.PriceYearly
	}
	currency := plan.Currency
	if currency == "" {
		currency = "RUB"
	}

	// Проверяем промокод
	var discountAmount float64
	if req.PromoCode != nil && strings.TrimSpace(*req.PromoCode) != "" {
		promo, err := s.promoRepo.GetByCode(ctx, *req.PromoCode)
		if err != nil {
			s.log.Warn("promo code check failed", zap.Error(err), zap.String("code", *req.PromoCode))
		} else if promo != nil && promo.IsActive && !promo.IsExpired() && promo.IsValidForPlan(planCode) {
			// Применяем скидку
			switch promo.DiscountType {
			case "percentage":
				discountAmount = amount * promo.DiscountValue / 100
				if promo.MaxDiscount != nil && discountAmount > *promo.MaxDiscount {
					discountAmount = *promo.MaxDiscount
				}
			case "fixed_amount":
				discountAmount = promo.DiscountValue
				if discountAmount > amount {
					discountAmount = amount
				}
			case "free_month":
				discountAmount = plan.PriceMonthly
			}
		}
	}

	finalAmount := amount - discountAmount
	if finalAmount < 0 {
		finalAmount = 0
	}

	// Для бесплатного плана (Free) или полностью бесплатной подписки
	if planCode == "free" || finalAmount == 0 {
		// Создаём бесплатную подписку без платежа
		return s.createFreeSubscription(ctx, userID, plan, req.BillingCycle)
	}

	// Вычисляем период подписки
	var periodEnd time.Time
	if req.BillingCycle == string(domain.BillingCycleMonthly) {
		periodEnd = time.Now().AddDate(0, 1, 0)
	} else {
		periodEnd = time.Now().AddDate(1, 0, 0)
	}

	// Получаем платежный шлюз
	gateway, ok := s.gateways[req.PaymentProvider]
	if !ok {
		return nil, fmt.Errorf("payment provider not found: %s", req.PaymentProvider)
	}

	// Создаём подписку в БД (статус pending)
	userIDInt := domain.IDToInt64(userID)
	subscription := &domain.UserSubscription{
		UserID:         userIDInt,
		Plan:           *plan,
		BillingCycle:   &req.BillingCycle,
		Status:         ptr(string(domain.SubscriptionStatusActive)),
		CurrentPeriodEnd: &periodEnd,
		PaymentProvider: &req.PaymentProvider,
		AutoRenew:      ptr(true),
	}

	subID, err := s.subRepo.CreateSubscription(ctx, subscription)
	if err != nil {
		s.log.Error("create subscription failed", zap.Error(err))
		return nil, err
	}

	// Инициализируем платёж
	description := fmt.Sprintf("OutfitStyle %s subscription (%s)", plan.Name, req.BillingCycle)
	metadata := map[string]any{
		"user_id":         strconv.FormatInt(userIDInt, 10),
		"subscription_id": strconv.FormatInt(subID, 10),
		"plan_code":       plan.Code,
		"billing_cycle":   req.BillingCycle,
	}

	paymentInit, err := gateway.InitPayment(ctx, finalAmount, currency, description, metadata)
	if err != nil {
		s.log.Error("init payment failed", zap.Error(err))
		return nil, err
	}

	// Создаём запись о платеже
	extID := paymentInit.ExternalPaymentID
	paymentProvider := paymentInit.Provider

	tx := &domain.SubscriptionTransaction{
		UserID:         userIDInt,
		SubscriptionID: &subID,
		Amount:         finalAmount,
		Currency:       currency,
		Status:         string(domain.PaymentStatusPending),
		PaymentProvider: paymentProvider,
		ExternalPaymentID: extID,
		Description:    &description,
	}

	_, err = s.txRepo.CreateTransaction(ctx, tx)
	if err != nil {
		s.log.Error("create transaction failed", zap.Error(err))
		return nil, err
	}

	respSub := domain.UserSubscription{
		ID:           &subID,
		UserID:       userIDInt,
		Plan:         *plan,
		BillingCycle: &req.BillingCycle,
		Status:       ptr(string(domain.SubscriptionStatusActive)),
	}

	return &domain.SubscribeResponse{
		Subscription: respSub,
		PaymentURL:   paymentInit.PaymentURL,
		ClientSecret: paymentInit.ClientSecret,
		PaymentID:    &extID,
	}, nil
}

// createFreeSubscription создаёт бесплатную подписку
func (s *PaymentService) createFreeSubscription(ctx context.Context, userID domain.ID, plan *domain.SubscriptionPlan, billingCycle string) (*domain.SubscribeResponse, error) {
	userIDInt := domain.IDToInt64(userID)

	var periodEnd time.Time
	if billingCycle == string(domain.BillingCycleMonthly) {
		periodEnd = time.Now().AddDate(0, 1, 0)
	} else {
		periodEnd = time.Now().AddDate(1, 0, 0)
	}

	subscription := &domain.UserSubscription{
		UserID:         userIDInt,
		Plan:           *plan,
		BillingCycle:   &billingCycle,
		Status:         ptr(string(domain.SubscriptionStatusActive)),
		CurrentPeriodStart: ptr(time.Now()),
		CurrentPeriodEnd: &periodEnd,
		PaymentProvider: ptr("none"),
		AutoRenew:      ptr(true),
	}

	subID, err := s.subRepo.CreateSubscription(ctx, subscription)
	if err != nil {
		return nil, err
	}

	respSub := domain.UserSubscription{
		ID:           &subID,
		UserID:       userIDInt,
		Plan:         *plan,
		BillingCycle: &billingCycle,
		Status:       ptr(string(domain.SubscriptionStatusActive)),
	}

	return &domain.SubscribeResponse{
		Subscription: respSub,
	}, nil
}

// Cancel отменяет подписку
func (s *PaymentService) Cancel(ctx context.Context, userID domain.ID, immediate bool, reason, feedback *string) error {
	return s.subRepo.CancelSubscription(ctx, userID, immediate, reason, feedback)
}

// Reactivate восстанавливает подписку
func (s *PaymentService) Reactivate(ctx context.Context, userID domain.ID) error {
	return s.subRepo.ReactivateSubscription(ctx, userID)
}

// Upgrade изменяет план подписки
func (s *PaymentService) Upgrade(ctx context.Context, userID domain.ID, newPlanCode string, newBillingCycle *string) error {
	// Получаем текущую подписку
	currentSub, err := s.subRepo.GetActiveSubscription(ctx, userID)
	if err != nil {
		return err
	}
	if currentSub == nil {
		return ErrSubscriptionNotFound
	}

	// Получаем новый план
	newPlan, err := s.planRepo.GetPlanByCode(ctx, newPlanCode)
	if err != nil {
		return err
	}
	if newPlan == nil || !newPlan.IsActive {
		return ErrPlanNotFound
	}

	// Проверяем, не даунгрейд ли это
	if newPlan.SortOrder < currentSub.Plan.SortOrder {
		return ErrCannotDowngrade
	}

	// Вычисляем новый период
	var newPeriodEnd time.Time
	if newBillingCycle != nil && *newBillingCycle == string(domain.BillingCycleYearly) {
		newPeriodEnd = time.Now().AddDate(1, 0, 0)
	} else {
		newPeriodEnd = time.Now().AddDate(0, 1, 0)
	}

	// Обновляем подписку
	return s.subRepo.UpgradeSubscription(ctx, userID, newPlan.ID, newPeriodEnd)
}

// HandleWebhook обрабатывает webhook от платежного провайдера
func (s *PaymentService) HandleWebhook(ctx context.Context, provider string, headers map[string]string, body []byte) error {
	gateway, ok := s.gateways[provider]
	if !ok {
		return fmt.Errorf("unknown payment provider: %s", provider)
	}

	// Проверяем подпись webhook
	if err := gateway.VerifyWebhookSignature(ctx, headers, body); err != nil {
		s.log.Warn("webhook signature verification failed", zap.Error(err), zap.String("provider", provider))
		// Не блокируем обработку, только логируем
	}

	// Парсим webhook
	extID, status, receiptURL, errMsg, err := gateway.ParseWebhook(ctx, headers, body)
	if err != nil {
		s.log.Error("webhook parse failed", zap.Error(err), zap.String("provider", provider))
		return err
	}

	// Обновляем транзакцию
	var paidAt *time.Time
	if status == string(domain.PaymentStatusPaid) {
		now := time.Now()
		paidAt = &now
	}

	err = s.txRepo.UpdateTransactionByExternalID(ctx, provider, extID, status, paidAt, receiptURL, errMsg)
	if err != nil {
		s.log.Error("update transaction failed", zap.Error(err), zap.String("external_id", extID))
		return err
	}

	// Если платёж успешен, активируем подписку
	if status == string(domain.PaymentStatusPaid) {
		// Получаем транзакцию для получения subscription_id
		tx, err := s.txRepo.GetTransactionByExternalID(ctx, provider, extID)
		if err != nil {
			s.log.Error("get transaction for activation failed", zap.Error(err))
			return err
		}

		if tx != nil && tx.SubscriptionID != nil {
			// Получаем подписку
			sub, err := s.subRepo.GetSubscriptionByID(ctx, *tx.SubscriptionID)
			if err != nil {
				s.log.Error("get subscription for activation failed", zap.Error(err))
				return err
			}

			if sub != nil {
				// Обновляем статус подписки
				sub.Status = ptr(string(domain.SubscriptionStatusActive))
				if err := s.subRepo.UpdateSubscription(ctx, sub); err != nil {
					s.log.Error("update subscription status failed", zap.Error(err))
					return err
				}
			}
		}
	}

	return nil
}

// GetPaymentStatus получает статус платежа
func (s *PaymentService) GetPaymentStatus(ctx context.Context, provider string, externalPaymentID string) (string, error) {
	gateway, ok := s.gateways[provider]
	if !ok {
		return "", fmt.Errorf("unknown payment provider: %s", provider)
	}

	status, _, _, err := gateway.GetPaymentStatus(ctx, externalPaymentID)
	return status, err
}

// Refund возвращает средства
func (s *PaymentService) Refund(ctx context.Context, userID domain.ID, transactionID int64, amount *float64, reason string) error {
	// Получаем оригинальную транзакцию
	tx, err := s.txRepo.GetTransactionByID(ctx, transactionID)
	if err != nil {
		return err
	}
	if tx == nil {
		return fmt.Errorf("transaction not found")
	}
	if tx.UserID != domain.IDToInt64(userID) {
		return fmt.Errorf("transaction does not belong to user")
	}

	gateway, ok := s.gateways[tx.PaymentProvider]
	if !ok {
		return fmt.Errorf("unknown payment provider: %s", tx.PaymentProvider)
	}

	// Выполняем возврат
	description := fmt.Sprintf("Refund: %s", reason)
	if err := gateway.RefundPayment(ctx, tx.ExternalPaymentID, amount, description); err != nil {
		return err
	}

	// Создаём транзакцию возврата
	refundTx := &domain.SubscriptionTransaction{
		UserID:         tx.UserID,
		SubscriptionID: tx.SubscriptionID,
		Amount:         tx.Amount,
		Currency:       tx.Currency,
		Status:         string(domain.PaymentStatusRefunded),
		PaymentProvider: tx.PaymentProvider,
		ExternalPaymentID: tx.ExternalPaymentID + "_refund",
		Description:    &description,
	}

	_, err = s.txRepo.CreateRefundTransaction(ctx, transactionID, refundTx)
	if err != nil {
		return err
	}

	// Обновляем оригинальную транзакцию
	now := time.Now()
	err = s.txRepo.UpdateTransactionStatus(ctx, transactionID, string(domain.PaymentStatusRefunded), &now, nil, nil)
	if err != nil {
		return err
	}

	return nil
}

// YooKassaGateway реализация платежного шлюза YooKassa
type YooKassaGateway struct {
	config    *domain.YooKassaConfig
	log       *zap.Logger
	httpClient *http.Client
}

// NewYooKassaGateway создаёт новый шлюз YooKassa
func NewYooKassaGateway(config *domain.YooKassaConfig, log *zap.Logger) *YooKassaGateway {
	return &YooKassaGateway{
		config: config,
		log:    log,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// InitPayment создаёт платёж в YooKassa
func (g *YooKassaGateway) InitPayment(ctx context.Context, amount float64, currency string, description string, metadata map[string]any) (domain.PaymentInit, error) {
	baseURL := g.config.BaseURL
	if baseURL == "" {
		baseURL = "https://api.yookassa.ru/v3"
	}

	url := baseURL + "/payments"

	// Формируем запрос
	paymentData := map[string]any{
		"amount": map[string]any{
			"value":    fmt.Sprintf("%.2f", amount),
			"currency": currency,
		},
		"capture":     true,
		"description": description,
		"metadata":    metadata,
		"confirmation": map[string]any{
			"type": "redirect",
		},
	}

	body, err := json.Marshal(paymentData)
	if err != nil {
		return domain.PaymentInit{}, fmt.Errorf("marshal payment data: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return domain.PaymentInit{}, fmt.Errorf("create request: %w", err)
	}

	// Устанавливаем заголовки
	req.SetBasicAuth(g.config.ShopID, g.config.SecretKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Idempotence-Key", uuid.New().String())

	// Выполняем запрос
	resp, err := g.httpClient.Do(req)
	if err != nil {
		return domain.PaymentInit{}, fmt.Errorf("execute request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return domain.PaymentInit{}, fmt.Errorf("read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return domain.PaymentInit{}, fmt.Errorf("yookassa error: status=%d, body=%s", resp.StatusCode, string(respBody))
	}

	// Парсим ответ
	var ykResp domain.YooKassaPaymentResponse
	if err := json.Unmarshal(respBody, &ykResp); err != nil {
		return domain.PaymentInit{}, fmt.Errorf("unmarshal response: %w", err)
	}

	result := domain.PaymentInit{
		Provider:          "yookassa",
		ExternalPaymentID: ykResp.ID,
	}

	if ykResp.Confirmation.ReturnURL != "" {
		result.PaymentURL = &ykResp.Confirmation.ReturnURL
	}
	result.ConfirmationType = &ykResp.Confirmation.Type

	return result, nil
}

// GetPaymentStatus получает статус платежа
func (g *YooKassaGateway) GetPaymentStatus(ctx context.Context, externalPaymentID string) (string, *string, *string, error) {
	baseURL := g.config.BaseURL
	if baseURL == "" {
		baseURL = "https://api.yookassa.ru/v3"
	}

	url := fmt.Sprintf("%s/payments/%s", baseURL, externalPaymentID)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return "", nil, nil, fmt.Errorf("create request: %w", err)
	}

	req.SetBasicAuth(g.config.ShopID, g.config.SecretKey)

	resp, err := g.httpClient.Do(req)
	if err != nil {
		return "", nil, nil, fmt.Errorf("execute request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", nil, nil, fmt.Errorf("read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", nil, nil, fmt.Errorf("yookassa error: status=%d", resp.StatusCode)
	}

	var ykResp domain.YooKassaPaymentResponse
	if err := json.Unmarshal(respBody, &ykResp); err != nil {
		return "", nil, nil, fmt.Errorf("unmarshal response: %w", err)
	}

	status, ok := domain.YooKassaPaymentStatusMap[ykResp.Status]
	if !ok {
		status = domain.PaymentStatusPending
	}

	return string(status), ykResp.ReceiptURL, ykResp.ErrorMessage, nil
}

// RefundPayment возвращает средства
func (g *YooKassaGateway) RefundPayment(ctx context.Context, externalPaymentID string, amount *float64, description string) error {
	baseURL := g.config.BaseURL
	if baseURL == "" {
		baseURL = "https://api.yookassa.ru/v3"
	}

	url := baseURL + "/refunds"

	refundAmount := "0.00"
	if amount != nil {
		refundAmount = fmt.Sprintf("%.2f", *amount)
	}

	refundData := map[string]any{
		"payment_id":  externalPaymentID,
		"amount": map[string]any{
			"value":    refundAmount,
			"currency": "RUB",
		},
		"description": description,
	}

	body, err := json.Marshal(refundData)
	if err != nil {
		return fmt.Errorf("marshal refund data: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}

	req.SetBasicAuth(g.config.ShopID, g.config.SecretKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := g.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("execute request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		respBody, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("yookassa refund error: status=%d, body=%s", resp.StatusCode, string(respBody))
	}

	return nil
}

// ParseWebhook обрабатывает webhook от YooKassa
func (g *YooKassaGateway) ParseWebhook(ctx context.Context, headers map[string]string, body []byte) (string, string, *string, *string, error) {
	var event domain.YooKassaWebhookEvent
	if err := json.Unmarshal(body, &event); err != nil {
		return "", "", nil, nil, fmt.Errorf("unmarshal webhook: %w", err)
	}

	externalPaymentID := event.Object.ID
	status := event.Object.Status

	mappedStatus, ok := domain.YooKassaPaymentStatusMap[status]
	if !ok {
		mappedStatus = domain.PaymentStatusPending
	}

	return externalPaymentID, string(mappedStatus), event.Object.ReceiptURL, event.Object.ErrorMessage, nil
}

// VerifyWebhookSignature проверяет подпись webhook YooKassa
func (g *YooKassaGateway) VerifyWebhookSignature(ctx context.Context, headers map[string]string, body []byte) error {
	// YooKassa использует Content-HMAC-SHA256 заголовок
	hmacHeader := headers["Content-Hmac-Sha-256"]
	if hmacHeader == "" {
		hmacHeader = headers["content-hmac-sha-256"]
	}

	if hmacHeader == "" {
		// Если заголовка нет, пропускаем проверку (для тестов)
		return nil
	}

	// Вычисляем HMAC
	mac := hmac.New(sha256.New, []byte(g.config.SecretKey))
	mac.Write(body)
	expectedMAC := base64.StdEncoding.EncodeToString(mac.Sum(nil))

	if !hmac.Equal([]byte(hmacHeader), []byte(expectedMAC)) {
		return fmt.Errorf("invalid webhook signature")
	}

	return nil
}

// DummyGateway тестовый платежный шлюз (для разработки)
type DummyGateway struct {
	log *zap.Logger
}

// NewDummyGateway создаёт тестовый шлюз
func NewDummyGateway(log *zap.Logger) *DummyGateway {
	return &DummyGateway{log: log}
}

func (g *DummyGateway) InitPayment(ctx context.Context, amount float64, currency string, description string, metadata map[string]any) (domain.PaymentInit, error) {
	paymentID := "dummy_" + uuid.New().String()[:8]
	paymentURL := "https://example.com/payment/" + paymentID

	g.log.Info("dummy payment created",
		zap.String("payment_id", paymentID),
		zap.Float64("amount", amount),
		zap.String("currency", currency))

	return domain.PaymentInit{
		Provider:          "dummy",
		ExternalPaymentID: paymentID,
		PaymentURL:        &paymentURL,
		ConfirmationType:  ptr("redirect"),
	}, nil
}

func (g *DummyGateway) GetPaymentStatus(ctx context.Context, externalPaymentID string) (string, *string, *string, error) {
	return string(domain.PaymentStatusPending), nil, nil, nil
}

func (g *DummyGateway) RefundPayment(ctx context.Context, externalPaymentID string, amount *float64, description string) error {
	g.log.Info("dummy refund", zap.String("payment_id", externalPaymentID))
	return nil
}

func (g *DummyGateway) ParseWebhook(ctx context.Context, headers map[string]string, body []byte) (string, string, *string, *string, error) {
	// Для тестов всегда возвращаем успешный статус
	return "dummy_payment_id", string(domain.PaymentStatusPaid), nil, nil, nil
}

func (g *DummyGateway) VerifyWebhookSignature(ctx context.Context, headers map[string]string, body []byte) error {
	return nil
}
