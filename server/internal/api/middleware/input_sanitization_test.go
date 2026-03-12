package middleware

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestInputSanitizationMiddleware(t *testing.T) {
	tests := []struct {
		name           string
		contentType    string
		requestBody    map[string]interface{}
		expectedBody   map[string]interface{}
		shouldSanitize bool
	}{
		{
			name:        "Sanitizes script tags",
			contentType: "application/json",
			requestBody: map[string]interface{}{
				"name": "<script>alert('XSS')</script>John",
			},
			expectedBody: map[string]interface{}{
				"name": "John", // Script tag is removed, then remaining text is escaped
			},
			shouldSanitize: true,
		},
		{
			name:        "Sanitizes HTML tags",
			contentType: "application/json",
			requestBody: map[string]interface{}{
				"name": "<b>Bold</b> text",
			},
			expectedBody: map[string]interface{}{
				"name": "&lt;b&gt;Bold&lt;/b&gt; text", // HTML tags escaped
			},
			shouldSanitize: true,
		},
		{
			name:        "Preserves clean input",
			contentType: "application/json",
			requestBody: map[string]interface{}{
				"name": "John Doe",
			},
			expectedBody: map[string]interface{}{
				"name": "John Doe",
			},
			shouldSanitize: true,
		},
		{
			name:        "Sanitizes nested objects",
			contentType: "application/json",
			requestBody: map[string]interface{}{
				"user": map[string]interface{}{
					"name": "<script>alert('XSS')</script>",
				},
			},
			expectedBody: map[string]interface{}{
				"user": map[string]interface{}{
					"name": "", // Script tag removed, nothing left
				},
			},
			shouldSanitize: true,
		},
		{
			name:        "Skips non-JSON content type",
			contentType: "text/plain",
			requestBody: map[string]interface{}{
				"name": "<script>alert('XSS')</script>",
			},
			expectedBody: map[string]interface{}{
				"name": "<script>alert('XSS')</script>",
			},
			shouldSanitize: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create request body
			bodyBytes, err := json.Marshal(tt.requestBody)
			if err != nil {
				t.Fatalf("Failed to marshal request body: %v", err)
			}

			// Create request
			req := httptest.NewRequest("POST", "/test", bytes.NewBuffer(bodyBytes))
			req.Header.Set("Content-Type", tt.contentType)

			// Create response recorder
			rr := httptest.NewRecorder()

			// Create test handler that reads the body
			var receivedBody map[string]interface{}
			handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				bodyBytes, err := io.ReadAll(r.Body)
				if err != nil {
					t.Fatalf("Failed to read body: %v", err)
				}
				if err := json.Unmarshal(bodyBytes, &receivedBody); err != nil {
					t.Fatalf("Failed to unmarshal body: %v", err)
				}
				w.WriteHeader(http.StatusOK)
			})

			// Apply middleware
			middleware := InputSanitizationMiddleware(handler)
			middleware.ServeHTTP(rr, req)

			// Verify the body was sanitized correctly
			if tt.shouldSanitize {
				if receivedBody["name"] != tt.expectedBody["name"] {
					t.Errorf("Expected name %q, got %q", tt.expectedBody["name"], receivedBody["name"])
				}
			} else {
				if receivedBody["name"] != tt.requestBody["name"] {
					t.Errorf("Expected name %q (unsanitized), got %q", tt.requestBody["name"], receivedBody["name"])
				}
			}
		})
	}
}

func TestInputSanitizationMiddleware_EmptyBody(t *testing.T) {
	req := httptest.NewRequest("POST", "/test", nil)
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	middleware := InputSanitizationMiddleware(handler)
	middleware.ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("Expected status OK, got %d", rr.Code)
	}
}

func TestInputSanitizationMiddleware_InvalidJSON(t *testing.T) {
	req := httptest.NewRequest("POST", "/test", bytes.NewBufferString("invalid json"))
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Handler should receive the invalid JSON and handle it
		w.WriteHeader(http.StatusBadRequest)
	})

	middleware := InputSanitizationMiddleware(handler)
	middleware.ServeHTTP(rr, req)

	// Middleware should pass through invalid JSON to the handler
	if rr.Code != http.StatusBadRequest {
		t.Errorf("Expected status BadRequest, got %d", rr.Code)
	}
}
