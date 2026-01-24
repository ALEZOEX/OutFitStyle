package http

import (
	"encoding/json"
	"net/http"
)

func Success(w http.ResponseWriter, data any) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(data)
}

func Error(w http.ResponseWriter, status int, err error) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(map[string]any{
		"error": err.Error(),
	})
}

// ValidationError sends a structured validation error response
func ValidationError(w http.ResponseWriter, validationErrors map[string]string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusBadRequest)
	_ = json.NewEncoder(w).Encode(map[string]any{
		"error":  "validation failed",
		"errors": validationErrors,
	})
}

// JSONResponse writes a JSON response with the specified status code
func JSONResponse(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

// JSONError writes a JSON error response with the specified status code and message
func JSONError(w http.ResponseWriter, statusCode int, message string) {
	response := map[string]string{
		"error": message,
	}
	JSONResponse(w, statusCode, response)
}
