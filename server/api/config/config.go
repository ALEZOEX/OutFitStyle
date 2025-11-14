package config

import (
	"os"
	"strconv"
)

type Config struct {
	Port              string
	Debug             bool
	LogLevel          string
	DBHost            string
	DBPort            string
	DBUser            string
	DBPassword        string
	DBName            string
	WeatherAPIKey     string
	WeatherAPIURL     string
	WeatherAPITimeout int
	MLServiceURL      string
}

func Load() *Config {
	return &Config{
		Port:              getEnv("PORT", "8080"),
		Debug:             getEnv("DEBUG", "true") == "true",
		LogLevel:          getEnv("LOG_LEVEL", "info"),
		DBHost:            getEnv("DB_HOST", "localhost"),
		DBPort:            getEnv("DB_PORT", "5432"),
		DBUser:            getEnv("DB_USER", "Admin"),
		DBPassword:        getEnv("DB_PASSWORD", "password"),
		DBName:            getEnv("DB_NAME", "outfitstyle"),
		WeatherAPIKey:     getEnv("WEATHER_API_KEY", ""),
		WeatherAPIURL:     getEnv("WEATHER_API_URL", "https://api.openweathermap.org/data/2.5/weather"),
		WeatherAPITimeout: getEnvAsInt("WEATHER_API_TIMEOUT", 10),
		MLServiceURL:      getEnv("ML_SERVICE_URL", "http://localhost:5000"),
	}
}

func (c *Config) DatabaseURL() string {
	return "host=" + c.DBHost + " port=" + c.DBPort +
		" user=" + c.DBUser + " password=" + c.DBPassword +
		" dbname=" + c.DBName + " sslmode=disable"
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}