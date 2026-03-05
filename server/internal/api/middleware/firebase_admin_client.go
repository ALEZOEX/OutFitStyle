package middleware

import (
	"context"

	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"
	firebase "firebase.google.com/go/v4"
)

// FirebaseAdminClient wrapper для Firebase Admin SDK
type FirebaseAdminClient struct {
	client *auth.Client
}

// NewFirebaseAdminClient создаёт новый Firebase Admin клиент
func NewFirebaseAdminClient(ctx context.Context) (*FirebaseAdminClient, error) {
	// Инициализируем Firebase Admin SDK
	// Firebase автоматически найдёт credentials из переменной окружения GOOGLE_APPLICATION_CREDENTIALS
	// или из Application Default Credentials
	app, err := firebase.NewApp(ctx, nil, option.WithCredentialsJSON([]byte("{}")))
	if err != nil {
		return nil, err
	}

	authClient, err := app.Auth(ctx)
	if err != nil {
		return nil, err
	}

	return &FirebaseAdminClient{
		client: authClient,
	}, nil
}

// VerifyIDToken проверяет Firebase ID Token
func (c *FirebaseAdminClient) VerifyIDToken(ctx context.Context, idToken string) (*Token, error) {
	token, err := c.client.VerifyIDToken(ctx, idToken)
	if err != nil {
		return nil, err
	}

	return &Token{
		UID: token.UID,
	}, nil
}
