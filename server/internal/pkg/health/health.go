// Пакет health предоставляет функциональность проверки работоспособности сервиса
// Реализует проверки состояния базы данных и внешних зависимостей
package health

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// MLHealthClient минимальный контракт, чтобы не тащить конкретную реализацию ML клиента
// Позволяет проверять доступность ML-сервиса без жесткой зависимости
type MLHealthClient interface {
	HealthCheck(ctx context.Context) bool
}

// Checker интерфейс для проверки работоспособности компонентов системы
type Checker interface {
	HealthCheck() error
}

// HealthStatus структура, представляющая общее состояние сервиса
type HealthStatus struct {
	Status    string                 `json:"status"`    // Общий статус сервиса (healthy/unhealthy)
	Version   string                 `json:"version"`   // Версия сервиса
	Timestamp time.Time              `json:"timestamp"` // Время проверки
	Checks    map[string]CheckResult `json:"checks"`    // Результаты проверок отдельных компонентов
}

// CheckResult структура, представляющая результат проверки отдельного компонента
type CheckResult struct {
	Status  string `json:"status"`            // Статус проверки (healthy/unhealthy)
	Error   string `json:"error,omitempty"`   // Сообщение об ошибке, если проверка не прошла
	Latency string `json:"latency,omitempty"` // Время выполнения проверки
}

// HealthChecker структура для выполнения проверок работоспособности
type HealthChecker struct {
	db       *pgxpool.Pool  // Подключение к базе данных PostgreSQL
	mlClient MLHealthClient // Клиент для проверки ML-сервиса
}

// NewHealthChecker создает новый экземпляр HealthChecker
// Принимает подключение к базе данных и клиент ML-сервиса
func NewHealthChecker(db *pgxpool.Pool, mlClient MLHealthClient) *HealthChecker {
	return &HealthChecker{db: db, mlClient: mlClient}
}

// Check выполняет проверки работоспособности всех зарегистрированных компонентов
// Возвращает общий статус сервиса и результаты проверок каждого компонента
func (h *HealthChecker) Check(ctx context.Context) HealthStatus {
	checks := map[string]CheckResult{}

	// Проверка базы данных
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

	// Проверка ML-сервиса (опционально, не влияет на общий статус)
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

	// Определение общего статуса (только критичные зависимости: БД)
	// ML service не влияет на общий статус - это опциональная зависимость
	overall := "healthy"
	if dbCheck, ok := checks["database"]; ok && dbCheck.Status == "unhealthy" {
		overall = "unhealthy"
	}

	return HealthStatus{
		Status:    overall,
		Version:   "1.0.0",
		Timestamp: time.Now(),
		Checks:    checks,
	}
}

// Handler возвращает HTTP-обработчик для проверки состояния сервиса
// Возвращает JSON с информацией о состоянии сервиса и его зависимостей
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

// ReadyHandler возвращает HTTP-обработчик для проверки готовности сервиса
// Используется для проверки готовности к приему трафика (например, в Kubernetes)
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
// Позволяет расширить функциональность проверки работоспособности
func RegisterChecks(checks map[string]Checker) {
	// В реальной реализации здесь будет регистрация проверок
	// Пока что просто заглушка
	for _, checker := range checks {
		_ = checker
	}
}
