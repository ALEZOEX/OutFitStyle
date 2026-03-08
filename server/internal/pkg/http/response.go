// Пакет http предоставляет вспомогательные функции для работы с HTTP-ответами
// Содержит функции для формирования стандартных ответов и ошибок
package http

import (
	"encoding/json"
	"net/http"
)

// Success отправляет успешный JSON-ответ с указанными данными
// Устанавливает заголовок Content-Type в application/json
func Success(w http.ResponseWriter, data any) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(data)
}

// Error отправляет JSON-ответ с ошибкой и указанным HTTP-статусом
// Формирует ответ с сообщением об ошибке в формате JSON
// SECURITY: This function should only be used with sanitized error messages
// For automatic error sanitization, use middleware.HandleError instead
func Error(w http.ResponseWriter, status int, err error) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	// Sanitize error message based on status code
	var message string
	switch {
	case status >= 500:
		message = "Internal server error"
	case status == http.StatusNotFound:
		message = "Resource not found"
	case status == http.StatusUnauthorized || status == http.StatusForbidden:
		message = "Unauthorized"
	case status >= 400:
		// For validation errors, we can provide the actual error message
		// as it should already be user-friendly
		message = err.Error()
	default:
		message = err.Error()
	}

	_ = json.NewEncoder(w).Encode(map[string]any{
		"error": message,
	})
}

// ValidationError отправляет структурированный ответ с ошибками валидации
// Используется для возврата ошибок валидации входных данных
func ValidationError(w http.ResponseWriter, validationErrors map[string]string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusBadRequest)
	_ = json.NewEncoder(w).Encode(map[string]any{
		"error":  "validation failed",
		"errors": validationErrors,
	})
}

// JSONResponse записывает JSON-ответ с указанным кодом состояния
// Обеспечивает корректное формирование HTTP-ответа с JSON-данными
func JSONResponse(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

// JSONError записывает JSON-ответ с ошибкой и указанным кодом состояния
// Используется для формирования стандартных ошибочных ответов
// SECURITY: Sanitizes error messages to prevent information disclosure
func JSONError(w http.ResponseWriter, statusCode int, message string) {
	// Sanitize message based on status code
	var sanitizedMessage string
	switch {
	case statusCode >= 500:
		sanitizedMessage = "Internal server error"
	case statusCode == http.StatusNotFound:
		sanitizedMessage = "Resource not found"
	case statusCode == http.StatusUnauthorized || statusCode == http.StatusForbidden:
		sanitizedMessage = "Unauthorized"
	case statusCode >= 400:
		// For client errors (validation), we can provide the message
		sanitizedMessage = message
	default:
		sanitizedMessage = message
	}

	response := map[string]string{
		"error": sanitizedMessage,
	}
	JSONResponse(w, statusCode, response)
}
