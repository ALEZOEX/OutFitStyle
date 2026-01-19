package middleware

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

func TestFunction(ctx context.Context, id domain.ID) context.Context {
	return context.WithValue(ctx, "test", id)
}