package middleware

import (
	"net/http"
	"strings"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

type SubscriptionLimiter struct {
	subscriptions *services.SubscriptionService
}

func NewSubscriptionLimiter(svc *services.SubscriptionService) *SubscriptionLimiter {
	return &SubscriptionLimiter{subscriptions: svc}
}

// EnforceRecommendationsLimit: ограничиваем только POST /api/v1/recommendations
func (l *SubscriptionLimiter) EnforceRecommendationsLimit() mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.Method != http.MethodPost {
				next.ServeHTTP(w, r)
				return
			}
			if normalizePath(r.URL.Path) != "/api/v1/recommendations" {
				next.ServeHTTP(w, r)
				return
			}

			userID, ok := GetUserIDFromContext(r.Context())
			if !ok {
				resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
				return
			}

			if err := l.subscriptions.CheckCanCreateRecommendation(r.Context(), userID); err != nil {
				if errors.Is(err, services.ErrRecommendationsLimitExceeded) {
					resp.Error(w, http.StatusPaymentRequired, err) // 402
					return
				}
				resp.Error(w, http.StatusInternalServerError, errors.New("subscription check failed"))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// EnforceWardrobeLimit: ограничиваем только POST /api/v1/wardrobe
func (l *SubscriptionLimiter) EnforceWardrobeLimit() mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.Method != http.MethodPost {
				next.ServeHTTP(w, r)
				return
			}
			if normalizePath(r.URL.Path) != "/api/v1/wardrobe" {
				next.ServeHTTP(w, r)
				return
			}

			userID, ok := GetUserIDFromContext(r.Context())
			if !ok {
				resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
				return
			}

			if err := l.subscriptions.CheckCanAddWardrobeItem(r.Context(), userID); err != nil {
				if errors.Is(err, services.ErrWardrobeLimitExceeded) {
					resp.Error(w, http.StatusPaymentRequired, err) // 402
					return
				}
				resp.Error(w, http.StatusInternalServerError, errors.New("subscription check failed"))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

func normalizePath(p string) string {
	if p == "" {
		return ""
	}
	if strings.HasSuffix(p, "/") {
		p = strings.TrimRight(p, "/")
		if p == "" {
			return "/"
		}
	}
	return p
}