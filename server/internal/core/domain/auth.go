package domain

import "time"

// TokenPair структура для хранения пары токенов (access и refresh)
type TokenPair struct {
	AccessToken  string    `json:"access_token"`  // Токен доступа для аутентификации запросов
	RefreshToken string    `json:"refresh_token"` // Токен обновления для получения новых access токенов
	ExpiresAt    time.Time `json:"expires_at"`    // Время истечения срока действия access токена
}
