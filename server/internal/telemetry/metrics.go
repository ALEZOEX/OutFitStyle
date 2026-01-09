package telemetry

import (
	"net/http"
	"strconv"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// HTTP request metrics
	requestCount = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	requestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request duration in seconds",
			Buckets: []float64{0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10},
		},
		[]string{"method", "endpoint", "status"},
	)

	// Business metrics
	recommendationsGenerated = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "recommendations_generated_total",
			Help: "Total number of recommendations generated",
		},
		[]string{"occasion", "weather_condition"},
	)

	recommendationsAccepted = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "recommendations_accepted_total",
			Help: "Total number of recommendations accepted by users",
		},
	)

	recommendationsRejected = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "recommendations_rejected_total",
			Help: "Total number of recommendations rejected by users",
		},
	)

	// ML service metrics
	mlInferenceDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "ml_inference_duration_seconds",
			Help:    "ML model inference duration in seconds",
			Buckets: []float64{0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5},
		},
		[]string{"model_version"},
	)

	weatherAPICalls = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "weather_api_calls_total",
			Help: "Total number of calls to weather API",
		},
	)
)

func init() {
	prometheus.MustRegister(requestCount)
	prometheus.MustRegister(requestDuration)
	prometheus.MustRegister(recommendationsGenerated)
	prometheus.MustRegister(recommendationsAccepted)
	prometheus.MustRegister(recommendationsRejected)
	prometheus.MustRegister(mlInferenceDuration)
	prometheus.MustRegister(weatherAPICalls)
}

// HTTPMiddleware returns a middleware that instruments HTTP requests
func HTTPMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		
		// Wrap response writer to capture status code
		wrapped := &responseWriter{ResponseWriter: w, statusCode: 200}
		
		next.ServeHTTP(wrapped, r)
		
		duration := time.Since(start).Seconds()
		
		requestCount.WithLabelValues(
			r.Method,
			r.URL.Path,
			strconv.Itoa(wrapped.statusCode),
		).Inc()
		
		requestDuration.WithLabelValues(
			r.Method,
			r.URL.Path,
			strconv.Itoa(wrapped.statusCode),
		).Observe(duration)
	})
}

// responseWriter wraps http.ResponseWriter to capture status code
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

// Business metric functions
func RecordRecommendationGenerated(occasion, weatherCondition string) {
	recommendationsGenerated.WithLabelValues(occasion, weatherCondition).Inc()
}

func RecordRecommendationAccepted() {
	recommendationsAccepted.Inc()
}

func RecordRecommendationRejected() {
	recommendationsRejected.Inc()
}

func RecordMLInferenceDuration(duration time.Duration, modelVersion string) {
	mlInferenceDuration.WithLabelValues(modelVersion).Observe(duration.Seconds())
}

func RecordWeatherAPICall() {
	weatherAPICalls.Inc()
}

// MetricsHandler returns the Prometheus metrics endpoint
func MetricsHandler() http.Handler {
	return promhttp.Handler()
}