// internal/infrastructure/config/config.go
package config

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
	"github.com/pkg/errors"
)

type AppConfig struct {
	Server     ServerConfig
	Database   DatabaseConfig
	WeatherAPI WeatherAPIConfig
	MLService  MLServiceConfig
	Email      EmailConfig
	Security   SecurityConfig
	Logging    LoggingConfig
	Cache      CacheConfig
}

type ServerConfig struct {
	Port            string        `env:"PORT" default:"8080"`
	Host            string        `env:"HOST" default:"0.0.0.0"`
	Environment     string        `env:"ENVIRONMENT" default:"development"`
	Debug           bool          `env:"DEBUG" default:"false"`
	ReadTimeout     time.Duration `env:"READ_TIMEOUT" default:"15s"`
	WriteTimeout    time.Duration `env:"WRITE_TIMEOUT" default:"30s"`
	ShutdownTimeout time.Duration `env:"SHUTDOWN_TIMEOUT" default:"30s"`
	EnablePprof     bool          `env:"ENABLE_PPROF" default:"false"`
}

type DatabaseConfig struct {
	Host     string `env:"DB_HOST" default:"localhost"`
	Port     string `env:"DB_PORT" default:"5432"`
	User     string `env:"DB_USER" default:"outfitstyle"`
	Password string `env:"DB_PASSWORD"`
	Name     string `env:"DB_NAME" default:"outfitstyle"`
	SSLMode  string `env:"DB_SSL_MODE" default:"require"`
}

type WeatherAPIConfig struct {
	Key     string `env:"WEATHER_API_KEY"`
	BaseURL string `env:"WEATHER_API_URL" default:"https://api.openweathermap.org/data/2.5"`
	Timeout int    `env:"WEATHER_API_TIMEOUT" default:"10"` // seconds
}

type MLServiceConfig struct {
	BaseURL string `env:"ML_SERVICE_URL" default:"http://localhost:5000"`
	Timeout int    `env:"ML_SERVICE_TIMEOUT" default:"30"` // seconds
}

type EmailConfig struct {
	SMTPHost     string `env:"SMTP_HOST"`
	SMTPPort     int    `env:"SMTP_PORT" default:"587"`
	SMTPUsername string `env:"SMTP_USERNAME"`
	SMTPPassword string `env:"SMTP_PASSWORD"`
	FromEmail    string `env:"SMTP_FROM_EMAIL"`
}

type SecurityConfig struct {
	JWTSecret              string `env:"JWT_SECRET"`
	TokenExpiryHours       int    `env:"TOKEN_EXPIRY_HOURS" default:"24"`
	RefreshTokenExpiryDays int    `env:"REFRESH_TOKEN_EXPIRY_DAYS" default:"7"`
	VerificationCodeExpiry int    `env:"VERIFICATION_CODE_EXPIRY" default:"10"` // minutes
	MaxLoginAttempts       int    `env:"MAX_LOGIN_ATTEMPTS" default:"5"`
	BlockDuration          int    `env:"BLOCK_DURATION" default:"30"` // minutes
	CORSAllowedOrigins     string `env:"CORS_ALLOWED_ORIGINS" default:"*"`
}

type LoggingConfig struct {
	Level  string `env:"LOG_LEVEL" default:"info"`
	Format string `env:"LOG_FORMAT" default:"json"`
}

type CacheConfig struct {
	Enabled    bool   `env:"CACHE_ENABLED" default:"true"`
	RedisURL   string `env:"REDIS_URL" default:"redis://localhost:6379"`
	Expiration int    `env:"CACHE_EXPIRATION" default:"300"` // seconds
}

func Load() (*AppConfig, error) {
	// Load .env file in development environment only
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: .env file not found or invalid: %v", err)
	}

	cfg := &AppConfig{
		Server:     loadServerConfig(),
		Database:   loadDatabaseConfig(),
		WeatherAPI: loadWeatherAPIConfig(),
		MLService:  loadMLServiceConfig(),
		Email:      loadEmailConfig(),
		Security:   loadSecurityConfig(),
		Logging:    loadLoggingConfig(),
		Cache:      loadCacheConfig(),
	}

	if err := validateConfig(cfg); err != nil {
		return nil, errors.Wrap(err, "config validation failed")
	}

	return cfg, nil
}

func (c *AppConfig) Validate() error {
	return validateConfig(c)
}

func validateConfig(cfg *AppConfig) error {
	if cfg.WeatherAPI.Key == "" {
		return errors.New("WEATHER_API_KEY is required")
	}

	if cfg.Server.Environment != "development" {
		if cfg.Database.Password == "" {
			return errors.New("DB_PASSWORD is required in production")
		}
		if cfg.Security.JWTSecret == "" {
			return errors.New("JWT_SECRET is required in production")
		}
	}

	// Validate SSL mode
	validSSLmodes := []string{"disable", "require", "verify-ca", "verify-full"}
	if !contains(validSSLmodes, cfg.Database.SSLMode) {
		return fmt.Errorf("invalid DB_SSL_MODE: %s (must be one of: %s)",
			cfg.Database.SSLMode, strings.Join(validSSLmodes, ", "))
	}

	// Validate connection limits
	if cfg.Database.MaxOpenConns < cfg.Database.MaxIdleConns {
		return errors.New("DB_MAX_OPEN_CONNS cannot be less than DB_MAX_IDLE_CONNS")
	}

	return nil
}

// DatabaseURL returns properly formatted database connection string
func (c *DatabaseConfig) DatabaseURL() string {
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.User, c.Password, c.Name, c.SSLMode)
}

// GetAllowedOrigins returns list of allowed CORS origins
func (c *SecurityConfig) GetAllowedOrigins() []string {
	if c.CORSAllowedOrigins == "*" {
		return []string{"*"}
	}
	return strings.Split(c.CORSAllowedOrigins, ",")
}

// Helper functions for environment variables
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvBool(key string, defaultValue bool) bool {
	if value := os.Getenv(key); value != "" {
		if b, err := strconv.ParseBool(value); err == nil {
			return b
		}
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue, min, max int) int {
	if value := os.Getenv(key); value != "" {
		if i, err := strconv.Atoi(value); err == nil {
			if i < min {
				log.Printf("Warning: %s value %d below minimum %d, using %d", key, i, min, min)
				return min
			}
			if i > max {
				log.Printf("Warning: %s value %d above maximum %d, using %d", key, i, max, max)
				return max
			}
			return i
		}
	}
	return defaultValue
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

// Load configuration functions
func loadServerConfig() ServerConfig {
	return ServerConfig{
		Port:            getEnv("PORT", "8080"),
		Host:            getEnv("HOST", "0.0.0.0"),
		Environment:     getEnv("ENVIRONMENT", "development"),
		Debug:           getEnvBool("DEBUG", false),
		ReadTimeout:     getEnvDuration("READ_TIMEOUT", 15*time.Second),
		WriteTimeout:    getEnvDuration("WRITE_TIMEOUT", 30*time.Second),
		ShutdownTimeout: getEnvDuration("SHUTDOWN_TIMEOUT", 30*time.Second),
		EnablePprof:     getEnvBool("ENABLE_PPROF", false),
	}
}

// Implement similar load functions for other config types...

func getEnvDuration(key string, defaultValue time.Duration) time.Duration {
	if value := os.Getenv(key); value != "" {
		if d, err := time.ParseDuration(value); err == nil {
			return d
		}
	}
	return defaultValue
}
