package middleware

import (
	"context"
	"os"
	"path/filepath"

	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"
	firebase "firebase.google.com/go/v4"
	"go.uber.org/zap"
)

// FirebaseAdminClient wrapper для Firebase Admin SDK
type FirebaseAdminClient struct {
	client *auth.Client
}

// NewFirebaseAdminClient создаёт новый Firebase Admin клиент
// Читает credentials из переменной окружения FIREBASE_CREDENTIALS_PATH или FIREBASE_CREDENTIALS_JSON
// Если credentials не указаны — логирует warning и возвращает nil (Firebase auth будет отключен)
func NewFirebaseAdminClient(ctx context.Context, logger *zap.Logger) (*FirebaseAdminClient, error) {
	credentialsPath := os.Getenv("FIREBASE_CREDENTIALS_PATH")
	credentialsJSON := os.Getenv("FIREBASE_CREDENTIALS_JSON")

	var app *firebase.App
	var err error

	if credentialsPath != "" {
		// Читаем credentials из файла
		absPath, err := filepath.Abs(credentialsPath)
		if err != nil {
			logger.Error("firebase: failed to resolve credentials path",
				zap.String("path", credentialsPath),
				zap.Error(err))
			return nil, err
		}

		credentialsBytes, err := os.ReadFile(absPath)
		if err != nil {
			logger.Error("firebase: failed to read credentials file",
				zap.String("path", absPath),
				zap.Error(err))
			return nil, err
		}

		app, err = firebase.NewApp(ctx, nil, option.WithCredentialsJSON(credentialsBytes))
		if err != nil {
			logger.Error("firebase: failed to initialize with credentials file",
				zap.String("path", absPath),
				zap.Error(err))
			return nil, err
		}

		logger.Info("firebase: initialized with credentials file",
			zap.String("path", absPath))

	} else if credentialsJSON != "" {
		// Используем credentials из JSON строки
		app, err = firebase.NewApp(ctx, nil, option.WithCredentialsJSON([]byte(credentialsJSON)))
		if err != nil {
			logger.Error("firebase: failed to initialize with credentials JSON",
				zap.Error(err))
			return nil, err
		}

		logger.Info("firebase: initialized with credentials JSON")

	} else {
		// Credentials не указаны — логируем warning и возвращаем nil
		logger.Warn("firebase: credentials not configured, Firebase auth will be disabled",
			zap.String("hint", "set FIREBASE_CREDENTIALS_PATH or FIREBASE_CREDENTIALS_JSON environment variable"))
		return nil, nil
	}

	authClient, err := app.Auth(ctx)
	if err != nil {
		logger.Error("firebase: failed to get auth client",
			zap.Error(err))
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
