package cache

import (
	"context"
	"testing"
	"time"

	"github.com/alicebob/miniredis/v2"
	"github.com/redis/go-redis/v9"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

func setupTestRedis(t *testing.T) (*redis.Client, *miniredis.Miniredis, func()) {
	t.Helper()

	mr, err := miniredis.Run()
	require.NoError(t, err)

	client := redis.NewClient(&redis.Options{
		Addr: mr.Addr(),
	})

	cleanup := func() {
		client.Close()
		mr.Close()
	}

	return client, mr, cleanup
}

func TestRecommendationCache_NewRecommendationCache(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	ttl := 5 * time.Minute

	cache := NewRecommendationCache(client, logger, ttl)

	assert.NotNil(t, cache)
	assert.Equal(t, ttl, cache.ttl)
}

func TestRecommendationCache_CacheKey(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	userID := domain.NewID()
	contextHash := "abc123"

	key := cache.CacheKey(userID, contextHash)

	expected := "rec:ml:" + userID.String() + ":abc123"
	assert.Equal(t, expected, key)
}

func TestRecommendationCache_GetOrCompute_CacheMiss(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:key"

	computeCalled := false
	compute := func() (*external.TZMLRankResponse, error) {
		computeCalled = true
		return &external.TZMLRankResponse{
			RequestID:        "req-123",
			ModelVersion:     "test-model-v1",
			ProcessingTimeMs: 100,
			StyleCoherence:   0.8,
			ColorHarmony:     0.7,
			Rankings: map[string][]external.TZMLRankedItem{
				"upper": {
					{ID: domain.NewID(), Score: 0.9, Confidence: 0.85},
				},
			},
		}, nil
	}

	response, found, err := cache.GetOrCompute(ctx, key, compute)

	require.NoError(t, err)
	assert.False(t, found)
	assert.True(t, computeCalled)
	assert.NotNil(t, response)
	assert.Equal(t, "test-model-v1", response.ModelVersion)

	// Проверяем, что значение сохранилось в кэш
	cachedResponse, found, err := cache.Get(ctx, key)
	require.NoError(t, err)
	assert.True(t, found)
	assert.Equal(t, "test-model-v1", cachedResponse.ModelVersion)
}

func TestRecommendationCache_GetOrCompute_CacheHit(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:key:hit"

	// Сначала сохраняем значение
	originalResponse := &external.TZMLRankResponse{
		RequestID:        "req-456",
		ModelVersion:     "cached-model",
		ProcessingTimeMs: 50,
	}
	err := cache.Set(ctx, key, originalResponse)
	require.NoError(t, err)

	computeCalled := false
	compute := func() (*external.TZMLRankResponse, error) {
		computeCalled = true
		return &external.TZMLRankResponse{
			ModelVersion: "new-model",
		}, nil
	}

	response, found, err := cache.GetOrCompute(ctx, key, compute)

	require.NoError(t, err)
	assert.True(t, found)
	assert.False(t, computeCalled)
	assert.Equal(t, "cached-model", response.ModelVersion)
}

func TestRecommendationCache_GetOrCompute_ComputeError(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:key:error"

	computeError := assert.AnError
	compute := func() (*external.TZMLRankResponse, error) {
		return nil, computeError
	}

	response, found, err := cache.GetOrCompute(ctx, key, compute)

	assert.Error(t, err)
	assert.False(t, found)
	assert.Nil(t, response)
}

func TestRecommendationCache_SetAndGet(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:setget"

	response := &external.TZMLRankResponse{
		RequestID:        "req-789",
		ModelVersion:     "model-v2",
		ProcessingTimeMs: 150,
		StyleCoherence:   0.85,
		ColorHarmony:     0.75,
		OutfitScore:      0.8,
		Rankings: map[string][]external.TZMLRankedItem{
			"outerwear": {
				{ID: domain.NewID(), Score: 0.95, Confidence: 0.9},
				{ID: domain.NewID(), Score: 0.85, Confidence: 0.8},
			},
			"upper": {
				{ID: domain.NewID(), Score: 0.9, Confidence: 0.85},
			},
		},
	}

	err := cache.Set(ctx, key, response)
	require.NoError(t, err)

	cached, found, err := cache.Get(ctx, key)
	require.NoError(t, err)
	assert.True(t, found)
	assert.NotNil(t, cached)
	assert.Equal(t, response.RequestID, cached.RequestID)
	assert.Equal(t, response.ModelVersion, cached.ModelVersion)
	assert.Equal(t, response.ProcessingTimeMs, cached.ProcessingTimeMs)
	assert.InDelta(t, response.StyleCoherence, cached.StyleCoherence, 0.001)
	assert.InDelta(t, response.ColorHarmony, cached.ColorHarmony, 0.001)
}

func TestRecommendationCache_Get_NotFound(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:notfound"

	response, found, err := cache.Get(ctx, key)

	require.NoError(t, err)
	assert.False(t, found)
	assert.Nil(t, response)
}

func TestRecommendationCache_Delete(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:delete"

	// Сначала сохраняем
	response := &external.TZMLRankResponse{
		ModelVersion: "to-delete",
	}
	err := cache.Set(ctx, key, response)
	require.NoError(t, err)

	// Проверяем, что сохранилось
	_, found, err := cache.Get(ctx, key)
	require.True(t, found)

	// Удаляем
	err = cache.Delete(ctx, key)
	require.NoError(t, err)

	// Проверяем, что удалено
	_, found, err = cache.Get(ctx, key)
	require.NoError(t, err)
	assert.False(t, found)
}

func TestRecommendationCache_InvalidateUser(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	userID := domain.NewID()

	// Создаем несколько ключей для пользователя
	keys := []string{
		cache.CacheKey(userID, "hash1"),
		cache.CacheKey(userID, "hash2"),
		cache.CacheKey(userID, "hash3"),
	}

	for _, key := range keys {
		err := cache.Set(ctx, key, &external.TZMLRankResponse{
			ModelVersion: "user-rec",
		})
		require.NoError(t, err)
	}

	// Создаем ключ для другого пользователя (не должен удалиться)
	otherUser := domain.NewID()
	otherKey := cache.CacheKey(otherUser, "hash1")
	err := cache.Set(ctx, otherKey, &external.TZMLRankResponse{
		ModelVersion: "other-user-rec",
	})
	require.NoError(t, err)

	// Инвалидируем кэш первого пользователя
	err = cache.InvalidateUser(ctx, userID)
	require.NoError(t, err)

	// Проверяем, что ключи первого пользователя удалены
	for _, key := range keys {
		_, found, err := cache.Get(ctx, key)
		require.NoError(t, err)
		assert.False(t, found, "Ключ %s должен быть удален", key)
	}

	// Проверяем, что ключ другого пользователя остался
	_, found, err := cache.Get(ctx, otherKey)
	require.NoError(t, err)
	assert.True(t, found, "Ключ другого пользователя должен остаться")
}

func TestRecommendationCache_GenerateContextHash(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	// Одинаковые параметры -> одинаковый хэш
	hash1 := cache.GenerateContextHash(15.0, "04d", "work", "casual", 2)
	hash2 := cache.GenerateContextHash(15.0, "04d", "work", "casual", 2)
	assert.Equal(t, hash1, hash2)

	// Разные параметры -> разные хэши
	hash3 := cache.GenerateContextHash(20.0, "04d", "work", "casual", 2)
	assert.NotEqual(t, hash1, hash3)

	hash4 := cache.GenerateContextHash(15.0, "01d", "work", "casual", 2)
	assert.NotEqual(t, hash1, hash4)

	hash5 := cache.GenerateContextHash(15.0, "04d", "party", "casual", 2)
	assert.NotEqual(t, hash1, hash5)

	hash6 := cache.GenerateContextHash(15.0, "04d", "work", "business", 2)
	assert.NotEqual(t, hash1, hash6)

	hash7 := cache.GenerateContextHash(15.0, "04d", "work", "casual", 3)
	assert.NotEqual(t, hash1, hash7)
}

func TestRecommendationCache_MLHealthStatus(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()

	// Создаем статус
	status := MLHealthStatus{
		Healthy:   true,
		CheckedAt: time.Now(),
		LatencyMs: 50,
	}

	err := cache.SetMLHealthStatus(ctx, status)
	require.NoError(t, err)

	// Получаем статус
	retrieved, err := cache.GetMLHealthStatus(ctx)
	require.NoError(t, err)
	assert.NotNil(t, retrieved)
	assert.True(t, retrieved.Healthy)
	assert.Equal(t, status.LatencyMs, retrieved.LatencyMs)
}

func TestRecommendationCache_IsMLHealthy(t *testing.T) {
	client, mr, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()

	// Когда статус не установлен
	healthy, err := cache.IsMLHealthy(ctx)
	require.NoError(t, err)
	assert.False(t, healthy)

	// Устанавливаем здоровый статус
	status := MLHealthStatus{
		Healthy:   true,
		CheckedAt: time.Now(),
		LatencyMs: 50,
	}
	err = cache.SetMLHealthStatus(ctx, status)
	require.NoError(t, err)

	healthy, err = cache.IsMLHealthy(ctx)
	require.NoError(t, err)
	assert.True(t, healthy)

	// Устанавливаем нездоровый статус
	status.Healthy = false
	status.Error = "connection refused"
	err = cache.SetMLHealthStatus(ctx, status)
	require.NoError(t, err)

	healthy, err = cache.IsMLHealthy(ctx)
	require.NoError(t, err)
	assert.False(t, healthy)

	// Проверяем TTL - статус должен протухнуть
	mr.FastForward(MLHealthStatusTTL + 1*time.Second)
	healthy, err = cache.IsMLHealthy(ctx)
	require.NoError(t, err)
	assert.False(t, healthy) // Истекло время жизни
}

func TestRecommendationCache_ClearAll(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()

	// Создаем несколько ключей
	keys := []string{
		RecommendationCachePrefix + ":user1:hash1",
		RecommendationCachePrefix + ":user1:hash2",
		RecommendationCachePrefix + ":user2:hash1",
	}

	for _, key := range keys {
		err := cache.Set(ctx, key, &external.TZMLRankResponse{
			ModelVersion: "test",
		})
		require.NoError(t, err)
	}

	// Очищаем всё
	err := cache.ClearAll(ctx)
	require.NoError(t, err)

	// Проверяем, что все ключи удалены
	for _, key := range keys {
		_, found, err := cache.Get(ctx, key)
		require.NoError(t, err)
		assert.False(t, found, "Ключ %s должен быть удален", key)
	}
}

func TestRecommendationCache_ConcurrentAccess(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:concurrent"

	// Запускаем несколько горутин для записи
	done := make(chan bool, 10)
	for i := 0; i < 10; i++ {
		go func(id int) {
			response := &external.TZMLRankResponse{
				ModelVersion:     "model-" + string(rune(id)),
				ProcessingTimeMs: id * 10,
			}
			_ = cache.Set(ctx, key, response)
			done <- true
		}(i)
	}

	// Ждем завершения
	for i := 0; i < 10; i++ {
		<-done
	}

	// Проверяем, что кэш работает
	_, found, err := cache.Get(ctx, key)
	require.NoError(t, err)
	assert.True(t, found)
}

func TestRecommendationCache_LargeResponse(t *testing.T) {
	client, _, cleanup := setupTestRedis(t)
	defer cleanup()

	logger := zap.NewNop()
	cache := NewRecommendationCache(client, logger, 10*time.Minute)

	ctx := context.Background()
	key := "test:large"

	// Создаем большой ответ с множеством элементов
	rankings := make(map[string][]external.TZMLRankedItem)
	categories := []string{"outerwear", "upper", "lower", "footwear", "accessory"}
	
	for _, cat := range categories {
		items := make([]external.TZMLRankedItem, 50)
		for i := 0; i < 50; i++ {
			items[i] = external.TZMLRankedItem{
				ID:         domain.NewID(),
				Score:      float64(i) / 50.0,
				Confidence: 0.9,
			}
		}
		rankings[cat] = items
	}

	response := &external.TZMLRankResponse{
		RequestID:        "large-req",
		ModelVersion:     "large-model",
		ProcessingTimeMs: 500,
		StyleCoherence:   0.85,
		ColorHarmony:     0.8,
		OutfitScore:      0.82,
		Rankings:         rankings,
	}

	err := cache.Set(ctx, key, response)
	require.NoError(t, err)

	cached, found, err := cache.Get(ctx, key)
	require.NoError(t, err)
	assert.True(t, found)
	assert.NotNil(t, cached)
	assert.Equal(t, len(rankings), len(cached.Rankings))
	
	for _, cat := range categories {
		assert.Equal(t, 50, len(cached.Rankings[cat]))
	}
}
