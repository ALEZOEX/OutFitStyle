package external

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"github.com/pkg/errors"
	"github.com/redis/go-redis/v9"

	"outfitstyle/server/internal/core/domain"
)

type WeatherService struct {
	provider WeatherProvider
	redis    *redis.Client
	cacheTTL time.Duration
	cacheNS  string
}

func NewWeatherService(provider WeatherProvider, redis *redis.Client, cacheTTL time.Duration, cacheNamespace string) *WeatherService {
	if cacheTTL <= 0 {
		cacheTTL = 10 * time.Minute
	}
	if cacheNamespace == "" {
		cacheNamespace = "default"
	}
	return &WeatherService{provider: provider, redis: redis, cacheTTL: cacheTTL, cacheNS: cacheNamespace}
}

type CachedCurrent struct {
	Weather   domain.WeatherSnapshot `json:"weather"`
	UpdatedAt time.Time              `json:"updated_at"`
}

type CachedForecast struct {
	Location  string    `json:"location"`
	Daily     []any     `json:"daily"`
	Hourly    []any     `json:"hourly"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (s *WeatherService) GetCurrent(ctx context.Context, lat, lon float64) (domain.WeatherSnapshot, time.Time, error) {
	key := s.key("current", lat, lon, 0)

	if s.redis != nil {
		val, err := s.redis.Get(ctx, key).Result()
		if err == nil && val != "" {
			var cached CachedCurrent
			if e := json.Unmarshal([]byte(val), &cached); e == nil {
				return cached.Weather, cached.UpdatedAt, nil
			}
		}
	}

	w, err := s.provider.Current(ctx, lat, lon)
	if err != nil {
		return domain.WeatherSnapshot{}, time.Time{}, errors.Wrap(err, "provider current")
	}

	updatedAt := time.Now()

	if s.redis != nil {
		b, _ := json.Marshal(CachedCurrent{Weather: w, UpdatedAt: updatedAt})
		_ = s.redis.Set(ctx, key, string(b), s.cacheTTL).Err()
	}

	return w, updatedAt, nil
}

func (s *WeatherService) GetForecast(ctx context.Context, lat, lon float64, days int) (string, []any, []any, time.Time, error) {
	key := s.key("forecast", lat, lon, days)

	if s.redis != nil {
		val, err := s.redis.Get(ctx, key).Result()
		if err == nil && val != "" {
			var cached CachedForecast
			if e := json.Unmarshal([]byte(val), &cached); e == nil {
				return cached.Location, cached.Daily, cached.Hourly, cached.UpdatedAt, nil
			}
		}
	}

	loc, daily, hourly, err := s.provider.Forecast(ctx, lat, lon, days)
	if err != nil {
		return "", nil, nil, time.Time{}, errors.Wrap(err, "provider forecast")
	}
	updatedAt := time.Now()

	if s.redis != nil {
		b, _ := json.Marshal(CachedForecast{Location: loc, Daily: daily, Hourly: hourly, UpdatedAt: updatedAt})
		_ = s.redis.Set(ctx, key, string(b), s.cacheTTL).Err()
	}

	return loc, daily, hourly, updatedAt, nil
}

func (s *WeatherService) key(kind string, lat, lon float64, days int) string {
	rlat := math.Round(lat*1000) / 1000
	rlon := math.Round(lon*1000) / 1000
	return fmt.Sprintf("weather:%s:%s:%.3f:%.3f:%d", s.cacheNS, kind, rlat, rlon, days)
}

// HealthCheck implements the health.Checker interface
func (s *WeatherService) HealthCheck() error {
	ctx := context.Background()
	if s.redis != nil {
		err := s.redis.Ping(ctx).Err()
		if err != nil {
			return fmt.Errorf("weather service health check failed: %w", err)
		}
	}
	return nil
}
