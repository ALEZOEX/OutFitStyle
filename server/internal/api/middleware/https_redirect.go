package middleware

import (
	"net/http"
	"strings"

	"github.com/gorilla/mux"
)

// HTTPSRedirectMiddleware redirects all HTTP requests to HTTPS
// Allows HTTP only in local development environment
func HTTPSRedirectMiddleware(environment string) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Allow HTTP in local development
			if environment == "development" || environment == "local" {
				next.ServeHTTP(w, r)
				return
			}

			// Skip redirect for health checks and metrics (used by k8s probes)
			if r.URL.Path == "/health" || r.URL.Path == "/metrics" || r.URL.Path == "/swagger/" {
				next.ServeHTTP(w, r)
				return
			}

			// Check if request is already HTTPS
			// Check X-Forwarded-Proto header (for reverse proxies/load balancers)
			proto := r.Header.Get("X-Forwarded-Proto")
			if proto == "" {
				// Fallback to request scheme
				if r.TLS != nil {
					proto = "https"
				} else {
					proto = "http"
				}
			}

			// Redirect HTTP to HTTPS
			if proto == "http" {
				// Build HTTPS URL
				host := r.Host
				if host == "" {
					host = r.URL.Host
				}

				// Remove port if it's the default HTTP port
				host = strings.TrimSuffix(host, ":80")

				// Use URL.Path and URL.RawQuery to build the redirect URL
				path := r.URL.Path
				if r.URL.RawQuery != "" {
					path += "?" + r.URL.RawQuery
				}

				httpsURL := "https://" + host + path

				// 301 Moved Permanently - tells clients to always use HTTPS
				http.Redirect(w, r, httpsURL, http.StatusMovedPermanently)
				return
			}

			// Request is already HTTPS, continue
			next.ServeHTTP(w, r)
		})
	}
}
