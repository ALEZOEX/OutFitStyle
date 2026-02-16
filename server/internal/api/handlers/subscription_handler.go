package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

// SubscriptionHandler обработчик запросов подписок
type SubscriptionHandler struct {
	subscriptionSvc *services.SubscriptionService
	paymentSvc      *services.PaymentService
	log             *zap.Logger
}

// NewSubscriptionHandler создаёт новый обработчик подписок
func NewSubscriptionHandler(
	subscriptionSvc *services.SubscriptionService,
	paymentSvc *services.PaymentService,
	log *zap.Logger,
) *SubscriptionHandler {
	return &SubscriptionHandler{
		subscriptionSvc: subscriptionSvc,
		paymentSvc:      paymentSvc,
		log:             log,
	}
}

// RegisterPublic регистрирует публичные маршруты
func (h *SubscriptionHandler) RegisterPublic(r *mux.Router) {
	r.HandleFunc("/plans", h.ListPlans).Methods(http.MethodGet)
}

// RegisterProtected регистрирует защищённые маршруты
func (h *SubscriptionHandler) RegisterProtected(r *mux.Router) {
	r.HandleFunc("/current", h.GetCurrent).Methods(http.MethodGet)
	r.HandleFunc("/subscribe", h.Subscribe).Methods(http.MethodPost)
	r.HandleFunc("/cancel", h.Cancel).Methods(http.MethodPost)
	r.HandleFunc("/upgrade", h.Upgrade).Methods(http.MethodPost)
	r.HandleFunc("/promo", h.ApplyPromoCode).Methods(http.MethodPost)
	r.HandleFunc("/transactions", h.GetTransactions).Methods(http.MethodGet)
	r.HandleFunc("/family", h.GetFamilyMembers).Methods(http.MethodGet)
	r.HandleFunc("/family/invite", h.AddFamilyMember).Methods(http.MethodPost)
	r.HandleFunc("/family/accept", h.AcceptFamilyInvitation).Methods(http.MethodPost)
	r.HandleFunc("/family/remove", h.RemoveFamilyMember).Methods(http.MethodPost)
	r.HandleFunc("/trial/start", h.StartTrial).Methods(http.MethodPost)
}

// ListPlans godoc
// @Summary Получить список планов подписок
// @Description Возвращает список всех доступных планов подписок
// @Tags subscriptions
// @Produce json
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/plans [get]
func (h *SubscriptionHandler) ListPlans(w http.ResponseWriter, r *http.Request) {
	plans, err := h.subscriptionSvc.ListPlans(r.Context())
	if err != nil {
		h.log.Error("list plans failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errFailedToLoadPlans)
		return
	}
	resp.Success(w, map[string]any{"plans": plans})
}

// GetCurrent godoc
// @Summary Получить текущую подписку
// @Description Возвращает информацию о текущей подписке пользователя и использовании лимитов
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/current [get]
func (h *SubscriptionHandler) GetCurrent(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	cur, err := h.subscriptionSvc.GetCurrent(r.Context(), userID)
	if err != nil {
		h.log.Error("get current subscription failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errFailedToLoadSubscription)
		return
	}
	resp.Success(w, cur)
}

// SubscribeRequest запрос на оформление подписки
type SubscribeRequest struct {
	PlanCode        string  `json:"plan_code" validate:"required"`
	BillingCycle    string  `json:"billing_cycle" validate:"required,oneof=monthly yearly"`
	PaymentProvider string  `json:"payment_provider" validate:"required,oneof=yookassa dummy"`
	PaymentMethodID *string `json:"payment_method_id,omitempty"`
	PromoCode       *string `json:"promo_code,omitempty"`
	ReturnURL       *string `json:"return_url,omitempty"`
}

// Subscribe godoc
// @Summary Оформить подписку
// @Description Создаёт новую подписку и инициирует платёж
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body SubscribeRequest true "Запрос на оформление подписки"
// @Success 200 {object} map[string]any
// @Failure 400 {object} map[string]any
// @Router /api/v1/subscription/subscribe [post]
func (h *SubscriptionHandler) Subscribe(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	var req SubscribeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errInvalidRequestBody)
		return
	}

	// Валидация
	if req.PlanCode == "" {
		resp.Error(w, http.StatusBadRequest, errPlanCodeRequired)
		return
	}
	if req.BillingCycle != "monthly" && req.BillingCycle != "yearly" {
		resp.Error(w, http.StatusBadRequest, errInvalidBillingCycle)
		return
	}
	if req.PaymentProvider == "" {
		req.PaymentProvider = "yookassa"
	}

	subReq := domain.SubscribeRequest{
		PlanCode:        req.PlanCode,
		BillingCycle:    req.BillingCycle,
		PaymentProvider: req.PaymentProvider,
		PaymentMethodID: req.PaymentMethodID,
		PromoCode:       req.PromoCode,
		ReturnURL:       req.ReturnURL,
	}

	result, err := h.paymentSvc.Subscribe(r.Context(), userID, subReq)
	if err != nil {
		h.log.Error("subscribe failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, result)
}

// CancelRequest запрос на отмену подписки
type CancelRequest struct {
	Reason    *string `json:"reason,omitempty"`
	Feedback  *string `json:"feedback,omitempty"`
	Immediate *bool   `json:"immediate,omitempty"`
}

// Cancel godoc
// @Summary Отменить подписку
// @Description Отменяет активную подписку пользователя
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body CancelRequest true "Запрос на отмену подписки"
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/cancel [post]
func (h *SubscriptionHandler) Cancel(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	var req CancelRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errInvalidRequestBody)
		return
	}

	immediate := false
	if req.Immediate != nil {
		immediate = *req.Immediate
	}

	if err := h.paymentSvc.Cancel(r.Context(), userID, immediate, req.Reason, req.Feedback); err != nil {
		h.log.Error("cancel subscription failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true, "message": "Subscription cancelled"})
}

// UpgradeRequest запрос на изменение плана
type UpgradeRequest struct {
	NewPlanCode     string  `json:"new_plan_code" validate:"required"`
	NewBillingCycle *string `json:"new_billing_cycle,omitempty"`
}

// Upgrade godoc
// @Summary Изменить план подписки
// @Description Повышает план подписки (upgrade)
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body UpgradeRequest true "Запрос на изменение плана"
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/upgrade [post]
func (h *SubscriptionHandler) Upgrade(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	var req UpgradeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errInvalidRequestBody)
		return
	}

	if req.NewPlanCode == "" {
		resp.Error(w, http.StatusBadRequest, errPlanCodeRequired)
		return
	}

	if err := h.paymentSvc.Upgrade(r.Context(), userID, req.NewPlanCode, req.NewBillingCycle); err != nil {
		h.log.Error("upgrade subscription failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true, "message": "Subscription upgraded"})
}

// PromoRequest запрос на проверку промокода
type PromoRequest struct {
	Code     string  `json:"code" validate:"required"`
	PlanCode *string `json:"plan_code,omitempty"`
}

// ApplyPromoCode godoc
// @Summary Применить промокод
// @Description Проверяет и применяет промокод к подписке
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body PromoRequest true "Запрос на применение промокода"
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/promo [post]
func (h *SubscriptionHandler) ApplyPromoCode(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	var req PromoRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errInvalidRequestBody)
		return
	}

	if req.Code == "" {
		resp.Error(w, http.StatusBadRequest, errPromoCodeRequired)
		return
	}

	planCode := "premium"
	if req.PlanCode != nil {
		planCode = *req.PlanCode
	}

	result, err := h.subscriptionSvc.ApplyPromoCode(r.Context(), req.Code, planCode, "monthly", userID)
	if err != nil {
		h.log.Error("apply promo code failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, result)
}

// GetTransactions godoc
// @Summary Получить историю транзакций
// @Description Возвращает список транзакций пользователя
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Param page query int false "Номер страницы" default(1)
// @Param limit query int false "Размер страницы" default(20)
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/transactions [get]
func (h *SubscriptionHandler) GetTransactions(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))

	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}

	transactions, pagination, err := h.subscriptionSvc.GetTransactions(r.Context(), userID, page, limit)
	if err != nil {
		h.log.Error("get transactions failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errFailedToLoadTransactions)
		return
	}

	resp.Success(w, map[string]any{
		"transactions": transactions,
		"pagination":   pagination,
	})
}

// GetFamilyMembers godoc
// @Summary Получить семейных участников
// @Description Возвращает список семейных участников владельца подписки
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/family [get]
func (h *SubscriptionHandler) GetFamilyMembers(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	members, err := h.subscriptionSvc.GetFamilyMembers(r.Context(), userID)
	if err != nil {
		h.log.Error("get family members failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errFailedToLoadFamilyMembers)
		return
	}

	resp.Success(w, map[string]any{"members": members})
}

// AddFamilyMemberRequest запрос на добавление семейного участника
type AddFamilyMemberRequest struct {
	MemberEmail string `json:"member_email" validate:"required,email"`
}

// AddFamilyMember godoc
// @Summary Добавить семейного участника
// @Description Отправляет приглашение пользователю для присоединения к семейной подписке
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body AddFamilyMemberRequest true "Запрос на добавление участника"
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/family/invite [post]
func (h *SubscriptionHandler) AddFamilyMember(w http.ResponseWriter, r *http.Request) {
	// В реальной реализации здесь будет lookup пользователя по email
	// Для MVP просто возвращаем ошибку "not implemented"
	resp.Error(w, http.StatusNotImplemented, errNotImplemented)
}

// AcceptFamilyInvitation godoc
// @Summary Принять приглашение в семью
// @Description Принимает приглашение на участие в семейной подписке
// @Tags subscriptions
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/family/accept [post]
func (h *SubscriptionHandler) AcceptFamilyInvitation(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	if err := h.subscriptionSvc.AcceptFamilyInvitation(r.Context(), userID); err != nil {
		h.log.Error("accept family invitation failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true, "message": "Invitation accepted"})
}

// RemoveFamilyMemberRequest запрос на удаление семейного участника
type RemoveFamilyMemberRequest struct {
	MemberUserID string `json:"member_user_id" validate:"required"`
}

// RemoveFamilyMember godoc
// @Summary Удалить семейного участника
// @Description Удаляет участника из семейной подписки
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body RemoveFamilyMemberRequest true "Запрос на удаление участника"
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/family/remove [post]
func (h *SubscriptionHandler) RemoveFamilyMember(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	var req RemoveFamilyMemberRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errInvalidRequestBody)
		return
	}

	memberID, err := domain.ParseID(req.MemberUserID)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errInvalidUserID)
		return
	}

	if err := h.subscriptionSvc.RemoveFamilyMember(r.Context(), userID, memberID); err != nil {
		h.log.Error("remove family member failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true, "message": "Family member removed"})
}

// StartTrialRequest запрос на начало пробного периода
type StartTrialRequest struct {
	PlanCode string `json:"plan_code" validate:"required"`
}

// StartTrial godoc
// @Summary Начать пробный период
// @Description Активирует 14-дневный пробный период Premium для нового пользователя
// @Tags subscriptions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body StartTrialRequest true "Запрос на начало пробного периода"
// @Success 200 {object} map[string]any
// @Router /api/v1/subscription/trial/start [post]
func (h *SubscriptionHandler) StartTrial(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errAuthRequired)
		return
	}

	var req StartTrialRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errInvalidRequestBody)
		return
	}

	if req.PlanCode == "" {
		req.PlanCode = "premium"
	}

	if err := h.subscriptionSvc.StartTrial(r.Context(), userID, req.PlanCode); err != nil {
		h.log.Error("start trial failed", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true, "message": "Trial period activated"})
}

// PaymentHandler обработчик webhook платежей
type PaymentHandler struct {
	paymentSvc *services.PaymentService
	log        *zap.Logger
}

// NewPaymentHandler создаёт новый обработчик платежей
func NewPaymentHandler(paymentSvc *services.PaymentService, log *zap.Logger) *PaymentHandler {
	return &PaymentHandler{
		paymentSvc: paymentSvc,
		log:        log,
	}
}

// RegisterWebhook регистрирует webhook маршруты
func (h *PaymentHandler) RegisterWebhook(r *mux.Router) {
	r.HandleFunc("/webhook/{provider}", h.Webhook).Methods(http.MethodPost)
}

// Webhook godoc
// @Summary Webhook от платежного провайдера
// @Description Обрабатывает уведомления от платежных систем (YooKassa, Stripe)
// @Tags payments
// @Accept json
// @Produce json
// @Param provider path string true "Платежный провайдер (yookassa, stripe)"
// @Success 200 {object} map[string]any
// @Router /api/v1/payment/webhook/{provider} [post]
func (h *PaymentHandler) Webhook(w http.ResponseWriter, r *http.Request) {
	provider := mux.Vars(r)["provider"]

	body := make([]byte, r.ContentLength)
	if _, err := r.Body.Read(body); err != nil && err.Error() != "EOF" {
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

// Ошибки handlers
var (
	errFailedToLoadPlans         = errInternal("failed to load plans")
	errFailedToLoadSubscription  = errInternal("failed to load subscription")
	errFailedToLoadTransactions  = errInternal("failed to load transactions")
	errFailedToLoadFamilyMembers = errInternal("failed to load family members")
	errFailedToReadBody          = errInternal("failed to read request body")
	errAuthRequired              = errClient("authentication required")
	errInvalidRequestBody        = errClient("invalid request body")
	errPlanCodeRequired          = errClient("plan_code is required")
	errInvalidBillingCycle       = errClient("billing_cycle must be monthly or yearly")
	errPromoCodeRequired         = errClient("promo code is required")
	errInvalidUserID             = errClient("invalid user_id")
	errNotImplemented            = errInternal("not implemented")
)

func errInternal(msg string) error {
	return &internalError{message: msg}
}

func errClient(msg string) error {
	return &clientError{message: msg}
}

type internalError struct{ message string }
func (e *internalError) Error() string { return e.message }

type clientError struct{ message string }
func (e *clientError) Error() string { return e.message }
