package services

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"strings"
	"time"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

var (
	ErrEmptyAPIKey   = errors.New("empty api key")
	ErrInvalidAPIKey = errors.New("invalid api key")
	ErrExpiredAPIKey = errors.New("api key expired")
)

type APIKeyService struct {
	repo   repositories.APIKeyRepository
	pepper []byte
}

func NewAPIKeyService(repo repositories.APIKeyRepository, pepper string) *APIKeyService {
	return &APIKeyService{
		repo:   repo,
		pepper: []byte(pepper),
	}
}

func (s *APIKeyService) Create(ctx context.Context, clientID domain.ID, req domain.APIKeyCreateRequest) (*domain.APIKeyCreateResponse, error) {
	if len(s.pepper) == 0 {
		return nil, errors.New("API_KEY_PEPPER is empty")
	}

	token, prefix, err := generateToken()
	if err != nil {
		return nil, err
	}

	rec := repositories.APIKeyCreateRecord{
		ClientID:  clientID,
		KeyPrefix: prefix,
		KeyHash:   s.hashToken(token),

		Name:        req.Name,
		Description: req.Description,

		Permissions: req.Permissions,

		IsActive:  true,
		ExpiresAt: nil,
	}

	id, err := s.repo.Create(ctx, rec)
	if err != nil {
		return nil, err
	}

	out := domain.APIKey{
		ID:       id,
		ClientID: clientID,

		KeyPrefix:   prefix,
		Name:        req.Name,
		Description: req.Description,

		Permissions: req.Permissions,

		IsActive:  true,
		CreatedAt: time.Now().UTC(),
	}

	return &domain.APIKeyCreateResponse{
		APIKey: out,
		Token:  token, // показываем один раз
	}, nil
}

func (s *APIKeyService) List(ctx context.Context, clientID domain.ID) ([]domain.APIKey, error) {
	recs, err := s.repo.ListByClient(ctx, clientID)
	if err != nil {
		return nil, err
	}

	out := make([]domain.APIKey, 0, len(recs))
	for _, r := range recs {
		out = append(out, domain.APIKey{
			ID:       r.ID,
			ClientID: r.ClientID,

			KeyPrefix:   r.KeyPrefix,
			Name:        r.Name,
			Description: r.Description,

			Permissions: r.Permissions,

			IsActive:   r.IsActive,
			LastUsedAt: r.LastUsedAt,
			ExpiresAt:  r.ExpiresAt,
			CreatedAt:  r.CreatedAt,
		})
	}
	return out, nil
}

func (s *APIKeyService) Delete(ctx context.Context, clientID domain.ID, apiKeyID domain.ID) error {
	return s.repo.Deactivate(ctx, clientID, apiKeyID)
}

type APIKeyAuthResult struct {
	ClientID domain.ID
	APIKeyID domain.ID

	RateLimitPerMinute int
	RateLimitPerDay    int

	Permissions []string
}

func (s *APIKeyService) Authenticate(ctx context.Context, token string) (*APIKeyAuthResult, error) {
	token = strings.TrimSpace(token)
	if token == "" {
		return nil, ErrEmptyAPIKey
	}

	prefix, ok := tokenPrefix(token)
	if !ok {
		return nil, ErrInvalidAPIKey
	}

	rec, err := s.repo.GetForAuthByPrefix(ctx, prefix)
	if err != nil {
		return nil, err
	}
	if rec == nil || !rec.IsActive {
		return nil, ErrInvalidAPIKey
	}
	if rec.ExpiresAt != nil && time.Now().After(*rec.ExpiresAt) {
		return nil, ErrExpiredAPIKey
	}

	expect := s.hashToken(token)
	if !hmac.Equal(expect, rec.KeyHash) {
		return nil, ErrInvalidAPIKey
	}

	_ = s.repo.TouchLastUsed(ctx, rec.APIKeyID, time.Now().UTC())

	return &APIKeyAuthResult{
		ClientID: rec.ClientID,
		APIKeyID: rec.APIKeyID,

		RateLimitPerMinute: rec.RateLimitPerMinute,
		RateLimitPerDay:    rec.RateLimitPerDay,

		Permissions: rec.Permissions,
	}, nil
}

func (s *APIKeyService) hashToken(token string) []byte {
	m := hmac.New(sha256.New, s.pepper)
	m.Write([]byte(token))
	return m.Sum(nil) // []byte -> BYTEA
}

// token = "<prefix>.<secret>"
func generateToken() (token string, prefix string, err error) {
	pb := make([]byte, 6)  // prefix bytes
	sb := make([]byte, 32) // secret bytes

	if _, err := rand.Read(pb); err != nil {
		return "", "", err
	}
	if _, err := rand.Read(sb); err != nil {
		return "", "", err
	}

	prefix = base64.RawURLEncoding.EncodeToString(pb)  // ~8 chars
	secret := base64.RawURLEncoding.EncodeToString(sb) // ~43 chars

	token = prefix + "." + secret
	return token, prefix, nil
}

func tokenPrefix(token string) (string, bool) {
	prefix, _, ok := strings.Cut(token, ".")
	if !ok || prefix == "" {
		return "", false
	}
	return prefix, true
}
