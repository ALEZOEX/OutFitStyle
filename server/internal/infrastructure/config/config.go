package config

import (
	"fmt"
	"time"
)

type AppConfig struct {
	Server     ServerConfig
	Database   DatabaseConfig
	WeatherAPI WeatherAPIConfig
	MLService  MLServiceConfig
	Logging    LoggingConfig
	Security   SecurityConfig
	Email      EmailConfig
	Cache      CacheConfig
}

type ServerConfig struct {
	Port            string        `env:"PORT" default:"8080"`
	Environment     string        `env:"ENVIRONMENT" default:"development"`
	Debug           bool          `env:"DEBUG" default:"false"`
	ReadTimeout     time.Duration `env:"READ_TIMEOUT" default:"15s"`
	WriteTimeout    time.Duration `env:"WRITE_TIMEOUT" default:"30s"`
	ShutdownTimeout time.Duration `env:"SHUTDOWN_TIMEOUT" default:"30s"`
	EnablePprof     bool          `env:"ENABLE_PPROF" default:"false"`
	Host            string        `env:"HOST" default:"localhost"`
}

type DatabaseConfig struct {
	Host            string `env:"DB_HOST" default:"localhost"`
	Port            string `env:"DB_PORT" default:"5432"`
	User            string `env:"DB_USER" default:"outfitstyle"`
	Password        string `env:"DB_PASSWORD"`
	Name            string `env:"DB_NAME" default:"outfitstyle"`
	SSLMode         string `env:"DB_SSL_MODE" default:"require"`
	MaxOpenConns    int    `env:"DB_MAX_OPEN_CONNS" default:"25"`
	MaxIdleConns    int    `env:"DB_MAX_IDLE_CONNS" default:"5"`
	ConnMaxLifetime int    `env:"DB_CONN_MAX_LIFETIME" default:"30"` // minutes
}

// DatabaseURL generates the PostgreSQL connection string
func (d *DatabaseConfig) DatabaseURL() string {
	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s",
		d.User, d.Password, d.Host, d.Port, d.Name, d.SSLMode)
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

type LoggingConfig struct {
	Level  string `env:"LOG_LEVEL" default:"info"`
	Format string `env:"LOG_FORMAT" default:"json"`
}

type SecurityConfig struct {
	JWTSecret              string `env:"JWT_SECRET"`
	TokenExpiryHours       int    `env:"TOKEN_EXPIRY_HOURS" default:"24"`
	RefreshTokenExpiryDays int    `env:"REFRESH_TOKEN_EXPIRY_DAYS" default:"7"`
	VerificationCodeExpiry int    `env:"VERIFICATION_CODE_EXPIRY" default:"10"` // minutes
	MaxLoginAttempts       int    `env:"MAX_LOGIN_ATTEMPTS" default:"5"`
	BlockDuration          int    `env:"BLOCK_DURATION" default:"30"` // minutes
	CORSAllowedOrigins     string `env:"CORS_ALLOWED_ORIGINS" default:"*"`
	RateLimit              int    `env:"RATE_LIMIT" default:"100"` // requests per minute
}

type EmailConfig struct {
	SMTPHost     string `env:"SMTP_HOST"`
	SMTPPort     int    `env:"SMTP_PORT" default:"587"`
	SMTPUsername string `env:"SMTP_USERNAME"`
	SMTPPassword string `env:"SMTP_PASSWORD"`
	FromEmail    string `env:"FROM_EMAIL"`
}

type CacheConfig struct {
	Enabled    bool   `env:"CACHE_ENABLED" default:"true"`
	RedisURL   string `env:"REDIS_URL" default:"redis://localhost:6379"`
	Expiration int    `env:"CACHE_EXPIRATION" default:"300"` // seconds
}
