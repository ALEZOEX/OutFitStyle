package queue

import (
	"fmt"
	"strings"

	"github.com/hibiken/asynq"
	"github.com/redis/go-redis/v9"
)

// ParseRedisURLToAsynqOpt converts REDIS_URL (redis://host:port/db) to asynq.RedisClientOpt.
func ParseRedisURLToAsynqOpt(redisURL string) (asynq.RedisClientOpt, error) {
	if strings.TrimSpace(redisURL) == "" {
		return asynq.RedisClientOpt{}, fmt.Errorf("empty redis url")
	}

	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		// fallback: treat as addr
		return asynq.RedisClientOpt{Addr: redisURL}, nil
	}

	return asynq.RedisClientOpt{
		Addr:     opt.Addr,
		Password: opt.Password,
		DB:       opt.DB,
	}, nil
}