package config

import (
	"context"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
	"github.com/pkg/errors"
	"outfitstyle/server/internal/secrets"
)

type ServerConfig struct {
	Host            string
	Port            string
	Environment     string
	ReadTimeout     time.Duration
	WriteTimeout    time.Duration
	ShutdownTimeout time.Duration
}

type DatabaseConfig struct {
	URL                string
	MaxConnections     int
	MaxIdleConnections int
}

type RedisConfig struct {
	URL      string
	Password string
}

type SecurityConfig struct {
	JWTSecret          string
	JWTPrivateKeyPath  string
	JWTPublicKeyPath   string
	UseRS256           bool
	AccessTokenTTL     time.Duration
	RefreshTokenTTL    time.Duration
	CORSAllowedOrigins []string
	RateLimitPerMinute int
	GoogleClientID     string
	CookieSecure       bool // Secure flag для refresh token cookie
}

type MLServiceConfig struct {
	BaseURL string
	Timeout time.Duration
}

type MLFallbackConfig struct {
	Enabled            bool          `json:"enabled"`              // Включить fallback механизм
	CacheTTL           time.Duration `json:"cache_ttl"`            // TTL кэша рекомендаций
	HealthCheckTTL     time.Duration `json:"health_check_ttl"`     // TTL статуса health check
	RetryAttempts      int           `json:"retry_attempts"`       // Количество попыток retry
	RetryDelayMs       int           `json:"retry_delay_ms"`       // Задержка между retry в мс
	RequestTimeout     time.Duration `json:"request_timeout"`      // Таймаут запроса к ML
	UseCache           bool          `json:"use_cache"`            // Использовать кэширование
	InvalidateOnUpdate bool          `json:"invalidate_on_update"` // Инвалидировать кэш при обновлении гардероба
}

type OpenWeatherConfig struct {
	APIKey   string
	CacheTTL time.Duration
	BaseURL  string
}

type WeatherProviderConfig struct {
	Provider         string // openweather|openmeteo
	OpenMeteoBaseURL string
}

type EmailConfig struct {
	SMTPHost     string
	SMTPPort     int
	SMTPUser     string
	SMTPPassword string
	From         string
}

type SentryConfig struct {
	DSN string
}

type StorageConfig struct {
	S3Endpoint  string
	S3Bucket    string
	S3AccessKey string
	S3SecretKey string
	S3Region    string

	PublicBaseURL string        // например https://cdn.outfitstyle.app
	PresignTTL    time.Duration // например 1h
}

type PaymentsConfig struct {
	YooKassaShopID    string
	YooKassaSecretKey string

	StripeSecretKey     string
	StripeWebhookSecret string
}

type PushConfig struct {
	FCMCredentialsFile string

	APNSKeyFile  string
	APNSKeyID    string
	APNSTeamID   string
	APNSBundleID string

	APNSEnvironment string // "production"|"development"
}

type QueueConfig struct {
	RedisURL string
}

type FeaturesConfig struct {
	ABTesting      bool
	PartnerCatalog bool
	Achievements   bool
}

type APIKeysConfig struct {
	Pepper string // для хеширования ключей (server-side secret)
}

type EventingConfig struct {
	KafkaBrokers              []string
	KafkaTopic                string
	KafkaTopicRecommendations string
	KafkaTopicEvents          string
	Enabled                   bool
}

type AdminConfig struct {
	APIKey string
}

type AppConfig struct {
	Server          ServerConfig
	Database        DatabaseConfig
	Redis           RedisConfig
	Security        SecurityConfig
	MLService       MLServiceConfig
	MLFallback      MLFallbackConfig
	OpenWeather     OpenWeatherConfig
	WeatherProvider WeatherProviderConfig
	Email           EmailConfig
	Sentry          SentryConfig
	Storage         StorageConfig
	Payments        PaymentsConfig
	Admin           AdminConfig
	Push            PushConfig
	Queue           QueueConfig
	Features        FeaturesConfig
	APIKeys         APIKeysConfig
	Eventing        EventingConfig

	// Secret manager for secure secret storage
	secretManager secrets.Manager
}

// SecretManagerConfig holds configuration for the secret manager
type SecretManagerConfig struct {
	Provider     string
	AWSRegion    string
	AWSSecretARN string
	GCPProjectID string
	VaultAddress string
	VaultToken   string
	VaultPath    string
	CacheTTL     time.Duration
}

func Load() (*AppConfig, error) {
	// Проверяем системное время на аномалии
	currentTime := time.Now()
	if currentTime.Year() > 2025 {
		log.Printf("Warning: System date is set to a future date (%s), this may cause issues with SSL certificates, JWT tokens, and caching", currentTime.Format("2006-01-02"))
	} else if currentTime.Year() < 2020 {
		log.Printf("Warning: System date is set to a past date (%s), this may cause issues with SSL certificates, JWT tokens, and caching", currentTime.Format("2006-01-02"))
	}

	// .env грузим только локально
	if os.Getenv("RUN_IN_DOCKER") == "" {
		if err := godotenv.Load(); err != nil {
			log.Printf("Warning: .env file not found or invalid: %v", err)
		}
	}

	// Initialize secret manager
	secretMgr, err := initSecretManager()
	if err != nil {
		return nil, fmt.Errorf("failed to initialize secret manager: %w", err)
	}

	// Load secrets from secret manager
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	secretKeys := []string{
		"JWT_SECRET",
		"ADMIN_API_KEY",
		"API_KEY_PEPPER",
		"OPENWEATHER_API_KEY",
		"REDIS_PASSWORD",
		"SMTP_PASSWORD",
		"S3_SECRET_KEY",
		"YOOKASSA_SECRET_KEY",
		"STRIPE_SECRET_KEY",
		"STRIPE_WEBHOOK_SECRET",
	}

	loadedSecrets, err := secretMgr.GetSecrets(ctx, secretKeys)
	if err != nil {
		log.Printf("Warning: failed to load secrets from secret manager: %v. Falling back to environment variables.", err)
		loadedSecrets = make(map[string]string)
	}

	// Helper function to get value from secrets or environment
	getSecretOrEnv := func(keys []string, def string) string {
		// First try to get from loaded secrets
		for _, k := range keys {
			if v, ok := loadedSecrets[k]; ok && v != "" {
				return v
			}
		}
		// Fallback to environment variables
		return getEnvFirst(keys, def)
	}

	cfg := &AppConfig{
		Server: ServerConfig{
			Host:            getEnvFirst([]string{"SERVER_HOST", "HOST"}, "0.0.0.0"),
			Port:            getEnvFirst([]string{"SERVER_PORT", "PORT"}, "8080"),
			Environment:     getEnvFirst([]string{"ENVIRONMENT"}, "development"),
			ReadTimeout:     getEnvDurationFirst([]string{"SERVER_READ_TIMEOUT", "READ_TIMEOUT"}, 15*time.Second),
			WriteTimeout:    getEnvDurationFirst([]string{"SERVER_WRITE_TIMEOUT", "WRITE_TIMEOUT"}, 30*time.Second),
			ShutdownTimeout: getEnvDurationFirst([]string{"SERVER_SHUTDOWN_TIMEOUT", "SHUTDOWN_TIMEOUT"}, 30*time.Second),
		},
		Database: DatabaseConfig{
			URL:                getEnvFirst([]string{"DATABASE_URL"}, ""),
			MaxConnections:     getEnvInt("DATABASE_MAX_CONNECTIONS", 100, 1, 1000),
			MaxIdleConnections: getEnvInt("DATABASE_MAX_IDLE_CONNECTIONS", 10, 1, 500),
		},
		Redis: RedisConfig{
			URL:      getEnvFirst([]string{"REDIS_URL"}, ""),
			Password: getSecretOrEnv([]string{"REDIS_PASSWORD"}, ""),
		},
		Security: SecurityConfig{
			JWTSecret:          getSecretOrEnv([]string{"JWT_SECRET"}, ""),
			JWTPrivateKeyPath:  getEnvFirst([]string{"JWT_PRIVATE_KEY_PATH"}, "config/jwt/private.pem"),
			JWTPublicKeyPath:   getEnvFirst([]string{"JWT_PUBLIC_KEY_PATH"}, "config/jwt/public.pem"),
			UseRS256:           getEnvBool("JWT_USE_RS256", false),
			AccessTokenTTL:     getEnvDurationFirst([]string{"JWT_ACCESS_TOKEN_TTL"}, 15*time.Minute), // Security: короткий TTL для access токена
			RefreshTokenTTL:    getEnvDurationFirst([]string{"JWT_REFRESH_TOKEN_TTL"}, 720*time.Hour), // 30 дней
			CORSAllowedOrigins: splitCSV(getEnvFirst([]string{"CORS_ALLOWED_ORIGINS", "CORS_ALLOWED_ORIGIN"}, "")),
			RateLimitPerMinute: getEnvInt("RATE_LIMIT_PER_MINUTE", getEnvInt("RATE_LIMIT", 100, 1, 100000), 1, 100000),
			GoogleClientID:     getEnvFirst([]string{"GOOGLE_CLIENT_ID"}, ""),
			CookieSecure:       getEnvBool("COOKIE_SECURE", true), // Secure cookie по умолчанию для production
		},
		MLService: MLServiceConfig{
			BaseURL: getEnvFirst([]string{"ML_SERVICE_URL"}, "http://ml-service:8000"),
			Timeout: getEnvDurationFirst([]string{"ML_SERVICE_TIMEOUT"}, 30*time.Second),
		},
		MLFallback: MLFallbackConfig{
			Enabled:            getEnvBool("ML_FALLBACK_ENABLED", true),
			CacheTTL:           getEnvDurationFirst([]string{"ML_CACHE_TTL"}, 10*time.Minute),
			HealthCheckTTL:     getEnvDurationFirst([]string{"ML_HEALTH_CHECK_TTL"}, 30*time.Second),
			RetryAttempts:      getEnvInt("ML_RETRY_ATTEMPTS", 2, 0, 5),
			RetryDelayMs:       getEnvInt("ML_RETRY_DELAY_MS", 500, 100, 2000),
			RequestTimeout:     getEnvDurationFirst([]string{"ML_REQUEST_TIMEOUT"}, 5*time.Second),
			UseCache:           getEnvBool("ML_USE_CACHE", true),
			InvalidateOnUpdate: getEnvBool("ML_INVALIDATE_ON_UPDATE", true),
		},
		OpenWeather: OpenWeatherConfig{
			APIKey:   getSecretOrEnv([]string{"OPENWEATHER_API_KEY", "WEATHER_API_KEY"}, ""),
			CacheTTL: getEnvDurationFirst([]string{"OPENWEATHER_CACHE_TTL"}, 10*time.Minute),
			BaseURL:  getEnvFirst([]string{"OPENWEATHER_BASE_URL"}, "https://api.openweathermap.org/data/2.5"),
		},
		WeatherProvider: WeatherProviderConfig{
			Provider:         getEnvFirst([]string{"WEATHER_PROVIDER"}, "openweather"),
			OpenMeteoBaseURL: getEnvFirst([]string{"OPENMETEO_BASE_URL"}, "https://api.open-meteo.com"),
		},
		Email: EmailConfig{
			SMTPHost:     getEnvFirst([]string{"SMTP_HOST"}, ""),
			SMTPPort:     getEnvInt("SMTP_PORT", 587, 1, 65535),
			SMTPUser:     getEnvFirst([]string{"SMTP_USER", "SMTP_USERNAME"}, ""),
			SMTPPassword: getSecretOrEnv([]string{"SMTP_PASSWORD"}, ""),
			From:         getEnvFirst([]string{"EMAIL_FROM", "SMTP_FROM_EMAIL", "FROM_EMAIL"}, "noreply@outfitstyle.app"),
		},
		Sentry: SentryConfig{
			DSN: getEnvFirst([]string{"SENTRY_DSN"}, ""),
		},
		Storage: StorageConfig{
			S3Endpoint:  getEnvFirst([]string{"S3_ENDPOINT"}, ""),
			S3Bucket:    getEnvFirst([]string{"S3_BUCKET"}, ""),
			S3AccessKey: getEnvFirst([]string{"S3_ACCESS_KEY"}, ""),
			S3SecretKey: getSecretOrEnv([]string{"S3_SECRET_KEY"}, ""),
			S3Region:    getEnvFirst([]string{"S3_REGION"}, ""),

			PublicBaseURL: getEnvFirst([]string{"S3_PUBLIC_BASE_URL"}, ""),
			PresignTTL:    getEnvDurationFirst([]string{"S3_PRESIGN_TTL"}, 1*time.Hour),
		},
		Payments: PaymentsConfig{
			YooKassaShopID:    getEnvFirst([]string{"YOOKASSA_SHOP_ID"}, ""),
			YooKassaSecretKey: getSecretOrEnv([]string{"YOOKASSA_SECRET_KEY"}, ""),

			StripeSecretKey:     getSecretOrEnv([]string{"STRIPE_SECRET_KEY"}, ""),
			StripeWebhookSecret: getSecretOrEnv([]string{"STRIPE_WEBHOOK_SECRET"}, ""),
		},
		Admin: AdminConfig{
			APIKey: getSecretOrEnv([]string{"ADMIN_API_KEY"}, ""),
		},
		Push: PushConfig{
			FCMCredentialsFile: getEnvFirst([]string{"FCM_CREDENTIALS_FILE"}, ""),

			APNSKeyFile:  getEnvFirst([]string{"APNS_KEY_FILE"}, ""),
			APNSKeyID:    getEnvFirst([]string{"APNS_KEY_ID"}, ""),
			APNSTeamID:   getEnvFirst([]string{"APNS_TEAM_ID"}, ""),
			APNSBundleID: getEnvFirst([]string{"APNS_BUNDLE_ID"}, ""),

			APNSEnvironment: getEnvFirst([]string{"APNS_ENVIRONMENT"}, "development"),
		},
		Queue: QueueConfig{
			RedisURL: getEnvFirst([]string{"QUEUE_REDIS_URL", "REDIS_URL"}, ""),
		},
		Features: FeaturesConfig{
			PartnerCatalog: getEnvBool("FEATURE_PARTNER_CATALOG", true),
			ABTesting:      getEnvBool("FEATURE_AB_TESTING", true),
			Achievements:   getEnvBool("FEATURE_ACHIEVEMENTS", true),
		},
		APIKeys: APIKeysConfig{
			Pepper: getSecretOrEnv([]string{"API_KEY_PEPPER"}, getSecretOrEnv([]string{"JWT_SECRET"}, "")),
		},
		Eventing: EventingConfig{
			KafkaBrokers:              splitCSV(getEnvFirst([]string{"KAFKA_BROKERS"}, "")),
			KafkaTopic:                getEnvFirst([]string{"KAFKA_TOPIC"}, "outfitstyle-events"),
			KafkaTopicRecommendations: getEnvFirst([]string{"KAFKA_TOPIC_RECOMMENDATIONS"}, "recommendations"),
			KafkaTopicEvents:          getEnvFirst([]string{"KAFKA_TOPIC_EVENTS"}, "user_events"),
			Enabled:                   getEnvBool("EVENTING_ENABLED", true),
		},
		secretManager: secretMgr,
	}

	if err := cfg.Validate(); err != nil {
		return nil, err
	}
	return cfg, nil
}

// initSecretManager initializes the secret manager based on environment configuration
func initSecretManager() (secrets.Manager, error) {
	provider := getEnvFirst([]string{"SECRET_MANAGER_PROVIDER"}, "env")

	cfg := secrets.Config{
		Provider:     provider,
		AWSRegion:    getEnvFirst([]string{"AWS_REGION", "AWS_DEFAULT_REGION"}, "us-east-1"),
		AWSSecretARN: getEnvFirst([]string{"AWS_SECRET_ARN"}, ""),
		GCPProjectID: getEnvFirst([]string{"GCP_PROJECT_ID"}, ""),
		VaultAddress: getEnvFirst([]string{"VAULT_ADDR"}, ""),
		VaultToken:   getEnvFirst([]string{"VAULT_TOKEN"}, ""),
		VaultPath:    getEnvFirst([]string{"VAULT_SECRET_PATH"}, "secret/data/outfitstyle"),
		CacheTTL:     getEnvDurationFirst([]string{"SECRET_CACHE_TTL"}, 5*time.Minute),
		Timeout:      getEnvDurationFirst([]string{"SECRET_MANAGER_TIMEOUT"}, 10*time.Second),
	}

	return secrets.NewManager(cfg)
}

func (c *AppConfig) Validate() error {
	if c.Database.URL == "" {
		// оставляем понятную ошибку именно по ТЗ
		return errors.New("DATABASE_URL is required")
	}
	if c.OpenWeather.APIKey == "" {
		return errors.New("OPENWEATHER_API_KEY is required")
	}

	if c.Server.Environment == "production" {
		if len(c.Security.JWTSecret) < 32 {
			return errors.New("JWT_SECRET must be at least 32 chars in production")
		}
	}
	return nil
}

func (c *DatabaseConfig) DatabaseURL() string { return c.URL }

func splitCSV(v string) []string {
	v = strings.TrimSpace(v)
	if v == "" {
		// Security: не используем wildcard по умолчанию для CORS
		// Требуем явного указания allowed origins
		return []string{}
	}
	if v == "*" {
		return []string{"*"}
	}
	parts := strings.Split(v, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			out = append(out, p)
		}
	}
	return out
}

func getEnvFirst(keys []string, def string) string {
	for _, k := range keys {
		if v := os.Getenv(k); v != "" {
			return v
		}
	}
	return def
}

func getEnvInt(key string, def, min, max int) int {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	i, err := strconv.Atoi(v)
	if err != nil {
		return def
	}
	if i < min {
		return min
	}
	if i > max {
		return max
	}
	return i
}

func getEnvDurationFirst(keys []string, def time.Duration) time.Duration {
	for _, k := range keys {
		if v := os.Getenv(k); v != "" {
			d, err := time.ParseDuration(v)
			if err == nil {
				return d
			}
		}
	}
	return def
}

func getEnvBool(key string, def bool) bool {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	// поддерживаем разные форматы
	v = strings.ToLower(strings.TrimSpace(v))
	switch v {
	case "1", "true", "yes", "on":
		return true
	case "0", "false", "no", "off":
		return false
	default:
		return def
	}
}

func (c *AppConfig) Addr() string {
	return fmt.Sprintf("%s:%s", c.Server.Host, c.Server.Port)
}

// Close cleans up resources, including the secret manager
func (c *AppConfig) Close() error {
	if c.secretManager != nil {
		return c.secretManager.Close()
	}
	return nil
}
