// Пакет queue предоставляет функциональность для работы с очередью задач
// Использует библиотеку asynq для асинхронной обработки задач через Redis
package queue

import (
	"fmt"
	"strings"

	"github.com/hibiken/asynq"
	"github.com/redis/go-redis/v9"
)

// ParseRedisURLToAsynqOpt преобразует REDIS_URL (redis://host:port/db) в asynq.RedisClientOpt
// Используется для настройки подключения к Redis для очереди задач
func ParseRedisURLToAsynqOpt(redisURL string) (asynq.RedisClientOpt, error) {
	if strings.TrimSpace(redisURL) == "" {
		return asynq.RedisClientOpt{}, fmt.Errorf("empty redis url")
	}

	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		// резервный вариант: рассматривать как адрес
		return asynq.RedisClientOpt{Addr: redisURL}, nil
	}

	return asynq.RedisClientOpt{
		Addr:     opt.Addr,
		Password: opt.Password,
		DB:       opt.DB,
	}, nil
}
