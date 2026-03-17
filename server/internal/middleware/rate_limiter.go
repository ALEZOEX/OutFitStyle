// Пакет middleware содержит промежуточное программное обеспечение для HTTP-сервера
// Реализует различные функции, такие как ограничение скорости запросов, аутентификация и т.д.
package middleware

import (
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"golang.org/x/time/rate"
)

// RateLimiter реализует ограничение частоты запросов для различных IP-адресов
// Использует алгоритм "leaky bucket" через библиотеку golang.org/x/time/rate
type RateLimiter struct {
	visitors map[string]*visitor // Карта посетителей с их лимитерами
	mu       sync.RWMutex        // Мьютекс для безопасного доступа к карте
	rate     rate.Limit          // Максимальная частота запросов
	burst    int                 // Максимальное количество запросов за короткий период
}

// visitor представляет одного посетителя с его лимитером и временем последнего посещения
type visitor struct {
	limiter  *rate.Limiter // Лимитер запросов для конкретного посетителя
	lastSeen time.Time     // Время последнего запроса от этого посетителя
}

// NewRateLimiter создает новый экземпляр RateLimiter с заданными параметрами
// Запускает фоновую горутину для очистки старых посетителей
func NewRateLimiter(r rate.Limit, b int) *RateLimiter {
	rl := &RateLimiter{
		visitors: make(map[string]*visitor),
		rate:     r,
		burst:    b,
	}

	// Очистка старых посетителей каждую минуту
	go rl.cleanupVisitors()

	return rl
}

// getVisitor возвращает лимитер для указанного IP-адреса
// Если посетитель новый, создает для него новый лимитер
func (rl *RateLimiter) getVisitor(ip string) *rate.Limiter {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	v, exists := rl.visitors[ip]
	if !exists {
		limiter := rate.NewLimiter(rl.rate, rl.burst)
		rl.visitors[ip] = &visitor{limiter, time.Now()}
		return limiter
	}

	v.lastSeen = time.Now()
	return v.limiter
}

// cleanupVisitors удаляет посетителей, которые не делали запросы более 3 минут
// Выполняется в фоновой горутине каждую минуту
func (rl *RateLimiter) cleanupVisitors() {
	for {
		time.Sleep(time.Minute)

		rl.mu.Lock()
		for ip, v := range rl.visitors {
			if time.Since(v.lastSeen) > 3*time.Minute {
				delete(rl.visitors, ip)
			}
		}
		rl.mu.Unlock()
	}
}

// Middleware возвращает HTTP-обработчик, который ограничивает частоту запросов
// Если лимит превышен, возвращает статус 429 Too Many Requests
func (rl *RateLimiter) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Пропускаем rate limiting для health check endpoints
		// Это необходимо для корректной работы Kubernetes liveness/readiness проб
		if r.URL.Path == "/health" || r.URL.Path == "/metrics" {
			next.ServeHTTP(w, r)
			return
		}

		ip := getIP(r)
		limiter := rl.getVisitor(ip)

		if !limiter.Allow() {
			w.Header().Set("Retry-After", "60")
			http.Error(w, "Too Many Requests", http.StatusTooManyRequests)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// getIP извлекает реальный IP-адрес клиента из HTTP-запроса
// Обрабатывает заголовки X-Forwarded-For и X-Real-IP для случаев, когда запрос проходит через прокси
func getIP(r *http.Request) string {
	// Проверяем заголовок X-Forwarded-For для проксированных запросов
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		return strings.Split(strings.TrimSpace(xff), ",")[0]
	}

	if xri := r.Header.Get("X-Real-IP"); xri != "" {
		return xri
	}

	ip, _, _ := net.SplitHostPort(r.RemoteAddr)
	return ip
}
