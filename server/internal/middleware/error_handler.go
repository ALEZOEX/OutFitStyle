// Package middleware contains HTTP middleware for the server
// Implements error message sanitization to prevent information disclosure
package middleware

import (
	"encoding/json"
	"errors"
	"net/http"
	"runtime/debug"

	"go.uber.org/zap"
)

// ErrorCategory represents the type of error for categorization
type ErrorCategory string

const (
	// ErrorCategoryValidation represents validation errors (400)
	ErrorCategoryValidation ErrorCategory = "validation"
	// ErrorCategoryNotFound represents resource not found errors (404)
	ErrorCategoryNotFound ErrorCategory = "not_found"
	// ErrorCategoryUnauthorized represents authentication/authorization errors (401/403)
	ErrorCategoryUnauthorized ErrorCategory = "unauthorized"
	// ErrorCategoryInternal represents internal server errors (500)
	ErrorCategoryInternal ErrorCategory = "internal"
)

// AppError represents an application error with category and details
type AppError struct {
	Category ErrorCategory
	Message  string
	Err      error
}

// Error implements the error interface
func (e *AppError) Error() string {
	if e.Err != nil {
		return e.Err.Error()
	}
	return e.Message
}

// Unwrap returns the underlying error
func (e *AppError) Unwrap() error {
	return e.Err
}

// NewValidationError creates a new validation error
func NewValidationError(message string) *AppError {
	return &AppError{
		Category: ErrorCategoryValidation,
		Message:  message,
	}
}

// NewNotFoundError creates a new not found error
func NewNotFoundError(message string) *AppError {
	return &AppError{
		Category: ErrorCategoryNotFound,
		Message:  message,
	}
}

// NewUnauthorizedError creates a new unauthorized error
func NewUnauthorizedError(message string) *AppError {
	return &AppError{
		Category: ErrorCategoryUnauthorized,
		Message:  message,
	}
}

// NewInternalError creates a new internal error
func NewInternalError(err error) *AppError {
	return &AppError{
		Category: ErrorCategoryInternal,
		Err:      err,
	}
}

// ErrorResponse represents the sanitized error response sent to clients
type ErrorResponse struct {
	Error string `json:"error"`
}

// categorizeError determines the error category and appropriate status code
func categorizeError(err error) (ErrorCategory, int, string) {
	// Check if it's already an AppError
	var appErr *AppError
	if errors.As(err, &appErr) {
		switch appErr.Category {
		case ErrorCategoryValidation:
			// For validation errors, we can provide helpful messages
			return ErrorCategoryValidation, http.StatusBadRequest, appErr.Message
		case ErrorCategoryNotFound:
			return ErrorCategoryNotFound, http.StatusNotFound, "Resource not found"
		case ErrorCategoryUnauthorized:
			return ErrorCategoryUnauthorized, http.StatusUnauthorized, "Unauthorized"
		case ErrorCategoryInternal:
			return ErrorCategoryInternal, http.StatusInternalServerError, "Internal server error"
		}
	}

	// Default categorization based on error message patterns
	errMsg := err.Error()

	// Check for common validation patterns
	if containsAny(errMsg, []string{"invalid", "validation", "required", "format"}) {
		return ErrorCategoryValidation, http.StatusBadRequest, "Invalid request"
	}

	// Check for not found patterns
	if containsAny(errMsg, []string{"not found", "does not exist", "no rows"}) {
		return ErrorCategoryNotFound, http.StatusNotFound, "Resource not found"
	}

	// Check for unauthorized patterns
	if containsAny(errMsg, []string{"unauthorized", "forbidden", "permission denied", "access denied"}) {
		return ErrorCategoryUnauthorized, http.StatusUnauthorized, "Unauthorized"
	}

	// Default to internal error
	return ErrorCategoryInternal, http.StatusInternalServerError, "Internal server error"
}

// containsAny checks if the string contains any of the substrings
func containsAny(s string, substrs []string) bool {
	for _, substr := range substrs {
		if len(s) >= len(substr) {
			for i := 0; i <= len(s)-len(substr); i++ {
				if s[i:i+len(substr)] == substr {
					return true
				}
			}
		}
	}
	return false
}

// HandleError logs the full error details and returns a sanitized response to the client
func HandleError(w http.ResponseWriter, r *http.Request, err error, logger *zap.Logger) {
	if err == nil {
		return
	}

	// Categorize the error
	category, statusCode, genericMessage := categorizeError(err)

	// Log full error details server-side with structured logging
	logFields := []zap.Field{
		zap.String("category", string(category)),
		zap.Int("status_code", statusCode),
		zap.String("method", r.Method),
		zap.String("path", r.URL.Path),
		zap.String("remote_addr", r.RemoteAddr),
		zap.Error(err),
	}

	// Add stack trace for internal errors
	if category == ErrorCategoryInternal {
		logFields = append(logFields, zap.ByteString("stack_trace", debug.Stack()))
		logger.Error("Internal server error", logFields...)
	} else {
		logger.Warn("Request error", logFields...)
	}

	// Return generic sanitized message to client
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)

	response := ErrorResponse{
		Error: genericMessage,
	}

	// Encode response, ignore encoding errors as we're already in error handling
	_ = json.NewEncoder(w).Encode(response)
}
