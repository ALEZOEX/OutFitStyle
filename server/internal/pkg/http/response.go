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
func Error(w http.ResponseWriter, status int, err error) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(map[string]any{
		"error": err.Error(),
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
func JSONError(w http.ResponseWriter, statusCode int, message string) {
	response := map[string]string{
		"error": message,
	}
	JSONResponse(w, statusCode, response)
}
