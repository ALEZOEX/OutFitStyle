package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"time"
)

// минимальный контракт, чтобы не тащить конкретную реализацию ML клиента
type MLHealthClient interface {
	HealthCheck(ctx context.Context) bool
}

type HealthChecker struct {
	db       *sql.DB
	mlClient MLHealthClient
}

func NewHealthChecker(db *sql.DB, mlClient MLHealthClient) *HealthChecker {
	return &HealthChecker{db: db, mlClient: mlClient}
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

type Server struct {
	db       *sql.DB
	mlClient MLHealthClient
}

func (h *HealthChecker) Check(ctx context.Context) HealthStatus {
	checks := map[string]CheckResult{}

	// DB
	{
		dbCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()

		start := time.Now()
		err := h.db.PingContext(dbCtx)
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

func (s *Server) healthCheck(w http.ResponseWriter, r *http.Request) {
	status := NewHealthChecker(s.db, s.mlClient).Check(r.Context())

	w.Header().Set("Content-Type", "application/json")
	if status.Status == "unhealthy" {
		w.WriteHeader(http.StatusServiceUnavailable)
	}
	_ = json.NewEncoder(w).Encode(status)
}

func (s *Server) readyCheck(w http.ResponseWriter, r *http.Request) {
	status := NewHealthChecker(s.db, s.mlClient).Check(r.Context())

	w.Header().Set("Content-Type", "application/json")
	if status.Status == "unhealthy" {
		w.WriteHeader(http.StatusServiceUnavailable)
	}
	_ = json.NewEncoder(w).Encode(map[string]any{
		"status": status.Status,
		"ready":  status.Status == "healthy",
	})
}
