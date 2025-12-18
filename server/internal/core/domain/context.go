package domain

import "context"

// Context key constants to avoid import cycles
type ctxKey int

const (
	userIDKey ctxKey = iota
	sessionIDKey
	apiKeyIDKey
	abVariantKey
	auditEnvelopeKey
)

// Context utilities for user ID
func WithUserID(ctx context.Context, userID ID) context.Context {
	return context.WithValue(ctx, userIDKey, userID)
}

func GetUserIDFromContext(ctx context.Context) (ID, bool) {
	v := ctx.Value(userIDKey)
	if v == nil {
		return ID{}, false
	}
	id, ok := v.(ID)
	return id, ok
}

// Context utilities for session ID 
func WithSessionID(ctx context.Context, sessionID ID) context.Context {
	return context.WithValue(ctx, sessionIDKey, sessionID)
}

func GetSessionIDFromContext(ctx context.Context) (ID, bool) {
	v := ctx.Value(sessionIDKey)
	if v == nil {
		return ID{}, false
	}
	id, ok := v.(ID)
	return id, ok
}

// Context utilities for API key ID
func WithAPIKeyID(ctx context.Context, apiKeyID ID) context.Context {
	return context.WithValue(ctx, apiKeyIDKey, apiKeyID)
}

func GetAPIKeyIDFromContext(ctx context.Context) (ID, bool) {
	v := ctx.Value(apiKeyIDKey)
	if v == nil {
		return ID{}, false
	}
	id, ok := v.(ID)
	return id, ok
}

// Context utilities for A/B testing variant
func WithABVariant(ctx context.Context, variant string) context.Context {
	return context.WithValue(ctx, abVariantKey, variant)
}

func GetABVariantFromContext(ctx context.Context) (string, bool) {
	v := ctx.Value(abVariantKey)
	if v == nil {
		return "", false
	}
	s, ok := v.(string)
	return s, ok
}

// Audit envelope for tracking changes
type AuditEnvelope struct {
	ResourceType string
	ResourceID   *ID
	OldJSON      []byte
	NewJSON      []byte
}

// Context utilities for audit envelope
func WithAuditEnvelope(ctx context.Context, envelope *AuditEnvelope) context.Context {
	return context.WithValue(ctx, auditEnvelopeKey, envelope)
}

func AuditFromContext(ctx context.Context) (*AuditEnvelope, bool) {
	v := ctx.Value(auditEnvelopeKey)
	if v == nil {
		return nil, false
	}
	env, ok := v.(*AuditEnvelope)
	return env, ok
}