// Пакет redis предоставляет реализации репозиториев для хранения данных в Redis
// Включая кэширование, сессии и blacklist токенов
package redis

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// TokenBlacklistRepository интерфейс для управления blacklist токенов
type TokenBlacklistRepository interface {
	// Add добавляет токен в blacklist с указанным TTL
	Add(ctx context.Context, jti string, ttl time.Duration) error
	// IsBlacklisted проверяет, находится ли токен в blacklist
	IsBlacklisted(ctx context.Context, jti string) (bool, error)
	// Remove удаляет токен из blacklist (если нужно)
	Remove(ctx context.Context, jti string) error
}

// tokenBlacklistRepository реализация TokenBlacklistRepository
type tokenBlacklistRepository struct {
	redis *redis.Client
	// Ключ неймспейс для blacklist токенов
	keyPrefix string
}

// NewTokenBlacklistRepository создает новый репозиторий blacklist токенов
func NewTokenBlacklistRepository(redisClient *redis.Client) TokenBlacklistRepository {
	return &tokenBlacklistRepository{
		redis:     redisClient,
		keyPrefix: "auth:blacklist:access:",
	}
}

// Add добавляет токен в blacklist с указанным TTL
// TTL должен равняться оставшемуся времени жизни access токена
func (r *tokenBlacklistRepository) Add(ctx context.Context, jti string, ttl time.Duration) error {
	if ttl <= 0 {
		// Токен уже истёк, нет смысла добавлять в blacklist
		return nil
	}

	key := fmt.Sprintf("%s%s", r.keyPrefix, jti)
	// Используем SET с EX для атомарной установки с TTL
	return r.redis.Set(ctx, key, "1", ttl).Err()
}

// IsBlacklisted проверяет, находится ли токен в blacklist
func (r *tokenBlacklistRepository) IsBlacklisted(ctx context.Context, jti string) (bool, error) {
	key := fmt.Sprintf("%s%s", r.keyPrefix, jti)
	exists, err := r.redis.Exists(ctx, key).Result()
	if err != nil {
		return false, err
	}
	return exists > 0, nil
}

// Remove удаляет токен из blacklist
// Обычно не используется, так как blacklist очищается автоматически по TTL
func (r *tokenBlacklistRepository) Remove(ctx context.Context, jti string) error {
	key := fmt.Sprintf("%s%s", r.keyPrefix, jti)
	return r.redis.Del(ctx, key).Err()
}
