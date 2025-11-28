package external

import (
	"context"
	"fmt"

	"google.golang.org/api/idtoken"
)

type GoogleAuthService struct {
	verifier *idtoken.Validator
}

func NewGoogleAuthService() (*GoogleAuthService, error) {
	verifier, err := idtoken.NewValidator(context.Background())
	if err != nil {
		return nil, fmt.Errorf("failed to create token validator: %w", err)
	}
	return &GoogleAuthService{verifier: verifier}, nil
}

// VerifyIDToken проверяет ID-токен и возвращает email
func (g *GoogleAuthService) VerifyIDToken(ctx context.Context, idToken string) (string, error) {
	payload, err := g.verifier.Validate(ctx, idToken, "")
	if err != nil {
		return "", fmt.Errorf("invalid Google ID token: %w", err)
	}

	email, ok := payload.Claims["email"].(string)
	if !ok || email == "" {
		return "", fmt.Errorf("email not found in token")
	}

	// Опционально: проверить verified_email
	verified, _ := payload.Claims["email_verified"].(bool)
	if !verified {
		return "", fmt.Errorf("email not verified")
	}

	return email, nil
}
