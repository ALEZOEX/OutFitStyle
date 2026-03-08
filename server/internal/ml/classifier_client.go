package ml

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// ClassifierClient defines the interface for ML classification service
type ClassifierClient interface {
	// ClassifyItem predicts category for a clothing item
	ClassifyItem(ctx context.Context, req *ClassifyRequest) (*ClassifyResponse, error)

	// HealthCheck verifies ML service availability
	HealthCheck(ctx context.Context) error
}

// ClassifyRequest represents the request payload for classification
type ClassifyRequest struct {
	Name        string   `json:"name"`
	Subcategory string   `json:"subcategory"`
	Materials   []string `json:"materials"`
	Style       string   `json:"style"`
}

// ClassifyResponse represents the response from the ML service
type ClassifyResponse struct {
	Category   string  `json:"category"`
	Confidence float64 `json:"confidence"`
}

// httpClassifierClient is the HTTP implementation of ClassifierClient
type httpClassifierClient struct {
	baseURL    string
	httpClient *http.Client
}

// NewClassifierClient creates a new ML classifier client
func NewClassifierClient(baseURL string) ClassifierClient {
	return &httpClassifierClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 50 * time.Millisecond, // Requirement 8.2: 50ms timeout
		},
	}
}

// ClassifyItem sends a classification request to the ML service
func (c *httpClassifierClient) ClassifyItem(ctx context.Context, req *ClassifyRequest) (*ClassifyResponse, error) {
	// Validate request
	if req == nil {
		return nil, fmt.Errorf("classification request cannot be nil")
	}

	// Marshal request to JSON
	jsonData, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create HTTP request
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/api/v1/classify", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create HTTP request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	// Send request
	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		// Handle connection errors and timeouts gracefully
		return nil, fmt.Errorf("ML service unavailable: %w", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	// Check for HTTP errors
	if resp.StatusCode >= 500 {
		return nil, fmt.Errorf("ML service error (status %d): %s", resp.StatusCode, string(body))
	}

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("invalid request (status %d): %s", resp.StatusCode, string(body))
	}

	// Parse response
	var classifyResp ClassifyResponse
	if err := json.Unmarshal(body, &classifyResp); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	// Validate confidence score range
	if classifyResp.Confidence < 0 || classifyResp.Confidence > 1 {
		return nil, fmt.Errorf("invalid confidence score: %f (must be between 0 and 1)", classifyResp.Confidence)
	}

	// Validate category
	if !isValidCategory(classifyResp.Category) {
		return nil, fmt.Errorf("invalid category in response: %s", classifyResp.Category)
	}

	return &classifyResp, nil
}

// HealthCheck verifies that the ML service is available
func (c *httpClassifierClient) HealthCheck(ctx context.Context) error {
	// Create health check request
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+"/health", nil)
	if err != nil {
		return fmt.Errorf("failed to create health check request: %w", err)
	}

	// Send request
	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return fmt.Errorf("ML service unavailable: %w", err)
	}
	defer resp.Body.Close()

	// Check status code
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("ML service unhealthy (status %d): %s", resp.StatusCode, string(body))
	}

	return nil
}

// isValidCategory checks if a category is one of the allowed values
func isValidCategory(category string) bool {
	validCategories := map[string]bool{
		"outerwear": true,
		"upper":     true,
		"lower":     true,
		"footwear":  true,
		"accessory": true,
	}
	return validCategories[category]
}
