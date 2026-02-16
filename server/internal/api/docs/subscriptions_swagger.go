// Пакет docs содержит Swagger документацию для API подписок и платежей
package docs

// @title OutfitStyle API - Subscriptions & Payments
// @version 1.0
// @description API для управления подписками и платежами OutfitStyle
// @termsOfService http://outfitstyle.app/terms

// @contact.name API Support
// @contact.url http://outfitstyle.app/support
// @contact.email support@outfitstyle.app

// @license.name MIT
// @license.url https://opensource.org/licenses/MIT

// @host localhost:8080
// @BasePath /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description JWT токен в формате "Bearer <token>"

// @securityDefinitions.apikey APIKeyAuth
// @in header
// @name X-API-Key
// @description API ключ для Business плана

// =============================================================================
// SUBSCRIPTIONS API
// =============================================================================

// @Summary Получить список планов подписок
// @Description Возвращает список всех доступных планов подписок (Free, Premium, Pro, Business)
// @Tags subscriptions
// @Produce json
// @Success 200 {object} map[string]any{data=map[string]any{plans=[]SubscriptionPlan}}
// @Failure 500 {object} map[string]any{error=string}
// @Router /api/v1/subscription/plans [get]
func ListPlans() {}

// @Summary Получить текущую подписку
// @Description Возвращает информацию о текущей подписке пользователя и использовании лимитов
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]any{data=CurrentSubscriptionResponse}
// @Failure 401 {object} map[string]any{error=string}
// @Failure 500 {object} map[string]any{error=string}
// @Router /api/v1/subscription/current [get]
func GetCurrentSubscription() {}

// @Summary Оформить подписку
// @Description Создаёт новую подписку и инициирует платёж через YooKassa
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body SubscribeRequest true "Запрос на оформление подписки"
// @Success 200 {object} map[string]any{data=SubscribeResponse}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Failure 500 {object} map[string]any{error=string}
// @Router /api/v1/subscription/subscribe [post]
func Subscribe() {}

// @Summary Отменить подписку
// @Description Отменяет активную подписку пользователя
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body CancelSubscriptionRequest true "Запрос на отмену подписки"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean,message=string}}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Router /api/v1/subscription/cancel [post]
func CancelSubscription() {}

// @Summary Изменить план подписки
// @Description Повышает план подписки (upgrade). Downgrade невозможен.
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body UpgradeSubscriptionRequest true "Запрос на изменение плана"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean,message=string}}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Router /api/v1/subscription/upgrade [post]
func UpgradeSubscription() {}

// @Summary Применить промокод
// @Description Проверяет и применяет промокод к подписке, возвращает информацию о скидке
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body PromoRequest true "Запрос на применение промокода"
// @Success 200 {object} map[string]any{data=ApplyPromoCodeResponse}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Router /api/v1/subscription/promo [post]
func ApplyPromoCode() {}

// @Summary Получить историю транзакций
// @Description Возвращает список транзакций пользователя с пагинацией
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Param page query int false "Номер страницы" default(1)
// @Param limit query int false "Размер страницы" default(20)
// @Success 200 {object} map[string]any{data=map[string]any{transactions=[]SubscriptionTransaction,pagination=Pagination}}
// @Failure 401 {object} map[string]any{error=string}
// @Failure 500 {object} map[string]any{error=string}
// @Router /api/v1/subscription/transactions [get]
func GetTransactions() {}

// @Summary Получить семейных участников
// @Description Возвращает список семейных участников владельца подписки Pro плана
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]any{data=map[string]any{members=[]FamilyMember}}
// @Failure 401 {object} map[string]any{error=string}
// @Failure 500 {object} map[string]any{error=string}
// @Router /api/v1/subscription/family [get]
func GetFamilyMembers() {}

// @Summary Добавить семейного участника
// @Description Отправляет приглашение пользователю для присоединения к семейной подписке
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body AddFamilyMemberRequest true "Запрос на добавление участника"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean,message=string}}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Failure 403 {object} map[string]any{error=string} "Plan does not support family members"
// @Router /api/v1/subscription/family/invite [post]
func AddFamilyMember() {}

// @Summary Принять приглашение в семью
// @Description Принимает приглашение на участие в семейной подписке
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean,message=string}}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Router /api/v1/subscription/family/accept [post]
func AcceptFamilyInvitation() {}

// @Summary Удалить семейного участника
// @Description Удаляет участника из семейной подписки
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body RemoveFamilyMemberRequest true "Запрос на удаление участника"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean,message=string}}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Router /api/v1/subscription/family/remove [post]
func RemoveFamilyMember() {}

// @Summary Начать пробный период
// @Description Активирует 14-дневный пробный период Premium для нового пользователя
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body StartTrialRequest true "Запрос на начало пробного периода"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean,message=string}}
// @Failure 400 {object} map[string]any{error=string} "Trial already used"
// @Failure 401 {object} map[string]any{error=string}
// @Router /api/v1/subscription/trial/start [post]
func StartTrial() {}

// =============================================================================
// PAYMENTS API
// =============================================================================

// @Summary Webhook от платежного провайдера
// @Description Обрабатывает уведомления от платежных систем (YooKassa, Stripe, Dummy)
// @Tags payments
// @Accept json
// @Produce json
// @Param provider path string true "Платежный провайдер (yookassa, stripe, dummy)"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean}}
// @Failure 400 {object} map[string]any{error=string}
// @Router /api/v1/payment/webhook/{provider} [post]
func PaymentWebhook() {}

// =============================================================================
// BILLING API
// =============================================================================

// @Summary Webhook от платежного провайдера (альтернативный endpoint)
// @Description Обрабатывает уведомления от платежных систем
// @Tags billing
// @Accept json
// @Produce json
// @Param provider path string true "Платежный провайдер (yookassa, stripe, dummy)"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean}}
// @Failure 400 {object} map[string]any{error=string}
// @Router /api/v1/billing/webhook/{provider} [post]
func BillingWebhook() {}

// @Summary Вернуть средства
// @Description Создаёт возврат средств по транзакции (требует admin прав)
// @Tags billing
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body RefundRequest true "Запрос на возврат средств"
// @Success 200 {object} map[string]any{data=map[string]any{success=boolean}}
// @Failure 400 {object} map[string]any{error=string}
// @Failure 401 {object} map[string]any{error=string}
// @Failure 403 {object} map[string]any{error=string} "Admin access required"
// @Router /api/v1/billing/refund [post]
func RefundPayment() {}

// @Summary Получить историю платежей
// @Description Возвращает список платежей пользователя
// @Tags billing
// @Produce json
// @Security BearerAuth
// @Param page query int false "Номер страницы" default(1)
// @Param limit query int false "Размер страницы" default(20)
// @Success 200 {object} map[string]any{data=map[string]any{payments=[]Payment,pagination=Pagination}}
// @Failure 401 {object} map[string]any{error=string}
// @Router /api/v1/billing/payments [get]
func GetPayments() {}

// =============================================================================
// MODELS
// =============================================================================

// SubscriptionPlan план подписки
// @Description Модель плана подписки
// @Tags models
type SubscriptionPlan struct {
	// ID плана
	ID int64 `json:"id" example:"1"`
	// Код плана (free, premium, pro, business)
	Code string `json:"code" example:"premium"`
	// Название плана
	Name string `json:"name" example:"Premium"`
	// Описание плана
	Description *string `json:"description,omitempty"`
	// Цена в месяц
	PriceMonthly float64 `json:"price_monthly" example:"299"`
	// Цена в год
	PriceYearly float64 `json:"price_yearly" example:"2990"`
	// Валюта
	Currency string `json:"currency" example:"RUB"`
	// Лимит рекомендаций в день (null = безлимит)
	RecommendationsPerDay *int `json:"recommendations_per_day,omitempty"`
	// Лимит вещей в гардеробе (null = безлимит)
	WardrobeItemsLimit *int `json:"wardrobe_items_limit,omitempty"`
	// Дней истории (null = безлимит)
	HistoryDays *int `json:"history_days,omitempty"`
	// Количество семейных аккаунтов
	FamilyAccounts int `json:"family_accounts" example:"1"`
	// Фичи плана
	Features []byte `json:"features"`
	// Активен ли план
	IsActive bool `json:"is_active" example:"true"`
	// Порядок сортировки
	SortOrder int `json:"sort_order" example:"1"`
	// Дней пробного периода
	TrialPeriodDays int `json:"trial_period_days" example:"14"`
}

// CurrentSubscriptionResponse ответ с текущей подпиской
// @Description Модель ответа с текущей подпиской и использованием
// @Tags models
type CurrentSubscriptionResponse struct {
	// Информация о подписке
	Subscription UserSubscription `json:"subscription"`
	// Использование лимитов
	Usage SubscriptionUsage `json:"usage"`
	// Лимиты подписки
	Limits SubscriptionLimits `json:"limits"`
}

// UserSubscription подписка пользователя
// @Description Модель подписки пользователя
// @Tags models
type UserSubscription struct {
	// ID подписки
	ID *int64 `json:"id,omitempty"`
	// ID пользователя
	UserID int64 `json:"user_id"`
	// План подписки
	Plan SubscriptionPlan `json:"plan"`
	// Цикл оплаты (monthly/yearly)
	BillingCycle *string `json:"billing_cycle,omitempty"`
	// Дата начала подписки
	StartedAt *string `json:"started_at,omitempty"`
	// Начало текущего периода
	CurrentPeriodStart *string `json:"current_period_start,omitempty"`
	// Конец текущего периода
	CurrentPeriodEnd *string `json:"current_period_end,omitempty"`
	// Конец пробного периода
	TrialEnd *string `json:"trial_end,omitempty"`
	// Статус подписки (active/trialing/cancelled/expired)
	Status *string `json:"status,omitempty"`
	// Автопродление
	AutoRenew *bool `json:"auto_renew,omitempty"`
	// Дата отмены
	CancelledAt *string `json:"cancelled_at,omitempty"`
	// Отмена в конце периода
	CancelAtPeriodEnd *bool `json:"cancel_at_period_end,omitempty"`
	// Платежный провайдер
	PaymentProvider *string `json:"payment_provider,omitempty"`
	// Внешний ID подписки
	ExternalSubscriptionID *string `json:"external_subscription_id,omitempty"`
}

// SubscriptionUsage использование лимитов
// @Description Модель использования лимитов подписки
// @Tags models
type SubscriptionUsage struct {
	// Использовано рекомендаций сегодня
	RecommendationsToday int `json:"recommendations_today"`
	// Лимит рекомендаций в день
	RecommendationsLimit *int `json:"recommendations_limit,omitempty"`
	// Количество вещей в гардеробе
	WardrobeCount int `json:"wardrobe_count"`
	// Лимит вещей в гардеробе
	WardrobeLimit *int `json:"wardrobe_limit,omitempty"`
}

// SubscriptionLimits лимиты подписки
// @Description Модель лимитов подписки
// @Tags models
type SubscriptionLimits struct {
	// Лимит рекомендаций в день
	RecommendationsPerDay *int `json:"recommendations_per_day,omitempty"`
	// Использовано рекомендаций сегодня
	RecommendationsToday int `json:"recommendations_today"`
	// Лимит вещей в гардеробе
	WardrobeItemsLimit *int `json:"wardrobe_items_limit,omitempty"`
	// Количество вещей в гардеробе
	WardrobeCount int `json:"wardrobe_count"`
	// Дней истории
	HistoryDays *int `json:"history_days,omitempty"`
	// Лимит стилей
	StylesLimit *int `json:"styles_limit,omitempty"`
	// Количество семейных аккаунтов
	FamilyAccounts int `json:"family_accounts"`
	// Количество семейных участников
	FamilyMembers int `json:"family_members_count"`
}

// SubscribeRequest запрос на оформление подписки
// @Description Модель запроса на оформление подписки
// @Tags models
type SubscribeRequest struct {
	// Код плана (free, premium, pro, business)
	PlanCode string `json:"plan_code" example:"premium"`
	// Цикл оплаты (monthly/yearly)
	BillingCycle string `json:"billing_cycle" example:"monthly"`
	// Платежный провайдер (yookassa/dummy)
	PaymentProvider string `json:"payment_provider" example:"yookassa"`
	// ID метода оплаты (опционально)
	PaymentMethodID *string `json:"payment_method_id,omitempty"`
	// Промокод (опционально)
	PromoCode *string `json:"promo_code,omitempty"`
	// URL возврата после оплаты (опционально)
	ReturnURL *string `json:"return_url,omitempty"`
}

// SubscribeResponse ответ на оформление подписки
// @Description Модель ответа на оформление подписки
// @Tags models
type SubscribeResponse struct {
	// Информация о подписке
	Subscription UserSubscription `json:"subscription"`
	// URL для оплаты (для yookassa)
	PaymentURL *string `json:"payment_url,omitempty"`
	// Client secret (для stripe)
	ClientSecret *string `json:"client_secret,omitempty"`
	// ID платежа
	PaymentID *string `json:"payment_id,omitempty"`
}

// CancelSubscriptionRequest запрос на отмену подписки
// @Description Модель запроса на отмену подписки
// @Tags models
type CancelSubscriptionRequest struct {
	// Причина отмены
	Reason *string `json:"reason,omitempty"`
	// Обратная связь
	Feedback *string `json:"feedback,omitempty"`
	// Немедленная отмена (по умолчанию false - отмена в конце периода)
	Immediate *bool `json:"immediate,omitempty"`
}

// UpgradeSubscriptionRequest запрос на изменение плана
// @Description Модель запроса на изменение плана подписки
// @Tags models
type UpgradeSubscriptionRequest struct {
	// Код нового плана
	NewPlanCode string `json:"new_plan_code" example:"pro"`
	// Новый цикл оплаты (опционально)
	NewBillingCycle *string `json:"new_billing_cycle,omitempty"`
}

// PromoRequest запрос на применение промокода
// @Description Модель запроса на применение промокода
// @Tags models
type PromoRequest struct {
	// Код промокода
	Code string `json:"code" example:"WELCOME20"`
	// Код плана для проверки применимости (опционально)
	PlanCode *string `json:"plan_code,omitempty"`
}

// ApplyPromoCodeResponse ответ на применение промокода
// @Description Модель ответа на применение промокода
// @Tags models
type ApplyPromoCodeResponse struct {
	// Успешно ли применён промокод
	Success bool `json:"success"`
	// Сумма скидки
	DiscountAmount float64 `json:"discount_amount"`
	// Оригинальная сумма
	OriginalAmount float64 `json:"original_amount"`
	// Итоговая сумма
	FinalAmount float64 `json:"final_amount"`
	// Валюта
	Currency string `json:"currency"`
	// Сообщение
	Message string `json:"message,omitempty"`
}

// SubscriptionTransaction транзакция подписки
// @Description Модель транзакции подписки
// @Tags models
type SubscriptionTransaction struct {
	// ID транзакции
	ID int64 `json:"id"`
	// ID пользователя
	UserID int64 `json:"user_id"`
	// ID подписки
	SubscriptionID *int64 `json:"subscription_id,omitempty"`
	// Сумма
	Amount float64 `json:"amount"`
	// Валюта
	Currency string `json:"currency"`
	// Статус (pending/paid/failed/refunded/cancelled)
	Status string `json:"status"`
	// Платежный провайдер
	PaymentProvider string `json:"payment_provider"`
	// Внешний ID платежа
	ExternalPaymentID string `json:"external_payment_id"`
	// Метод оплаты
	PaymentMethod *string `json:"payment_method,omitempty"`
	// Описание
	Description *string `json:"description,omitempty"`
	// URL чека
	ReceiptURL *string `json:"receipt_url,omitempty"`
	// Сообщение об ошибке
	ErrorMessage *string `json:"error_message,omitempty"`
	// Дата оплаты
	PaidAt *string `json:"paid_at,omitempty"`
	// Дата создания
	CreatedAt string `json:"created_at"`
}

// FamilyMember семейный участник
// @Description Модель семейного участника для Pro плана
// @Tags models
type FamilyMember struct {
	// ID записи
	ID int64 `json:"id"`
	// ID владельца подписки
	OwnerUserID int64 `json:"owner_user_id"`
	// ID участника
	MemberUserID int64 `json:"member_user_id"`
	// Статус (pending/active/removed/expired)
	Status string `json:"status"`
	// Дата приглашения
	InvitedAt string `json:"invited_at"`
	// Дата принятия
	AcceptedAt *string `json:"accepted_at,omitempty"`
	// Дата истечения
	ExpiresAt *string `json:"expires_at,omitempty"`
}

// Pagination пагинация
// @Description Модель пагинации
// @Tags models
type Pagination struct {
	// Текущая страница
	Page int `json:"page"`
	// Размер страницы
	Limit int `json:"limit"`
	// Общее количество записей
	Total int `json:"total"`
}

// AddFamilyMemberRequest запрос на добавление семейного участника
// @Description Модель запроса на добавление семейного участника
// @Tags models
type AddFamilyMemberRequest struct {
	// Email участника
	MemberEmail string `json:"member_email" example:"friend@example.com"`
}

// RemoveFamilyMemberRequest запрос на удаление семейного участника
// @Description Модель запроса на удаление семейного участника
// @Tags models
type RemoveFamilyMemberRequest struct {
	// ID пользователя участника
	MemberUserID string `json:"member_user_id"`
}

// StartTrialRequest запрос на начало пробного периода
// @Description Модель запроса на начало пробного периода
// @Tags models
type StartTrialRequest struct {
	// Код плана для триала (по умолчанию premium)
	PlanCode string `json:"plan_code" example:"premium"`
}

// RefundRequest запрос на возврат средств
// @Description Модель запроса на возврат средств
// @Tags models
type RefundRequest struct {
	// ID транзакции
	TransactionID int64 `json:"transaction_id"`
	// Сумма возврата (по умолчанию полная сумма)
	Amount *float64 `json:"amount,omitempty"`
	// Причина возврата
	Reason string `json:"reason"`
}
