package http

import (
	"encoding/json"
	"net/http"
)

// JSONResponse отправляет JSON ответ с указанным статус-кодом
func JSONResponse(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		// Если есть ошибка при кодировании JSON, логируем ее,
		// но не возвращаем ответ, так как заголовки уже отправлены
	}
}

// Error отправляет JSON ошибку
func Error(w http.ResponseWriter, status int, err error) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
}

// Success отправляет успешный JSON ответ
func Success(w http.ResponseWriter, data interface{}) {
	JSONResponse(w, http.StatusOK, data)
}
