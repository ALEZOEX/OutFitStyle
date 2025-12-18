package services

import (
	"context"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)


type BillingService struct {
	subRepo   repositories.SubscriptionRepository
	billingRepo repositories.BillingRepository
	promoRepo repositories.PromoRepository

	gateways map[string]domain.PaymentGateway
}

func NewBillingService(sub repositories.SubscriptionRepository, bill repositories.BillingRepository, promo repositories.PromoRepository, gateways map[string]domain.PaymentGateway) *BillingService {
	return &BillingService{subRepo: sub, billingRepo: bill, promoRepo: promo, gateways: gateways}
}

func (s *BillingService) Subscribe(ctx context.Context, userID domain.ID, req domain.SubscribeRequest) (*domain.SubscribeResponse, error) {
	planCode := strings.TrimSpace(req.PlanCode)
	if planCode == "" {
		return nil, errors.New("plan_code is required")
	}
	if req.BillingCycle != "monthly" && req.BillingCycle != "yearly" {
		return nil, errors.New("billing_cycle must be monthly or yearly")
	}

	plan, err := s.subRepo.GetPlanByCode(ctx, planCode)
	if err != nil {
		return nil, err
	}
	if plan == nil || !plan.IsActive {
		return nil, errors.New("plan not found")
	}

	amount := plan.PriceMonthly
	if req.BillingCycle == "yearly" {
		amount = plan.PriceYearly
	}
	currency := plan.Currency
	if currency == "" {
		currency = "RUB"
	}

	periodEnd := time.Now().AddDate(0, 1, 0)
	if req.BillingCycle == "yearly" {
		periodEnd = time.Now().AddDate(1, 0, 0)
	}

	// promo (MVP: только проверка валидности; реальный дисконт применим позже)
	if req.PromoCode != nil && strings.TrimSpace(*req.PromoCode) != "" {
		promo, err := s.promoRepo.GetByCode(ctx, *req.PromoCode)
		if err != nil {
			return nil, err
		}
		if promo == nil || !promo.IsActive {
			return nil, errors.New("invalid promo code")
		}
		// срок
		if promo.ValidUntil != nil && time.Now().After(*promo.ValidUntil) {
			return nil, errors.New("promo code expired")
		}
		// здесь можно применить discount_type/discount_value, но лучше отдельным модулем
	}

	// создаём подписку
	userIDInt := domain.IDToInt64(userID)
	subID, err := s.billingRepo.CreateUserSubscription(ctx, userIDInt, plan.ID, req.BillingCycle, periodEnd, "gateway")
	if err != nil {
		return nil, err
	}

	// создаём платёж у провайдера
	gw, ok := s.gateways[req.PaymentProvider]
	if !ok {
		return nil, errors.New("payment provider not found: " + req.PaymentProvider)
	}

	init, err := gw.InitPayment(ctx, amount, currency, "OutfitStyle subscription", map[string]any{
		"user_id": strconv.FormatInt(userIDInt, 10),
		"subscription_id": strconv.FormatInt(subID, 10),
		"plan_code": plan.Code,
	})
	if err != nil {
		return nil, err
	}

	extID := init.ExternalPaymentID
	paymentProvider := init.Provider

	_, err = s.billingRepo.CreatePayment(ctx, repositories.CreatePaymentParams{
		UserID:         userIDInt,
		SubscriptionID: &subID,
		Amount:         amount,
		Currency:       currency,
		Status:         "pending",
		PaymentProvider: paymentProvider,
		ExternalPaymentID: &extID,
		PaymentMethod: req.PaymentMethodID,
		Description: ptr("Subscription " + plan.Code),
	})
	if err != nil {
		return nil, err
	}

	respSub := domain.UserSubscription{
		ID: &subID,
		UserID: userIDInt,
		Plan: *plan,
		BillingCycle: &req.BillingCycle,
		Status: ptr("active"),
	}

	return &domain.SubscribeResponse{
		Subscription: respSub,
		PaymentURL: init.PaymentURL,
		ClientSecret: init.ClientSecret,
	}, nil
}

func (s *BillingService) Cancel(ctx context.Context, userID domain.ID, immediate bool) error {
	userIDInt := domain.IDToInt64(userID)
	return s.billingRepo.CancelSubscription(ctx, userIDInt, immediate)
}

func (s *BillingService) Reactivate(ctx context.Context, userID domain.ID) error {
	userIDInt := domain.IDToInt64(userID)
	return s.billingRepo.ReactivateSubscription(ctx, userIDInt)
}

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
		"code": p.Code,
		"discount_type": p.DiscountType,
		"discount_value": p.DiscountValue,
		"applicable_plans": p.ApplicablePlans,
		"valid_until": p.ValidUntil,
	}, nil
}

func (s *BillingService) ListPayments(ctx context.Context, userID domain.ID, page, limit int) ([]domain.Payment, domain.Pagination, error) {
	userIDInt := domain.IDToInt64(userID)
	items, total, err := s.billingRepo.ListPayments(ctx, userIDInt, page, limit)
	if err != nil {
		return nil, domain.Pagination{}, err
	}
	if page <= 0 { page = 1 }
	if limit <= 0 { limit = 20 }
	return items, domain.Pagination{Page: page, Limit: limit, Total: total}, nil
}

func (s *BillingService) HandleWebhook(ctx context.Context, provider string, headers map[string]string, body []byte) error {
	gw := s.gateways[provider]
	if gw == nil {
		return errors.New("unknown payment provider")
	}

	extID, status, receipt, errMsg, err := gw.ParseWebhook(ctx, headers, body)
	if err != nil {
		return err
	}
	return s.billingRepo.UpdatePaymentStatusByExternalID(ctx, provider, extID, status, receipt, errMsg)
}

func ptr[T any](v T) *T { return &v }

func newExternalID() string { return uuid.NewString() }