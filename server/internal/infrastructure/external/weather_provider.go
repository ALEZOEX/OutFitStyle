package external

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type WeatherProvider interface {
	Current(ctx context.Context, lat, lon float64) (domain.WeatherSnapshot, error)
	Forecast(ctx context.Context, lat, lon float64, days int) (location string, daily []any, hourly []any, err error)
}
