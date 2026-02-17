// Пакет circuitbreaker предоставляет реализацию паттерна Circuit Breaker
// Защита от каскадных сбоев при работе с ненадёжными внешними сервисами
package circuitbreaker

import (
	"context"
	"errors"
	"sync"
	"time"
)

// State определяет состояние circuit breaker
type State int

const (
	// StateClosed - нормальное состояние, запросы выполняются
	StateClosed State = iota
	// StateOpen - цепь разомкнута, запросы блокируются
	StateOpen
	// StateHalfOpen - проверка восстановления сервиса
	StateHalfOpen
)

func (s State) String() string {
	switch s {
	case StateClosed:
		return "CLOSED"
	case StateOpen:
		return "OPEN"
	case StateHalfOpen:
		return "HALF_OPEN"
	default:
		return "UNKNOWN"
	}
}

// Config конфигурация circuit breaker
type Config struct {
	// Максимальное количество ошибок перед размыканием цепи
	MaxFailures int
	// Таймаут перед попыткой восстановления (состояние Half-Open)
	ResetTimeout time.Duration
	// Таймаут выполнения операции
	Timeout time.Duration
	// Количество успешных запросов в состоянии Half-Open для перехода в Closed
	HalfOpenSuccesses int
}

// DefaultConfig возвращает конфигурацию по умолчанию
func DefaultConfig() Config {
	return Config{
		MaxFailures:       5,
		ResetTimeout:      30 * time.Second,
		Timeout:           10 * time.Second,
		HalfOpenSuccesses: 3,
	}
}

// CircuitBreaker реализует паттерн Circuit Breaker
type CircuitBreaker struct {
	mu sync.RWMutex

	// Текущее состояние
	state State

	// Счётчики
	failures      int
	successes     int
	lastFailureAt time.Time

	// Конфигурация
	config Config
}

// New создаёт новый CircuitBreaker
func New(config Config) *CircuitBreaker {
	return &CircuitBreaker{
		state:  StateClosed,
		config: config,
	}
}

// Execute выполняет функцию с защитой circuit breaker
func (cb *CircuitBreaker) Execute(ctx context.Context, fn func() error) error {
	if err := cb.CanExecute(); err != nil {
		return err
	}

	// Создаём контекст с таймаутом
	execCtx, cancel := context.WithTimeout(ctx, cb.config.Timeout)
	defer cancel()

	// Канал для результата
	done := make(chan error, 1)

	go func() {
		done <- fn()
	}()

	select {
	case err := <-done:
		if err != nil {
			cb.RecordFailure()
			return err
		}
		cb.RecordSuccess()
		return nil

	case <-execCtx.Done():
		cb.RecordFailure()
		return errors.New("operation timeout")
	}
}

// CanExecute проверяет, можно ли выполнить запрос
func (cb *CircuitBreaker) CanExecute() error {
	cb.mu.Lock()
	defer cb.mu.Unlock()

	switch cb.state {
	case StateClosed:
		return nil

	case StateOpen:
		// Проверяем, не истёк ли timeout
		if time.Since(cb.lastFailureAt) > cb.config.ResetTimeout {
			cb.state = StateHalfOpen
			cb.successes = 0
			return nil
		}
		return errors.New("circuit breaker is OPEN")

	case StateHalfOpen:
		// Разрешаем выполнение для проверки
		return nil

	default:
		return errors.New("unknown circuit breaker state")
	}
}

// RecordSuccess записывает успешное выполнение
func (cb *CircuitBreaker) RecordSuccess() {
	cb.mu.Lock()
	defer cb.mu.Unlock()

	switch cb.state {
	case StateHalfOpen:
		cb.successes++
		if cb.successes >= cb.config.HalfOpenSuccesses {
			cb.state = StateClosed
			cb.failures = 0
			cb.successes = 0
		}

	case StateClosed:
		// Сбрасываем счётчик ошибок после успеха
		cb.failures = 0
	}
}

// RecordFailure записывает ошибку выполнения
func (cb *CircuitBreaker) RecordFailure() {
	cb.mu.Lock()
	defer cb.mu.Unlock()

	cb.failures++
	cb.lastFailureAt = time.Now()

	switch cb.state {
	case StateClosed:
		if cb.failures >= cb.config.MaxFailures {
			cb.state = StateOpen
		}

	case StateHalfOpen:
		// При ошибке в Half-Open состоянии сразу размыкаем цепь
		cb.state = StateOpen
	}
}

// State возвращает текущее состояние
func (cb *CircuitBreaker) State() State {
	cb.mu.RLock()
	defer cb.mu.RUnlock()
	return cb.state
}

// StateString возвращает строковое представление состояния
func (cb *CircuitBreaker) StateString() string {
	cb.mu.RLock()
	defer cb.mu.RUnlock()
	return cb.state.String()
}

// Stats возвращает статистику circuit breaker
func (cb *CircuitBreaker) Stats() (failures int, successes int, lastFailureAt time.Time) {
	cb.mu.RLock()
	defer cb.mu.RUnlock()
	return cb.failures, cb.successes, cb.lastFailureAt
}

// Reset сбрасывает circuit breaker в состояние Closed
func (cb *CircuitBreaker) Reset() {
	cb.mu.Lock()
	defer cb.mu.Unlock()

	cb.state = StateClosed
	cb.failures = 0
	cb.successes = 0
	cb.lastFailureAt = time.Time{}
}
