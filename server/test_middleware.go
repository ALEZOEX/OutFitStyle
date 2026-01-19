package main

import (
	"context"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/api/middleware"
)

func main() {
	id := domain.NewID()
	ctx := context.Background()
	ctx = middleware.WithClientID(ctx, id)
	clientID, ok := middleware.GetClientIDFromContext(ctx)
	if ok {
		println(clientID.String())
	}
}