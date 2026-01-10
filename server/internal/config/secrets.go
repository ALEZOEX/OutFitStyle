package config

import (
	"os"
)

type SecretManager struct{}

func NewSecretManager() *SecretManager {
	return &SecretManager{}
}

func (sm *SecretManager) GetDatabaseURL() string {
	url := os.Getenv("DATABASE_URL")
	if url == "" {
		panic("DATABASE_URL is required")
	}
	return url
}

func (sm *SecretManager) GetJWTSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		panic("JWT_SECRET is required")
	}
	return []byte(secret)
}

func (sm *SecretManager) GetOpenWeatherAPIKey() string {
	key := os.Getenv("OPENWEATHER_API_KEY")
	if key == "" {
		panic("OPENWEATHER_API_KEY is required")
	}
	return key
}

func (sm *SecretManager) GetGoogleClientID() string {
	id := os.Getenv("GOOGLE_CLIENT_ID")
	if id == "" {
		panic("GOOGLE_CLIENT_ID is required")
	}
	return id
}

func (sm *SecretManager) GetGoogleClientSecret() string {
	secret := os.Getenv("GOOGLE_CLIENT_SECRET")
	if secret == "" {
		panic("GOOGLE_CLIENT_SECRET is required")
	}
	return secret
}

func (sm *SecretManager) GetMLServiceAPIKey() string {
	key := os.Getenv("ML_SERVICE_API_KEY")
	if key == "" {
		panic("ML_SERVICE_API_KEY is required")
	}
	return key
}