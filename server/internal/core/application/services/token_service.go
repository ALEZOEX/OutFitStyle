package services

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"outfitstyle/server/internal/core/domain"
)

type TokenService struct {
	secret          []byte
	accessTTL       time.Duration
	refreshTTL      time.Duration
}

type AccessClaims struct {
	jwt.RegisteredClaims
	SessionID string `json:"sid"`
}

func NewTokenService(jwtSecret string, accessTTL, refreshTTL time.Duration) *TokenService {
	return &TokenService{
		secret:     []byte(jwtSecret),
		accessTTL:  accessTTL,
		refreshTTL: refreshTTL,
	}
}

func (s *TokenService) AccessTTL() time.Duration  { return s.accessTTL }
func (s *TokenService) RefreshTTL() time.Duration { return s.refreshTTL }

func (s *TokenService) GenerateAccessToken(userID, sessionID domain.ID) (token string, expiresAt time.Time, err error) {
	now := time.Now()
	expiresAt = now.Add(s.accessTTL)

	claims := AccessClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID.String(),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
		},
		SessionID: sessionID.String(),
	}

	t := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	token, err = t.SignedString(s.secret)
	return token, expiresAt, err
}

func (s *TokenService) ValidateAccessToken(tokenString string) (userID domain.ID, sessionID domain.ID, err error) {
	parser := jwt.NewParser(jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Name}))
	var claims AccessClaims

	_, err = parser.ParseWithClaims(tokenString, &claims, func(token *jwt.Token) (any, error) {
		return s.secret, nil
	})
	if err != nil {
		return domain.ID{}, domain.ID{}, err
	}

	if claims.Subject == "" || claims.SessionID == "" {
		return domain.ID{}, domain.ID{}, errors.New("missing claims")
	}

	userID, err = domain.ParseID(claims.Subject)
	if err != nil {
		return domain.ID{}, domain.ID{}, err
	}
	sessionID, err = domain.ParseID(claims.SessionID)
	if err != nil {
		return domain.ID{}, domain.ID{}, err
	}

	return userID, sessionID, nil
}

func (s *TokenService) GenerateRefreshToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

func (s *TokenService) HashRefreshToken(refreshToken string) string {
	sum := sha256.Sum256([]byte(refreshToken))
	return hex.EncodeToString(sum[:])
}
