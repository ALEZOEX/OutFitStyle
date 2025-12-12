package middleware

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"go.uber.org/zap"
)

// ContextKey is a custom type for context keys
type ContextKey string

const (
	// UserIDKey is the context key for user ID
	UserIDKey ContextKey = "user_id"
)

// AuthMiddleware validates JWT tokens and adds user info to context
type AuthMiddleware struct {
	jwtSecret string
	logger    *zap.Logger
}

// NewAuthMiddleware creates a new authentication middleware
func NewAuthMiddleware(jwtSecret string, logger *zap.Logger) *AuthMiddleware {
	return &AuthMiddleware{
		jwtSecret: jwtSecret,
		logger:    logger,
	}
}

// AuthMiddleware is the actual middleware function
func (m *AuthMiddleware) Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			m.logger.Error("No authorization header")
			http.Error(w, "Authorization header required", http.StatusUnauthorized)
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			// If no "Bearer " prefix, try "Token " prefix
			tokenString = strings.TrimPrefix(authHeader, "Token ")
			if tokenString == authHeader {
				// Neither prefix found
				m.logger.Error("Invalid authorization header format")
				http.Error(w, "Invalid authorization header format", http.StatusUnauthorized)
				return
			}
		}

		claims, err := m.validateToken(tokenString)
		if err != nil {
			m.logger.Error("Invalid token", zap.Error(err))
			http.Error(w, "Invalid token", http.StatusUnauthorized)
			return
		}

		// Extract user ID from claims
		userIDFloat, ok := claims["user_id"].(float64) // JWT numbers are parsed as float64
		if !ok {
			m.logger.Error("Invalid user_id in token")
			http.Error(w, "Invalid token claims", http.StatusUnauthorized)
			return
		}

		userID := int(userIDFloat)
		if userID <= 0 {
			m.logger.Error("Invalid user ID in token", zap.Float64("user_id", userIDFloat))
			http.Error(w, "Invalid user ID in token", http.StatusUnauthorized)
			return
		}

		// Add user ID to request context
		ctx := context.WithValue(r.Context(), UserIDKey, userID)
		r = r.WithContext(ctx)

		// Log successful authentication
		m.logger.Info("Authentication successful",
			zap.Int("user_id", userID),
			zap.String("path", r.URL.Path),
			zap.String("method", r.Method))

		next.ServeHTTP(w, r)
	})
}

// validateToken validates the JWT token
func (m *AuthMiddleware) validateToken(tokenString string) (jwt.MapClaims, error) {
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

	// Check if token is expired
	if exp, ok := claims["exp"].(float64); ok {
		if time.Now().Unix() >= int64(exp) {
			return nil, fmt.Errorf("token expired")
		}
	}

	return claims, nil
}

// GetUserIDFromContext extracts user ID from context
func GetUserIDFromContext(ctx context.Context) (int, bool) {
	userID, ok := ctx.Value(UserIDKey).(int)
	return userID, ok
}

// RequireAuth wraps a handler to require authentication
func (m *AuthMiddleware) RequireAuth(handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			m.logger.Error("No authorization header")
			http.Error(w, "Authorization header required", http.StatusUnauthorized)
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			// If no "Bearer " prefix, try "Token " prefix
			tokenString = strings.TrimPrefix(authHeader, "Token ")
			if tokenString == authHeader {
				// Neither prefix found
				m.logger.Error("Invalid authorization header format")
				http.Error(w, "Invalid authorization header format", http.StatusUnauthorized)
				return
			}
		}

		claims, err := m.validateToken(tokenString)
		if err != nil {
			m.logger.Error("Invalid token", zap.Error(err))
			http.Error(w, "Invalid token", http.StatusUnauthorized)
			return
		}

		// Extract user ID from claims
		userIDFloat, ok := claims["user_id"].(float64) // JWT numbers are parsed as float64
		if !ok {
			m.logger.Error("Invalid user_id in token")
			http.Error(w, "Invalid token claims", http.StatusUnauthorized)
			return
		}

		userID := int(userIDFloat)
		if userID <= 0 {
			m.logger.Error("Invalid user ID in token", zap.Float64("user_id", userIDFloat))
			http.Error(w, "Invalid user ID in token", http.StatusUnauthorized)
			return
		}

		// Add user ID to request context
		ctx := context.WithValue(r.Context(), UserIDKey, userID)
		r = r.WithContext(ctx)

		handler(w, r)
	}
}

// GetUserIDFromContext extracts user ID from context
func GetUserIDFromContext(ctx context.Context) (int, bool) {
	userID, ok := ctx.Value(UserIDKey).(int)
	return userID, ok
}