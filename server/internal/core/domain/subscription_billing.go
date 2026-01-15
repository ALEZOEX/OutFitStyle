package domain

type SubscribeRequest struct {
	PlanCode        string `json:"plan_code"`
	BillingCycle    string `json:"billing_cycle"`    // monthly|yearly
	PaymentProvider string `json:"payment_provider"` // dummy, stripe, yookassa

	PaymentMethodID *string `json:"payment_method_id,omitempty"`
	PromoCode       *string `json:"promo_code,omitempty"`
}

type SubscribeResponse struct {
	Subscription UserSubscription `json:"subscription"`
	PaymentURL   *string          `json:"payment_url,omitempty"`
	ClientSecret *string          `json:"client_secret,omitempty"`
}

type CancelSubscriptionRequest struct {
	Reason    *string `json:"reason,omitempty"`
	Feedback  *string `json:"feedback,omitempty"`
	Immediate *bool   `json:"immediate,omitempty"`
}

type PromoRequest struct {
	Code string `json:"code"`
}

type PromoResponse struct {
	Promo map[string]any `json:"promo"`
}
