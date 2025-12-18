package services

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"strings"
	"time"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type APIKeyService struct {
	repo   repositories.APIKeyRepository
	pepper string
}

func NewAPIKeyService(repo repositories.APIKeyRepository, pepper string) *APIKeyService {
	return &APIKeyService{repo: repo, pepper: pepper}
}

func (s *APIKeyService) Create(ctx context.Context, userID domain.ID, req domain.APIKeyCreateRequest) (*domain.APIKeyCreateResponse, error) {
	token, err := generateToken()
	if err != nil {
		return nil, err
	}
	prefix := token
	if len(prefix) > 8 {
		prefix = prefix[:8]
	}

	rec := repositories.APIKeyRecord{
		UserID: userID,
		KeyPrefix: prefix,
		KeyHash: s.hash(token),

		Name: req.Name,
		Description: req.Description,
		Permissions: req.Permissions,
		AllowedOrigins: req.AllowedOrigins,
		RateLimitPerMinute: coalesceInt(req.RateLimitPerMinute, 60),
		RateLimitPerDay: coalesceInt(req.RateLimitPerDay, 10000),
		IsActive: true,
		ExpiresAt: nil,
	}
	id, err := s.repo.Create(ctx, rec)
	if err != nil {
		return nil, err
	}

	out := domain.APIKey{
		ID: id,
		KeyPrefix: prefix,
		Name: req.Name,
		Description: req.Description,
		Permissions: req.Permissions,
		AllowedOrigins: req.AllowedOrigins,
		RateLimitPerMinute: rec.RateLimitPerMinute,
		RateLimitPerDay: rec.RateLimitPerDay,
		IsActive: true,
		CreatedAt: time.Now(),
	}

	return &domain.APIKeyCreateResponse{APIKey: out, Token: token}, nil
}

func (s *APIKeyService) List(ctx context.Context, userID domain.ID) ([]domain.APIKey, error) {
	recs, err := s.repo.ListByUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	out := make([]domain.APIKey, 0, len(recs))
	for _, r := range recs {
		out = append(out, domain.APIKey{
			ID: r.ID,
			KeyPrefix: r.KeyPrefix,
			Name: r.Name,
			Description: r.Description,
			Permissions: r.Permissions,
			AllowedOrigins: r.AllowedOrigins,
			RateLimitPerMinute: r.RateLimitPerMinute,
			RateLimitPerDay: r.RateLimitPerDay,
			IsActive: r.IsActive,
			LastUsedAt: r.LastUsedAt,
			ExpiresAt: r.ExpiresAt,
			CreatedAt: r.CreatedAt,
		})
	}
	return out, nil
}

func (s *APIKeyService) Delete(ctx context.Context, userID domain.ID, apiKeyID domain.ID) error {
	return s.repo.Deactivate(ctx, userID, apiKeyID)
}

type APIKeyAuthResult struct {
	UserID  domain.ID
	APIKeyID domain.ID

	RateLimitPerMinute int
	RateLimitPerDay    int

	Permissions     []string
	AllowedOrigins  []string
}

func (s *APIKeyService) Authenticate(ctx context.Context, token string) (*APIKeyAuthResult, error) {
	token = strings.TrimSpace(token)
	if token == "" {
		return nil, errors.New("empty api key")
	}
	h := s.hash(token)
	rec, err := s.repo.FindByHash(ctx, h)
	if err != nil {
		return nil, err
	}
	if rec == nil || !rec.IsActive {
		return nil, errors.New("invalid api key")
	}
	if rec.ExpiresAt != nil && time.Now().After(*rec.ExpiresAt) {
		return nil, errors.New("api key expired")
	}

	_ = s.repo.TouchLastUsed(ctx, rec.ID)

	return &APIKeyAuthResult{
		UserID:  rec.UserID,
		APIKeyID: rec.ID,

		RateLimitPerMinute: rec.RateLimitPerMinute,
		RateLimitPerDay:    rec.RateLimitPerDay,

		Permissions:    rec.Permissions,
		AllowedOrigins: rec.AllowedOrigins,
	}, nil
}

func (s *APIKeyService) hash(token string) string {
	sum := sha256.Sum256([]byte(s.pepper + ":" + token))
	return hex.EncodeToString(sum[:])
}

func generateToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	// префиксируем, чтобы легче отличать
	return "os_" + base64.RawURLEncoding.EncodeToString(b), nil
}

func coalesceInt(v *int, def int) int {
	if v == nil {
		return def
	}
	return *v
}