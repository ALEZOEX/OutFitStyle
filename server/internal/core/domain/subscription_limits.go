package domain

import "time"

// SubscriptionLimits лимиты подписки для различных операций
type SubscriptionLimits struct {
	// Рекомендации
	RecommendationsPerDay *int `json:"recommendations_per_day,omitempty"`
	RecommendationsToday  int  `json:"recommendations_today"`

	// Гардероб
	WardrobeItemsLimit *int `json:"wardrobe_items_limit,omitempty"`
	WardrobeCount      int  `json:"wardrobe_count"`

	// История
	HistoryDays *int `json:"history_days,omitempty"`

	// Стили
	StylesLimit *int `json:"styles_limit,omitempty"`

	// Семейные аккаунты
	FamilyAccounts int `json:"family_accounts"`
	FamilyMembers  int `json:"family_members_count"`
}

// CanCreateRecommendation проверяет, можно ли создать рекомендацию
func (l *SubscriptionLimits) CanCreateRecommendation() bool {
	if l.RecommendationsPerDay == nil {
		return true // безлимит
	}
	return l.RecommendationsToday < *l.RecommendationsPerDay
}

// CanAddWardrobeItem проверяет, можно ли добавить вещь в гардероб
func (l *SubscriptionLimits) CanAddWardrobeItem() bool {
	if l.WardrobeItemsLimit == nil {
		return true // безлимит
	}
	return l.WardrobeCount < *l.WardrobeItemsLimit
}

// CanAddFamilyMember проверяет, можно ли добавить семейного участника
func (l *SubscriptionLimits) CanAddFamilyMember() bool {
	return l.FamilyMembers < l.FamilyAccounts
}

// GetHistoryCutoff возвращает дату, до которой доступна история
func (l *SubscriptionLimits) GetHistoryCutoff(now time.Time) time.Time {
	if l.HistoryDays == nil {
		return time.Time{} // безлимитная история
	}
	return now.AddDate(0, 0, -*l.HistoryDays)
}

// SubscriptionPlanCode коды планов подписки
type SubscriptionPlanCode string

const (
	PlanCodeFree     SubscriptionPlanCode = "free"
	PlanCodePremium  SubscriptionPlanCode = "premium"
	PlanCodePro      SubscriptionPlanCode = "pro"
	PlanCodeBusiness SubscriptionPlanCode = "business"
)

// BillingCycle цикл оплаты
type BillingCycle string

const (
	BillingCycleMonthly BillingCycle = "monthly"
	BillingCycleYearly  BillingCycle = "yearly"
)

// SubscriptionStatus статус подписки
type SubscriptionStatus string

const (
	SubscriptionStatusActive   SubscriptionStatus = "active"
	SubscriptionStatusTrialing SubscriptionStatus = "trialing"
	SubscriptionStatusCancelled SubscriptionStatus = "cancelled"
	SubscriptionStatusExpired  SubscriptionStatus = "expired"
	SubscriptionStatusPastDue  SubscriptionStatus = "past_due"
)

// PaymentStatus статус платежа
type PaymentStatus string

const (
	PaymentStatusPending  PaymentStatus = "pending"
	PaymentStatusPaid     PaymentStatus = "paid"
	PaymentStatusFailed   PaymentStatus = "failed"
	PaymentStatusRefunded PaymentStatus = "refunded"
	PaymentStatusCancelled PaymentStatus = "cancelled"
)

// FamilyMemberStatus статус семейного участника
type FamilyMemberStatus string

const (
	FamilyMemberStatusPending FamilyMemberStatus = "pending"
	FamilyMemberStatusActive  FamilyMemberStatus = "active"
	FamilyMemberStatusRemoved FamilyMemberStatus = "removed"
	FamilyMemberStatusExpired FamilyMemberStatus = "expired"
)
