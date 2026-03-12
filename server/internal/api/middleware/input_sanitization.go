// Package middleware provides HTTP middleware for the application
package middleware

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"

	"outfitstyle/server/internal/validation/sanitization"
)

// InputSanitizationMiddleware sanitizes all string inputs in JSON request bodies
// This provides consistent protection against XSS and injection attacks across all endpoints
func InputSanitizationMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Only process requests with JSON content type
		contentType := r.Header.Get("Content-Type")
		if contentType != "application/json" && contentType != "application/json; charset=utf-8" {
			next.ServeHTTP(w, r)
			return
		}

		// Only process requests with a body
		if r.Body == nil || r.ContentLength == 0 {
			next.ServeHTTP(w, r)
			return
		}

		// Read the request body
		bodyBytes, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusBadRequest)
			return
		}
		r.Body.Close()

		// Parse JSON
		var data interface{}
		if err := json.Unmarshal(bodyBytes, &data); err != nil {
			// If it's not valid JSON, let the handler deal with it
			r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
			next.ServeHTTP(w, r)
			return
		}

		// Sanitize the data
		sanitized := sanitization.SanitizeJSONValue(data)

		// Re-encode to JSON
		sanitizedBytes, err := json.Marshal(sanitized)
		if err != nil {
			http.Error(w, "Failed to sanitize request", http.StatusInternalServerError)
			return
		}

		// Replace the request body with sanitized version
		r.Body = io.NopCloser(bytes.NewBuffer(sanitizedBytes))
		r.ContentLength = int64(len(sanitizedBytes))

		next.ServeHTTP(w, r)
	})
}
