package health

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// минимальный контракт, чтобы не тащить конкретную реализацию ML клиента
type MLHealthClient interface {
	HealthCheck(ctx context.Context) bool
}

type Checker interface {
	HealthCheck() error
}

type HealthStatus struct {
	Status    string                 `json:"status"`
	Version   string                 `json:"version"`
	Timestamp time.Time              `json:"timestamp"`
	Checks    map[string]CheckResult `json:"checks"`
}

type CheckResult struct {
	Status  string `json:"status"`
	Error   string `json:"error,omitempty"`
	Latency string `json:"latency,omitempty"`
}

type HealthChecker struct {
	db       *pgxpool.Pool
	mlClient MLHealthClient
}

func NewHealthChecker(db *pgxpool.Pool, mlClient MLHealthClient) *HealthChecker {
	return &HealthChecker{db: db, mlClient: mlClient}
}

func (h *HealthChecker) Check(ctx context.Context) HealthStatus {
	checks := map[string]CheckResult{}

	// DB
	{
		dbCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()

		start := time.Now()
		err := h.db.Ping(dbCtx)
		lat := time.Since(start)

		if err != nil {
			checks["database"] = CheckResult{Status: "unhealthy", Error: err.Error()}
		} else {
			checks["database"] = CheckResult{Status: "healthy", Latency: lat.String()}
		}
	}

	// ML
	{
		mlCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()

		start := time.Now()
		ok := h.mlClient != nil && h.mlClient.HealthCheck(mlCtx)
		lat := time.Since(start)

		if !ok {
			checks["ml_service"] = CheckResult{Status: "unhealthy", Error: "ML service not responding"}
		} else {
			checks["ml_service"] = CheckResult{Status: "healthy", Latency: lat.String()}
		}
	}

	overall := "healthy"
	for _, c := range checks {
		if c.Status == "unhealthy" {
			overall = "unhealthy"
			break
		}
	}

	return HealthStatus{
		Status:    overall,
		Version:   "1.0.0",
		Timestamp: time.Now(),
		Checks:    checks,
	}
}

// Handler godoc
// @Summary      Проверка состояния сервиса
// @Description  Возвращает состояние сервиса и его зависимостей
// @Tags         health
// @Accept       json
// @Produce      json
// @Success      200  {object}  HealthStatus
// @Router       /health [get]
func Handler(db *pgxpool.Pool, mlClient MLHealthClient) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		status := NewHealthChecker(db, mlClient).Check(r.Context())

		w.Header().Set("Content-Type", "application/json")
		if status.Status == "unhealthy" {
			w.WriteHeader(http.StatusServiceUnavailable)
		}
		_ = json.NewEncoder(w).Encode(status)
	}
}

// ReadyHandler проверяет готовность сервиса
func ReadyHandler(db *pgxpool.Pool, mlClient MLHealthClient) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		status := NewHealthChecker(db, mlClient).Check(r.Context())

		w.Header().Set("Content-Type", "application/json")
		if status.Status == "unhealthy" {
			w.WriteHeader(http.StatusServiceUnavailable)
		}
		_ = json.NewEncoder(w).Encode(map[string]any{
			"status": status.Status,
			"ready":  status.Status == "healthy",
		})
	}
}

// RegisterChecks регистрирует проверки для использования в других частях приложения
func RegisterChecks(checks map[string]Checker) {
	// В реальной реализации здесь будет регистрация проверок
	// Пока что просто заглушка
	for _, checker := range checks {
		_ = checker
	}
}
