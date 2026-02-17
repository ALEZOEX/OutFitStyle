package middleware

import (
	"context"
	"fmt"
	"net/http"
	"sync"
	"time"

	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
)

// AccountLockoutMiddleware защищает от brute-force атак на логин
// Блокирует аккаунт после N неудачных попыток входа
type AccountLockout struct {
	redis *redis.Client
	logger *zap.Logger
	
	// Настройки блокировки
	maxAttempts   int           // Максимальное количество попыток
	lockoutDuration time.Duration // Длительность блокировки
	windowDuration  time.Duration // Окно для подсчёта попыток
	
	// In-memory fallback если Redis недоступен
	mu       sync.RWMutex
	attempts map[string]*attemptInfo
}

type attemptInfo struct {
	count      int
	firstAttempt time.Time
	lastAttempt  time.Time
	lockedUntil  time.Time
}

// NewAccountLockout создает новый middleware защиты от brute-force
func NewAccountLockout(
	redis *redis.Client,
	logger *zap.Logger,
	maxAttempts int,
	lockoutDuration time.Duration,
	windowDuration time.Duration,
) *AccountLockout {
	if maxAttempts <= 0 {
		maxAttempts = 5
	}
	if lockoutDuration <= 0 {
		lockoutDuration = 15 * time.Minute
	}
	if windowDuration <= 0 {
		windowDuration = 15 * time.Minute
	}
	
	lockout := &AccountLockout{
		redis:           redis,
		logger:          logger,
		maxAttempts:     maxAttempts,
		lockoutDuration: lockoutDuration,
		windowDuration:  windowDuration,
		attempts:        make(map[string]*attemptInfo),
	}
	
	// Очистка старых записей in-memory
	go lockout.cleanupMemory()
	
	return lockout
}

// cleanupMemory периодически очищает старые записи in-memory
func (l *AccountLockout) cleanupMemory() {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()
	
	for range ticker.C {
		l.mu.Lock()
		now := time.Now()
		for key, info := range l.attempts {
			if now.Sub(info.lastAttempt) > l.windowDuration*2 {
				delete(l.attempts, key)
			}
		}
		l.mu.Unlock()
	}
}

// CheckLoginAttempt проверяет, не заблокирован ли аккаунт
// Возвращает true если вход разрешён, false если заблокирован
func (l *AccountLockout) CheckLoginAttempt(ctx context.Context, identifier string) (allowed bool, remainingAttempts int, lockedUntil *time.Time, err error) {
	// Пытаемся использовать Redis
	if l.redis != nil {
		return l.checkRedis(ctx, identifier)
	}
	
	// Fallback на in-memory
	return l.checkMemory(identifier)
}

func (l *AccountLockout) checkRedis(ctx context.Context, identifier string) (bool, int, *time.Time, error) {
	lockKey := fmt.Sprintf("lockout:%s", identifier)
	attemptKey := fmt.Sprintf("lockout:attempts:%s", identifier)
	
	// Проверяем, есть ли активная блокировка
	ttl, err := l.redis.TTL(ctx, lockKey).Result()
	if err == nil && ttl > 0 {
		until := time.Now().Add(ttl)
		l.logger.Warn("Account locked",
			zap.String("identifier", identifier),
			zap.Duration("ttl", ttl),
		)
		return false, 0, &until, nil
	}
	
	// Получаем количество попыток
	attemptsStr, err := l.redis.Get(ctx, attemptKey).Result()
	if err == redis.Nil {
		// Попыток ещё не было
		return true, l.maxAttempts, nil, nil
	}
	if err != nil {
		// Ошибка Redis, разрешаем вход (graceful degradation)
		l.logger.Error("Redis error in lockout check, allowing", zap.Error(err))
		return true, l.maxAttempts, nil, nil
	}
	
	// Парсим количество попыток
	var attempts int
	fmt.Sscanf(attemptsStr, "%d", &attempts)
	
	remaining := l.maxAttempts - attempts
	if remaining < 0 {
		remaining = 0
	}
	
	if attempts >= l.maxAttempts {
		// Превышено количество попыток, но блокировка ещё не установлена
		// Это значит что окно истекло, сбрасываем
		_ = l.redis.Del(ctx, attemptKey).Err()
		return true, l.maxAttempts, nil, nil
	}
	
	return true, remaining, nil, nil
}

func (l *AccountLockout) checkMemory(identifier string) (bool, int, *time.Time, error) {
	l.mu.RLock()
	info, exists := l.attempts[identifier]
	l.mu.RUnlock()
	
	if !exists {
		return true, l.maxAttempts, nil, nil
	}
	
	now := time.Now()
	
	// Проверяем, не истекло ли окно
	if now.Sub(info.firstAttempt) > l.windowDuration {
		// Окно истекло, сбрасываем
		l.mu.Lock()
		delete(l.attempts, identifier)
		l.mu.Unlock()
		return true, l.maxAttempts, nil, nil
	}
	
	// Проверяем активную блокировку
	if !info.lockedUntil.IsZero() && now.Before(info.lockedUntil) {
		remaining := info.lockedUntil.Sub(now)
		return false, 0, &remaining, nil
	}
	
	// Блокировка истекла, сбрасываем
	if !info.lockedUntil.IsZero() && now.After(info.lockedUntil) {
		l.mu.Lock()
		delete(l.attempts, identifier)
		l.mu.Unlock()
		return true, l.maxAttempts, nil, nil
	}
	
	remaining := l.maxAttempts - info.count
	if remaining < 0 {
		remaining = 0
	}
	
	return true, remaining, nil, nil
}

// RecordFailedAttempt записывает неудачную попытку входа
// При превышении лимита блокирует аккаунт
func (l *AccountLockout) RecordFailedAttempt(ctx context.Context, identifier string) error {
	if l.redis != nil {
		return l.recordRedis(ctx, identifier)
	}
	return l.recordMemory(identifier)
}

func (l *AccountLockout) recordRedis(ctx context.Context, identifier string) error {
	attemptKey := fmt.Sprintf("lockout:attempts:%s", identifier)
	lockKey := fmt.Sprintf("lockout:%s", identifier)
	
	// Увеличиваем счётчик попыток
	newCount, err := l.redis.Incr(ctx, attemptKey).Result()
	if err != nil {
		return fmt.Errorf("failed to increment attempt counter: %w", err)
	}
	
	// Устанавливаем TTL для окна
	if newCount == 1 {
		_ = l.redis.Expire(ctx, attemptKey, l.windowDuration).Err()
	}
	
	// Проверяем, не превышен ли лимит
	if int(newCount) >= l.maxAttempts {
		// Блокируем аккаунт
		_ = l.redis.Set(ctx, lockKey, "locked", l.lockoutDuration).Err()
		
		l.logger.Warn("Account locked due to too many failed attempts",
			zap.String("identifier", identifier),
			zap.Int64("attempts", newCount),
			zap.Duration("lockout_duration", l.lockoutDuration),
		)
	}
	
	return nil
}

func (l *AccountLockout) recordMemory(identifier string) error {
	l.mu.Lock()
	defer l.mu.Unlock()
	
	now := time.Now()
	info, exists := l.attempts[identifier]
	
	if !exists {
		info = &attemptInfo{
			count:        0,
			firstAttempt: now,
		}
		l.attempts[identifier] = info
	}
	
	// Проверяем, не истекло ли окно
	if now.Sub(info.firstAttempt) > l.windowDuration {
		// Сбрасываем
		info.count = 0
		info.firstAttempt = now
		info.lockedUntil = time.Time{}
	}
	
	info.count++
	info.lastAttempt = now
	
	// Проверяем, не превышен ли лимит
	if info.count >= l.maxAttempts {
		info.lockedUntil = now.Add(l.lockoutDuration)
		
		l.logger.Warn("Account locked (in-memory)",
			zap.String("identifier", identifier),
			zap.Int("attempts", info.count),
			zap.Duration("lockout_duration", l.lockoutDuration),
		)
	}
	
	return nil
}

// Reset сбрасывает счётчик попыток (например, после успешного входа)
func (l *AccountLockout) Reset(ctx context.Context, identifier string) error {
	if l.redis != nil {
		attemptKey := fmt.Sprintf("lockout:attempts:%s", identifier)
		_ = l.redis.Del(ctx, attemptKey).Err()
	}
	
	l.mu.Lock()
	delete(l.attempts, identifier)
	l.mu.Unlock()
	
	return nil
}

// AccountLockoutMiddleware создаёт middleware для защиты от brute-force
func (l *AccountLockout) Middleware() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Извлекаем identifier (email или IP)
			identifier := r.FormValue("email")
			if identifier == "" {
				// Пытаемся получить из JSON body (для POST)
				// Это упрощённая версия, в production лучше парсить body заранее
				identifier = r.RemoteAddr
			}
			
			allowed, remaining, lockedUntil, err := l.CheckLoginAttempt(r.Context(), identifier)
			
			// Добавляем заголовки с информацией о rate limit
			w.Header().Set("X-Login-Attempts-Remaining", fmt.Sprintf("%d", remaining))
			
			if !allowed {
				w.Header().Set("Retry-After", fmt.Sprintf("%d", int(l.lockoutDuration.Seconds())))
				http.Error(w, "Too many failed login attempts. Please try again later.", http.StatusTooManyRequests)
				return
			}
			
			if err != nil {
				l.logger.Error("Account lockout check error", zap.Error(err))
				// Не блокируем вход при ошибке проверки (graceful degradation)
			}
			
			next.ServeHTTP(w, r)
		})
	}
}
