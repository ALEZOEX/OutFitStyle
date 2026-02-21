package cache

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

const (
	// RecommendationCachePrefix — префикс ключей кэша рекомендаций
	RecommendationCachePrefix = "rec:ml"

	// DefaultRecommendationTTL — время жизни кэша рекомендаций по умолчанию
	DefaultRecommendationTTL = 10 * time.Minute

	// MLHealthStatusTTL — время жизни статуса health check ML
	MLHealthStatusTTL = 30 * time.Second

	// MLHealthStatusKey — ключ для кэширования статуса ML
	MLHealthStatusKey = "ml:health:status"
)

// RecommendationCache — кэш для результатов ML рекомендаций
type RecommendationCache struct {
	client *redis.Client
	logger *zap.Logger
	ttl    time.Duration
}

// MLHealthStatus — статус доступности ML сервиса
type MLHealthStatus struct {
	Healthy   bool      `json:"healthy"`
	CheckedAt time.Time `json:"checked_at"`
	LatencyMs int       `json:"latency_ms,omitempty"`
	Error     string    `json:"error,omitempty"`
}

// NewRecommendationCache создает новый экземпляр кэша рекомендаций
func NewRecommendationCache(client *redis.Client, logger *zap.Logger, ttl time.Duration) *RecommendationCache {
	return &RecommendationCache{
		client: client,
		logger: logger,
		ttl:    ttl,
	}
}

// CacheKey генерирует ключ кэша на основе параметров запроса
func (c *RecommendationCache) CacheKey(userID domain.ID, contextHash string) string {
	return fmt.Sprintf("%s:%s:%s", RecommendationCachePrefix, userID.String(), contextHash)
}

// Get получает результат ранжирования из кэша
func (c *RecommendationCache) Get(ctx context.Context, key string) (*external.TZMLRankResponse, bool, error) {
	data, err := c.client.Get(ctx, key).Result()
	if err != nil {
		if err == redis.Nil {
			return nil, false, nil
		}
		c.logger.Error("Ошибка получения из кэша рекомендаций", zap.String("key", key), zap.Error(err))
		return nil, false, err
	}

	var response external.TZMLRankResponse
	if err := json.Unmarshal([]byte(data), &response); err != nil {
		c.logger.Error("Ошибка десериализации кэша рекомендаций", zap.String("key", key), zap.Error(err))
		return nil, false, err
	}

	c.logger.Debug("Кэш рекомендаций hit", zap.String("key", key))
	return &response, true, nil
}

// Set сохраняет результат ранжирования в кэш
func (c *RecommendationCache) Set(ctx context.Context, key string, response *external.TZMLRankResponse) error {
	data, err := json.Marshal(response)
	if err != nil {
		c.logger.Error("Ошибка сериализации кэша рекомендаций", zap.String("key", key), zap.Error(err))
		return err
	}

	if err := c.client.Set(ctx, key, data, c.ttl).Err(); err != nil {
		c.logger.Error("Ошибка сохранения в кэш рекомендаций", zap.String("key", key), zap.Error(err))
		return err
	}

	c.logger.Debug("Кэш рекомендаций saved", zap.String("key", key), zap.Duration("ttl", c.ttl))
	return nil
}

// Delete удаляет результат из кэша
func (c *RecommendationCache) Delete(ctx context.Context, key string) error {
	if err := c.client.Del(ctx, key).Err(); err != nil {
		c.logger.Error("Ошибка удаления из кэша рекомендаций", zap.String("key", key), zap.Error(err))
		return err
	}
	return nil
}

// InvalidateUser инвалидирует весь кэш рекомендаций для пользователя
// Вызывается при изменении гардероба или предпочтений пользователя
func (c *RecommendationCache) InvalidateUser(ctx context.Context, userID domain.ID) error {
	pattern := fmt.Sprintf("%s:%s:*", RecommendationCachePrefix, userID.String())

	iter := c.client.Scan(ctx, 0, pattern, 0).Iterator()
	deleted := 0

	for iter.Next(ctx) {
		key := iter.Val()
		if err := c.client.Del(ctx, key).Err(); err != nil {
			c.logger.Error("Ошибка инвалидации кэша рекомендации", zap.String("key", key), zap.Error(err))
		} else {
			deleted++
		}
	}

	if err := iter.Err(); err != nil {
		c.logger.Error("Ошибка итерации при инвалидации кэша", zap.String("pattern", pattern), zap.Error(err))
		return err
	}

	c.logger.Info("Инвалидирован кэш рекомендаций пользователя",
		zap.String("user_id", userID.String()),
		zap.Int("deleted_keys", deleted))

	return nil
}

// GetOrCompute получает из кэша или вычисляет значение
func (c *RecommendationCache) GetOrCompute(
	ctx context.Context,
	key string,
	compute func() (*external.TZMLRankResponse, error),
) (*external.TZMLRankResponse, bool, error) {

	// Попытка получить из кэша
	response, found, err := c.Get(ctx, key)
	if err != nil {
		c.logger.Warn("Ошибка чтения кэша, вычисляем заново", zap.Error(err))
	}
	if found && response != nil {
		return response, true, nil
	}

	// Вычисляем значение
	response, err = compute()
	if err != nil {
		return nil, false, err
	}

	// Сохраняем в кэш
	if err := c.Set(ctx, key, response); err != nil {
		c.logger.Warn("Не удалось сохранить в кэш", zap.Error(err))
	}

	return response, false, nil
}

// GenerateContextHash генерирует хэш контекста для кэширования
func (c *RecommendationCache) GenerateContextHash(
	temperature float64,
	weatherCode string,
	occasion string,
	style string,
	formality int,
) string {
	input := fmt.Sprintf("%.1f:%s:%s:%s:%d", temperature, weatherCode, occasion, style, formality)
	hash := sha256.Sum256([]byte(input))
	return hex.EncodeToString(hash[:8]) // Используем первые 8 байт
}

// SetMLHealthStatus сохраняет статус health check ML сервиса
func (c *RecommendationCache) SetMLHealthStatus(ctx context.Context, status MLHealthStatus) error {
	data, err := json.Marshal(status)
	if err != nil {
		c.logger.Error("Ошибка сериализации ML health status", zap.Error(err))
		return err
	}

	if err := c.client.Set(ctx, MLHealthStatusKey, data, MLHealthStatusTTL).Err(); err != nil {
		c.logger.Error("Ошибка сохранения ML health status", zap.Error(err))
		return err
	}

	return nil
}

// GetMLHealthStatus получает статус health check ML сервиса
func (c *RecommendationCache) GetMLHealthStatus(ctx context.Context) (*MLHealthStatus, error) {
	data, err := c.client.Get(ctx, MLHealthStatusKey).Result()
	if err != nil {
		if err == redis.Nil {
			return nil, nil
		}
		return nil, err
	}

	var status MLHealthStatus
	if err := json.Unmarshal([]byte(data), &status); err != nil {
		c.logger.Error("Ошибка десериализации ML health status", zap.Error(err))
		return nil, err
	}

	return &status, nil
}

// IsMLHealthy проверяет, здоров ли ML сервис (с учетом кэша)
func (c *RecommendationCache) IsMLHealthy(ctx context.Context) (bool, error) {
	status, err := c.GetMLHealthStatus(ctx)
	if err != nil {
		return false, err
	}
	if status == nil {
		return false, nil
	}

	// Проверяем, не истекло ли время жизни статуса
	if time.Since(status.CheckedAt) > MLHealthStatusTTL {
		return false, nil
	}

	return status.Healthy, nil
}

// ClearAll очищает весь кэш рекомендаций (для отладки/сброса)
func (c *RecommendationCache) ClearAll(ctx context.Context) error {
	pattern := RecommendationCachePrefix + ":*"

	iter := c.client.Scan(ctx, 0, pattern, 0).Iterator()
	deleted := 0

	for iter.Next(ctx) {
		key := iter.Val()
		if err := c.client.Del(ctx, key).Err(); err != nil {
			c.logger.Error("Ошибка очистки кэша", zap.String("key", key), zap.Error(err))
		} else {
			deleted++
		}
	}

	if err := iter.Err(); err != nil {
		return err
	}

	c.logger.Info("Очищен весь кэш рекомендаций", zap.Int("deleted_keys", deleted))
	return nil
}
