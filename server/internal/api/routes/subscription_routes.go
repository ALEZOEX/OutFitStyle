// Пакет routes содержит функции регистрации маршрутов для API подписок и платежей
package routes

import (
	"github.com/gorilla/mux"

	"outfitstyle/server/internal/api/handlers"
)

// RegisterSubscriptionRoutes регистрирует маршруты для API подписок
// Публичные: /api/v1/subscription/plans
// Защищённые: /api/v1/subscription/current, /subscribe, /cancel, /upgrade, /promo, /transactions, /family/*
func RegisterSubscriptionRoutes(router *mux.Router, subscriptionHandler *handlers.SubscriptionHandler) {
	subscription := router.PathPrefix("/api/v1/subscription").Subrouter()

	// Публичные маршруты
	public := subscription.PathPrefix("").Subrouter()
	public.HandleFunc("/plans", subscriptionHandler.ListPlans).Methods("GET")

	// Для защищённых маршрутов требуется middleware аутентификации
	// Вызывается из основного middleware stack
}

// RegisterSubscriptionProtectedRoutes регистрирует защищённые маршруты подписок
// Должен вызываться после применения AuthMiddleware
func RegisterSubscriptionProtectedRoutes(router *mux.Router, subscriptionHandler *handlers.SubscriptionHandler) {
	subscription := router.PathPrefix("/api/v1/subscription").Subrouter()

	subscription.HandleFunc("/current", subscriptionHandler.GetCurrent).Methods("GET")
	subscription.HandleFunc("/subscribe", subscriptionHandler.Subscribe).Methods("POST")
	subscription.HandleFunc("/cancel", subscriptionHandler.Cancel).Methods("POST")
	subscription.HandleFunc("/upgrade", subscriptionHandler.Upgrade).Methods("POST")
	subscription.HandleFunc("/promo", subscriptionHandler.ApplyPromoCode).Methods("POST")
	subscription.HandleFunc("/transactions", subscriptionHandler.GetTransactions).Methods("GET")
	subscription.HandleFunc("/family", subscriptionHandler.GetFamilyMembers).Methods("GET")
	subscription.HandleFunc("/family/invite", subscriptionHandler.AddFamilyMember).Methods("POST")
	subscription.HandleFunc("/family/accept", subscriptionHandler.AcceptFamilyInvitation).Methods("POST")
	subscription.HandleFunc("/family/remove", subscriptionHandler.RemoveFamilyMember).Methods("POST")
	subscription.HandleFunc("/trial/start", subscriptionHandler.StartTrial).Methods("POST")
}

// RegisterPaymentRoutes регистрирует маршруты для API платежей
func RegisterPaymentRoutes(router *mux.Router, paymentHandler *handlers.PaymentHandler) {
	payment := router.PathPrefix("/api/v1/payment").Subrouter()

	// Webhook маршруты (без аутентификации, но с проверкой подписи)
	payment.HandleFunc("/webhook/{provider}", paymentHandler.Webhook).Methods("POST")
}

// RegisterBillingRoutes регистрирует маршруты для API биллинга
func RegisterBillingRoutes(router *mux.Router, billingHandler *handlers.BillingHandler) {
	billing := router.PathPrefix("/api/v1/billing").Subrouter()

	// Webhook маршруты
	billing.HandleFunc("/webhook/{provider}", billingHandler.Webhook).Methods("POST")

	// Защищённые маршруты (требуют admin прав)
	// billing.HandleFunc("/refund", billingHandler.Refund).Methods("POST")
	// billing.HandleFunc("/payments", billingHandler.GetPayments).Methods("GET")
}
