// Пакет http предоставляет вспомогательные функции для работы с HTTP-ответами
// Содержит функции для формирования стандартных ответов и ошибок
package http

import (
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"
)

// CORSMiddleware настраивает CORS заголовки для обеспечения безопасности
// Позволяет контролировать, какие домены могут обращаться к API
func CORSMiddleware(allowedOrigins []string) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Установка CORS заголовков
			origin := r.Header.Get("Origin")
			for _, allowedOrigin := range allowedOrigins {
				if allowedOrigin == "*" || origin == allowedOrigin {
					w.Header().Set("Access-Control-Allow-Origin", origin)
					break
				}
			}
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
			w.Header().Set("Access-Control-Expose-Headers", "Content-Length, X-Time")
			w.Header().Set("Access-Control-Allow-Credentials", "true")
			w.Header().Set("Access-Control-Max-Age", "86400") // 24 часа

			// Обработка предварительных запросов
			if r.Method == "OPTIONS" {
				w.WriteHeader(http.StatusOK)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// LoggerMiddleware логирует все HTTP-запросы для мониторинга и отладки
// Записывает метод, путь, продолжительность и статус ответа
func LoggerMiddleware(logger *zap.Logger) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			// Обертываем ResponseWriter для захвата статус-кода
			rw := &responseWriter{ResponseWriter: w}

			next.ServeHTTP(rw, r)

			logger.Info("Request completed",
				zap.String("method", r.Method),
				zap.String("path", r.URL.Path),
				zap.Duration("duration", time.Since(start)),
				zap.Int("status", rw.statusCode),
			)
		})
	}
}

// responseWriter обертка вокруг http.ResponseWriter для захвата статус-кода
// Используется в логирующем middleware для записи статуса ответа
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

// WriteHeader переопределяет метод WriteHeader для захвата статус-кода
func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}
