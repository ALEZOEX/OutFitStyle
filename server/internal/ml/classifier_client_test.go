package ml

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

// TestClassifyItem_Success tests successful classification
func TestClassifyItem_Success(t *testing.T) {
	// Create mock ML service
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify request method and path
		if r.Method != http.MethodPost {
			t.Errorf("Expected POST request, got %s", r.Method)
		}
		if r.URL.Path != "/api/v1/classify" {
			t.Errorf("Expected path /api/v1/classify, got %s", r.URL.Path)
		}

		// Verify content type
		contentType := r.Header.Get("Content-Type")
		if contentType != "application/json" {
			t.Errorf("Expected Content-Type application/json, got %s", contentType)
		}

		// Parse request
		var req ClassifyRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("Failed to decode request: %v", err)
		}

		// Verify request fields
		if req.Name != "Blue Jeans" {
			t.Errorf("Expected name 'Blue Jeans', got '%s'", req.Name)
		}
		if req.Subcategory != "jeans" {
			t.Errorf("Expected subcategory 'jeans', got '%s'", req.Subcategory)
		}

		// Send response
		resp := ClassifyResponse{
			Category:   "lower",
			Confidence: 0.95,
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Make request
	req := &ClassifyRequest{
		Name:        "Blue Jeans",
		Subcategory: "jeans",
		Materials:   []string{"cotton", "denim"},
		Style:       "casual",
	}

	resp, err := client.ClassifyItem(context.Background(), req)
	if err != nil {
		t.Fatalf("Expected successful classification, got error: %v", err)
	}

	// Verify response
	if resp.Category != "lower" {
		t.Errorf("Expected category 'lower', got '%s'", resp.Category)
	}
	if resp.Confidence != 0.95 {
		t.Errorf("Expected confidence 0.95, got %f", resp.Confidence)
	}
}

// TestClassifyItem_Timeout tests timeout handling
func TestClassifyItem_Timeout(t *testing.T) {
	// Create slow mock server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Sleep longer than the 50ms timeout
		time.Sleep(100 * time.Millisecond)
		resp := ClassifyResponse{
			Category:   "upper",
			Confidence: 0.9,
		}
		json.NewEncoder(w).Encode(resp)
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Make request
	req := &ClassifyRequest{
		Name:        "T-Shirt",
		Subcategory: "t-shirt",
		Materials:   []string{"cotton"},
		Style:       "casual",
	}

	_, err := client.ClassifyItem(context.Background(), req)
	if err == nil {
		t.Fatal("Expected timeout error, got nil")
	}
}

// TestClassifyItem_ConnectionError tests connection error handling
func TestClassifyItem_ConnectionError(t *testing.T) {
	// Create client with invalid URL
	client := NewClassifierClient("http://localhost:99999")

	// Make request
	req := &ClassifyRequest{
		Name:        "Jacket",
		Subcategory: "jacket",
		Materials:   []string{"polyester"},
		Style:       "casual",
	}

	_, err := client.ClassifyItem(context.Background(), req)
	if err == nil {
		t.Fatal("Expected connection error, got nil")
	}
}

// TestClassifyItem_ServerError tests 5xx error handling
func TestClassifyItem_ServerError(t *testing.T) {
	// Create mock server that returns 500
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Internal server error"))
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Make request
	req := &ClassifyRequest{
		Name:        "Shoes",
		Subcategory: "shoes",
		Materials:   []string{"leather"},
		Style:       "formal",
	}

	_, err := client.ClassifyItem(context.Background(), req)
	if err == nil {
		t.Fatal("Expected server error, got nil")
	}
}

// TestClassifyItem_InvalidResponse tests malformed JSON response handling
func TestClassifyItem_InvalidResponse(t *testing.T) {
	// Create mock server that returns invalid JSON
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte("invalid json"))
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Make request
	req := &ClassifyRequest{
		Name:        "Hat",
		Subcategory: "hat",
		Materials:   []string{"wool"},
		Style:       "casual",
	}

	_, err := client.ClassifyItem(context.Background(), req)
	if err == nil {
		t.Fatal("Expected parse error, got nil")
	}
}

// TestClassifyItem_InvalidConfidenceScore tests confidence score validation
func TestClassifyItem_InvalidConfidenceScore(t *testing.T) {
	testCases := []struct {
		name       string
		confidence float64
	}{
		{"confidence > 1", 1.5},
		{"confidence < 0", -0.1},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			// Create mock server with invalid confidence
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				resp := ClassifyResponse{
					Category:   "upper",
					Confidence: tc.confidence,
				}
				json.NewEncoder(w).Encode(resp)
			}))
			defer server.Close()

			// Create client
			client := NewClassifierClient(server.URL)

			// Make request
			req := &ClassifyRequest{
				Name:        "Shirt",
				Subcategory: "shirt",
				Materials:   []string{"cotton"},
				Style:       "formal",
			}

			_, err := client.ClassifyItem(context.Background(), req)
			if err == nil {
				t.Fatalf("Expected error for %s, got nil", tc.name)
			}
		})
	}
}

// TestClassifyItem_InvalidCategory tests category validation
func TestClassifyItem_InvalidCategory(t *testing.T) {
	// Create mock server with invalid category
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		resp := ClassifyResponse{
			Category:   "invalid_category",
			Confidence: 0.9,
		}
		json.NewEncoder(w).Encode(resp)
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Make request
	req := &ClassifyRequest{
		Name:        "Item",
		Subcategory: "unknown",
		Materials:   []string{"cotton"},
		Style:       "casual",
	}

	_, err := client.ClassifyItem(context.Background(), req)
	if err == nil {
		t.Fatal("Expected error for invalid category, got nil")
	}
}

// TestClassifyItem_NilRequest tests nil request handling
func TestClassifyItem_NilRequest(t *testing.T) {
	// Create mock server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Error("Server should not be called with nil request")
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Make request with nil
	_, err := client.ClassifyItem(context.Background(), nil)
	if err == nil {
		t.Fatal("Expected error for nil request, got nil")
	}
}

// TestHealthCheck_Success tests successful health check
func TestHealthCheck_Success(t *testing.T) {
	// Create mock server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify request method and path
		if r.Method != http.MethodGet {
			t.Errorf("Expected GET request, got %s", r.Method)
		}
		if r.URL.Path != "/health" {
			t.Errorf("Expected path /health, got %s", r.URL.Path)
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{
			"status":  "healthy",
			"service": "category-classification",
		})
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Check health
	err := client.HealthCheck(context.Background())
	if err != nil {
		t.Fatalf("Expected successful health check, got error: %v", err)
	}
}

// TestHealthCheck_ServiceUnavailable tests health check with unavailable service
func TestHealthCheck_ServiceUnavailable(t *testing.T) {
	// Create client with invalid URL
	client := NewClassifierClient("http://localhost:99999")

	// Check health
	err := client.HealthCheck(context.Background())
	if err == nil {
		t.Fatal("Expected error for unavailable service, got nil")
	}
}

// TestHealthCheck_UnhealthyStatus tests health check with non-200 status
func TestHealthCheck_UnhealthyStatus(t *testing.T) {
	// Create mock server that returns 503
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusServiceUnavailable)
		w.Write([]byte("Service unavailable"))
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Check health
	err := client.HealthCheck(context.Background())
	if err == nil {
		t.Fatal("Expected error for unhealthy service, got nil")
	}
}

// TestIsValidCategory tests category validation function
func TestIsValidCategory(t *testing.T) {
	testCases := []struct {
		category string
		expected bool
	}{
		{"outerwear", true},
		{"upper", true},
		{"lower", true},
		{"footwear", true},
		{"accessory", true},
		{"invalid", false},
		{"", false},
		{"UPPER", false}, // case-sensitive
	}

	for _, tc := range testCases {
		t.Run(tc.category, func(t *testing.T) {
			result := isValidCategory(tc.category)
			if result != tc.expected {
				t.Errorf("Expected isValidCategory('%s') = %v, got %v", tc.category, tc.expected, result)
			}
		})
	}
}

// TestClassifyItem_ContextCancellation tests context cancellation handling
func TestClassifyItem_ContextCancellation(t *testing.T) {
	// Create mock server with delay
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(100 * time.Millisecond)
		resp := ClassifyResponse{
			Category:   "upper",
			Confidence: 0.9,
		}
		json.NewEncoder(w).Encode(resp)
	}))
	defer server.Close()

	// Create client
	client := NewClassifierClient(server.URL)

	// Create context with immediate cancellation
	ctx, cancel := context.WithCancel(context.Background())
	cancel() // Cancel immediately

	// Make request
	req := &ClassifyRequest{
		Name:        "T-Shirt",
		Subcategory: "t-shirt",
		Materials:   []string{"cotton"},
		Style:       "casual",
	}

	_, err := client.ClassifyItem(ctx, req)
	if err == nil {
		t.Fatal("Expected context cancellation error, got nil")
	}
}
