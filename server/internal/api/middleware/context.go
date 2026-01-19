package middleware

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type ctxKey int

const (
	ctxUserID ctxKey = iota
	ctxSessionID
	ctxAPIKeyID
	ctxAPIKeyMeta
	ctxClientID = iota + 1000 // Явно задаем уникальное значение
)

// ---------- User (JWT) ----------

func WithUserID(ctx context.Context, id domain.ID) context.Context {
	return context.WithValue(ctx, ctxUserID, id)
}

func GetUserIDFromContext(ctx context.Context) (domain.ID, bool) {
	v := ctx.Value(ctxUserID)
	id, ok := v.(domain.ID)
	return id, ok
}

func WithSessionID(ctx context.Context, id domain.ID) context.Context {
	return context.WithValue(ctx, ctxSessionID, id)
}

func GetSessionIDFromContext(ctx context.Context) (domain.ID, bool) {
	v := ctx.Value(ctxSessionID)
	id, ok := v.(domain.ID)
	return id, ok
}

// ---------- Partner (API Key) ----------

func WithClientID(ctx context.Context, id domain.ID) context.Context {
	return context.WithValue(ctx, ctxClientID, id)
}

func GetClientIDFromContext(ctx context.Context) (domain.ID, bool) {
	v := ctx.Value(ctxClientID)
	id, ok := v.(domain.ID)
	return id, ok
}

func WithAPIKeyID(ctx context.Context, id domain.ID) context.Context {
	return context.WithValue(ctx, ctxAPIKeyID, id)
}

func GetAPIKeyIDFromContext(ctx context.Context) (domain.ID, bool) {
	v := ctx.Value(ctxAPIKeyID)
	id, ok := v.(domain.ID)
	return id, ok
}

type APIKeyMeta struct {
	APIKeyID domain.ID `json:"api_key_id"`

	RateLimitPerMinute int `json:"rate_limit_per_minute"`
	RateLimitPerDay    int `json:"rate_limit_per_day"`

	Permissions []string `json:"permissions,omitempty"`
}

func WithAPIKeyMeta(ctx context.Context, meta APIKeyMeta) context.Context {
	return context.WithValue(ctx, ctxAPIKeyMeta, meta)
}

func GetAPIKeyMetaFromContext(ctx context.Context) (APIKeyMeta, bool) {
	v := ctx.Value(ctxAPIKeyMeta)
	m, ok := v.(APIKeyMeta)
	return m, ok
}
