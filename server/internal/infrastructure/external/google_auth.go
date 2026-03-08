package external

import (
	"context"
	"fmt"
	"strings"

	"google.golang.org/api/idtoken"
)

type GoogleUser struct {
	ID            string // Google sub - уникальный идентификатор пользователя
	Email         string
	EmailVerified bool
	FirstName     string
	LastName      string
	Picture       string
}

type GoogleAuthClient struct {
	clientID        string
	firebaseProject string
}

func NewGoogleAuthClient(clientID string) *GoogleAuthClient {
	// Firebase project ID для валидации Firebase ID токенов
	// Firebase токены имеют aud = project ID, а не client ID
	firebaseProject := "outfitstyle-ce15f"
	return &GoogleAuthClient{
		clientID:        clientID,
		firebaseProject: firebaseProject,
	}
}

// ClientID возвращает client ID для отладки
func (c *GoogleAuthClient) ClientID() string {
	return c.clientID
}

func (c *GoogleAuthClient) Verify(ctx context.Context, tokenString string) (*GoogleUser, error) {
	// Используем Firebase project ID для валидации Firebase ID токенов
	// Firebase Auth генерирует токены с aud = project ID

	// Debug: логируем первые 50 символов токена для отладки
	tokenPreview := tokenString
	if len(tokenPreview) > 50 {
		tokenPreview = tokenPreview[:50] + "..."
	}

	// Пробуем валидировать токен
	payload, err := idtoken.Validate(ctx, tokenString, c.firebaseProject)
	if err != nil {
		// Если ошибка связана с cert keyId, пробуем альтернативный подход
		if strings.Contains(err.Error(), "could not find matching cert keyId") {
			// Пробуем валидировать с Google OAuth client ID вместо Firebase project ID
			payload, err2 := idtoken.Validate(ctx, tokenString, c.clientID)
			if err2 != nil {
				// Обе попытки провалились - возвращаем оригинальную ошибку
				return nil, fmt.Errorf("google token invalid (firebase project ID): %w, also tried client ID: %v", err, err2)
			}
			// Успешно валидировали с client ID
			payload = payload
			err = nil
		} else {
			return nil, fmt.Errorf("google token invalid: %w", err)
		}
	}

	var email, givenName, familyName, picture, sub string
	var verified bool

	if v, ok := payload.Claims["email"].(string); ok {
		email = v
	}
	if v, ok := payload.Claims["email_verified"].(bool); ok {
		verified = v
	}
	if v, ok := payload.Claims["given_name"].(string); ok {
		givenName = v
	}
	if v, ok := payload.Claims["family_name"].(string); ok {
		familyName = v
	}
	if v, ok := payload.Claims["picture"].(string); ok {
		picture = v
	}
	if v, ok := payload.Claims["sub"].(string); ok {
		sub = v
	}

	if sub == "" {
		return nil, fmt.Errorf("google token missing sub claim")
	}

	return &GoogleUser{
		ID:            sub,
		Email:         email,
		EmailVerified: verified,
		FirstName:     givenName,
		LastName:      familyName,
		Picture:       picture,
	}, nil
}
