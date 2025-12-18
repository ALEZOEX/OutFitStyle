package middleware

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
)

var (
	httpInFlight = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "http_in_flight_requests",
		Help: "Current number of in-flight HTTP requests.",
	})

	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests.",
		},
		[]string{"method", "route", "status"},
	)

	httpRequestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request latency in seconds.",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "route"},
	)
)

func init() {
	prometheus.MustRegister(httpInFlight, httpRequestsTotal, httpRequestDuration)
}

type metricsRW struct {
	http.ResponseWriter
	status int
}

func (w *metricsRW) WriteHeader(code int) {
	w.status = code
	w.ResponseWriter.WriteHeader(code)
}

func MetricsMiddleware() mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			httpInFlight.Inc()
			defer httpInFlight.Dec()

			start := time.Now()
			mw := &metricsRW{ResponseWriter: w, status: http.StatusOK}

			next.ServeHTTP(mw, r)

			route := routeTemplateOrPath(r)
			status := strconv.Itoa(mw.status)

			httpRequestsTotal.WithLabelValues(r.Method, route, status).Inc()
			httpRequestDuration.WithLabelValues(r.Method, route).Observe(time.Since(start).Seconds())
		})
	}
}

// Helper function to get route template or path
func routeTemplateOrPath(r *http.Request) string {
	route := mux.CurrentRoute(r)
	if route != nil {
		if tmpl, err := route.GetPathTemplate(); err == nil {
			return tmpl
		}
	}
	return r.URL.Path
}