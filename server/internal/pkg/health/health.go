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

// runChecks выполняет все зарегистрированные проверки здоровья
func runChecks() map[string]interface{} {
	results := make(map[string]interface{})
	results["status"] = "ok"
	checkResults := make(map[string]map[string]string)

	for name, checker := range checks {
		checkResult := make(map[string]string)
		if err := checker.HealthCheck(); err != nil {
			checkResult["status"] = "error"
			checkResult["message"] = err.Error()
			results["status"] = "error"
		} else {
			checkResult["status"] = "ok"
		}
		checkResults[name] = checkResult
	}

	results["checks"] = checkResults
	results["version"] = version
	return results
}

// Handler godoc
// @Summary      Проверка состояния сервиса
// @Description  Возвращает состояние сервиса и его зависимостей
// @Tags         health
// @Accept       json
// @Produce      json
// @Success      200  {object}  map[string]interface{}
// @Router       /health [get]
func Handler(w http.ResponseWriter, r *http.Request) {
	results := runChecks()

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(results); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

// ReadyHandler проверяет готовность сервиса
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