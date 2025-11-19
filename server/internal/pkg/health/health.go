package health

import (
	"encoding/json"
	"net/http"
)

type Checker interface {
	HealthCheck() error
}

type HealthResponse struct {
	Status  string           `json:"status"`
	Checks  map[string]Check `json:"checks"`
	Version string           `json:"version"`
}

type Check struct {
	Status  string `json:"status"`
	Message string `json:"message,omitempty"`
}

var checks = make(map[string]Checker)
var version = "1.0.0"

func RegisterChecks(newChecks map[string]Checker) {
	for name, checker := range newChecks {
		checks[name] = checker
	}
}

func Handler(w http.ResponseWriter, r *http.Request) {
	results := make(map[string]Check)
	allHealthy := true

	for name, checker := range checks {
		err := checker.HealthCheck()
		status := "healthy"
		message := ""

		if err != nil {
			status = "unhealthy"
			message = err.Error()
			allHealthy = false
		}

		results[name] = Check{
			Status:  status,
			Message: message,
		}
	}

	response := HealthResponse{
		Status:  map[bool]string{true: "healthy", false: "unhealthy"}[allHealthy],
		Checks:  results,
		Version: version,
	}

	w.Header().Set("Content-Type", "application/json")
	if !allHealthy {
		w.WriteHeader(http.StatusServiceUnavailable)
	}
	json.NewEncoder(w).Encode(response)
}

func ReadyHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"status":  "ready",
		"version": version,
	})
}

// SetVersion устанавливает версию приложения
func SetVersion(v string) {
	version = v
}
