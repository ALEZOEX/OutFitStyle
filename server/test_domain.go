package main

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

func main() {
	id := domain.NewID()
	ctx := context.Background()
	ctx = context.WithValue(ctx, "test", id)
	println(ctx.Value("test").(domain.ID).String())
}