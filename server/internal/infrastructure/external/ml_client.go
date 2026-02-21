package external

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/pkg/circuitbreaker"
)

type MLClient struct {
	baseURL string
	http    *http.Client
	cb      *circuitbreaker.CircuitBreaker
	logger  *zap.Logger

	// Настройки retry
	retryAttempts int
	retryDelayMs  int
}

type MLClientConfig struct {
	BaseURL       string
	Timeout       time.Duration
	RetryAttempts int
	RetryDelayMs  int
	Logger        *zap.Logger
}

func NewMLClient(baseURL string, timeout time.Duration) *MLClient {
	return NewMLClientWithConfig(MLClientConfig{
		BaseURL:       baseURL,
		Timeout:       timeout,
		RetryAttempts: 2,
		RetryDelayMs:  500,
		Logger:        nil,
	})
}

func NewMLClientWithConfig(cfg MLClientConfig) *MLClient {
	if cfg.Logger == nil {
		cfg.Logger = zap.NewNop()
	}

	// Create transport with connection pooling and keep-alive
	transport := &http.Transport{
		MaxIdleConns:        100,
		MaxIdleConnsPerHost: 10,
		IdleConnTimeout:     90 * time.Second,
		TLSHandshakeTimeout: 10 * time.Second,
	}

	// Circuit breaker для защиты от сбоев ML сервиса
	cb := circuitbreaker.New(circuitbreaker.Config{
		MaxFailures:       5,
		ResetTimeout:      30 * time.Second,
		Timeout:           cfg.Timeout,
		HalfOpenSuccesses: 3,
	})

	return &MLClient{
		baseURL: cfg.BaseURL,
		http: &http.Client{
			Timeout:   cfg.Timeout,
			Transport: transport,
		},
		cb:            cb,
		logger:        cfg.Logger,
		retryAttempts: cfg.RetryAttempts,
		retryDelayMs:  cfg.RetryDelayMs,
	}
}

// GetCircuitBreaker возвращает circuit breaker для мониторинга
func (c *MLClient) GetCircuitBreaker() *circuitbreaker.CircuitBreaker {
	return c.cb
}

// MLHealthResponse — ответ health endpoint ML сервиса
type MLHealthResponse struct {
	Status    string `json:"status"`
	Version   string `json:"version,omitempty"`
	ModelInfo string `json:"model_info,omitempty"`
}

func (c *MLClient) Rank(ctx context.Context, req TZMLRankRequest) (TZMLRankResponse, error) {
	var out TZMLRankResponse

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal rank request")
	}

	u := fmt.Sprintf("%s/api/v1/rank", c.baseURL)

	// Circuit breaker обёртка
	err = c.cb.Execute(ctx, func() error {
		var lastErr error

		for attempt := 0; attempt <= c.retryAttempts; attempt++ {
			// Логирование попытки
			if attempt > 0 {
				c.logger.Warn("ML rank retry",
					zap.Int("attempt", attempt+1),
					zap.Int("max_attempts", c.retryAttempts+1),
					zap.String("request_id", req.RequestID))
			}

			httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
			if err != nil {
				return errors.Wrap(err, "new request")
			}
			httpReq.Header.Set("Content-Type", "application/json")

			// Пробрасываем request_id в заголовке
			httpReq.Header.Set("X-Request-Id", req.RequestID)
			httpReq.Header.Set("X-User-Id", req.UserID.String())

			start := time.Now()
			res, err := c.http.Do(httpReq)
			latency := time.Since(start).Milliseconds()

			if err != nil {
				lastErr = errors.Wrap(err, "do request")
				c.logger.Error("ML rank request failed",
					zap.Error(lastErr),
					zap.Int("attempt", attempt+1),
					zap.String("request_id", req.RequestID))

				if attempt >= c.retryAttempts {
					return lastErr
				}
				// Экспоненциальная задержка перед retry
				delay := time.Duration(c.retryDelayMs*(1<<uint(attempt))) * time.Millisecond
				select {
				case <-ctx.Done():
					return ctx.Err()
				case <-time.After(delay):
					continue
				}
			}

			defer res.Body.Close()

			if res.StatusCode/100 != 2 {
				lastErr = errors.Errorf("ml bad status: %d", res.StatusCode)
				c.logger.Warn("ML rank bad status",
					zap.Int("status", res.StatusCode),
					zap.Int("attempt", attempt+1),
					zap.String("request_id", req.RequestID),
					zap.Int64("latency_ms", latency))

				if attempt >= c.retryAttempts {
					return lastErr
				}
				// Экспоненциальная задержка перед retry
				delay := time.Duration(c.retryDelayMs*(1<<uint(attempt))) * time.Millisecond
				select {
				case <-ctx.Done():
					return ctx.Err()
				case <-time.After(delay):
					continue
				}
			}

			if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
				return errors.Wrap(err, "decode response")
			}

			c.logger.Debug("ML rank success",
				zap.String("request_id", req.RequestID),
				zap.Int64("latency_ms", latency),
				zap.String("model_version", out.ModelVersion))
			return nil
		}
		return lastErr
	})

	return out, err
}

// ActionRequest представляет запрос для отправки действия пользователя
type ActionRequest struct {
	RequestID  string                 `json:"request_id"`
	UserID     string                 `json:"user_id"`
	ActionType string                 `json:"action_type"`
	EntityID   string                 `json:"entity_id"`
	EntityType string                 `json:"entity_type"`
	Meta       map[string]interface{} `json:"meta,omitempty"`
}

// ActionResponse представляет ответ от ML сервиса
type ActionResponse struct {
	Ok bool `json:"ok"`
}

// SendAction отправляет действие пользователя в ML сервис
func (c *MLClient) SendAction(ctx context.Context, req ActionRequest) (ActionResponse, error) {
	var out ActionResponse

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal action request")
	}

	u := fmt.Sprintf("%s/api/action", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	// Устанавливаем заголовки для отслеживания
	httpReq.Header.Set("X-Request-Id", req.RequestID)
	httpReq.Header.Set("X-User-Id", req.UserID)

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("ml action bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode action response")
	}
	return out, nil
}

// HealthCheckResult — результат проверки здоровья ML сервиса
type HealthCheckResult struct {
	Healthy   bool   `json:"healthy"`
	Status    string `json:"status,omitempty"`
	Version   string `json:"version,omitempty"`
	ModelInfo string `json:"model_info,omitempty"`
	LatencyMs int64  `json:"latency_ms,omitempty"`
	Error     string `json:"error,omitempty"`
}

// HealthCheck выполняет проверку здоровья ML сервиса
// Возвращает расширенную информацию о статусе
func (c *MLClient) HealthCheck(ctx context.Context) HealthCheckResult {
	result := HealthCheckResult{
		Healthy: false,
		Status:  "unknown",
	}

	u := fmt.Sprintf("%s/health", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		result.Error = err.Error()
		return result
	}

	start := time.Now()
	res, err := c.http.Do(httpReq)
	result.LatencyMs = time.Since(start).Milliseconds()

	if err != nil {
		result.Error = err.Error()
		result.Status = "unreachable"
		c.logger.Debug("ML health check failed", zap.Error(err))
		return result
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		result.Error = fmt.Sprintf("status %d", res.StatusCode)
		result.Status = "unhealthy"
		return result
	}

	// Пытаемся распарсить ответ
	var healthResp MLHealthResponse
	if err := json.NewDecoder(res.Body).Decode(&healthResp); err == nil {
		result.Status = healthResp.Status
		result.Version = healthResp.Version
		result.ModelInfo = healthResp.ModelInfo
	} else {
		result.Status = "healthy"
	}

	result.Healthy = true
	c.logger.Debug("ML health check passed",
		zap.String("status", result.Status),
		zap.Int64("latency_ms", result.LatencyMs))

	return result
}

// IsHealthy выполняет быструю проверку здоровья (только статус код)
func (c *MLClient) IsHealthy(ctx context.Context) bool {
	u := fmt.Sprintf("%s/health", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return false
	}

	res, err := c.http.Do(httpReq)
	if err != nil {
		return false
	}
	defer res.Body.Close()

	return res.StatusCode >= 200 && res.StatusCode < 300
}

// GenerateOutfitRequest структура запроса для генерации наряда
type GenerateOutfitRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// GenerateOutfitResponse структура ответа для генерации наряда
type GenerateOutfitResponse struct {
	Success bool `json:"success"`
}

// GenerateOutfit вызывает ML-сервис для генерации наряда
func (c *MLClient) GenerateOutfit(ctx context.Context, userID string, meta map[string]interface{}) (GenerateOutfitResponse, error) {
	var out GenerateOutfitResponse

	req := GenerateOutfitRequest{
		RequestID: "req-" + userID, // В реальной системе это будет нормальный request ID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal generate outfit request")
	}

	u := fmt.Sprintf("%s/api/v1/outfit/generate", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("generate outfit bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode generate outfit response")
	}
	return out, nil
}

// GenerateRecommendationRequest структура запроса для генерации рекомендации
type GenerateRecommendationRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// GenerateRecommendationResponse структура ответа для генерации рекомендации
type GenerateRecommendationResponse struct {
	Success bool `json:"success"`
}

// GenerateRecommendation вызывает ML-сервис для генерации рекомендации
func (c *MLClient) GenerateRecommendation(ctx context.Context, userID string, meta map[string]interface{}) (GenerateRecommendationResponse, error) {
	var out GenerateRecommendationResponse

	req := GenerateRecommendationRequest{
		RequestID: "req-" + userID, // В реальной системе это будет нормальный request ID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal generate recommendation request")
	}

	u := fmt.Sprintf("%s/api/v1/recommendation/generate", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("generate recommendation bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode generate recommendation response")
	}
	return out, nil
}

// ProcessFeedbackRequest структура запроса для обработки обратной связи
type ProcessFeedbackRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// ProcessFeedbackResponse структура ответа для обработки обратной связи
type ProcessFeedbackResponse struct {
	Success bool `json:"success"`
}

// ProcessFeedback вызывает ML-сервис для обработки обратной связи
func (c *MLClient) ProcessFeedback(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error {
	req := ProcessFeedbackRequest{
		RequestID: requestID, // Используем переданный requestID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return errors.Wrap(err, "marshal process feedback request")
	}

	u := fmt.Sprintf("%s/api/v1/feedback/process", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return errors.Errorf("process feedback bad status: %d", res.StatusCode)
	}

	return nil
}

// UpdateUserPreferencesRequest структура запроса для обновления пользовательских предпочтений
type UpdateUserPreferencesRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// UpdateUserPreferencesResponse структура ответа для обновления пользовательских предпочтений
type UpdateUserPreferencesResponse struct {
	Success bool `json:"success"`
}

// UpdateUserPreferences вызывает ML-сервис для обновления пользовательских предпочтений
func (c *MLClient) UpdateUserPreferences(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error {
	req := UpdateUserPreferencesRequest{
		RequestID: requestID, // Используем переданный requestID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return errors.Wrap(err, "marshal update user preferences request")
	}

	u := fmt.Sprintf("%s/api/v1/preferences/update", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return errors.Errorf("update user preferences bad status: %d", res.StatusCode)
	}

	return nil
}
