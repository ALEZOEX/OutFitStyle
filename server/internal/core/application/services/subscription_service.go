package services

import (
	"context"
	"errors"
	"fmt"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// Ошибки сервиса подписок
var (
	ErrRecommendationsLimitExceeded = errors.New("recommendations daily limit exceeded")
	ErrWardrobeLimitExceeded        = errors.New("wardrobe items limit exceeded")
	ErrSubscriptionNotFound         = errors.New("subscription not found")
	ErrPlanNotFound                 = errors.New("plan not found")
	ErrPlanNotActive                = errors.New("plan is not active")
	ErrInvalidBillingCycle          = errors.New("invalid billing cycle")
	ErrTrialAlreadyUsed             = errors.New("trial period already used")
	ErrCannotDowngrade              = errors.New("cannot downgrade subscription")
	ErrFamilyLimitExceeded          = errors.New("family member limit exceeded")
	ErrPromoCodeInvalid             = errors.New("invalid promo code")
	ErrPromoCodeExpired             = errors.New("promo code expired")
	ErrPromoCodeUsageLimit          = errors.New("promo code usage limit exceeded")
)

// SubscriptionService сервис управления подписками
type SubscriptionService struct {
	planRepo     repositories.SubscriptionPlanRepository
	userSubRepo  repositories.UserSubscriptionRepository
	usageRepo    repositories.SubscriptionUsageRepository
	txRepo       repositories.SubscriptionTransactionRepository
	promoRepo    repositories.PromoCodeRepository
	redemptionRepo repositories.PromoRedemptionRepository
	familyRepo   repositories.FamilyMemberRepository
	log          *zap.Logger
}

// NewSubscriptionService создаёт новый сервис подписок
func NewSubscriptionService(
	planRepo repositories.SubscriptionPlanRepository,
	userSubRepo repositories.UserSubscriptionRepository,
	usageRepo repositories.SubscriptionUsageRepository,
	txRepo repositories.SubscriptionTransactionRepository,
	promoRepo repositories.PromoCodeRepository,
	redemptionRepo repositories.PromoRedemptionRepository,
	familyRepo repositories.FamilyMemberRepository,
	log *zap.Logger,
) *SubscriptionService {
	return &SubscriptionService{
		planRepo:     planRepo,
		userSubRepo:  userSubRepo,
		usageRepo:    usageRepo,
		txRepo:       txRepo,
		promoRepo:    promoRepo,
		redemptionRepo: redemptionRepo,
		familyRepo:   familyRepo,
		log:          log,
	}
}

// ListPlans возвращает список всех доступных планов подписки
func (s *SubscriptionService) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	return s.planRepo.ListPlans(ctx)
}

// GetPlanByCode возвращает план подписки по коду
func (s *SubscriptionService) GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error) {
	plan, err := s.planRepo.GetPlanByCode(ctx, code)
	if err != nil {
		return nil, err
	}
	if plan == nil {
		return nil, ErrPlanNotFound
	}
	if !plan.IsActive {
		return nil, ErrPlanNotActive
	}
	return plan, nil
}

// GetCurrent возвращает текущую подписку пользователя с использованием лимитов
func (s *SubscriptionService) GetCurrent(ctx context.Context, userID domain.ID) (*domain.CurrentSubscriptionResponse, error) {
	// Получаем активную подписку
	sub, err := s.userSubRepo.GetActiveSubscription(ctx, userID)
	if err != nil {
		s.log.Error("get active subscription", zap.Error(err))
		return nil, err
	}

	// Если подписки нет, возвращаем Free план
	var effective domain.UserSubscription
	if sub == nil {
		freePlan, err := s.planRepo.GetPlanByCode(ctx, "free")
		if err != nil {
			return nil, err
		}

		// Fallback если в БД нет free плана
		var plan domain.SubscriptionPlan
		if freePlan == nil {
			limit := 3
			wardrobeLimit := 50
			historyLimit := 7
			stylesLimit := 2
			plan = domain.SubscriptionPlan{
				Code:                  "free",
				Name:                  "Free (Fallback)",
				RecommendationsPerDay: &limit,
				WardrobeItemsLimit:    &wardrobeLimit,
				HistoryDays:           &historyLimit,
				StylesLimit:           &stylesLimit,
				FamilyAccounts:        1,
				PriceMonthly:          0,
				PriceYearly:           0,
				Currency:              "RUB",
				Features:              []byte(`["basic_recommendations", "weather_alerts"]`),
				IsActive:              true,
				SortOrder:             0,
			}
		} else {
			plan = *freePlan
		}

		effective = domain.UserSubscription{
			ID:     nil,
			UserID: domain.IDToInt64(userID),
			Plan:   plan,
		}
	} else {
		effective = *sub
	}

	// Получаем использование лимитов
	usage, err := s.usageRepo.GetUsage(ctx, userID)
	if err != nil {
		s.log.Error("get usage", zap.Error(err))
		return nil, err
	}

	if usage == nil {
		usage = &domain.SubscriptionUsage{
			UserID:   domain.IDToInt64(userID),
			RecommendationsToday: 0,
			WardrobeCount:        0,
		}
	}

	// Заполняем лимиты из плана
	usage.RecommendationsLimit = effective.Plan.RecommendationsPerDay
	usage.WardrobeLimit = effective.Plan.WardrobeItemsLimit

	// Создаём ответ с лимитами
	limits := domain.SubscriptionLimits{
		RecommendationsPerDay: effective.Plan.RecommendationsPerDay,
		RecommendationsToday:  usage.RecommendationsToday,
		WardrobeItemsLimit:    effective.Plan.WardrobeItemsLimit,
		WardrobeCount:         usage.WardrobeCount,
		HistoryDays:           effective.Plan.HistoryDays,
		StylesLimit:           effective.Plan.StylesLimit,
		FamilyAccounts:        effective.Plan.FamilyAccounts,
	}

	return &domain.CurrentSubscriptionResponse{
		Subscription: effective,
		Usage:        *usage,
		Limits:       limits,
	}, nil
}

// CheckCanCreateRecommendation проверяет, можно ли создать рекомендацию
func (s *SubscriptionService) CheckCanCreateRecommendation(ctx context.Context, userID domain.ID) error {
	cur, err := s.GetCurrent(ctx, userID)
	if err != nil {
		return err
	}

	if !cur.Limits.CanCreateRecommendation() {
		return ErrRecommendationsLimitExceeded
	}

	return nil
}

// CheckCanAddWardrobeItem проверяет, можно ли добавить вещь в гардероб
func (s *SubscriptionService) CheckCanAddWardrobeItem(ctx context.Context, userID domain.ID) error {
	cur, err := s.GetCurrent(ctx, userID)
	if err != nil {
		return err
	}

	if !cur.Limits.CanAddWardrobeItem() {
		return ErrWardrobeLimitExceeded
	}

	return nil
}

// IncrementRecommendationUsage увеличивает счётчик использованных рекомендаций
func (s *SubscriptionService) IncrementRecommendationUsage(ctx context.Context, userID domain.ID) error {
	return s.usageRepo.IncrementRecommendations(ctx, userID)
}

// IncrementWardrobeUsage увеличивает счётчик вещей в гардеробе
func (s *SubscriptionService) IncrementWardrobeUsage(ctx context.Context, userID domain.ID) error {
	return s.usageRepo.IncrementWardrobe(ctx, userID)
}

// DecrementWardrobeUsage уменьшает счётчик вещей в гардеробе
func (s *SubscriptionService) DecrementWardrobeUsage(ctx context.Context, userID domain.ID) error {
	return s.usageRepo.DecrementWardrobe(ctx, userID)
}

// StartTrial начинает пробный период для пользователя
func (s *SubscriptionService) StartTrial(ctx context.Context, userID domain.ID, planCode string) error {
	// Проверяем, не использовал ли пользователь уже триал
	existingSub, err := s.userSubRepo.GetActiveSubscription(ctx, userID)
	if err != nil {
		return err
	}

	// Проверяем, есть ли уже активная подписка
	if existingSub != nil && existingSub.Status != nil {
		if *existingSub.Status == "trialing" || *existingSub.Status == "active" {
			// Проверяем, был ли уже триал
			if existingSub.TrialEnd != nil && existingSub.TrialEnd.Before(time.Now()) {
				return ErrTrialAlreadyUsed
			}
			// Если триал ещё активен, ничего не делаем
			if existingSub.TrialEnd != nil && existingSub.TrialEnd.After(time.Now()) {
				return nil
			}
		}
	}

	// Получаем план
	plan, err := s.planRepo.GetPlanByCode(ctx, planCode)
	if err != nil {
		return err
	}
	if plan == nil || !plan.IsActive {
		return ErrPlanNotFound
	}

	if plan.TrialPeriodDays <= 0 {
		return fmt.Errorf("plan %s does not have trial period", planCode)
	}

	// Начинаем триал
	return s.userSubRepo.StartTrial(ctx, userID, plan.ID, plan.TrialPeriodDays)
}

// GetFamilyMembers возвращает семейных участников пользователя
func (s *SubscriptionService) GetFamilyMembers(ctx context.Context, userID domain.ID) ([]domain.FamilyMember, error) {
	return s.familyRepo.GetFamilyMembers(ctx, userID)
}

// AddFamilyMember добавляет семейного участника
func (s *SubscriptionService) AddFamilyMember(ctx context.Context, ownerUserID, memberUserID domain.ID) error {
	// Проверяем подписку владельца
	sub, err := s.userSubRepo.GetActiveSubscription(ctx, ownerUserID)
	if err != nil {
		return err
	}
	if sub == nil {
		return ErrSubscriptionNotFound
	}

	// Проверяем, поддерживает ли план семейные аккаунты
	if sub.Plan.FamilyAccounts <= 1 {
		return fmt.Errorf("plan %s does not support family members", sub.Plan.Code)
	}

	// Проверяем лимит
	count, err := s.familyRepo.GetActiveFamilyMembersCount(ctx, ownerUserID)
	if err != nil {
		return err
	}

	if count >= sub.Plan.FamilyAccounts-1 { // -1 потому что владелец не считается
		return ErrFamilyLimitExceeded
	}

	// Проверяем, не является ли пользователь уже семейным участником
	existingMember, err := s.familyRepo.GetFamilyMemberByMemberID(ctx, memberUserID)
	if err != nil {
		return err
	}
	if existingMember != nil && existingMember.Status == "active" {
		return fmt.Errorf("user is already a family member")
	}

	// Создаём приглашение
	now := time.Now()
	member := &domain.FamilyMember{
		OwnerUserID: domain.IDToInt64(ownerUserID),
		MemberUserID: domain.IDToInt64(memberUserID),
		Status:      "pending",
		InvitedAt:   now,
		ExpiresAt:   &now,
		AddedBy:     ptr(domain.IDToInt64(ownerUserID)),
	}

	// Устанавливаем срок действия приглашения (7 дней)
	expiresAt := now.AddDate(0, 0, 7)
	member.ExpiresAt = &expiresAt

	_, err = s.familyRepo.CreateFamilyMember(ctx, member)
	if err != nil {
		return err
	}

	return nil
}

// AcceptFamilyInvitation принимает приглашение в семью
func (s *SubscriptionService) AcceptFamilyInvitation(ctx context.Context, userID domain.ID) error {
	return s.familyRepo.AcceptInvitation(ctx, userID)
}

// RemoveFamilyMember удаляет семейного участника
func (s *SubscriptionService) RemoveFamilyMember(ctx context.Context, ownerUserID, memberUserID domain.ID) error {
	member, err := s.familyRepo.GetFamilyMemberByMemberID(ctx, memberUserID)
	if err != nil {
		return err
	}
	if member == nil {
		return fmt.Errorf("family member not found")
	}
	if member.OwnerUserID != domain.IDToInt64(ownerUserID) {
		return fmt.Errorf("not your family member")
	}

	return s.familyRepo.RemoveFamilyMember(ctx, member.ID)
}

// GetTransactions возвращает транзакции пользователя
func (s *SubscriptionService) GetTransactions(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SubscriptionTransaction, domain.Pagination, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	items, total, err := s.txRepo.GetUserTransactions(ctx, userID, page, limit)
	if err != nil {
		return nil, domain.Pagination{}, err
	}

	pagination := domain.Pagination{
		Page:  page,
		Limit: limit,
		Total: total,
	}

	return items, pagination, nil
}

// ValidatePromoCode проверяет валидность промокода
func (s *SubscriptionService) ValidatePromoCode(ctx context.Context, code string, planCode string, billingCycle string, userID domain.ID) (*domain.PromoCode, error) {
	promo, err := s.promoRepo.GetByCode(ctx, code)
	if err != nil {
		return nil, err
	}
	if promo == nil {
		return nil, ErrPromoCodeInvalid
	}
	if !promo.IsActive {
		return nil, ErrPromoCodeInvalid
	}
	if promo.IsExpired() {
		return nil, ErrPromoCodeExpired
	}

	// Проверяем применимость к плану
	if !promo.IsValidForPlan(planCode) {
		return nil, fmt.Errorf("promo code not applicable to plan %s", planCode)
	}

	// Проверяем применимость к циклу оплаты
	if !promo.IsValidForCycle(billingCycle) {
		return nil, fmt.Errorf("promo code not applicable to billing cycle %s", billingCycle)
	}

	// Проверяем лимит использований
	// promo.ID имеет тип domain.ID (UUID), конвертируем в int64 для совместимости
	promoIDInt64 := domain.IDToInt64(promo.ID)
	usedCount, err := s.promoRepo.GetUsageCount(ctx, promoIDInt64, userID)
	if err != nil {
		return nil, err
	}
	if !promo.CanBeUsedByUser(usedCount) {
		return nil, ErrPromoCodeUsageLimit
	}

	return promo, nil
}

// ApplyPromoCode применяет промокод и возвращает информацию о скидке
func (s *SubscriptionService) ApplyPromoCode(ctx context.Context, code string, planCode string, billingCycle string, userID domain.ID) (*domain.ApplyPromoCodeResponse, error) {
	promo, err := s.ValidatePromoCode(ctx, code, planCode, billingCycle, userID)
	if err != nil {
		return &domain.ApplyPromoCodeResponse{
			Success: false,
			Message: err.Error(),
		}, nil
	}

	// Получаем план
	plan, err := s.planRepo.GetPlanByCode(ctx, planCode)
	if err != nil {
		return nil, err
	}
	if plan == nil {
		return nil, ErrPlanNotFound
	}

	// Вычисляем сумму
	originalAmount := plan.GetPrice(domain.BillingCycle(billingCycle))
	var discountAmount float64

	switch promo.DiscountType {
	case "percentage":
		discountAmount = originalAmount * promo.DiscountValue / 100
		if promo.MaxDiscount != nil && discountAmount > *promo.MaxDiscount {
			discountAmount = *promo.MaxDiscount
		}
	case "fixed_amount":
		discountAmount = promo.DiscountValue
		if discountAmount > originalAmount {
			discountAmount = originalAmount
		}
	case "free_trial":
		discountAmount = 0 // Триал обрабатывается отдельно
	case "free_month":
		discountAmount = plan.PriceMonthly
	}

	finalAmount := originalAmount - discountAmount
	if finalAmount < 0 {
		finalAmount = 0
	}

	return &domain.ApplyPromoCodeResponse{
		Success:        true,
		DiscountAmount: discountAmount,
		OriginalAmount: originalAmount,
		FinalAmount:    finalAmount,
		Currency:       plan.Currency,
		Message:        fmt.Sprintf("Promo code applied: %.0f%% discount", promo.DiscountValue),
	}, nil
}
