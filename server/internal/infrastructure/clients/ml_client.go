package mlclient

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	"outfit-style-rec/contracts"
)

const (
	DefaultTimeout    = 800 * time.Millisecond
	MaxCandidates     = 250
	CircuitBreakerErrorThreshold = 20
	CircuitBreakerTimeout       = 30 * time.Second
	TimeBudgetThreshold         = 400 * time.Millisecond  // Если уже потрачено > этого времени, не дергаем ML
)

// State represents the state of the circuit breaker
type State int

const (
	Closed State = iota
	Open
	HalfOpen
)

// CircuitBreaker implements the circuit breaker pattern
type CircuitBreaker struct {
	maxErrors     int
	timeout       time.Duration
	state         State
	mutex         sync.RWMutex
	errorCount    int
	lastErrorTime time.Time
}

// NewCircuitBreaker creates a new circuit breaker
func NewCircuitBreaker(maxErrors int, timeout time.Duration) *CircuitBreaker {
	return &CircuitBreaker{
		maxErrors: maxErrors,
		timeout:   timeout,
		state:     Closed,
	}
}

// Call executes the function if the circuit is closed
func (cb *CircuitBreaker) Call(fn func() error) error {
	cb.mutex.Lock()
	defer cb.mutex.Unlock()

	switch cb.state {
	case Open:
		// Check if timeout has passed to move to HalfOpen
		if time.Since(cb.lastErrorTime) > cb.timeout {
			cb.state = HalfOpen
		} else {
			return fmt.Errorf("circuit breaker is open")
		}
	case HalfOpen:
		// In HalfOpen state, allow one request to test the circuit
		break
	}

	err := fn()
	if err != nil {
		cb.errorCount++
		cb.lastErrorTime = time.Now()
		if cb.errorCount >= cb.maxErrors {
			cb.state = Open
		}
		return err
	}

	// Success - reset the circuit
	cb.errorCount = 0
	cb.state = Closed
	return nil
}

// Client represents a client for the ML ranking service
type Client struct {
	baseURL         string
	httpClient      *http.Client
	circuitBreaker  *CircuitBreaker
}

// NewClient creates a new ML ranking client
func NewClient(baseURL string) *Client {
	return &Client{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: DefaultTimeout,
		},
		circuitBreaker: NewCircuitBreaker(CircuitBreakerErrorThreshold, CircuitBreakerTimeout),
	}
}

// RankCandidates sends candidates to the ML service for ranking
func (c *Client) RankCandidates(ctx context.Context, req *contracts.MLRankRequest, timeSpent time.Duration) (*contracts.MLRankResponse, error) {
	// Check time budget - if we've already spent too much time, don't call ML
	if timeSpent > TimeBudgetThreshold {
		return nil, fmt.Errorf("time budget exceeded: %v > %v", timeSpent, TimeBudgetThreshold)
	}

	// Validate request
	if len(req.Candidates) > MaxCandidates {
		return nil, fmt.Errorf("too many candidates: %d, maximum allowed: %d", len(req.Candidates), MaxCandidates)
	}

	// Marshal request to JSON
	jsonData, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create HTTP request
	url := fmt.Sprintf("%s/api/rank", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create HTTP request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	// Execute request via circuit breaker
	var mlResp *contracts.MLRankResponse
	cbErr := c.circuitBreaker.Call(func() error {
		resp, err := c.httpClient.Do(httpReq)
		if err != nil {
			return fmt.Errorf("failed to execute request: %w", err)
		}
		defer resp.Body.Close()

		// Read response body
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			return fmt.Errorf("failed to read response body: %w", err)
		}

		// Check status code
		if resp.StatusCode != http.StatusOK {
			return fmt.Errorf("ML service returned status %d: %s", resp.StatusCode, string(body))
		}

		// Unmarshal response
		mlResp = &contracts.MLRankResponse{}
		if err := json.Unmarshal(body, &mlResp); err != nil {
			return fmt.Errorf("failed to unmarshal response: %w", err)
		}

		return nil
	})

	return mlResp, cbErr
}

// RankCandidatesWithRetry attempts to rank candidates with retry logic and circuit breaker
func (c *Client) RankCandidatesWithRetry(ctx context.Context, req *contracts.MLRankRequest, maxRetries int, timeSpent time.Duration) (*contracts.MLRankResponse, error) {
	var lastErr error

	for i := 0; i <= maxRetries; i++ {
		resp, err := c.RankCandidates(ctx, req, timeSpent)
		if err == nil {
			return resp, nil
		}

		// Check if error is circuit breaker error - don't retry if circuit is open
		if err.Error() == "circuit breaker is open" {
			return nil, err
		}

		// Check if error is time budget error - don't retry if budget exceeded
		if err.Error() == fmt.Sprintf("time budget exceeded: %v > %v", timeSpent, TimeBudgetThreshold) {
			return nil, err
		}

		// Check if error is retryable (network-related, not business logic)
		if c.isRetryableError(err) {
			lastErr = err
			if i < maxRetries {
				// Exponential backoff: 10ms, 20ms, 40ms, etc.
				time.Sleep(time.Duration(10<<uint(i)) * time.Millisecond)
				continue
			}
		}

		// Non-retryable error or max retries reached
		return nil, err
	}

	return nil, lastErr
}

// isRetryableError determines if an error is worth retrying
func (c *Client) isRetryableError(err error) bool {
	// For now, consider network errors retryable
	// In a real implementation, you'd check for specific error types
	return true
}