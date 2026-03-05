package middleware

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

// Token представляет Firebase ID Token
type Token struct {
	UID string
}

// FirebaseAuthClient интерфейс для Firebase Auth клиента
type FirebaseAuthClient interface {
	VerifyIDToken(ctx context.Context, idToken string) (*Token, error)
}

// AuthMiddlewareWithFirebase проверяет JWT и Firebase ID Token
type AuthMiddlewareWithFirebase struct {
	jwtSecret    string
	firebaseAuth FirebaseAuthClient
	logger       *zap.Logger
}

// NewAuthMiddlewareWithFirebase создаёт middleware с поддержкой Firebase
func NewAuthMiddlewareWithFirebase(jwtSecret string, firebaseAuth FirebaseAuthClient, logger *zap.Logger) *AuthMiddlewareWithFirebase {
	return &AuthMiddlewareWithFirebase{
		jwtSecret:    jwtSecret,
		firebaseAuth: firebaseAuth,
		logger:       logger,
	}
}

// Handler проверяет токен и добавляет user_id в контекст
func (m *AuthMiddlewareWithFirebase) Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			m.logger.Debug("No authorization header")
			next.ServeHTTP(w, r)
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			m.logger.Debug("Invalid authorization header format")
			next.ServeHTTP(w, r)
			return
		}

		// Пытаемся проверить как Firebase ID Token
		if m.firebaseAuth != nil {
			token, err := m.firebaseAuth.VerifyIDToken(r.Context(), tokenString)
			if err == nil {
				userID, err := uuid.Parse(token.UID)
				if err != nil {
					m.logger.Error("Invalid Firebase UID format", zap.String("uid", token.UID))
					next.ServeHTTP(w, r)
					return
				}
				ctx := context.WithValue(r.Context(), ctxUserID, userID)
				m.logger.Info("Firebase ID Token authenticated",
					zap.String("user_id", userID.String()),
					zap.String("path", r.URL.Path),
					zap.String("method", r.Method))
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}
			m.logger.Debug("Firebase ID Token validation failed, trying JWT", zap.Error(err))
		}

		// Пытаемся проверить как JWT
		claims, err := m.validateToken(tokenString)
		if err != nil {
			m.logger.Debug("JWT validation failed", zap.Error(err))
			next.ServeHTTP(w, r)
			return
		}

		var userID domain.ID
		userIDInterface := claims["user_id"]

		switch v := userIDInterface.(type) {
		case string:
			parsedID, err := uuid.Parse(v)
			if err != nil {
				m.logger.Error("Invalid user_id format in token", zap.String("user_id", v))
				next.ServeHTTP(w, r)
				return
			}
			userID = parsedID
		case float64:
			numericID := int(v)
			if numericID <= 0 {
				m.logger.Error("Invalid user ID in token", zap.Float64("user_id", v))
				next.ServeHTTP(w, r)
				return
			}
			userID = domain.NewID()
			m.logger.Warn("Legacy numeric user ID detected", zap.Int("legacy_id", numericID))
		default:
			m.logger.Error("Invalid user_id type in token", zap.Any("type", userIDInterface))
			next.ServeHTTP(w, r)
			return
		}

		ctx := context.WithValue(r.Context(), ctxUserID, userID)
		m.logger.Info("JWT authenticated",
			zap.String("user_id", userID.String()),
			zap.String("path", r.URL.Path),
			zap.String("method", r.Method))
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// validateToken проверяет JWT
func (m *AuthMiddlewareWithFirebase) validateToken(tokenString string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(m.jwtSecret), nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, fmt.Errorf("invalid token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, fmt.Errorf("invalid token claims")
	}

	if exp, ok := claims["exp"].(float64); ok {
		if time.Now().Unix() >= int64(exp) {
			return nil, fmt.Errorf("token expired")
		}
	}

	return claims, nil
}
