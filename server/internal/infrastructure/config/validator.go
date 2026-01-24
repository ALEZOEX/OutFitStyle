package config

import (
	"errors"
	"fmt"
)

// Validate проверяет конфигурацию на корректность
func (cfg *AppConfig) Validate() error {
	if err := cfg.Database.validate(); err != nil {
		return fmt.Errorf("database config error: %w", err)
	}

	if err := cfg.Security.validate(); err != nil {
		return fmt.Errorf("security config error: %w", err)
	}

	if err := cfg.Email.validate(); err != nil {
		return fmt.Errorf("email config error: %w", err)
	}

	return nil
}

func (cfg *DatabaseConfig) validate() error {
	if cfg.Host == "" {
		return errors.New("database host is required")
	}
	if cfg.Port == "" {
		return errors.New("database port is required")
	}
	if cfg.User == "" {
		return errors.New("database user is required")
	}
	if cfg.Name == "" {
		return errors.New("database name is required")
	}
	return nil
}

func (cfg *SecurityConfig) validate() error {
	if cfg.JWTSecret == "" {
		return errors.New("JWT secret is required")
	}
	if cfg.TokenExpiryHours <= 0 {
		return errors.New("token expiry hours must be positive")
	}
	return nil
}

func (cfg *EmailConfig) validate() error {
	if cfg.SMTPHost == "" {
		return errors.New("SMTP host is required")
	}
	if cfg.SMTPPort <= 0 {
		return errors.New("SMTP port is required")
	}
	if cfg.SMTPUsername == "" {
		return errors.New("SMTP username is required")
	}
	if cfg.SMTPPassword == "" {
		return errors.New("SMTP password is required")
	}
	if cfg.FromEmail == "" {
		return errors.New("from email is required")
	}
	return nil
}
