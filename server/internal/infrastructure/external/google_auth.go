package external

import (
	"context"
	"fmt"

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
	clientID string
}

func NewGoogleAuthClient(clientID string) *GoogleAuthClient {
	return &GoogleAuthClient{clientID: clientID}
}

// ClientID возвращает client ID для отладки
func (c *GoogleAuthClient) ClientID() string {
	return c.clientID
}

func (c *GoogleAuthClient) Verify(ctx context.Context, tokenString string) (*GoogleUser, error) {
	payload, err := idtoken.Validate(ctx, tokenString, c.clientID)
	if err != nil {
		return nil, fmt.Errorf("google token invalid: %w", err)
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
