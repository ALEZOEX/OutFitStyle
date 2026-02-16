package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// SubscriptionPlanRepository репозиторий для работы с планами подписок
type SubscriptionPlanRepository interface {
	// ListPlans возвращает список всех активных планов подписки
	ListPlans(ctx context.Context) ([]domain.SubscriptionPlan, error)

	// GetPlanByID возвращает план подписки по ID
	GetPlanByID(ctx context.Context, id int64) (*domain.SubscriptionPlan, error)

	// GetPlanByCode возвращает план подписки по коду
	GetPlanByCode(ctx context.Context, code string) (*domain.SubscriptionPlan, error)

	// CreatePlan создаёт новый план подписки
	CreatePlan(ctx context.Context, plan *domain.SubscriptionPlan) (int64, error)

	// UpdatePlan обновляет план подписки
	UpdatePlan(ctx context.Context, plan *domain.SubscriptionPlan) error

	// DeletePlan удаляет план подписки (мягкое удаление через is_active)
	DeletePlan(ctx context.Context, id int64) error
}

// UserSubscriptionRepository репозиторий для работы с подписками пользователей
type UserSubscriptionRepository interface {
	// GetActiveSubscription возвращает активную подписку пользователя
	GetActiveSubscription(ctx context.Context, userID domain.ID) (*domain.UserSubscription, error)

	// GetSubscriptionByID возвращает подписку по ID
	GetSubscriptionByID(ctx context.Context, id int64) (*domain.UserSubscription, error)

	// GetUserSubscriptions возвращает все подписки пользователя
	GetUserSubscriptions(ctx context.Context, userID domain.ID) ([]domain.UserSubscription, error)

	// CreateSubscription создаёт новую подписку пользователя
	CreateSubscription(ctx context.Context, sub *domain.UserSubscription) (int64, error)

	// UpdateSubscription обновляет подписку пользователя
	UpdateSubscription(ctx context.Context, sub *domain.UserSubscription) error

	// CancelSubscription отменяет подписку пользователя
	CancelSubscription(ctx context.Context, userID domain.ID, immediate bool, reason, feedback *string) error

	// ReactivateSubscription восстанавливает подписку пользователя
	ReactivateSubscription(ctx context.Context, userID domain.ID) error

	// UpgradeSubscription изменяет план подписки
	UpgradeSubscription(ctx context.Context, userID domain.ID, newPlanID int64, newPeriodEnd time.Time) error

	// ExtendSubscription продлевает подписку на указанный период
	ExtendSubscription(ctx context.Context, userID domain.ID, duration time.Duration) error

	// StartTrial начинает пробный период для пользователя
	StartTrial(ctx context.Context, userID domain.ID, planID int64, trialDays int) error

	// GetSubscriptionsExpiringSoon возвращает подписки, истекающие в ближайшее время
	GetSubscriptionsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error)

	// GetTrialsExpiringSoon возвращает пробные подписки, истекающие в ближайшее время
	GetTrialsExpiringSoon(ctx context.Context, before time.Time) ([]domain.UserSubscription, error)
}

// SubscriptionUsageRepository репозиторий для работы с использованием лимитов
type SubscriptionUsageRepository interface {
	// GetUsage возвращает использование лимитов пользователя
	GetUsage(ctx context.Context, userID domain.ID) (*domain.SubscriptionUsage, error)

	// GetOrCreateUsage возвращает или создаёт использование лимитов
	GetOrCreateUsage(ctx context.Context, userID domain.ID, subscriptionID *int64) (*domain.SubscriptionUsage, error)

	// UpdateUsage обновляет использование лимитов
	UpdateUsage(ctx context.Context, usage *domain.SubscriptionUsage) error

	// IncrementRecommendations увеличивает счётчик рекомендаций
	IncrementRecommendations(ctx context.Context, userID domain.ID) error

	// IncrementWardrobe увеличивает счётчик вещей в гардеробе
	IncrementWardrobe(ctx context.Context, userID domain.ID) error

	// DecrementWardrobe уменьшает счётчик вещей в гардеробе
	DecrementWardrobe(ctx context.Context, userID domain.ID) error

	// ResetDailyCounters сбрасывает дневные счётчики
	ResetDailyCounters(ctx context.Context, userID domain.ID) error

	// BulkResetDailyCounters сбрасывает дневные счётчики для всех пользователей
	BulkResetDailyCounters(ctx context.Context) error
}

// SubscriptionTransactionRepository репозиторий для работы с транзакциями
type SubscriptionTransactionRepository interface {
	// CreateTransaction создаёт новую транзакцию
	CreateTransaction(ctx context.Context, tx *domain.SubscriptionTransaction) (int64, error)

	// GetTransactionByID возвращает транзакцию по ID
	GetTransactionByID(ctx context.Context, id int64) (*domain.SubscriptionTransaction, error)

	// GetTransactionByExternalID возвращает транзакцию по внешнему ID
	GetTransactionByExternalID(ctx context.Context, provider string, externalID string) (*domain.SubscriptionTransaction, error)

	// GetUserTransactions возвращает транзакции пользователя
	GetUserTransactions(ctx context.Context, userID domain.ID, page, limit int) ([]domain.SubscriptionTransaction, int, error)

	// UpdateTransactionStatus обновляет статус транзакции
	UpdateTransactionStatus(ctx context.Context, id int64, status string, paidAt *time.Time, receiptURL, errorMessage *string) error

	// UpdateTransactionByExternalID обновляет транзакцию по внешнему ID
	UpdateTransactionByExternalID(ctx context.Context, provider string, externalID string, status string, paidAt *time.Time, receiptURL, errorMessage *string) error

	// CreateRefundTransaction создаёт транзакцию возврата
	CreateRefundTransaction(ctx context.Context, originalTxID int64, refundTx *domain.SubscriptionTransaction) (int64, error)
}

// PromoCodeRepository репозиторий для работы с промокодами
type PromoCodeRepository interface {
	// GetByCode возвращает промокод по коду
	GetByCode(ctx context.Context, code string) (*domain.PromoCode, error)

	// GetByID возвращает промокод по ID
	GetByID(ctx context.Context, id int64) (*domain.PromoCode, error)

	// CreatePromoCode создаёт новый промокод
	CreatePromoCode(ctx context.Context, promo *domain.PromoCode) (int64, error)

	// UpdatePromoCode обновляет промокод
	UpdatePromoCode(ctx context.Context, promo *domain.PromoCode) error

	// DeletePromoCode удаляет промокод (мягкое удаление через is_active)
	DeletePromoCode(ctx context.Context, id int64) error

	// GetUsageCount возвращает количество использований промокода пользователем
	GetUsageCount(ctx context.Context, promoCodeID int64, userID domain.ID) (int, error)

	// IncrementUsage увеличивает счётчик использований промокода
	IncrementUsage(ctx context.Context, promoCodeID int64) error

	// ListActivePromoCodes возвращает список активных промокодов
	ListActivePromoCodes(ctx context.Context) ([]domain.PromoCode, error)
}

// PromoRedemptionRepository репозиторий для работы с использованиями промокодов
type PromoRedemptionRepository interface {
	// CreateRedemption создаёт запись об использовании промокода
	CreateRedemption(ctx context.Context, redemption *domain.PromoRedemption) (int64, error)

	// GetRedemptionsByUser возвращает использования промокодов пользователем
	GetRedemptionsByUser(ctx context.Context, userID domain.ID) ([]domain.PromoRedemption, error)

	// GetRedemptionByPromoAndUser возвращает использование промокода пользователем
	GetRedemptionByPromoAndUser(ctx context.Context, promoCodeID int64, userID domain.ID) (*domain.PromoRedemption, error)
}

// FamilyMemberRepository репозиторий для работы с семейными участниками
type FamilyMemberRepository interface {
	// GetFamilyMembers возвращает семейных участников владельца
	GetFamilyMembers(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error)

	// GetFamilyMemberByID возвращает семейного участника по ID
	GetFamilyMemberByID(ctx context.Context, id int64) (*domain.FamilyMember, error)

	// GetFamilyMemberByMemberID возвращает семейного участника по ID участника
	GetFamilyMemberByMemberID(ctx context.Context, memberUserID domain.ID) (*domain.FamilyMember, error)

	// CreateFamilyMember создаёт нового семейного участника
	CreateFamilyMember(ctx context.Context, member *domain.FamilyMember) (int64, error)

	// UpdateFamilyMember обновляет семейного участника
	UpdateFamilyMember(ctx context.Context, member *domain.FamilyMember) error

	// RemoveFamilyMember удаляет семейного участника
	RemoveFamilyMember(ctx context.Context, id int64) error

	// AcceptInvitation принимает приглашение в семью
	AcceptInvitation(ctx context.Context, memberUserID domain.ID) error

	// GetActiveFamilyMembersCount возвращает количество активных семейных участников
	GetActiveFamilyMembersCount(ctx context.Context, ownerUserID domain.ID) (int, error)

	// GetPendingInvitations возвращает ожидающие приглашения
	GetPendingInvitations(ctx context.Context, ownerUserID domain.ID) ([]domain.FamilyMember, error)
}
