package middleware

import (
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"go.uber.org/zap"
)

func TestCategorizeError(t *testing.T) {
	tests := []struct {
		name           string
		err            error
		wantCategory   ErrorCategory
		wantStatusCode int
		wantMessage    string
	}{
		{
			name:           "validation error",
			err:            NewValidationError("invalid email format"),
			wantCategory:   ErrorCategoryValidation,
			wantStatusCode: http.StatusBadRequest,
			wantMessage:    "invalid email format",
		},
		{
			name:           "not found error",
			err:            NewNotFoundError("user not found"),
			wantCategory:   ErrorCategoryNotFound,
			wantStatusCode: http.StatusNotFound,
			wantMessage:    "Resource not found",
		},
		{
			name:           "unauthorized error",
			err:            NewUnauthorizedError("invalid token"),
			wantCategory:   ErrorCategoryUnauthorized,
			wantStatusCode: http.StatusUnauthorized,
			wantMessage:    "Unauthorized",
		},
		{
			name:           "internal error",
			err:            NewInternalError(errors.New("database connection failed")),
			wantCategory:   ErrorCategoryInternal,
			wantStatusCode: http.StatusInternalServerError,
			wantMessage:    "Internal server error",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			category, statusCode, message := categorizeError(tt.err)

			if category != tt.wantCategory {
				t.Errorf("categorizeError() category = %v, want %v", category, tt.wantCategory)
			}
			if statusCode != tt.wantStatusCode {
				t.Errorf("categorizeError() statusCode = %v, want %v", statusCode, tt.wantStatusCode)
			}
			if message != tt.wantMessage {
				t.Errorf("categorizeError() message = %v, want %v", message, tt.wantMessage)
			}
		})
	}
}

func TestHandleError_NoStackTraceInResponse(t *testing.T) {
	logger, _ := zap.NewDevelopment()

	tests := []struct {
		name           string
		err            error
		wantStatusCode int
		wantBody       string
	}{
		{
			name:           "internal error returns generic message",
			err:            NewInternalError(errors.New("database error: connection timeout")),
			wantStatusCode: http.StatusInternalServerError,
			wantBody:       `{"error":"Internal server error"}`,
		},
		{
			name:           "validation error returns helpful message",
			err:            NewValidationError("email is required"),
			wantStatusCode: http.StatusBadRequest,
			wantBody:       `{"error":"email is required"}`,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := httptest.NewRecorder()
			r := httptest.NewRequest(http.MethodGet, "/test", nil)

			HandleError(w, r, tt.err, logger)

			if w.Code != tt.wantStatusCode {
				t.Errorf("HandleError() status code = %v, want %v", w.Code, tt.wantStatusCode)
			}

			body := w.Body.String()
			if len(body) > 0 && body[len(body)-1] == '\n' {
				body = body[:len(body)-1]
			}

			if body != tt.wantBody {
				t.Errorf("HandleError() body = %v, want %v", body, tt.wantBody)
			}
		})
	}
}
