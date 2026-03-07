package config

import (
	"log"
	"os"
)

type SecretManager struct{}

func NewSecretManager() *SecretManager {
	return &SecretManager{}
}

func (sm *SecretManager) GetDatabaseURL() string {
	url := os.Getenv("DATABASE_URL")
	if url == "" {
		log.Fatal("DATABASE_URL is required")
	}
	return url
}

func (sm *SecretManager) GetJWTSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET is required")
	}
	return []byte(secret)
}

func (sm *SecretManager) GetOpenWeatherAPIKey() string {
	key := os.Getenv("OPENWEATHER_API_KEY")
	if key == "" {
		log.Printf("WARNING: OPENWEATHER_API_KEY is not set, weather features will be disabled")
		return ""
	}
	return key
}

func (sm *SecretManager) GetGoogleClientID() string {
	id := os.Getenv("GOOGLE_CLIENT_ID")
	if id == "" {
		log.Printf("WARNING: GOOGLE_CLIENT_ID is not set, Google auth will be disabled")
		return ""
	}
	return id
}

func (sm *SecretManager) GetGoogleClientSecret() string {
	secret := os.Getenv("GOOGLE_CLIENT_SECRET")
	if secret == "" {
		log.Printf("WARNING: GOOGLE_CLIENT_SECRET is not set, Google auth will be disabled")
		return ""
	}
	return secret
}

func (sm *SecretManager) GetMLServiceAPIKey() string {
	key := os.Getenv("ML_SERVICE_API_KEY")
	if key == "" {
		log.Printf("WARNING: ML_SERVICE_API_KEY is not set, ML features will be disabled")
		return ""
	}
	return key
}
