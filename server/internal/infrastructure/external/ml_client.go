package external

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/sony/gobreaker"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

// MLService отвечает за общение с ML-сервисом рекомендаций.
type MLService struct {
	baseURL        string
	client         *http.Client
	circuitBreaker *gobreaker.CircuitBreaker
	logger         *zap.Logger
}

// MLRecommendationRequest – DTO-запрос к ML-сервису.
type MLRecommendationRequest struct {
	UserID  int                `json:"user_id"`
	Weather domain.WeatherData `json:"weather"`
}

// MLRecommendationResponse – DTO-ответ от ML-сервиса.
type MLRecommendationResponse struct {
	Recommendations []domain.ClothingItem `json:"recommendations"`
	OutfitScore     float64               `json:"outfit_score"`
	Algorithm       string                `json:"algorithm"`
}

// NewMLService создаёт клиент ML-сервиса.
// Сигнатура оставлена такой же, как у тебя, чтобы не ломать вызовы в main.go.
func NewMLService(baseURL string, logger *zap.Logger) *MLService {
	if logger == nil {
		logger = zap.NewNop()
	}

	cb := gobreaker.NewCircuitBreaker(gobreaker.Settings{
		Name:        "MLService",
		MaxRequests: 3,
		Interval:    30 * time.Second,
		Timeout:     5 * time.Minute,
		ReadyToTrip: func(counts gobreaker.Counts) bool {
			return counts.ConsecutiveFailures > 2
		},
		OnStateChange: func(name string, from gobreaker.State, to gobreaker.State) {
			logger.Info("circuit breaker state changed",
				zap.String("name", name),
				zap.String("from", from.String()),
				zap.String("to", to.String()))
		},
	})

	return &MLService{
		baseURL: baseURL,
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
		circuitBreaker: cb,
		logger:         logger,
	}
}

// GetRecommendations запрашивает рекомендации у ML-сервиса.
// Контракт оставлен как в твоём коде: (ctx, userID int, weather domain.WeatherData) -> *domain.RecommendationResponse.
func (s *MLService) GetRecommendations(
	ctx context.Context,
	userID int,
	weather domain.WeatherData,
) (*domain.RecommendationResponse, error) {

	reqPayload := MLRecommendationRequest{
		UserID:  userID,
		Weather: weather,
	}

	jsonData, err := json.Marshal(reqPayload)
	if err != nil {
		return nil, fmt.Errorf("ml: failed to marshal request: %w", err)
	}

	var mlResp MLRecommendationResponse

	// Выполняем запрос с circuit breaker и экспоненциальным backoff.
	if err := s.doWithCircuitBreaker(func() error {
		return s.doRequest(ctx, "/api/ml/recommend", http.MethodPost, jsonData, &mlResp)
	}); err != nil {
		return nil, fmt.Errorf("ml: request failed: %w", err)
	}

	// Маппим DTO в доменную модель.
	rec := &domain.RecommendationResponse{
		// ID заполняется ниже по слою (БД), здесь его нет.
		UserID:         domain.ID(userID),
		Location:       weather.Location,
		Temperature:    weather.Temperature,
		FeelsLike:      weather.FeelsLike,
		Weather:        weather.Weather,
		Humidity:       weather.Humidity,
		WindSpeed:      weather.WindSpeed,
		MinTemp:        weather.MinTemp,
		MaxTemp:        weather.MaxTemp,
		WillRain:       weather.WillRain,
		WillSnow:       weather.WillSnow,
		HourlyForecast: weather.HourlyForecast,
		Items:          mlResp.Recommendations,
		OutfitScore:    mlResp.OutfitScore,
		MLPowered:      true,
		Algorithm:      mlResp.Algorithm,
		Timestamp:      time.Now(),
	}

	return rec, nil
}

// HealthCheck реализует интерфейс health.Checker.
func (s *MLService) HealthCheck() error {
	if s.baseURL == "" {
		return fmt.Errorf("ml service base url is empty")
	}
	// Здесь можно сделать лёгкий ping /health, если он есть в ML-сервисе.
	return nil
}

// doWithCircuitBreaker оборачивает операцию в circuit breaker + backoff.
func (s *MLService) doWithCircuitBreaker(operation func() error) error {
	_, err := s.circuitBreaker.Execute(func() (interface{}, error) {
		bo := backoff.NewExponentialBackOff()
		bo.MaxElapsedTime = 60 * time.Second
		return nil, backoff.Retry(operation, backoff.WithMaxRetries(bo, 3))
	})
	return err
}

// doRequest выполняет HTTP-запрос к ML-сервису и декодирует ответ в result.
func (s *MLService) doRequest(
	ctx context.Context,
	endpoint, method string,
	body []byte,
	result interface{},
) error {
	url := s.baseURL + endpoint

	req, err := http.NewRequestWithContext(ctx, method, url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("ml: failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	// TODO: брать API-ключ из конфига, а не хардкодить.
	// req.Header.Set("X-API-Key", s.apiKey)
	req.Header.Set("User-Agent", "OutfitStyle-Backend/1.0")

	s.logger.Debug("ml request",
		zap.String("url", url),
		zap.String("method", method))

	start := time.Now()
	resp, err := s.client.Do(req)
	latency := time.Since(start)

	s.logger.Debug("ml response",
		zap.Duration("latency", latency),
		zap.Error(err))

	if err != nil {
		return fmt.Errorf("ml: request error: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("ml: status %d, body: %s", resp.StatusCode, string(bodyBytes))
	}

	if result != nil {
		if err := json.NewDecoder(resp.Body).Decode(result); err != nil {
			return fmt.Errorf("ml: failed to decode response: %w", err)
		}
	}

	return nil
}
