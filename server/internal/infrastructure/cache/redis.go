package cache

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/redis/go-redis/v9"
)

func NewRedisClient(redisURL, password string) (*redis.Client, error) {
	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		// fallback: treat as addr
		opt = &redis.Options{
			Addr: redisURL,
		}
	}
	if password != "" {
		opt.Password = password
	}

	// Настройка TLS для rediss:// схемы
	if opt.TLSConfig != nil || isTLSURL(redisURL) {
		tlsConfig, err := buildRedisTLSConfig()
		if err != nil {
			return nil, fmt.Errorf("failed to configure Redis TLS: %w", err)
		}
		opt.TLSConfig = tlsConfig
	}

	c := redis.NewClient(opt)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	if err := c.Ping(ctx).Err(); err != nil {
		_ = c.Close()
		return nil, err
	}

	return c, nil
}

// isTLSURL проверяет используется ли TLS (rediss://)
func isTLSURL(url string) bool {
	return len(url) >= 8 && url[:8] == "rediss://"
}

// buildRedisTLSConfig создаёт TLS конфигурацию для Redis
func buildRedisTLSConfig() (*tls.Config, error) {
	config := &tls.Config{
		MinVersion: tls.VersionTLS12,
	}

	// Загружаем CA сертификат для верификации сервера
	caCertPath := os.Getenv("REDIS_TLS_CA_CERT")
	if caCertPath == "" {
		caCertPath = "/etc/ssl/certs/internal-ca.crt"
	}

	// G304: Используем os.Root для ограничения доступа к файлам
	root := os.DirFS("/etc/ssl/certs")
	// G703: Проверяем существование файла
	stat, statErr := os.Stat(caCertPath)
	if statErr == nil && !stat.IsDir() {
		file, err := root.Open(filepath.Base(caCertPath))
		if err != nil {
			return nil, fmt.Errorf("failed to open CA cert: %w", err)
		}
		defer file.Close()

		caCert, err := io.ReadAll(file)
		if err != nil {
			return nil, fmt.Errorf("failed to read CA cert: %w", err)
		}

		pool := x509.NewCertPool()
		if !pool.AppendCertsFromPEM(caCert) {
			return nil, fmt.Errorf("failed to parse CA cert")
		}
		config.RootCAs = pool
	}

	return config, nil
}
