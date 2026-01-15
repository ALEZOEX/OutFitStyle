package postgres

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

func NewPGXPool(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
	return pgxpool.New(ctx, dsn)
}
