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
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

type MLService struct {
	baseURL        string
	client         *http.Client
	circuitBreaker *gobreaker.CircuitBreaker
	logger         *zap.Logger
}

type MLRecommendationRequest struct {
	UserID  int              `json:"user_id"`
	Weather domain.WeatherData `json:"weather"`
}

type MLRecommendationResponse struct {
	Recommendations []domain.ClothingItem `json:"recommendations"`
	OutfitScore     float64              `json:"outfit_score"`
	Algorithm       string               `json:"algorithm"`
}

func NewMLService(baseURL string, logger *zap.Logger) *MLService {
	// Configure circuit breaker
	cb := gobreaker.NewCircuitBreaker(gobreaker.Settings{
		Name:          "MLService",
		MaxRequests:   3,
		Interval:      30 * time.Second,
		Timeout:       5 * time.Minute,
		ReadyToTrip: func(counts gobreaker.Counts) bool {
			return counts.ConsecutiveFailures > 2
		},
		OnStateChange: func(name string, from gobreaker.State, to gobreaker.State) {
			logger.Info("Circuit breaker state changed",
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

func (s *MLService) GetRecommendations(ctx context.Context, userID int, weather *domain.WeatherData) (*domain.RecommendationResponse, error) {
	// Create request data
	requestData := MLRecommendationRequest{
		UserID:  userID,
		Weather: *weather,
	}
	
	// Marshal to JSON
	jsonData, err := json.Marshal(requestData)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request  %w", err)
	}

	// Execute request with circuit breaker and retries
	var resp MLRecommendationResponse
	err = s.doWithCircuitBreaker(func() error {
		return s.doRequest(ctx, "/api/ml/recommend", "POST", jsonData, &resp)
	})

	if err != nil {
		return nil, fmt.Errorf("ML service request failed: %w", err)
	}

	// Calculate outfit score
	outfitScore := resp.OutfitScore

	// Create response
	return &domain.RecommendationResponse{
		UserID:          userID,
		Location:        weather.Location,
		Temperature:     weather.Temperature,
		Weather:         weather.Weather,
		Recommendations: resp.Recommendations,
		MLPowered:       true,
		OutfitScore:     &outfitScore,
		Algorithm:       resp.Algorithm,
		Timestamp:       time.Now(),
	}, nil
}

func (s *MLService) HealthCheck(ctx context.Context) error {
	return s.doWithCircuitBreaker(func() error {
		return s.doRequest(ctx, "/health", "GET", nil, nil)
	})
}

func (s *MLService) doWithCircuitBreaker(operation func() error) error {
	return s.circuitBreaker.Execute(func() (interface{}, error) {
		b := backoff.WithMaxRetries(backoff.NewExponentialBackOff(), 3)
		b.MaxElapsedTime = 60 * time.Second
		return nil, backoff.Retry(operation, b)
	})
}

func (s *MLService) doRequest(ctx context.Context, endpoint, method string, body []byte, result interface{}) error {
	// Build URL
	url := s.baseURL + endpoint
	
	// Create request
	req, err := http.NewRequestWithContext(ctx, method, url, bytes.NewBuffer(body))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", "your_secure_api_key_here") // TODO: Get from config
	req.Header.Set("User-Agent", "OutfitStyle-Backend/1.0")

	// Log request
	s.logger.Debug("Making ML service request",
		zap.String("url", url),
		zap.String("method", method))

	// Execute request
	start := time.Now()
	resp, err := s.client.Do(req)
	duration := time.Since(start)
	
	// Log response
	s.logger.Debug("ML service request completed",
		zap.Duration("duration", duration),
		zap.Error(err))

	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	// Check response status
	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("ML service returned status %d: %s", resp.StatusCode, string(bodyBytes))
	}

	// Parse response
	if result != nil {
		if err := json.NewDecoder(resp.Body).Decode(result); err != nil {
			return fmt.Errorf("failed to decode response: %w", err)
		}
	}

	return nil
}