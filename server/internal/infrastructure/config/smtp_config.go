package config

import (
	"fmt"
	"os"
	"strconv"
)

// SMTPConfig holds the SMTP configuration
type SMTPConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	From     string
	TLS      bool
	Debug    bool
}

// LoadSMTPConfig loads SMTP configuration from environment variables
func LoadSMTPConfig() *SMTPConfig {
	return &SMTPConfig{
		Host:     getEnv("SMTP_HOST", ""),
		Port:     getEnvAsInt("SMTP_PORT", 587),
		User:     getEnv("SMTP_USER", ""),
		Password: getEnv("SMTP_PASSWORD", ""),
		From:     getEnv("FROM_EMAIL", ""),
		TLS:      getEnvAsBool("SMTP_TLS", true),
		Debug:    getEnvAsBool("SMTP_DEBUG", false),
	}
}

// Validate validates the SMTP configuration
func (c *SMTPConfig) Validate() error {
	requiredFields := []struct {
		name  string
		value string
	}{
		{"SMTP_HOST", c.Host},
		{"SMTP_USER", c.User},
		{"SMTP_PASSWORD", c.Password},
		{"FROM_EMAIL", c.From},
	}

	for _, field := range requiredFields {
		if field.value == "" {
			return fmt.Errorf("%s is required but not set", field.name)
		}
	}

	return nil
}

// getEnvAsBool reads an environment variable as a boolean or returns a default value
func getEnvAsBool(key string, defaultValue bool) bool {
	if value, exists := os.LookupEnv(key); exists {
		if boolValue, err := strconv.ParseBool(value); err == nil {
			return boolValue
		}
	}
	return defaultValue
}