package middleware_test

import (
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"

	"outfitstyle/server/internal/middleware"

	"go.uber.org/zap"
)

// Example_errorHandling demonstrates how to use the error handler middleware
func Example_errorHandling() {
	logger, _ := zap.NewDevelopment()

	// Simulate a handler that encounters different types of errors
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Simulate different error scenarios based on query parameter
		errorType := r.URL.Query().Get("error")

		switch errorType {
		case "validation":
			// Validation error - helpful message shown to user
			err := middleware.NewValidationError("email is required")
			middleware.HandleError(w, r, err, logger)

		case "notfound":
			// Not found error - generic message shown
			err := middleware.NewNotFoundError("user with id 123 not found")
			middleware.HandleError(w, r, err, logger)

		case "unauthorized":
			// Unauthorized error - generic message shown
			err := middleware.NewUnauthorizedError("invalid token")
			middleware.HandleError(w, r, err, logger)

		case "internal":
			// Internal error - generic message shown, full details logged
			err := middleware.NewInternalError(errors.New("database connection failed: timeout after 30s"))
			middleware.HandleError(w, r, err, logger)

		default:
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("success"))
		}
	})

	// Test validation error
	req := httptest.NewRequest(http.MethodGet, "/test?error=validation", nil)
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, req)
	fmt.Printf("Validation Error Response: %s\n", w.Body.String())

	// Test internal error
	req = httptest.NewRequest(http.MethodGet, "/test?error=internal", nil)
	w = httptest.NewRecorder()
	handler.ServeHTTP(w, req)
	fmt.Printf("Internal Error Response: %s\n", w.Body.String())

	// Output:
	// Validation Error Response: {"error":"email is required"}
	// Internal Error Response: {"error":"Internal server error"}
}

// Example_automaticCategorization demonstrates automatic error categorization
func Example_automaticCategorization() {
	logger, _ := zap.NewDevelopment()

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// These errors are automatically categorized based on their message
		errorType := r.URL.Query().Get("error")

		var err error
		switch errorType {
		case "db_notfound":
			err = errors.New("record not found in database")
		case "db_error":
			err = errors.New("pq: duplicate key violates unique constraint")
		case "validation":
			err = errors.New("validation failed: invalid email format")
		default:
			err = errors.New("unexpected error")
		}

		middleware.HandleError(w, r, err, logger)
	})

	// Test database not found - automatically categorized as NotFound
	req := httptest.NewRequest(http.MethodGet, "/test?error=db_notfound", nil)
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, req)
	fmt.Printf("DB Not Found Response: %s\n", w.Body.String())

	// Test database error - automatically categorized as Internal
	req = httptest.NewRequest(http.MethodGet, "/test?error=db_error", nil)
	w = httptest.NewRecorder()
	handler.ServeHTTP(w, req)
	fmt.Printf("DB Error Response: %s\n", w.Body.String())

	// Output:
	// DB Not Found Response: {"error":"Resource not found"}
	// DB Error Response: {"error":"Internal server error"}
}
