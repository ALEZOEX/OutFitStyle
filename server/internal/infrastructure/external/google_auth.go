package external

import (
	"context"
	"fmt"

	"google.golang.org/api/idtoken"
)

type GoogleUser struct {
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

func (c *GoogleAuthClient) Verify(ctx context.Context, tokenString string) (*GoogleUser, error) {
	payload, err := idtoken.Validate(ctx, tokenString, c.clientID)
	if err != nil {
		return nil, fmt.Errorf("google token invalid: %w", err)
	}

	email, _ := payload.Claims["email"].(string)
	verified, _ := payload.Claims["email_verified"].(bool)
	givenName, _ := payload.Claims["given_name"].(string)
	familyName, _ := payload.Claims["family_name"].(string)
	picture, _ := payload.Claims["picture"].(string)

	return &GoogleUser{
		Email:         email,
		EmailVerified: verified,
		FirstName:     givenName,
		LastName:      familyName,
		Picture:       picture,
	}, nil
}