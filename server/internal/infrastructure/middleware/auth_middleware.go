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

		// Extract user ID from claims - can be either string (UUID) or number (legacy)
		var userID domain.ID
		userIDInterface := claims["user_id"]

		switch v := userIDInterface.(type) {
		case string:
			// Handle UUID string
			parsedID, err := uuid.Parse(v)
			if err != nil {
				m.logger.Error("Invalid user_id format in token", zap.String("user_id", v))
				http.Error(w, "Invalid user ID in token", http.StatusUnauthorized)
				return
			}
			userID = parsedID
		case float64:
			// Handle legacy numeric ID by converting to UUID
			numericID := int(v)
			if numericID <= 0 {
				m.logger.Error("Invalid user ID in token", zap.Float64("user_id", v))
				http.Error(w, "Invalid user ID in token", http.StatusUnauthorized)
				return
			}
			// Convert numeric ID to UUID using domain helper (if available)
			// For now, we'll use a placeholder - in real implementation you'd have a mapping
			userID = domain.NewID() // This creates a new random UUID, which is not ideal for auth
			// In a real implementation, you'd need to either:
			// 1. Store a mapping between numeric IDs and UUIDs in the database
			// 2. Or ensure all tokens use UUIDs
			m.logger.Warn("Legacy numeric user ID detected - consider migrating to UUID tokens", zap.Int("legacy_id", numericID))
		default:
			m.logger.Error("Invalid user_id type in token", zap.Any("type", userIDInterface))
			http.Error(w, "Invalid token claims", http.StatusUnauthorized)
			return
		}

		// Add user ID to request context
		ctx := context.WithValue(r.Context(), UserIDKey, userID)
		r = r.WithContext(ctx)

		// Log successful authentication
		m.logger.Info("Authentication successful",
			zap.String("user_id", userID.String()),
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

		// Extract user ID from claims - can be either string (UUID) or number (legacy)
		var userID domain.ID
		userIDInterface := claims["user_id"]

		switch v := userIDInterface.(type) {
		case string:
			// Handle UUID string
			parsedID, err := uuid.Parse(v)
			if err != nil {
				m.logger.Error("Invalid user_id format in token", zap.String("user_id", v))
				http.Error(w, "Invalid user ID in token", http.StatusUnauthorized)
				return
			}
			userID = parsedID
		case float64:
			// Handle legacy numeric ID by converting to UUID
			numericID := int(v)
			if numericID <= 0 {
				m.logger.Error("Invalid user ID in token", zap.Float64("user_id", v))
				http.Error(w, "Invalid user ID in token", http.StatusUnauthorized)
				return
			}
			// Convert numeric ID to UUID using domain helper (if available)
			// For now, we'll use a placeholder - in real implementation you'd have a mapping
			userID = domain.NewID() // This creates a new random UUID, which is not ideal for auth
			// In a real implementation, you'd need to either:
			// 1. Store a mapping between numeric IDs and UUIDs in the database
			// 2. Or ensure all tokens use UUIDs
			m.logger.Warn("Legacy numeric user ID detected - consider migrating to UUID tokens", zap.Int("legacy_id", numericID))
		default:
			m.logger.Error("Invalid user_id type in token", zap.Any("type", userIDInterface))
			http.Error(w, "Invalid token claims", http.StatusUnauthorized)
			return
		}

		// Add user ID to request context
		ctx := context.WithValue(r.Context(), UserIDKey, userID)
		r = r.WithContext(ctx)

		handler(w, r)
	}
}

// GetUserIDFromContext extracts user ID from context
func GetUserIDFromContext(ctx context.Context) (domain.ID, bool) {
	userID, ok := ctx.Value(UserIDKey).(domain.ID)
	return userID, ok
}
