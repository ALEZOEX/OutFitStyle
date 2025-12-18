package middleware

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type APIKeyMeta struct {
	APIKeyID domain.ID

	RateLimitPerMinute int
	RateLimitPerDay    int

	Permissions    []string
	AllowedOrigins []string
}

type apiKeyMetaKeyType int

const apiKeyMetaKey apiKeyMetaKeyType = 1

func WithAPIKeyMeta(ctx context.Context, meta APIKeyMeta) context.Context {
	return context.WithValue(ctx, apiKeyMetaKey, meta)
}

func GetAPIKeyMetaFromContext(ctx context.Context) (APIKeyMeta, bool) {
	v := ctx.Value(apiKeyMetaKey)
	if v == nil {
		return APIKeyMeta{}, false
	}
	m, ok := v.(APIKeyMeta)
	return m, ok
}