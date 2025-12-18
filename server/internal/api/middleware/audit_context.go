package middleware

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type AuditEnvelope struct {
	ResourceType string
	ResourceID   *domain.ID

	OldJSON []byte
	NewJSON []byte
}

type auditKey int

const auditEnvelopeKey auditKey = 1

func WithAuditEnvelope(ctx context.Context, env *AuditEnvelope) context.Context {
	return context.WithValue(ctx, auditEnvelopeKey, env)
}

func AuditFromContext(ctx context.Context) *AuditEnvelope {
	v := ctx.Value(auditEnvelopeKey)
	if v == nil {
		return nil
	}
	env, _ := v.(*AuditEnvelope)
	return env
}