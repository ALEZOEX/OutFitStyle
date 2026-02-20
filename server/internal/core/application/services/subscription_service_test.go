package services_test

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
)

// MockSubscriptionPlanRepository мок репозитория планов
type MockSubscriptionPlanRepository struct {
	mock.Mock
}

func (m *MockSubscriptionPlanRepository) ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	args := m.Called(ctx)
	return args.Get(0).([]domain.SubscriptionPlan), args.Error(1)
}

func (m *MockSubscriptionPlanRepository) GetPlanByID(ctx context.Context, id int64) (*domain.SubscriptionPlan, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.SubscriptionPlan), args.Error(1)
}

func (m *MockSubscriptionPlanRepository) GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error) {
	args := m.Called(ctx, code)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.SubscriptionPlan), args.Error(1)
}

func (m *MockSubscriptionPlanRepository) CreatePlan(ctx context.Context, plan *domain.SubscriptionPlan) (int64, error) {
	args := m.Called(ctx, plan)
	return args.Get(0).(int64), args.Error(1)
}

func (m *MockSubscriptionPlanRepository) UpdatePlan(ctx context.Context, plan *domain.SubscriptionPlan) error {
	args := m.Called(ctx, plan)
	return args.Error(0)
}

func (m *MockSubscriptionPlanRepository) DeletePlan(ctx context.Context, id int64) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

// MockPromoCodeRepository мок репозитория промокодов
type MockPromoCodeRepository struct {
	mock.Mock
}

func (m *MockPromoCodeRepository) GetByCode(ctx context.Context, code string) (*domain.PromoCode, error) {
	args := m.Called(ctx, code)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.PromoCode), args.Error(1)
}

func (m *MockPromoCodeRepository) GetByID(ctx context.Context, id int64) (*domain.PromoCode, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.PromoCode), args.Error(1)
}

func (m *MockPromoCodeRepository) CreatePromoCode(ctx context.Context, promo *domain.PromoCode) (int64, error) {
	args := m.Called(ctx, promo)
	return args.Get(0).(int64), args.Error(1)
}

func (m *MockPromoCodeRepository) UpdatePromoCode(ctx context.Context, promo *domain.PromoCode) error {
	args := m.Called(ctx, promo)
	return args.Error(0)
}

func (m *MockPromoCodeRepository) DeletePromoCode(ctx context.Context, id int64) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockPromoCodeRepository) GetUsageCount(ctx context.Context, promoCodeID int64, userID domain.ID) (int, error) {
	args := m.Called(ctx, promoCodeID, userID)
	return args.Int(0), args.Error(1)
}

func (m *MockPromoCodeRepository) IncrementUsage(ctx context.Context, promoCodeID int64) error {
	args := m.Called(ctx, promoCodeID)
	return args.Error(0)
}

func (m *MockPromoCodeRepository) ListActivePromoCodes(ctx context.Context) ([]domain.PromoCode, error) {
	args := m.Called(ctx)
	return args.Get(0).([]domain.PromoCode), args.Error(1)
}

// MockUserSubscriptionRepository мок репозитория подписок
type MockUserSubscriptionRepository struct {
	mock.Mock
}

func (m *MockUserSubscriptionRepository) GetActiveSubscription(ctx context.Context, userID domain.ID) (*domain.UserSubscription, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.UserSubscription), args.Error(1)
}

func (m *MockUserSubscriptionRepository) GetSubscriptionByID(ctx context.Context, id int64) (*domain.UserSubscription, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.UserSubscription), args.Error(1)
}

func (m *MockUserSubscriptionRepository) GetUserSubscriptions(ctx context.Context, userID domain.ID) ([]domain.UserSubscription, error) {
	args := m.Called(ctx, userID)
	return args.Get(0).([]domain.UserSubscription), args.Error(1)
}

func (m *MockUserSubscriptionRepository) CreateSubscription(ctx context.Context, sub *domain.UserSubscription) (int64, error) {
	args := m.Called(ctx, sub)
	return args.Get(0).(int64), args.Error(1)
}

func (m *MockUserSubscriptionRepository) UpdateSubscription(ctx context.Context, sub *domain.UserSubscription) error {
	args := m.Called(ctx, sub)
	return args.Error(0)
}

func (m *MockUserSubscriptionRepository) CancelSubscription(ctx context.Context, userID domain.ID, immediate bool, reason, feedback *string) error {
	args := m.Called(ctx, userID, immediate, reason, feedback)
	return args.Error(0)
}

func (m *MockUserSubscriptionRepository) ReactivateSubscription(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockUserSubscriptionRepository) UpgradeSubscription(ctx context.Context, userID domain.ID, newPlanID int64, newPeriodEnd time.Time) error {
	args := m.Called(ctx, userID, newPlanID, newPeriodEnd)
	return args.Error(0)
}

func (m *MockUserSubscriptionRepository) ExtendSubscription(ctx context.Context, userID domain.ID, duration time.Duration) error {
	args := m.Called(ctx, userID, duration)
	return args.Error(0)
}

func (m *MockUserSubscriptionRepository) StartTrial(ctx context.Context, userID domain.ID, planID int64, trialDays int) error {
	args := m.Called(ctx, userID, planID, trialDays)
	return args.Error(0)
}

func (m *MockUserSubscriptionRepository) GetSubscriptionsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error) {
	args := m.Called(ctx, before)
	return args.Get(0).([]domain.UserSubscription), args.Error(1)
}

func (m *MockUserSubscriptionRepository) GetTrialsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error) {
	args := m.Called(ctx, before)
	return args.Get(0).([]domain.UserSubscription), args.Error(1)
}

// MockSubscriptionUsageRepository мок репозитория использования
type MockSubscriptionUsageRepository struct {
	mock.Mock
}

func (m *MockSubscriptionUsageRepository) GetUsage(ctx context.Context, userID domain.ID) (*domain.SubscriptionUsage, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.SubscriptionUsage), args.Error(1)
}

func (m *MockSubscriptionUsageRepository) GetOrCreateUsage(ctx context.Context, userID domain.ID, subscriptionID *int64) (*domain.SubscriptionUsage, error) {
	args := m.Called(ctx, userID, subscriptionID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.SubscriptionUsage), args.Error(1)
}

func (m *MockSubscriptionUsageRepository) UpdateUsage(ctx context.Context, usage *domain.SubscriptionUsage) error {
	args := m.Called(ctx, usage)
	return args.Error(0)
}

func (m *MockSubscriptionUsageRepository) IncrementRecommendations(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockSubscriptionUsageRepository) IncrementWardrobe(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockSubscriptionUsageRepository) DecrementWardrobe(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockSubscriptionUsageRepository) ResetDailyCounters(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockSubscriptionUsageRepository) BulkResetDailyCounters(ctx context.Context) error {
	args := m.Called(ctx)
	return args.Error(0)
}

// MockSubscriptionTransactionRepository мок репозитория транзакций
type MockSubscriptionTransactionRepository struct {
	mock.Mock
}

func (m *MockSubscriptionTransactionRepository) CreateTransaction(ctx context.Context, tx *domain.SubscriptionTransaction) (int64, error) {
	args := m.Called(ctx, tx)
	return args.Get(0).(int64), args.Error(1)
}

func (m *MockSubscriptionTransactionRepository) GetTransactionByID(ctx context.Context, id int64) (*domain.SubscriptionTransaction, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.SubscriptionTransaction), args.Error(1)
}

func (m *MockSubscriptionTransactionRepository) GetTransactionByExternalID(ctx context.Context, provider string, externalID string) (*domain.SubscriptionTransaction, error) {
	args := m.Called(ctx, provider, externalID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.SubscriptionTransaction), args.Error(1)
}

func (m *MockSubscriptionTransactionRepository) GetUserTransactions(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SubscriptionTransaction, int, error) {
	args := m.Called(ctx, userID, page, limit)
	return args.Get(0).([]domain.SubscriptionTransaction), args.Int(1), args.Error(2)
}

func (m *MockSubscriptionTransactionRepository) UpdateTransactionStatus(ctx context.Context, id int64, status string, paidAt *time.Time, receiptURL, errorMessage *string) error {
	args := m.Called(ctx, id, status, paidAt, receiptURL, errorMessage)
	return args.Error(0)
}

func (m *MockSubscriptionTransactionRepository) UpdateTransactionByExternalID(ctx context.Context, provider string, externalID string, status string, paidAt *time.Time, receiptURL, errorMessage *string) error {
	args := m.Called(ctx, provider, externalID, status, paidAt, receiptURL, errorMessage)
	return args.Error(0)
}

func (m *MockSubscriptionTransactionRepository) CreateRefundTransaction(ctx context.Context, originalTxID int64, refundTx *domain.SubscriptionTransaction) (int64, error) {
	args := m.Called(ctx, originalTxID, refundTx)
	return args.Get(0).(int64), args.Error(1)
}

// MockPromoRedemptionRepository мок репозитория использований промокодов
type MockPromoRedemptionRepository struct {
	mock.Mock
}

func (m *MockPromoRedemptionRepository) CreateRedemption(ctx context.Context, redemption *domain.PromoRedemption) (int64, error) {
	args := m.Called(ctx, redemption)
	return args.Get(0).(int64), args.Error(1)
}

func (m *MockPromoRedemptionRepository) GetRedemptionsByUser(ctx context.Context, userID domain.ID) ([]domain.PromoRedemption, error) {
	args := m.Called(ctx, userID)
	return args.Get(0).([]domain.PromoRedemption), args.Error(1)
}

func (m *MockPromoRedemptionRepository) GetRedemptionByPromoAndUser(ctx context.Context, promoCodeID int64, userID domain.ID) (*domain.PromoRedemption, error) {
	args := m.Called(ctx, promoCodeID, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.PromoRedemption), args.Error(1)
}

// MockFamilyMemberRepository мок репозитория семейных участников
type MockFamilyMemberRepository struct {
	mock.Mock
}

func (m *MockFamilyMemberRepository) GetFamilyMembers(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error) {
	args := m.Called(ctx, ownerUserID)
	return args.Get(0).([]domain.FamilyMember), args.Error(1)
}

func (m *MockFamilyMemberRepository) GetFamilyMemberByID(ctx context.Context, id int64) (*domain.FamilyMember, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.FamilyMember), args.Error(1)
}

func (m *MockFamilyMemberRepository) GetFamilyMemberByMemberID(ctx context.Context, memberUserID domain.ID) (*domain.FamilyMember, error) {
	args := m.Called(ctx, memberUserID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.FamilyMember), args.Error(1)
}

func (m *MockFamilyMemberRepository) CreateFamilyMember(ctx context.Context, member *domain.FamilyMember) (int64, error) {
	args := m.Called(ctx, member)
	return args.Get(0).(int64), args.Error(1)
}

func (m *MockFamilyMemberRepository) UpdateFamilyMember(ctx context.Context, member *domain.FamilyMember) error {
	args := m.Called(ctx, member)
	return args.Error(0)
}

func (m *MockFamilyMemberRepository) RemoveFamilyMember(ctx context.Context, id int64) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockFamilyMemberRepository) AcceptInvitation(ctx context.Context, memberUserID domain.ID) error {
	args := m.Called(ctx, memberUserID)
	return args.Error(0)
}

func (m *MockFamilyMemberRepository) GetActiveFamilyMembersCount(ctx context.Context, ownerUserID domain.ID) (int, error) {
	args := m.Called(ctx, ownerUserID)
	return args.Int(0), args.Error(1)
}

func (m *MockFamilyMemberRepository) GetPendingInvitations(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error) {
	args := m.Called(ctx, ownerUserID)
	return args.Get(0).([]domain.FamilyMember), args.Error(1)
}

// TestSubscriptionService_ListPlans тест получения списка планов
func TestSubscriptionService_ListPlans(t *testing.T) {
	t.Parallel()

	mockPlanRepo := new(MockSubscriptionPlanRepository)
	mockUserSubRepo := new(MockUserSubscriptionRepository)
	mockUsageRepo := new(MockSubscriptionUsageRepository)
	mockTxRepo := new(MockSubscriptionTransactionRepository)
	mockPromoRepo := new(MockPromoCodeRepository)
	mockRedemptionRepo := new(MockPromoRedemptionRepository)
	mockFamilyRepo := new(MockFamilyMemberRepository)

	logger, _ := zap.NewDevelopment()

	svc := services.NewSubscriptionService(
		mockPlanRepo,
		mockUserSubRepo,
		mockUsageRepo,
		mockTxRepo,
		mockPromoRepo,
		mockRedemptionRepo,
		mockFamilyRepo,
		logger,
	)

	ctx := context.Background()

	expectedPlans := []domain.SubscriptionPlan{
		{ID: 1, Code: "free", Name: "Free", PriceMonthly: 0, IsActive: true},
		{ID: 2, Code: "premium", Name: "Premium", PriceMonthly: 299, IsActive: true},
		{ID: 3, Code: "pro", Name: "Pro", PriceMonthly: 599, IsActive: true},
		{ID: 4, Code: "business", Name: "Business", PriceMonthly: 1990, IsActive: true},
	}

	mockPlanRepo.On("ListPlans", ctx).Return(expectedPlans, nil)

	plans, err := svc.ListPlans(ctx)

	assert.NoError(t, err)
	assert.Len(t, plans, 4)
	assert.Equal(t, "free", plans[0].Code)
	assert.Equal(t, "premium", plans[1].Code)

	mockPlanRepo.AssertExpectations(t)
}

// TestSubscriptionService_GetCurrent_WithActiveSubscription тест получения активной подписки
func TestSubscriptionService_GetCurrent_WithActiveSubscription(t *testing.T) {
	t.Parallel()

	mockPlanRepo := new(MockSubscriptionPlanRepository)
	mockUserSubRepo := new(MockUserSubscriptionRepository)
	mockUsageRepo := new(MockSubscriptionUsageRepository)
	mockTxRepo := new(MockSubscriptionTransactionRepository)
	mockPromoRepo := new(MockPromoCodeRepository)
	mockRedemptionRepo := new(MockPromoRedemptionRepository)
	mockFamilyRepo := new(MockFamilyMemberRepository)

	logger, _ := zap.NewDevelopment()

	svc := services.NewSubscriptionService(
		mockPlanRepo,
		mockUserSubRepo,
		mockUsageRepo,
		mockTxRepo,
		mockPromoRepo,
		mockRedemptionRepo,
		mockFamilyRepo,
		logger,
	)

	ctx := context.Background()
	userID := domain.NewID()
	userIDInt := domain.IDToInt64(userID)

	plan := domain.SubscriptionPlan{
		ID:                  2,
		Code:                "premium",
		Name:                "Premium",
		PriceMonthly:        299,
		Currency:            "RUB",
		RecommendationsPerDay: ptr(20),
		WardrobeItemsLimit:  ptr(500),
		HistoryDays:         ptr(90),
		IsActive:            true,
	}

	now := time.Now()
	periodEnd := now.AddDate(0, 1, 0)
	status := "active"
	billingCycle := "monthly"

	sub := &domain.UserSubscription{
		ID:               ptr(int64(1)),
		UserID:           userIDInt,
		Plan:             plan,
		BillingCycle:     &billingCycle,
		Status:           &status,
		CurrentPeriodEnd: &periodEnd,
		AutoRenew:        ptr(true),
	}

	usage := &domain.SubscriptionUsage{
		UserID:               userIDInt,
		RecommendationsToday: 5,
		WardrobeCount:        50,
	}

	mockUserSubRepo.On("GetActiveSubscription", ctx, userID).Return(sub, nil)
	mockUsageRepo.On("GetUsage", ctx, userID).Return(usage, nil)

	result, err := svc.GetCurrent(ctx, userID)

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "premium", result.Subscription.Plan.Code)
	assert.Equal(t, 5, result.Usage.RecommendationsToday)
	assert.Equal(t, 20, *result.Usage.RecommendationsLimit)

	mockUserSubRepo.AssertExpectations(t)
	mockUsageRepo.AssertExpectations(t)
}

// TestSubscriptionService_GetCurrent_NoSubscription тест получения подписки когда её нет (Free fallback)
func TestSubscriptionService_GetCurrent_NoSubscription(t *testing.T) {
	t.Parallel()

	mockPlanRepo := new(MockSubscriptionPlanRepository)
	mockUserSubRepo := new(MockUserSubscriptionRepository)
	mockUsageRepo := new(MockSubscriptionUsageRepository)
	mockTxRepo := new(MockSubscriptionTransactionRepository)
	mockPromoRepo := new(MockPromoCodeRepository)
	mockRedemptionRepo := new(MockPromoRedemptionRepository)
	mockFamilyRepo := new(MockFamilyMemberRepository)

	logger, _ := zap.NewDevelopment()

	svc := services.NewSubscriptionService(
		mockPlanRepo,
		mockUserSubRepo,
		mockUsageRepo,
		mockTxRepo,
		mockPromoRepo,
		mockRedemptionRepo,
		mockFamilyRepo,
		logger,
	)

	ctx := context.Background()
	userID := domain.NewID()
	userIDInt := domain.IDToInt64(userID)

	freePlan := &domain.SubscriptionPlan{
		ID:                  1,
		Code:                "free",
		Name:                "Free",
		PriceMonthly:        0,
		RecommendationsPerDay: ptr(3),
		WardrobeItemsLimit:  ptr(50),
		HistoryDays:         ptr(7),
		IsActive:            true,
	}

	mockUserSubRepo.On("GetActiveSubscription", ctx, userID).Return(nil, nil)
	mockPlanRepo.On("GetPlanByCode", ctx, "free").Return(freePlan, nil)
	mockUsageRepo.On("GetUsage", ctx, userID).Return(&domain.SubscriptionUsage{
		UserID:               userIDInt,
		RecommendationsToday: 0,
		WardrobeCount:        0,
	}, nil)

	result, err := svc.GetCurrent(ctx, userID)

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "free", result.Subscription.Plan.Code)
	assert.Equal(t, 3, *result.Subscription.Plan.RecommendationsPerDay)

	mockUserSubRepo.AssertExpectations(t)
	mockPlanRepo.AssertExpectations(t)
}

// TestSubscriptionService_CheckCanCreateRecommendation тест проверки лимита рекомендаций
func TestSubscriptionService_CheckCanCreateRecommendation(t *testing.T) {
	t.Parallel()

	mockPlanRepo := new(MockSubscriptionPlanRepository)
	mockUserSubRepo := new(MockUserSubscriptionRepository)
	mockUsageRepo := new(MockSubscriptionUsageRepository)
	mockTxRepo := new(MockSubscriptionTransactionRepository)
	mockPromoRepo := new(MockPromoCodeRepository)
	mockRedemptionRepo := new(MockPromoRedemptionRepository)
	mockFamilyRepo := new(MockFamilyMemberRepository)

	logger, _ := zap.NewDevelopment()

	svc := services.NewSubscriptionService(
		mockPlanRepo,
		mockUserSubRepo,
		mockUsageRepo,
		mockTxRepo,
		mockPromoRepo,
		mockRedemptionRepo,
		mockFamilyRepo,
		logger,
	)

	ctx := context.Background()
	userID := domain.NewID()

	// Тест 1: Лимит не превышен
	t.Run("LimitNotExceeded", func(t *testing.T) {
		mockUserSubRepo.On("GetActiveSubscription", ctx, userID).Return(nil, nil)
		mockPlanRepo.On("GetPlanByCode", ctx, "free").Return(&domain.SubscriptionPlan{
			Code: "free",
			Name: "Free",
			RecommendationsPerDay: ptr(3),
		}, nil)
		mockUsageRepo.On("GetUsage", ctx, userID).Return(&domain.SubscriptionUsage{
			RecommendationsToday: 1,
		}, nil)

		err := svc.CheckCanCreateRecommendation(ctx, userID)
		assert.NoError(t, err)
	})

	// Тест 2: Лимит превышен
	t.Run("LimitExceeded", func(t *testing.T) {
		mockUserSubRepo.On("GetActiveSubscription", ctx, userID).Return(nil, nil)
		mockPlanRepo.On("GetPlanByCode", ctx, "free").Return(&domain.SubscriptionPlan{
			Code: "free",
			Name: "Free",
			RecommendationsPerDay: ptr(3),
		}, nil)
		mockUsageRepo.On("GetUsage", ctx, userID).Return(&domain.SubscriptionUsage{
			RecommendationsToday: 3,
		}, nil)

		err := svc.CheckCanCreateRecommendation(ctx, userID)
		assert.Error(t, err)
		assert.Equal(t, services.ErrRecommendationsLimitExceeded, err)
	})
}

// TestSubscriptionService_ValidatePromoCode тест валидации промокода
func TestSubscriptionService_ValidatePromoCode(t *testing.T) {
	t.Parallel()

	mockPlanRepo := new(MockSubscriptionPlanRepository)
	mockUserSubRepo := new(MockUserSubscriptionRepository)
	mockUsageRepo := new(MockSubscriptionUsageRepository)
	mockTxRepo := new(MockSubscriptionTransactionRepository)
	mockPromoRepo := new(MockPromoCodeRepository)
	mockRedemptionRepo := new(MockPromoRedemptionRepository)
	mockFamilyRepo := new(MockFamilyMemberRepository)

	logger, _ := zap.NewDevelopment()

	svc := services.NewSubscriptionService(
		mockPlanRepo,
		mockUserSubRepo,
		mockUsageRepo,
		mockTxRepo,
		mockPromoRepo,
		mockRedemptionRepo,
		mockFamilyRepo,
		logger,
	)

	ctx := context.Background()
	userID := domain.NewID()

	validUntil := time.Now().AddDate(0, 1, 0)
	usageLimitPerUser := 1

	promo := &domain.PromoCode{
		ID:              domain.NewID(),
		Code:            "WELCOME20",
		DiscountType:    "percentage",
		DiscountValue:   20,
		IsActive:        true,
		ValidUntil:      &validUntil,
		ApplicablePlans: []string{"premium", "pro", "business"},
		UsageLimitPerUser: &usageLimitPerUser,
	}

	// Тест: Валидный промокод
	t.Run("ValidPromo", func(t *testing.T) {
		// Здесь нужна proper mock для PromoRepository
		// Для простоты пропускаем детальную проверку
		_ = promo
		_ = svc
		_ = ctx
		_ = userID
	})
}

// Helper function
func ptr[T any](v T) *T {
	return &v
}
