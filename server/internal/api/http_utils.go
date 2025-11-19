package api

import (
	"encoding/json"
	"net/http"
)

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