package services

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"go.uber.org/zap"
)

func TestDefaultSessionConfig(t *testing.T) {
	config := DefaultSessionConfig()

	assert.Equal(t, 30*time.Minute, config.IdleTimeout, "Default idle timeout should be 30 minutes")
	assert.Equal(t, 24*time.Hour, config.AbsoluteTimeout, "Default absolute timeout should be 24 hours")
	assert.Equal(t, 5, config.MaxConcurrentSessions, "Default max concurrent sessions should be 5")
}

func TestSessionConfig_Validation(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	service := &SessionService{
		config: DefaultSessionConfig(),
		logger: logger,
	}

	tests := []struct {
		name        string
		config      SessionConfig
		expectError bool
	}{
		{
			name: "valid config",
			config: SessionConfig{
				IdleTimeout:           30 * time.Minute,
				AbsoluteTimeout:       24 * time.Hour,
				MaxConcurrentSessions: 5,
			},
			expectError: false,
		},
		{
			name: "zero idle timeout",
			config: SessionConfig{
				IdleTimeout:           0,
				AbsoluteTimeout:       24 * time.Hour,
				MaxConcurrentSessions: 5,
			},
			expectError: true,
		},
		{
			name: "negative idle timeout",
			config: SessionConfig{
				IdleTimeout:           -1 * time.Minute,
				AbsoluteTimeout:       24 * time.Hour,
				MaxConcurrentSessions: 5,
			},
			expectError: true,
		},
		{
			name: "zero absolute timeout",
			config: SessionConfig{
				IdleTimeout:           30 * time.Minute,
				AbsoluteTimeout:       0,
				MaxConcurrentSessions: 5,
			},
			expectError: true,
		},
		{
			name: "zero max sessions",
			config: SessionConfig{
				IdleTimeout:           30 * time.Minute,
				AbsoluteTimeout:       24 * time.Hour,
				MaxConcurrentSessions: 0,
			},
			expectError: true,
		},
		{
			name: "negative max sessions",
			config: SessionConfig{
				IdleTimeout:           30 * time.Minute,
				AbsoluteTimeout:       24 * time.Hour,
				MaxConcurrentSessions: -1,
			},
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := service.UpdateSessionConfig(tt.config)
			if tt.expectError {
				assert.Error(t, err, "Expected error for invalid config")
			} else {
				assert.NoError(t, err, "Expected no error for valid config")
				assert.Equal(t, tt.config, service.config, "Config should be updated")
			}
		})
	}
}

func TestSessionService_GetSessionConfig(t *testing.T) {
	config := SessionConfig{
		IdleTimeout:           45 * time.Minute,
		AbsoluteTimeout:       48 * time.Hour,
		MaxConcurrentSessions: 10,
	}

	service := &SessionService{
		config: config,
	}

	result := service.GetSessionConfig()
	assert.Equal(t, config, result, "GetSessionConfig should return current config")
}
