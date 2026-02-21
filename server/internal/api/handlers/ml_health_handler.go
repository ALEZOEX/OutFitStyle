package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/cache"
	"outfitstyle/server/internal/infrastructure/external"
	resp "outfitstyle/server/internal/pkg/http"
)

// MLHealthHandler обработчик health check для ML сервиса
type MLHealthHandler struct {
	mlClient *external.MLClient
	cache    *cache.RecommendationCache
	logger   *zap.Logger

	// Кэширование последнего статуса в памяти
	lastStatus     *MLHealthStatus
	lastStatusTime time.Time
	mu             sync.RWMutex
	cacheTTL       time.Duration
}

// MLHealthStatus статус ML сервиса
type MLHealthStatus struct {
	Healthy      bool   `json:"healthy"`
	Status       string `json:"status,omitempty"`
	Version      string `json:"version,omitempty"`
	ModelInfo    string `json:"model_info,omitempty"`
	LatencyMs    int64  `json:"latency_ms,omitempty"`
	Cached       bool   `json:"cached,omitempty"`
	LastCheck    string `json:"last_check,omitempty"`
	FallbackUsed bool   `json:"fallback_used,omitempty"`
}

// NewMLHealthHandler создает новый обработчик health check
func NewMLHealthHandler(
	mlClient *external.MLClient,
	recCache *cache.RecommendationCache,
	logger *zap.Logger,
	cacheTTL time.Duration,
) *MLHealthHandler {
	return &MLHealthHandler{
		mlClient: mlClient,
		cache:    recCache,
		logger:   logger,
		cacheTTL: cacheTTL,
	}
}

// RegisterRoutes регистрирует маршруты
func (h *MLHealthHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.GetHealth).Methods(http.MethodGet)
}

// GetHealth возвращает статус здоровья ML сервиса
// GET /api/v1/ml/health
func (h *MLHealthHandler) GetHealth(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Проверяем кэш в памяти
	h.mu.RLock()
	if h.lastStatus != nil && time.Since(h.lastStatusTime) < h.cacheTTL {
		status := *h.lastStatus
		status.Cached = true
		h.mu.RUnlock()

		h.logger.Debug("ML health status from memory cache",
			zap.Bool("healthy", status.Healthy),
			zap.Bool("cached", status.Cached))

		resp.JSONResponse(w, http.StatusOK, status)
		return
	}
	h.mu.RUnlock()

	// Проверяем Redis кэш
	if h.cache != nil {
		cachedStatus, err := h.cache.GetMLHealthStatus(ctx)
		if err == nil && cachedStatus != nil {
			// Проверяем актуальность
			if time.Since(cachedStatus.CheckedAt) < h.cacheTTL {
				status := MLHealthStatus{
					Healthy:      cachedStatus.Healthy,
					LatencyMs:    int64(cachedStatus.LatencyMs),
					Cached:       true,
					LastCheck:    cachedStatus.CheckedAt.Format(time.RFC3339),
					FallbackUsed: !cachedStatus.Healthy,
				}

				h.logger.Debug("ML health status from Redis cache",
					zap.Bool("healthy", status.Healthy),
					zap.Bool("cached", status.Cached))

				resp.JSONResponse(w, http.StatusOK, status)
				return
			}
		}
	}

	// Выполняем реальную проверку
	start := time.Now()
	healthResult := h.mlClient.HealthCheck(ctx)
	latency := time.Since(start).Milliseconds()

	status := MLHealthStatus{
		Healthy:      healthResult.Healthy,
		Status:       healthResult.Status,
		Version:      healthResult.Version,
		ModelInfo:    healthResult.ModelInfo,
		LatencyMs:    healthResult.LatencyMs,
		Cached:       false,
		LastCheck:    start.Format(time.RFC3339),
		FallbackUsed: !healthResult.Healthy,
	}

	// Если ML недоступен, но у нас есть fallback
	if !healthResult.Healthy {
		status.Status = "degraded"
		status.ModelInfo = "fallback-v2 available"
		h.logger.Info("ML service unavailable — fallback mode active",
			zap.String("error", healthResult.Error),
			zap.Int64("latency_ms", latency))
	}

	// Сохраняем в кэш памяти
	h.mu.Lock()
	h.lastStatus = &status
	h.lastStatusTime = time.Now()
	h.mu.Unlock()

	// Сохраняем в Redis кэш
	if h.cache != nil {
		cacheStatus := cache.MLHealthStatus{
			Healthy:   healthResult.Healthy,
			CheckedAt: start,
			LatencyMs: int(latency),
		}
		if !healthResult.Healthy {
			cacheStatus.Error = healthResult.Error
		}
		if err := h.cache.SetMLHealthStatus(ctx, cacheStatus); err != nil {
			h.logger.Warn("Failed to cache ML health status", zap.Error(err))
		}
	}

	h.logger.Debug("ML health check completed",
		zap.Bool("healthy", status.Healthy),
		zap.Int64("latency_ms", latency),
		zap.Bool("cached", status.Cached))

	resp.JSONResponse(w, http.StatusOK, status)
}

// GetHealthDetailed возвращает расширенную информацию о здоровье ML сервиса
// GET /api/v1/ml/health/detailed
func (h *MLHealthHandler) GetHealthDetailed(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Выполняем реальную проверку без кэширования
	start := time.Now()
	healthResult := h.mlClient.HealthCheck(ctx)

	// Получаем статус circuit breaker
	cb := h.mlClient.GetCircuitBreaker()
	cbState := "closed"
	if cb != nil {
		switch cb.State() {
		case 0:
			cbState = "closed"
		case 1:
			cbState = "open"
		case 2:
			cbState = "half-open"
		}
	}

	status := map[string]interface{}{
		"healthy":        healthResult.Healthy,
		"status":         healthResult.Status,
		"version":        healthResult.Version,
		"model_info":     healthResult.ModelInfo,
		"latency_ms":     healthResult.LatencyMs,
		"error":          healthResult.Error,
		"circuit_breaker": cbState,
		"checked_at":     start.Format(time.RFC3339),
		"fallback_available": true,
		"fallback_version":   "fallback-v2",
	}

	if !healthResult.Healthy {
		status["status"] = "degraded"
		status["fallback_active"] = true
	}

	resp.JSONResponse(w, http.StatusOK, status)
}
