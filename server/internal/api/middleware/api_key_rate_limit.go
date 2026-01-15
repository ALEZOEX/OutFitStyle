package middleware

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	resp "outfitstyle/server/internal/pkg/http"
)

func APIKeyRateLimitMiddleware(limiter *RateLimiter) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			meta, ok := GetAPIKeyMetaFromContext(r.Context())
			if !ok {
				next.ServeHTTP(w, r)
				return
			}

			key := "apikey:" + meta.APIKeyID.String()

			// per-minute
			minLimit := meta.RateLimitPerMinute
			if minLimit <= 0 {
				minLimit = 60
			}
			ok1, cur1, rem1, reset1, _ := limiter.AllowWithCurrent(r.Context(), key+":m", minLimit, time.Minute)
			w.Header().Set("X-APIKey-RateLimit-Limit", fmt.Sprintf("%d", minLimit))
			w.Header().Set("X-APIKey-RateLimit-Remaining", fmt.Sprintf("%d", rem1))
			w.Header().Set("X-APIKey-RateLimit-Reset", fmt.Sprintf("%d", reset1))

			if !ok1 {
				if limiter != nil && limiter.violations != nil {
					_ = limiter.violations.Record(r.Context(), repositories.RateLimitViolation{
						Identifier:     meta.APIKeyID.String(),
						IdentifierType: "apikey",
						Endpoint:       routeTemplateOrPath(r),
						LimitType:      "apikey_per_minute",
						LimitValue:     minLimit,
						CurrentValue:   cur1,
					})
				}
				resp.Error(w, http.StatusTooManyRequests, errors.New("api key rate limit exceeded (per-minute)"))
				return
			}

			// per-day
			dayLimit := meta.RateLimitPerDay
			if dayLimit <= 0 {
				dayLimit = 10000
			}
			ok2, cur2, rem2, reset2, _ := limiter.AllowWithCurrent(r.Context(), key+":d", dayLimit, 24*time.Hour)
			w.Header().Set("X-APIKey-RateLimit-Limit-Day", fmt.Sprintf("%d", dayLimit))
			w.Header().Set("X-APIKey-RateLimit-Remaining-Day", fmt.Sprintf("%d", rem2))
			w.Header().Set("X-APIKey-RateLimit-Reset-Day", fmt.Sprintf("%d", reset2))

			if !ok2 {
				if limiter != nil && limiter.violations != nil {
					_ = limiter.violations.Record(r.Context(), repositories.RateLimitViolation{
						Identifier:     meta.APIKeyID.String(),
						IdentifierType: "apikey",
						Endpoint:       routeTemplateOrPath(r),
						LimitType:      "apikey_per_day",
						LimitValue:     dayLimit,
						CurrentValue:   cur2,
					})
				}
				resp.Error(w, http.StatusTooManyRequests, errors.New("api key rate limit exceeded (per-day)"))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
