package cache

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/rs/xid"
	"go.uber.org/zap"
)

const (
	// DefaultCacheTTL - время жизни кэша по умолчанию
	DefaultCacheTTL = 10 * time.Minute
)

// RepositoryCache - интерфейс для кэширования репозиториев
type RepositoryCache struct {
	client *redis.Client
	logger *zap.Logger
}

// NewRepositoryCache - создает новый экземпляр кэша для репозиториев
func NewRepositoryCache(client *redis.Client, logger *zap.Logger) *RepositoryCache {
	return &RepositoryCache{
		client: client,
		logger: logger,
	}
}

// Get - получить значение из кэша
func (rc *RepositoryCache) Get(ctx context.Context, key string, dest interface{}) error {
	val, err := rc.client.Get(ctx, key).Result()
	if err != nil {
		if err == redis.Nil {
			return nil // ключ не найден
		}
		rc.logger.Error("Ошибка получения из кэша", zap.String("key", key), zap.Error(err))
		return err
	}

	if err := json.Unmarshal([]byte(val), dest); err != nil {
		rc.logger.Error("Ошибка десериализации из кэша", zap.String("key", key), zap.Error(err))
		return err
	}

	return nil
}

// Set - установить значение в кэш
func (rc *RepositoryCache) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
	data, err := json.Marshal(value)
	if err != nil {
		rc.logger.Error("Ошибка сериализации в кэш", zap.String("key", key), zap.Error(err))
		return err
	}

	if err := rc.client.Set(ctx, key, data, ttl).Err(); err != nil {
		rc.logger.Error("Ошибка установки в кэш", zap.String("key", key), zap.Error(err))
		return err
	}

	return nil
}

// Delete - удалить значение из кэша
func (rc *RepositoryCache) Delete(ctx context.Context, key string) error {
	if err := rc.client.Del(ctx, key).Err(); err != nil {
		rc.logger.Error("Ошибка удаления из кэша", zap.String("key", key), zap.Error(err))
		return err
	}
	return nil
}

// GenerateKey - генерирует ключ кэша с префиксом
func (rc *RepositoryCache) GenerateKey(prefix string, args ...interface{}) string {
	key := prefix
	for _, arg := range args {
		key += fmt.Sprintf(":%v", arg)
	}
	return key
}

// InvalidatePattern - инвалидирует все ключи, соответствующие шаблону
func (rc *RepositoryCache) InvalidatePattern(ctx context.Context, pattern string) error {
	iter := rc.client.Scan(ctx, 0, pattern, 0).Iterator()
	for iter.Next(ctx) {
		key := iter.Val()
		if err := rc.client.Del(ctx, key).Err(); err != nil {
			rc.logger.Error("Ошибка инвалидации кэша по шаблону", zap.String("key", key), zap.Error(err))
		}
	}
	if err := iter.Err(); err != nil {
		rc.logger.Error("Ошибка итерации по ключам кэша", zap.String("pattern", pattern), zap.Error(err))
		return err
	}
	return nil
}

// WithCache - универсальная функция для кэширования результатов
func (rc *RepositoryCache) WithCache(
	ctx context.Context,
	cacheKey string,
	cacheTTL time.Duration,
	loadFunc func() (interface{}, error),
	dest interface{},
) error {
	// Попытка получить из кэша
	if err := rc.Get(ctx, cacheKey, dest); err != nil {
		return err
	}

	// Если в кэше нет данных, загружаем и сохраняем
	if dest == nil || isEmpty(dest) {
		result, err := loadFunc()
		if err != nil {
			return err
		}

		if err := rc.Set(ctx, cacheKey, result, cacheTTL); err != nil {
			// Не возвращаем ошибку кэширования, просто логируем
			rc.logger.Warn("Ошибка сохранения в кэш", zap.String("key", cacheKey), zap.Error(err))
		}

		// Копируем результат в dest
		data, err := json.Marshal(result)
		if err != nil {
			return err
		}
		return json.Unmarshal(data, dest)
	}

	return nil
}

// isEmpty проверяет, является ли значение пустым
func isEmpty(v interface{}) bool {
	if v == nil {
		return true
	}

	switch val := v.(type) {
	case string:
		return val == ""
	case []byte:
		return len(val) == 0
	case int:
		return val == 0
	case *int:
		return val == nil || *val == 0
	case []interface{}:
		return len(val) == 0
	default:
		// Для других типов проверяем через JSON сериализацию
		data, err := json.Marshal(v)
		if err != nil {
			return true
		}
		return string(data) == "null" || string(data) == "{}" || string(data) == "[]" || string(data) == "\"\""
	}
}

// GenerateCacheKeyWithSalt - генерирует ключ кэша с солью для предотвращения коллизий
func (rc *RepositoryCache) GenerateCacheKeyWithSalt(prefix string, salt string, args ...interface{}) string {
	key := fmt.Sprintf("%s:%s", prefix, salt)
	for _, arg := range args {
		key += fmt.Sprintf(":%v", arg)
	}
	return key
}

// GenerateRandomSalt - генерирует случайную соль для кэша
func (rc *RepositoryCache) GenerateRandomSalt() string {
	return xid.New().String()
}