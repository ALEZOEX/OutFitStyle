package api

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
)

type HealthChecker struct {
	db      *sql.DB
	mlClient *service.MLClient
}

func NewHealthChecker(db *sql.DB, mlClient *service.MLClient) *HealthChecker {
	return &HealthChecker{
		db:      db,
		mlClient: mlClient,
	}
}

type HealthStatus struct {
	Status      string                 `json:"status"`
	Version     string                 `json:"version"`
	Timestamp   time.Time              `json:"timestamp"`
	Checks      map[string]CheckResult `json:"checks"`
}

type CheckResult struct {
	Status  string    `json:"status"`
	Error   string    `json:"error,omitempty"`
	Latency string    `json:"latency,omitempty"`
}

func (h *HealthChecker) Check(ctx context.Context) HealthStatus {
	checks := make(map[string]CheckResult)
	
	// Database check
	dbCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	
	dbStart := time.Now()
	err := h.db.PingContext(dbCtx)
	dbLatency := time.Since(dbStart)
	
	if err != nil {
		checks["database"] = CheckResult{
			Status: "unhealthy",
			Error:  err.Error(),
		}
	} else {
		checks["database"] = CheckResult{
			Status:  "healthy",
			Latency: dbLatency.String(),
		}
	}
	
	// ML service check
	mlCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	
	mlStart := time.Now()
	mlHealthy := h.mlClient.HealthCheck(mlCtx)
	mlLatency := time.Since(mlStart)
	
	if !mlHealthy {
		checks["ml_service"] = CheckResult{
			Status: "unhealthy",
			Error:  "ML service not responding",
		}
	} else {
		checks["ml_service"] = CheckResult{
			Status:  "healthy",
			Latency: mlLatency.String(),
		}
	}
	
	// Overall status
	overallStatus := "healthy"
	for _, check := range checks {
		if check.Status == "unhealthy" {
			overallStatus = "unhealthy"
			break
		}
	}
	
	return HealthStatus{
		Status:    overallStatus,
		Version:   "1.0.0",
		Timestamp: time.Now(),
		Checks:    checks,
	}
}

func (s *Server) healthCheck(w http.ResponseWriter, r *http.Request) {
	healthChecker := NewHealthChecker(s.db, s.mlClient)
	status := healthChecker.Check(r.Context())
	
	w.Header().Set("Content-Type", "application/json")
	
	if status.Status == "unhealthy" {
		w.WriteHeader(http.StatusServiceUnavailable)
	}
	
	json.NewEncoder(w).Encode(status)
}

// Добавить новый endpoint для readiness probe
func (s *Server) readyCheck(w http.ResponseWriter, r *http.Request) {
	// Проверяем только критичные зависимости
	healthChecker := NewHealthChecker(s.db, s.mlClient)
	status := healthChecker.Check(r.Context())
	
	w.Header().Set("Content-Type", "application/json")
	
	if status.Status == "unhealthy" {
		w.WriteHeader(http.StatusServiceUnavailable)
	}
	
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": status.Status,
		"ready":  status.Status == "healthy",
	})
}